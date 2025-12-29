# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("@integration//rules/utils:log_utils.bzl", "agibot_fail")

BuildFileInfo = provider(
    fields = {
        "files": "depset of buildfiles",
        "deps": "dependencies",
    },
)

DataFileInfo = provider(
    fields = {
        "files": "depset of data files.",
    },
)

_gen_top_header_template = """
# Reference to generated top header
alias(
    name = "gen_top_header",
    actual = ":{name}.h",
)
"""

# All files will have this mtime.
_MTIME = "UTC 2000-01-01"

def _pkg_lib(ctx):
    files = []
    args = []
    output_tar = ctx.actions.declare_file("%s.tar" % ctx.attr.name)
    output = ctx.actions.declare_file("%s.tar.gz" % ctx.attr.name)

    args.append("--dereference")
    args.append("--hard-dereference")
    args.append("--sort=name")
    args.append("--mode=%s" % ctx.attr.mode)
    args.append("--mtime='%s' " % _MTIME)
    args.append("--owner=0")
    args.append("--group=0")
    args.append("--numeric-owner")

    # For when we are building binaries from projects such as integration. Example:
    # bazel-out/k8-opt/bin/external/aimrt
    args.append("--transform=s#.*external/[^/]*/##")

    # For when a binary is built from the source project, it won't be `external`:
    args.append("--transform=s#bazel-out/k8-opt/bin/##")

    # Add prefix if specified
    if ctx.attr.prefix:
        args.append("--transform=s#^#%s/#" % ctx.attr.prefix)

    # Strip prefix if specified
    if ctx.attr.strip_prefix:
        args.append("--transform=s#^%s/##" % ctx.attr.strip_prefix)

    # Do not use gzip here or it will insert a timestamp and you will get different shas!
    args.append("-cf")
    args.append(output_tar.path)

    transformed_files = {}
    for src in ctx.files.srcs:
        # Check duplicate files after 'tar --transform' implemented
        transformed_path = src.path

        # Implement "--transform=s#.*external/[^/]*/##"
        target_str = "external/"
        ext_idx = transformed_path.find(target_str)
        if ext_idx != -1:
            strip_idx = transformed_path.find("/", ext_idx + len(target_str))
            if strip_idx != -1:
                transformed_path = transformed_path[strip_idx + 1:]

        # Implement "--transform=s#bazel-out/k8-opt/bin/##"
        target_str = "bazel-out/k8-opt/bin/"
        transformed_path = transformed_path.replace(target_str, "")

        # Implement strip_prefix
        if ctx.attr.strip_prefix:
            if transformed_path.startswith(ctx.attr.strip_prefix):
                transformed_path = transformed_path[len(ctx.attr.strip_prefix):].lstrip("/")
        if not src.path.endswith(".idl") and \
           transformed_files.get(transformed_path) != None:
            # Abort if error exist
            error = "Package files Failed"
            cause = "Duplicate files will appear after packaging\n" + \
                    "original file paths:\n   " + src.path + \
                    "\nand:\n   " + transformed_files[transformed_path]
            solution = "Even if in different repositories, the file path should not be duplicated\n" + \
                       "Files with the same path listed above will conflict when merging and packing\n" + \
                       "Please check files listed above"
            agibot_fail(error, cause, solution)
        transformed_files[transformed_path] = src.path

        files.append(src)

    # Means we don't hit the command line arg limit.
    input_files_name = ctx.attr.name + "_input_files.txt"
    input_files = ctx.actions.declare_file(input_files_name)
    ctx.actions.write(
        output = input_files,
        content = "\n".join([f.path for f in files]),
    )

    args.append("--files-from {}".format(input_files.path))

    args = " ".join(args)
    command = "tar " + args

    # Now we can gzip in order to remove the timestamp and be reproducible,
    command += "; gzip -%s -n -c %s > %s" % (ctx.attr.compression_level, output_tar.path, output.path)

    ctx.actions.run_shell(
        inputs = files + [input_files],
        outputs = [output, output_tar],
        command = command,
        progress_message = "Creating package %s" % output.short_path,
    )

    return [DefaultInfo(
        files = depset([output]),
    )]

pkg_lib = rule(
    implementation = _pkg_lib,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
        ),
        "mode": attr.string(
            default = "0775",
        ),
        "compression_level": attr.string(
            default = "6",
            values = ["1", "2", "3", "4", "5", "6", "7", "8", "9"],
        ),
        "prefix": attr.string(
            default = "",
            doc = "An optional directory prefix to add to all paths in the archive. Supports select().",
        ),
        "strip_prefix": attr.string(
            default = "",
            doc = "An optional directory prefix to strip from all paths in the archive.",
        ),
    },
    doc = """
Creates a zipped tar of the library. Sources retain their directory structure.
Cc binary outputs are placed in `libs/`.
Note: strip_prefix currently does not support paths containing commas due to tar transform limitations.
    """,
)

TargetDepsInfo = provider(
    fields = {
        "kind": "kind",
        "name": "target name",
        "srcs": "sources",
        "hdrs": "headers",
        "deps": "direct dependencies",
        "transient_deps": "transient deps",
        "transient_external_deps": "transient_external_deps",
        "includes": "includes",
        "linkopts": "link opts",
        "linkstatic": "linkstatic",
        "defines": "defines",
        "copts": "copts",
        "data": "data",
        "is_executable": "is it executable",
        "main": "main file",
        "glob": "glob dir",
        "tags": "tags",
        "sdk_public_hdrs": "sdk_public_hdrs",
    },
)

# Scrapes info about the cc_library targets in order to
# help us construct the below filegroup.
def _src_dep_aspect_impl(target, ctx):
    kind = ""
    name = ""
    srcs = []
    hdrs = []
    deps = []
    transient_deps = []
    transient_external_deps = []
    srcs = []
    linkopts = []
    linkstatic = False
    defines = []
    data = []
    main = ""
    is_executable = False
    glob = []
    tags = []
    sdk_public_hdrs = []

    _transient_external_deps_visited = []

    # To stop this transient_deps from exploding in size and slowing
    # bazel down, we only take project transient dependencies
    # and remove duplicates.
    if hasattr(ctx.rule, "kind"):
        kind = ctx.rule.kind
    if hasattr(ctx.rule.attr, "name"):
        name = ctx.rule.attr.name
    if hasattr(ctx.rule.attr, "srcs"):
        srcs = ctx.rule.attr.srcs
        for src in srcs:
            if target.label.workspace_name == src.label.workspace_name:
                if TargetDepsInfo in src:
                    transient_deps.append(src)
                    transient_deps.extend(src[TargetDepsInfo].transient_deps)

            # If an external dependency
            if target.label.workspace_name != src.label.workspace_name:
                if TargetDepsInfo in src:
                    if not str(src) in _transient_external_deps_visited:
                        transient_external_deps.append(src)
                        _transient_external_deps_visited.append(str(src))
                    for tr in src[TargetDepsInfo].transient_external_deps:
                        if not str(tr) in _transient_external_deps_visited:
                            transient_external_deps.append(tr)
                            _transient_external_deps_visited.append(str(tr))
    if hasattr(ctx.rule.attr, "hdrs"):
        hdrs = ctx.rule.attr.hdrs
    if hasattr(ctx.rule.attr, "deps"):
        deps = ctx.rule.attr.deps
        for dep in deps:
            if target.label.workspace_name == dep.label.workspace_name:
                # TODO(finn): Inspect this to see if we should loop through deps too.
                # transient_deps.extend(dep[TargetDepsInfo].deps)
                # transient_deps.extend(dep[TargetDepsInfo].transient_deps)
                for dep_file in dep[TargetDepsInfo].deps:
                    if (dep_file not in transient_deps):
                        transient_deps.append(dep_file)
                for dep_file in dep[TargetDepsInfo].transient_deps:
                    if (dep_file not in transient_deps):
                        transient_deps.append(dep_file)
            for d in dep[TargetDepsInfo].deps:
                if target.label.workspace_name != d.label.workspace_name:
                    if not str(d) in _transient_external_deps_visited:
                        transient_external_deps.append(d)
                        _transient_external_deps_visited.append(str(d))
                    for tr in d[TargetDepsInfo].transient_external_deps:
                        if not str(tr) in _transient_external_deps_visited:
                            transient_external_deps.append(tr)
                            _transient_external_deps_visited.append(str(tr))
    if hasattr(ctx.rule.attr, "linkopts"):
        linkopts = ctx.rule.attr.linkopts
    if hasattr(ctx.rule.attr, "linkstatic"):
        linkstatic = ctx.rule.attr.linkstatic
    if hasattr(ctx.rule.attr, "defines"):
        defines = ctx.rule.attr.defines
    if hasattr(ctx.rule.attr, "data"):
        data = ctx.rule.attr.data
        for src in data:
            if target.label.workspace_name == src.label.workspace_name:
                for src in data:
                    if TargetDepsInfo in src:
                        transient_deps.append(src)
                        transient_deps.extend(src[TargetDepsInfo].transient_deps)
    if hasattr(ctx.rule.attr, "main"):
        main = ctx.rule.attr.main
    if hasattr(ctx.rule.attr, "_is_executable"):
        is_executable = ctx.rule.attr._is_executable
    if hasattr(ctx.rule.attr, "glob"):
        glob = ctx.rule.attr.glob
    if hasattr(ctx.rule.attr, "tags"):
        tags = ctx.rule.attr.tags
    if hasattr(ctx.rule.attr, "sdk_public_hdrs"):
        sdk_public_hdrs = ctx.rule.attr.sdk_public_hdrs
    return [TargetDepsInfo(
        kind = kind,
        name = name,
        srcs = srcs,
        hdrs = hdrs,
        deps = deps,
        transient_deps = transient_deps,
        transient_external_deps = transient_external_deps,
        linkopts = linkopts,
        linkstatic = linkstatic,
        defines = defines,
        data = data,
        main = main,
        is_executable = is_executable,
        glob = glob,
        tags = tags,
        sdk_public_hdrs = sdk_public_hdrs,
    )]

src_dep_aspect = aspect(
    implementation = _src_dep_aspect_impl,
    attr_aspects = ["srcs", "deps", "data", "name"],
)

_filegroup_template = """filegroup(
    name = "{name}",
    srcs = [
        {srcs}
    ],
)

"""

_filegroup_with_glob_template = """filegroup(
    name = "{name}",
    srcs = glob([
        {srcs}
    ]),
)

"""

_cc_library_template = """cc_library(
    name = "{name}",
    srcs = {srcs},
    hdrs = {hdrs},
    deps = [
        {deps}
    ]{deps_select},
    linkopts = [
        {linkopts}
    ],
    defines = [
        {defines}
    ],
)

"""

_cc_binary_template = """cc_binary(
    name = "{name}",
    srcs = [
        {srcs}
    ],
    deps = [
        {deps}
    ],
    linkopts = [
        {linkopts}
    ],
    linkstatic = {linkstatic},
)

"""

_root_cc_library_template = """cc_library (
    name = "{name}",
    deps = [
        {deps}
    ],
)

"""

_py_library_template = """py_library (
    name = "{name}",
    srcs = [
        {srcs}
    ],
    data = [
        {data}
    ],
    deps = [
        {deps}
    ],
)

"""

_py_binary_template = """py_binary (
    name = "{name}",
    main = "{main}",
    srcs = [
        {srcs}
    ],
    data = [
        {data}
    ],
    deps = [
        {deps}
    ],
)

"""

_proto_library_template = """proto_library(
    name = "{name}",
    srcs = [
        {srcs}
    ],
    deps = [
        {deps}
    ],
)
"""

_cc_proto_library_template = """cc_proto_library(
    name = "{name}",
    deps = [
        {deps}
    ],
)
"""

_cc_single_library_template = """cc_library(
    name = "{name}",
    srcs = [
        {srcs}
    ],
    hdrs = [
        {hdrs}
    ],
    deps = [
        {deps}
    ],
    linkopts = [
        {linkopts}
    ],
)
"""

def _filegroup_data(ctx):
    src_files = []
    build_files = []

    # First group the various names by their packages.
    # Format is {package: {name: depset(srcs)}}
    packages = {}

    # Map of aspects.
    # Format is {package: {name: aspect}}
    asps = {}
    for src in ctx.attr.srcs:
        target = {src.label.name: src.files}
        if src.label.package in packages:
            packages[src.label.package][src.label.name] = src.files
            asps[src.label.package][src.label.name] = src[TargetDepsInfo]
        else:
            packages[src.label.package] = {src.label.name: src.files}
            asps[src.label.package] = {src.label.name: src[TargetDepsInfo]}

    # Build the root package if it won't be generated below.
    if "" not in packages.keys():
        srcs = []
        for s in ctx.attr.srcs:
            srcs.append('"{}"'.format(rm_repo_prefix(s.label, ctx)))

        filename = "{}_data_BUILD".format(ctx.attr.name)
        build_file = ctx.actions.declare_file(filename)
        build_file_contents = _filegroup_template.format(
            name = ctx.attr.name,
            srcs = ", \n{}".format(" " * 8).join(srcs),
        )

        # Write out the BUILD file for this package.
        ctx.actions.write(
            output = build_file,
            content = build_file_contents,
        )
        build_files.append(build_file)

    for package, target in packages.items():
        build_file_contents = ""

        dirname = package.replace("//", "") + ("/" if package else "")
        filename = "_data_BUILD"
        build_file = ctx.actions.declare_file(dirname + filename)

        # Add the root BUILD file.
        if not package:
            srcs = []
            for s in ctx.attr.srcs:
                srcs.append('"{}"'.format(rm_repo_prefix(s.owner, ctx)))

            build_file_contents += _filegroup_template.format(
                name = ctx.attr.name,
                srcs = ", \n{}".format(" " * 8).join(srcs),
            )

        for name, files in target.items():
            srcs = []

            # Grab all the files from the target
            for f in files.to_list():
                if f.is_source:
                    srcs.append('"{}"'.format(rm_repo_prefix(f.owner, ctx)))  #format(f.short_path.replace(dirname, "")))
                else:
                    srcs.append('"{}"'.format(f.short_path.replace(dirname, "")))

            build_file_contents += _filegroup_template.format(
                name = name,
                srcs = ", \n{}".format(" " * 8).join(srcs),
            )

        # Write out the BUILD file for this package.
        ctx.actions.write(
            output = build_file,
            content = build_file_contents,
        )
        build_files.append(build_file)

    return [
        DefaultInfo(
            files = depset(ctx.files.srcs),
        ),
        BuildFileInfo(
            files = depset(build_files),
        ),
    ]

filegroup_data = rule(
    implementation = _filegroup_data,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            aspects = [src_dep_aspect],
        ),
    },
    doc = """
Filegroup for cc libs. Returns the files and direct information.
    """,
)

def _filegroup_py(ctx):
    build_files = []

    # First group the various names by their packages.
    # Format is {package: {name: depset(srcs)}}
    packages = {}

    # Map of aspects.
    # Format is {package: {name: aspect}}
    asps = {}
    for src in ctx.attr.srcs:
        if src.label.package in packages:
            packages[src.label.package][src.label.name] = src.files
            asps[src.label.package][src.label.name] = src[TargetDepsInfo]
        else:
            packages[src.label.package] = {src.label.name: src.files}
            asps[src.label.package] = {src.label.name: src[TargetDepsInfo]}

    # Build the root package if it won't be generated below.
    if "" not in packages.keys():
        srcs = []
        for s in ctx.attr.srcs:
            srcs.append('"{}"'.format(rm_repo_prefix(s.label, ctx)))

        filename = "{}_py_BUILD".format(ctx.attr.name)
        build_file = ctx.actions.declare_file(filename)
        build_file_contents = _filegroup_template.format(
            name = ctx.attr.name,
            srcs = ", \n{}".format(" " * 8).join(srcs),
        )

        # Write out the BUILD file for this package.
        ctx.actions.write(
            output = build_file,
            content = build_file_contents,
        )
        build_files.append(build_file)

    for package, target in packages.items():
        build_file_contents = ""
        dirname = package.replace("//", "") + ("/" if package else "")
        filename = "{}_{}_py_BUILD".format(ctx.attr.name, package.replace("/", "_"))
        build_file = ctx.actions.declare_file(dirname + filename)

        # Add the root BUILD file.
        if not package:
            srcs = []
            for s in ctx.attr.srcs:
                srcs.append('"{}"'.format(s.label))
            build_file_contents += _filegroup_template.format(
                name = ctx.attr.name,
                srcs = ", \n{}".format(" " * 8).join(srcs),
            )

        for name, files in target.items():
            srcs = []

            # Grab all the files from the target.
            for f in files.to_list():
                if name != f.owner.name:
                    srcs.append('"{}"'.format(rm_repo_prefix(f.owner, ctx)))

            deps = []
            data = []
            attrs = asps[package][name]
            for d in attrs.deps:
                deps.append('"{}"'.format(rm_repo_prefix(d.label, ctx)))
            for d in attrs.data:
                data.append('"{}"'.format(rm_repo_prefix(d.label, ctx)))

            if attrs.is_executable:
                build_file_contents += _py_binary_template.format(
                    name = name,
                    main = rm_repo_prefix(attrs.main.label, ctx),
                    srcs = ", \n{}".format(" " * 8).join(srcs),
                    data = ", \n{}".format(" " * 8).join(data),
                    deps = ", \n{}".format(" " * 8).join(deps),
                )
            else:
                build_file_contents += _py_library_template.format(
                    name = name,
                    srcs = ", \n{}".format(" " * 8).join(srcs),
                    data = ", \n{}".format(" " * 8).join(data),
                    deps = ", \n{}".format(" " * 8).join(deps),
                )

        # Write out the BUILD file for this package.
        ctx.actions.write(
            output = build_file,
            content = build_file_contents,
        )
        build_files.append(build_file)

    return [
        DefaultInfo(
            files = depset(ctx.files.srcs),
        ),
        BuildFileInfo(
            files = depset(build_files),
        ),
    ]

filegroup_py = rule(
    implementation = _filegroup_py,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            providers = [PyInfo],
            aspects = [src_dep_aspect],
        ),
    },
    doc = """
Filegroup for py libs.
    """,
)

# A filegroup wrapper around CcInfo. It will return files and a merge of CcInfo.
# Normally `filegroup` removes providers, this one includes `CcInfo`:
# https://github.com/bazelbuild/bazel/issues/8904
# Can also generate BUILD files.
def _filegroup_cc(ctx):
    src_files = []
    build_files = []
    data_files = []

    src_extensions = ctx.attr.src_extensions

    # We want all the direct dependencies for consumption later on.
    # https://docs.bazel.build/versions/master/skylark/lib/cc_common.html#merge_cc_infos
    cc_info = cc_common.merge_cc_infos(direct_cc_infos = [src[CcInfo] for src in ctx.attr.srcs])

    # First group the various names by their packages.
    # Format is {package: {name: src}}
    packages = {}

    # Map of aspects.
    # Format is {package: {name: aspect}}
    asps = {}
    for src in ctx.attr.srcs:
        if src.label.package in packages:
            packages[src.label.package][src.label.name] = src
            asps[src.label.package][src.label.name] = src[TargetDepsInfo]
        else:
            packages[src.label.package] = {src.label.name: src}
            asps[src.label.package] = {src.label.name: src[TargetDepsInfo]}

    # Build the root package if it won't be generated below.
    if "" not in packages.keys():
        srcs = []
        for s in ctx.attr.srcs:
            srcs.append('"{}"'.format(s.label))

        filename = "{}_cc_BUILD".format(ctx.attr.name)
        build_file = ctx.actions.declare_file(filename)

        build_file_contents = _root_cc_library_template.format(
            name = ctx.attr.name,
            deps = ", \n{}".format(" " * 8).join(srcs),
        )

        # Write out the BUILD file for this package.
        ctx.actions.write(
            output = build_file,
            content = build_file_contents,
        )
        build_files.append(build_file)

    for package, target in packages.items():
        build_file_contents = ""
        dirname = package.replace("//", "") + ("/" if package else "")
        filename = "{}_{}_cc_BUILD".format(ctx.attr.name, package.replace("/", "_"))
        build_file = ctx.actions.declare_file(dirname + filename)

        if not package:
            srcs = []
            for s in ctx.attr.srcs:
                srcs.append('"{}"'.format(s.label))

            build_file_contents += _root_cc_library_template.format(
                name = ctx.attr.name,
                deps = ", \n{}".format(" " * 8).join(srcs),
            )

        # Collect the cc_library files.
        for name, files in target.items():
            srcs = []
            attrs = asps[package][name]

            # Grab all the files from the target
            for f in files.files.to_list():
                # Only take specific extensions.
                # Here we give all .so files a unique name.
                # The reason for this is incase two repositories produce the same .so file i.e:
                # libutils.so -> becomes: repository_path_to_so_libutils.so
                if "*" in src_extensions or f.extension in src_extensions:
                    copy_root = f.dirname.replace(f.root.path, "").lstrip("/")
                    if copy_root:
                        copy_path = copy_root + "/" + copy_root.replace("/", "_") + "_" + f.basename
                        dst = copy_file(ctx, f, copy_path)
                        srcs.append('"{}"'.format(dst.basename))
                        src_files.append(dst)
                    else:
                        srcs.append('"{}"'.format(f.basename))
                        src_files.append(f)

            # if attrs.kind == "cc_binary":
            # for f in files.output_groups.compilation_outputs.to_list():
            #     srcs.append('"{}"'.format("_objs/perception_lidar_node/lidar_perception_node.pic.o"))
            #     src_files.append(f)

            deps = []
            hdrs = []
            links = []
            defines = []
            if attrs.kind != "cc_proto_library" and attrs.kind != "cc_single_library":
                for d in attrs.deps:
                    deps.append('"{}"'.format(d.label))
            deps_select = []
            attrs = asps[package][name]
            for l in attrs.linkopts:
                links.append('"{}"'.format(l))
            for m in attrs.defines:
                defines.append('"{}"'.format(m))
            for h in files[CcInfo].compilation_context.direct_public_headers:
                if h.is_source:
                    hdrs.append('"{}"'.format(h.owner))
                else:
                    pkg = ("{}".format(h.owner)).split(":")[0]
                    hdrs.append('"{}:{}"'.format(pkg, h.basename))

            hdrs = depset(hdrs).to_list()

            if (attrs.kind == "cc_proto_library" or
                attrs.kind == "cc_library" or
                attrs.kind == "cuda_library" or
                attrs.kind == "cc_single_library"):
                build_file_contents += _cc_library_template.format(
                    name = name,
                    srcs = "[\n        {}\n    ]".format(", \n{}".format(" " * 8).join(srcs)),
                    hdrs = "[\n        {}\n    ]".format(", \n{}".format(" " * 8).join(hdrs)),
                    deps = ", \n{}".format(" " * 8).join(deps),
                    deps_select = "\n".join(deps_select),
                    linkopts = ", \n{}".format(" " * 8).join(links),
                    defines = ", \n{}".format(" " * 8).join(defines),
                )

                # elif attrs.kind == "cc_binary":
                # build_file_contents += _cc_binary_template.format(
                #     name = name,
                #     srcs = ", \n{}".format(" "*8).join(srcs),
                #     deps = ", \n{}".format(" "*8).join(deps),
                #     linkopts = ", \n{}".format(" "*8).join(links),
                # )
                # build_file_contents += _filegroup_template.format(
                # name = name,
                # srcs = ", \n{}".format(" "*8).join(srcs),
                # deps = ", \n{}".format(" "*8).join(deps),
                # linkopts = ", \n{}".format(" "*8).join(links),
                # )

            else:
                fail("Rule not supported yet.")

        # Write out the BUILD file for this package.
        ctx.actions.write(
            output = build_file,
            content = build_file_contents,
        )

        build_files.append(build_file)

    return [
        DefaultInfo(
            files = depset(src_files),
        ),
        BuildFileInfo(
            files = depset(build_files),
        ),
        cc_info,
    ]

filegroup_cc = rule(
    implementation = _filegroup_cc,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            providers = [CcInfo],
            aspects = [src_dep_aspect],
        ),
        "src_extensions": attr.string_list(
            default = ["so"],
        ),
        "idl_utils_ext": attr.bool(
            default = True,
        ),
    },
    doc = """
Filegroup for cc libs. Returns the files and direct information.
    """,
)

def _normalize_label(label):
    label_str = str(label)

    if label_str.startswith("@@//"):
        return label_str.replace("@@//", "//", 1)

    if label_str.startswith("@@"):
        double_slash_index = label_str.find("//")
        if double_slash_index != -1:
            return label_str.replace("@@", "@", 1)

    return label_str

# Normally, we want to generate a BUILD file by returning the output file created.
# For this rule, we actually want the protos which were originally consumed by the rule.
# So we instead loop through the srcs aspect.
def _filegroup_proto_impl(ctx):
    build_files = []
    src_files = []
    asps = {}
    deps = []

    # For protobufs, the ".bin" file they produce isn't as useful to us.
    # So instead, find the transient sources consumed by the original rule.
    asps = {}
    for src in ctx.attr.srcs:
        for transient_srcs in src[TargetDepsInfo].srcs:
            transient_srcs_files = transient_srcs.files.to_list()
            src_files.extend(transient_srcs_files)
            if src.label.package in asps:
                asps[src.label.package][src.label.name] = src[TargetDepsInfo]
            else:
                asps[src.label.package] = {src.label.name: src[TargetDepsInfo]}

    # Build the root package if it won't be generated below.
    if "" not in asps.keys():
        srcs = []
        for s in ctx.attr.srcs:
            srcs.append('"{}"'.format(s.label))

        filename = "{}_proto_library_BUILD".format(ctx.attr.name)
        build_file = ctx.actions.declare_file(filename)

        build_file_contents = _proto_library_template.format(
            name = ctx.attr.name,
            srcs = "",
            deps = ", \n{}".format(" " * 8).join(srcs),
        )

        # Write out the BUILD file for this package.
        ctx.actions.write(
            output = build_file,
            content = build_file_contents,
        )
        build_files.append(build_file)

    # Create one BUILD file per package.
    for package, target in asps.items():
        build_file_contents = ""
        dirname = package.replace("//", "") + ("/" if package else "")
        filename = "{}_{}_proto_library_BUILD".format(ctx.attr.name, package.replace("/", "_"))
        build_file = ctx.actions.declare_file(dirname + filename)

        if not package:
            srcs = []
            for s in ctx.attr.srcs:
                srcs.append('"{}"'.format(s.label))

            build_file_contents += _proto_library_template.format(
                name = ctx.attr.name,
                src = "",
                deps = ", \n{}".format(" " * 8).join(srcs),
            )

        # Collect the proto_library files.
        for name, files in target.items():
            srcs = []
            attrs = asps[package][name]

            # Grab all the files from the target
            for f in attrs.srcs:
                srcs.append('"{}"'.format(f.label))
            for d in attrs.deps:
                deps.append('"{}"'.format(d.label))

        build_file_contents += _proto_library_template.format(
            name = name,
            srcs = ", \n{}".format(" " * 8).join(srcs),
            deps = ", \n{}".format(" " * 8).join(deps),
        )

        ctx.actions.write(
            output = build_file,
            content = build_file_contents,
        )
        build_files.append(build_file)

    return [
        DefaultInfo(
            files = depset(src_files),
        ),
        BuildFileInfo(
            files = depset(build_files),
        ),
    ]

filegroup_proto = rule(
    implementation = _filegroup_proto_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            providers = [ProtoInfo],
            aspects = [src_dep_aspect],
        ),
        "deps": attr.label_list(
            aspects = [src_dep_aspect],
        ),
    },
    doc = """
Filegroup for protbuf libs. Returns the .proto and their BUILD files.
    """,
)

# At the moment this just returns the first BUILD file it finds.
def __generate_build_file_data(ctx, target):
    cc_kind = [
        "cc_binary",
        "cc_library",
        "cuda_library",
        "qt_cc_library",
    ]
    cc_single_kind = [
        "cc_single_library",
    ]
    cc_proto_library = [
        "cc_proto_library",
    ]
    proto_kind = [
        "proto_library",
    ]
    python_kind = [
        "py_library",
        "py_binary",
    ]
    filegroup_kind = [
        "filegroup",
        "genrule",
    ]
    skip_kind = [
        "_generate_cc",
        "filegroup_cc",
        "filegroup_data",
        "filegroup_py",
    ]

    kind = target[TargetDepsInfo].kind

    if kind in cc_kind:
        return __generate_cc_build_file_data(ctx, target)
    if kind in cc_proto_library:
        return __generate_cc_proto_library(ctx, target)
    elif kind in proto_kind:
        return __generate_proto_build_file_data(ctx, target)
    elif kind in python_kind:
        return __generate_py_build_file_data(ctx, target)
    elif kind in filegroup_kind:
        return __generate_filegroup_build_file_data(ctx, target)
    elif kind in cc_single_kind:
        return __generate_cc_single_build_file_data(ctx, target)
    elif kind in skip_kind:
        return "", []
    else:
        fail("Kind not supported: " + kind)

def __generate_cc_proto_library(ctx, target):
    deps = target[TargetDepsInfo].deps
    build_file_contents = _cc_proto_library_template.format(
        name = target.label.name,
        deps = ", \n{}".format(" " * 8).join(['"{}"'.format(d.label) for d in deps]),
    )
    return build_file_contents, []

def __generate_filegroup_build_file_data(ctx, target):
    srcs = []
    for src in target.files.to_list():
        srcs.append(get_file_path(target, src))

    srcs = depset(srcs).to_list()

    build_file_contents = _filegroup_template.format(
        name = target.label.name,
        srcs = ", \n{}".format(" " * 8).join(['"{}"'.format(s) for s in srcs]),
    )
    return build_file_contents, target.files.to_list()

# ToDo: We could implement CcInfo on cc_static to make this more reliable.
# i.e target[CcInfo].compilation_context.direct_public_headers
def __generate_cc_single_build_file_data(ctx, target):
    srcs = []
    hdrs = []
    deps = []
    deps_visited = []
    linkopts = []
    outputs = []
    if target[TargetDepsInfo].linkstatic:
        lib_extension = ".a"
    else:
        lib_extension = ".so"

    for src in target.files.to_list():
        path = label_of_file(src)
        if path.endswith(lib_extension):
            srcs.append(path)
            outputs.append(src)
    for h in target[CcInfo].compilation_context.headers.to_list():
        if ctx.label.workspace_name == h.owner.workspace_name or h.owner.workspace_name == "":
            path = label_of_file(h)
            if (path.endswith(".hpp") or path.endswith(".h") or path.endswith(".inl")) and (not path.endswith(".pb.h")):
                hdrs.append(path)
                outputs.append(h)

    # Find all external dependencies.
    for dep in target[TargetDepsInfo].deps + target[TargetDepsInfo].transient_deps:
        if ctx.label.workspace_name != dep.label.workspace_name:
            if not str(dep.label) in deps_visited:
                deps_visited.append(str(dep.label))
                if CcInfo in dep:
                    if dep[TargetDepsInfo].kind != "proto_library":
                        deps.append(str(dep.label))

                # else:
                #     srcs.append(str(d.label))

        else:
            for linkopt in dep[TargetDepsInfo].linkopts:
                if linkopt not in linkopts:
                    linkopts.append(linkopt)

    build_file_contents = _cc_single_library_template.format(
        name = target.label.name,
        srcs = ", \n{}".format(" " * 8).join(['"{}"'.format(s) for s in sorted(srcs)]),
        hdrs = ", \n{}".format(" " * 8).join(['"{}"'.format(h) for h in sorted(hdrs)]),
        deps = ", \n{}".format(" " * 8).join(['"{}"'.format(d) for d in sorted(deps)]),
        linkopts = ", \n{}".format(" " * 8).join(['"{}"'.format(l) for l in linkopts]),
    )
    return build_file_contents, outputs

# Normally, we want to generate a BUILD file by returning the output file created.
# For this rule, we actually want the protos which were originally consumed by the rule.
# So we instead loop through the srcs aspect.
def __generate_proto_build_file_data(ctx, target):
    srcs = target[TargetDepsInfo].srcs
    deps = target[TargetDepsInfo].deps

    # For protobufs, the ".bin" file they produce isn't as useful to us.
    # So instead, find the transient sources consumed by the original rule.
    outputs = []
    for src in srcs:
        outputs.extend(src.files.to_list())

    if CcInfo in target:
        outputs.extend(target[CcInfo].compilation_context.direct_public_headers)

    build_file_contents = _proto_library_template.format(
        name = target[TargetDepsInfo].name,
        srcs = ", \n{}".format(" " * 8).join(['"{}"'.format(s.label) for s in srcs]),
        deps = ", \n{}".format(" " * 8).join(['"{}"'.format(d.label) for d in deps]),
    )
    return build_file_contents, outputs

def __generate_py_build_file_data(ctx, target):
    build_file_contents = ""
    is_executable = target[TargetDepsInfo].is_executable

    data = target[TargetDepsInfo].data
    deps = target[TargetDepsInfo].deps
    main = target[TargetDepsInfo].main

    srcs = []
    for f in target.files.to_list():
        if target.label.name != f.owner.name:
            srcs.append(f)

    if target[TargetDepsInfo].is_executable:
        build_file_contents += _py_binary_template.format(
            name = target.label.name,
            main = main.label,
            srcs = ", \n{}".format(" " * 8).join(['"{}"'.format(s.owner) for s in srcs]),
            data = ", \n{}".format(" " * 8).join(['"{}"'.format(d.label) for d in data]),
            deps = ", \n{}".format(" " * 8).join(['"{}"'.format(d.label) for d in deps]),
        )
    else:
        build_file_contents += _py_library_template.format(
            name = target.label.name,
            srcs = ", \n{}".format(" " * 8).join(['"{}"'.format(s.owner) for s in srcs]),
            data = ", \n{}".format(" " * 8).join(['"{}"'.format(d.label) for d in data]),
            deps = ", \n{}".format(" " * 8).join(['"{}"'.format(d.label) for d in deps]),
        )

    return build_file_contents, target.files.to_list()

# Generate the build file data for a target. Must contain CcInfo.
def __generate_cc_build_file_data(ctx, target):
    build_file_contents = ""
    outputs = []
    package = target.label.package
    name = target[TargetDepsInfo].name
    srcs = target[TargetDepsInfo].srcs
    kind = target[TargetDepsInfo].kind
    hdrs = target[TargetDepsInfo].hdrs
    deps = target[TargetDepsInfo].deps
    linkopts = target[TargetDepsInfo].linkopts
    defines = target[TargetDepsInfo].defines
    linkstatic = target[TargetDepsInfo].linkstatic
    tags = target[TargetDepsInfo].tags

    # Generate cc_binary() for cc_irs_module()
    irs_module_tag = "_irs_module_"
    if irs_module_tag in tags and name.endswith("_main"):
        module_name = name[:-5]
        build_file_contents += _cc_binary_template.format(
            name = module_name,
            srcs = ", \n{}".format(" " * 8).join([]),
            deps = ", \n{}".format(" " * 8).join(['"{}"'.format(l) for l in [name]]),
            linkopts = ", \n{}".format(" " * 8).join([]),
            linkstatic = str(linkstatic),
        )

    dirname = package.replace("//", "") + ("/" if package else "")
    build_deps = []
    tensorrt = False
    for d in deps:
        build_deps.append(_normalize_label(d.label))

    deps_select = []

    build_hdrs = []

    # Create the correct label for the header files.
    # If the target does not own the header, include the correct label.
    # for h in target[CcInfo].compilation_context.direct_public_headers:
    for hdr in hdrs:
        for h in hdr.files.to_list():
            path = get_file_path(target, h)
            if path.endswith(".h") or path.endswith(".hpp") or path.endswith(".inl"):
                build_hdrs.append(path)

    build_hdrs = depset(build_hdrs).to_list()

    build_hdrs_without_codegen = []
    for build_hdr in build_hdrs:
        if build_hdr.endswith("_grpc_grpc_codegen"):
            continue
        build_hdrs_without_codegen.append(build_hdr)
    build_hdrs = build_hdrs_without_codegen

    # Here we copy the .so files to give them a unique name. This helps at the
    # linker stage when you have two targets called e.g "utils".
    copied_files = []
    for f in target.files.to_list():
        # Check for requested extensions.
        if f.extension in ctx.attr.cc_src_extensions:
            path = unique_name(f)
            dst = copy_file(ctx, f, path)
            copied_files.append(dst)
    srcs_list = ['"//:{}"'.format(s.basename) for s in copied_files]

    # if src has header files, should remain
    for src in srcs:
        for s in src.files.to_list():
            if s.basename.endswith(".h"):
                srcs_list.append('"{}"'.format(get_file_path(target, s)))

    # Format the data and return it.

    srcs_list_without_codegen = []
    for srcs_list_entry in srcs_list:
        if srcs_list_entry.endswith("_grpc_grpc_codegen\""):
            continue
        srcs_list_without_codegen.append(srcs_list_entry)
    srcs_list = srcs_list_without_codegen

    build_file_contents += _cc_library_template.format(
        name = name,
        srcs = "[\n        {}\n    ]".format(", \n{}".format(" " * 8).join(srcs_list)),
        hdrs = "[\n        {}\n    ]".format(", \n{}".format(" " * 8).join(['"{}"'.format(str(h)) for h in build_hdrs])),
        deps = ", \n{}".format(" " * 8).join(['"{}"'.format(str(d)) for d in build_deps]),
        deps_select = "\n".join(deps_select),
        linkopts = ", \n{}".format(" " * 8).join(['"{}"'.format(l) for l in linkopts]),
        defines = ", \n{}".format(" " * 8).join(['"{}"'.format(m) for m in defines]),
    )
    if "has_top_header" in tags:
        build_file_contents += _gen_top_header_template.format(name = name)

    # The output of a rule cc_library rule are the library files.
    # We also want the headers.
    outputs.extend(copied_files + target[CcInfo].compilation_context.direct_headers)
    return build_file_contents, outputs

def rm_external_prefix(file_path, workspace_root):
    # Remove 'bazel-out/k8-opt/bin/external/@Repo_name/' & 'external/@Repo_name/' from file path
    external_src_prefix = "bazel-out/k8-opt/bin/"
    external_bin_prefix = workspace_root + "/"
    if file_path.startswith(external_src_prefix):
        file_path = file_path.replace(external_src_prefix, "", 1)
    if file_path.startswith(external_bin_prefix):
        file_path = file_path.replace(external_bin_prefix, "", 1)
    return file_path

def rm_repo_prefix(target_name, ctx):
    target_label = str(target_name)
    if target_name.workspace_name == ctx.label.workspace_name and target_label.startswith("@"):
        # Remove @Repo_name prefix from generated file path for SDK package
        start_idx = target_label.find("//")
        if start_idx >= 0:
            target_label = target_label[start_idx:]
    return target_label

def get_file_path(target, src):
    """
    获取源文件的正确路径表示。
    处理包内文件、包外依赖、外部库和双 @ 前缀问题。

    Args:
        target: 当前处理的目标
        src: 源文件

    Returns:
        源文件的正确路径表示（相对路径或标签）
    """

    # 提取包路径信息
    target_package = target.label.package
    src_owner_str = str(src.owner)

    # 规范化标签
    if src_owner_str.startswith("@@"):
        src_owner_str = src_owner_str[1:]

    # 检查文件是否属于目标所在的包
    is_in_same_package = False
    src_package = ""

    # 从 src.owner 提取包路径 (安全处理分割操作)
    if ":" in src_owner_str:
        owner_parts = src_owner_str.split(":")
        prefix_part = owner_parts[0]
        if "//" in prefix_part:
            src_package = prefix_part.split("//")[-1]
            is_in_same_package = (target_package == src_package)

    # 对于包内文件，返回相对路径
    if is_in_same_package:
        # 获取文件名或相对路径
        short_path = src.short_path

        # 处理外部仓库路径（以 .. 开头）
        if short_path.startswith(".."):
            # 提取仓库名称，处理可能的 @ 前缀
            workspace_name = target.label.workspace_name
            if workspace_name.startswith("@"):
                workspace_name = workspace_name[1:]

            # 移除 ../repo_name 前缀
            short_path = short_path.replace("../" + workspace_name, "", 1)

        # 从路径中移除包前缀，获得相对路径
        path = short_path
        if target_package and short_path.startswith(target_package):
            path = short_path[len(target_package):]

            # 移除开头的斜杠
            if path.startswith("/"):
                path = path[1:]
        else:
            # 处理其他可能的路径格式
            path_parts = short_path.split("//")
            if len(path_parts) > 1:
                path = path_parts[-1]

        return path

    # 对于包外文件，返回规范化的标签
    if src_owner_str.startswith("@@"):
        return src_owner_str[1:]  # 防止使用外部函数可能出现的问题
    return src_owner_str

# Returns the label of a file
def label_of_file(file):
    if file.is_source:
        return str(file.owner)
    else:
        a = file.short_path.split("/")

        # If built from integration, the path will be in the form:
        # ../external_repo/path/to:target
        # Which we transorm to:
        # @external_repo//path/to:target
        prefix = ""
        if a[0] == "..":
            prefix = "@" + a[1]
            a = a[2:len(a)]
        dir_path = "/".join(a[0:len(a) - 1])
        return prefix + "//" + dir_path + ":" + file.basename

# Appends the folder path to the file name
def unique_name(file):
    root = file.dirname.replace(file.root.path, "").lstrip("/")
    path = root.replace("/", "_") + "_" + file.basename

    # Many binaries can start with the string "external_".
    # So we remove this to keep the length down.
    if path.startswith("external_"):
        path = path.replace("external_", "", 1)
    path = path.lstrip("_")
    return path

# Copy a file from one place to another.
def copy_file(ctx, file, name):
    dst = ctx.actions.declare_file(name)
    ctx.actions.run_shell(
        tools = [file],
        outputs = [dst],
        command = "cp -f \"$1\" \"$2\"",
        arguments = [file.path, dst.path],
        mnemonic = "CopyFile",
        progress_message = "Copying files",
        use_default_shell_env = True,
    )
    return dst
