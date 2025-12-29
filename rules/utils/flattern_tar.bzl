# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

_py_script_template = """
#!/usr/bin/env python3
import tarfile
import os
import sys


def main():
    if len(sys.argv) < 3 or len(sys.argv) > 4:
        print("Usage: flatten_tar.py <input_tar> <output_tar> [prefix]")
        sys.exit(1)
    
    input_tar, output_tar = sys.argv[1], sys.argv[2]
    prefix = sys.argv[3] if len(sys.argv) == 4 else ""
    
    with tarfile.open(input_tar, "r:*") as tar:
        members = []
        for member in tar.getmembers():
            if member.isdir():
                continue
            filename = os.path.basename(member.name)
            if prefix:
                member.name = os.path.join(prefix, filename)
            else:
                member.name = filename
            members.append(member)
        
        with tarfile.open(output_tar, "w") as out_tar:
            for member in members:
                file_obj = tar.extractfile(member)
                out_tar.addfile(member, file_obj)

if __name__ == "__main__":
    main()
"""

def _flatten_tar_impl(ctx):
    input_tar = ctx.file.src
    output_tar = ctx.actions.declare_file(ctx.label.name + ".tar")
    prefix = ctx.attr.prefix

    py_script = ctx.actions.declare_file("_tmp/flatten_tar.py")
    ctx.actions.write(
        output = py_script,
        content = _py_script_template,
        is_executable = True,
    )

    command = "python3 %s %s %s %s" % (py_script.path, input_tar.path, output_tar.path, prefix)

    ctx.actions.run_shell(
        inputs = depset([py_script, input_tar]),
        outputs = [output_tar],
        use_default_shell_env = True,
        progress_message = "Generating flattened tar: %s" % output_tar.path,
        command = command,
    )

    default_info = DefaultInfo(
        files = depset([output_tar]),
    )
    return [default_info]

flatten_tar = rule(
    implementation = _flatten_tar_impl,
    attrs = {
        "src": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "Input tar file to flatten",
        ),
        "prefix": attr.string(
            default = "",
            doc = "Optional prefix directory for files in the output tar",
        ),
    },
    doc = "Flattens the directory structure of a tar file into a new tar",
)