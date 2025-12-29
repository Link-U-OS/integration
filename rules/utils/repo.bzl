# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

_template_bzl = '''load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")
def {name}():
{content}'''

_template_git = '''
    git_repository(
        name = "{name}",
        remote = "{remote}",
        {version},
        patch_cmds = [
            {patch_cmds}
        ],
        shallow_since = "{shallow_since}",
    )
'''

_template_local = '''
    native.local_repository(
        name = "{name}",
        path = "{path}",
    )
'''

_template_http_archive = '''
    http_archive(
        name = "{name}",
        urls = [
            "{urls}"
        ],
        sha256 = "{sha256}",
    )
'''

_template_http_file = '''
    http_file(
        name = "{name}",
        url = "{url}",
        sha256 = "{sha256}",
        downloaded_file_path = "{downloaded_file_path}",
    )
'''

def _parse_git(name, data):
    if "remote" not in data:
        fail("Could not find a remote: %s", data)
    version = ""
    if "commit" in data:
        version = 'commit = "{}"'.format(data["commit"])
    elif "branch" in data:
        version = 'branch = "{}"'.format(data["branch"])
    elif "tag" in data:
        version = 'tag = "{}"'.format(data["tag"])
    else:
        fail("Could not find version: " + data)
    patch_cmds = []
    if "patch_cmds" in data:
        patch_cmds = data["patch_cmds"]
    shallow_since = ""
    if "shallow_since" in data:
        shallow_since = data["shallow_since"]
    return _template_git.format(
        name = name,
        remote = data["remote"],
        version = version,
        patch_cmds = ",\n{}".format(" " * 8).join(['"{}"'.format(x) for x in patch_cmds]),
        shallow_since = shallow_since,
    )

def _parse_local(name, data):
    if "path" not in data:
        fail("Could not find path: %s", data)
    return _template_local.format(
        name = name,
        path = data["path"],
    )

def _parse_http_archive(name, data):
    if "urls" not in data:
        fail("Could not find urls: %s", data)
    sha256 = ""
    if "sha256" in data:
        sha256 = data["sha256"]

    return _template_http_archive.format(
        name = name,
        urls = ",\n{}".format(" " * 8).join(data["urls"]),
        sha256 = sha256,
    )

def _parse_http_file(name, data):
    if "url" not in data:
        fail("Could not find url: %s", data)
    url = data["url"]
    sha256 = ""
    if "sha256" in data:
        sha256 = data["sha256"]
    
    downloaded_file_path = ""
    if "downloaded_file_path" in data:
        downloaded_file_path = data["downloaded_file_path"]
    
    # 如果 downloaded_file_path 为空，从 URL 中提取文件名
    if not downloaded_file_path:
        # 从 URL 中提取最后一个路径段作为文件名
        url_parts = url.rstrip("/").split("/")
        downloaded_file_path = url_parts[-1] if url_parts else "file"
        
        # 如果提取的文件名包含查询参数，去掉它们
        if "?" in downloaded_file_path:
            downloaded_file_path = downloaded_file_path.split("?")[0]

    return _template_http_file.format(
        name = name,
        url = url,
        sha256 = sha256,
        downloaded_file_path = downloaded_file_path,
    )

def parse_repository(name, data):
    if "git" in data:
        return _parse_git(name, data["git"])
    elif "local" in data:
        return _parse_local(name, data["local"])
    elif "http_archive" in data:
        return _parse_http_archive(name, data["http_archive"])
    elif "http_file" in data:
        return _parse_http_file(name, data["http_file"])
    else:
        fail("Type not supported: " + data)

def _parse_yaml(ctx, yaml_content):
    """Parse YAML content using an external Python command."""
    # 创建临时文件存储 YAML 内容
    yaml_file = ctx.path("temp_yaml_file.yaml")
    ctx.file("temp_yaml_file.yaml", content=yaml_content)
    
    # 创建临时文件存储输出的 JSON
    json_file = ctx.path("temp_json_file.json")
    
    # 执行 Python 脚本将 YAML 转换为 JSON
    result = ctx.execute(["python3", "-c", """
import yaml
import json
import sys

with open(sys.argv[1], 'r') as yaml_file:
    yaml_data = yaml.safe_load(yaml_file)

with open(sys.argv[2], 'w') as json_file:
    json.dump(yaml_data, json_file)
""", str(yaml_file), str(json_file)])
    
    if result.return_code != 0:
        fail("Failed to parse YAML: " + result.stderr)
    
    # 读取生成的 JSON 文件
    json_content = ctx.read(json_file)
    return json.decode(json_content)

def _impl(ctx):
    # Create a WORKSPACE to make it a proper external dependency.
    ctx.file("WORKSPACE")

    # We need to be able to export the .bzl file created.
    build_content = [
        'package(default_visibility = ["//visibility:public"])',
        'exports_files(["{name}.bzl","{name}.json"])'.format(name = ctx.name),
    ]
    ctx.file("BUILD", content = "\n".join(build_content))
    repos_json = {}
    
    if "AGIBOT_FROM_COMMIT" in ctx.os.environ:
        # Get default source
        for v in ctx.attr._default_srcs_path:
            if v.name == "source_commit.yaml":
                data = ctx.read(v)
                repos_json.update(_parse_yaml(ctx, data))
                break
    else:
        # Get default source
        for v in ctx.attr._default_srcs_path:
            if v.name == "source_branch.yaml":
                data = ctx.read(v)
                repos_json.update(_parse_yaml(ctx, data))
                break
    
    # Get default archives
    for v in ctx.attr._default_archives_path:
        if v.name == "archives.yaml":
            data = ctx.read(v)
            repos_json.update(_parse_yaml(ctx, data))
            break
    
    # Apply overrides
    data = ctx.read(ctx.attr._override)
    repos_json.update(json.decode(data))
    
    repos = {}
    for k, v in repos_json.items():
        repos[k] = parse_repository(k, v)

    # If this is empty, just add a pass statement.
    if not repos:
        repos["pass"] = "    pass"

    # Create the .bzl file which bazel will load.
    ctx.file(
        ctx.name + ".bzl",
        content = _template_bzl.format(
            name = ctx.name,
            # Sort the list of repositories to write.
            content = "".join([repos[x] for x in sorted(repos)]),
        ),
    )

    # Write out the json representation.
    ctx.file(
        ctx.name + ".json",
        content = json.encode_indent(repos_json),
    )

agibot_repo = repository_rule(
    implementation = _impl,
    attrs = {
        "_default_srcs_path": attr.label_list(
            default = [
                "@integration//projects/defs:source_branch.yaml",
                "@integration//projects/defs:source_commit.yaml",
            ],
        ),
        "_default_archives_path": attr.label_list(
            default = [
                "@integration//projects/defs:archives.yaml",
            ],
        ),
        "_override": attr.label(
            default = "@override//:override.json",
        ),
        "_projects_dir": attr.label(
            default = "@integration//:WORKSPACE",
        ),
    },
    environ = [
        "AGIBOT_FROM_COMMIT",
    ],
    local = True,
    doc = """
This rule is used to generate the repositories that a project depends on. It is
possible to choose between source or platform defined binary defaults as well as
being able to override any of these.""",
)

def _impl_json(ctx):
    # Create a WORKSPACE to make it a proper external dependency.
    ctx.file("WORKSPACE")

    # We need to be able to export the .json file created.
    build_content = [
        'package(default_visibility = ["//visibility:public"])',
        'exports_files(["{name}.json"])'.format(name = ctx.name),
    ]
    ctx.file("BUILD", content = "\n".join(build_content))
    ctx.file("{name}.json".format(name = ctx.name), content = "{}")

empty_json = repository_rule(
    implementation = _impl_json,
    attrs = {},
    local = True,
    doc = """
Creates an empty JSON file inside a repository. Useful for the override rule.
""",
)
