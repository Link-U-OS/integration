# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

_template_script_apply = """#!/bin/bash
set -e
set -x

# This script will copy the contents of the user defined json to the override.

if [ "$#" -eq 1 ]; then
    path=$1
    echo "Overriding repositories with $path"
else
    echo "Use: apply_override <path>"
    exit -1
fi

# Break the sandbox and override the .json file.
override=$(readlink {override_path})
cp $path $override
"""

_template_script_rm = """#!/bin/bash
set -e
set -x

# Break the sandbox and override the .json file.
override=$(readlink {override_path})
echo "{{}}" > "$override"
"""

_template_script_show = """#!/bin/bash
set -e
set -x

if [ "$#" -eq 0 ]; then
    if ! command -v jq &> /dev/null
    then
        cat external/agibot_repo_loader/agibot_repo_loader.json
        exit 0
    fi
    jq 'with_entries(.)' external/agibot_repo_loader/agibot_repo_loader.json
    exit 0
fi

if ! command -v jq &> /dev/null
then
    echo "Needs `jq` in order to show specific repositories."
    exit -1
fi
args=""
i=0
for arg in "$@"; do
    if [ "$i" -eq 0 ]; then
        args+=$(printf "%s" $arg)
    else
        args+=$(printf ",%s" $arg)
    fi
    i+=1
done
jq {"$args"} external/agibot_repo_loader/agibot_repo_loader.json
"""

def _apply_override_impl(ctx):
    script = ctx.actions.declare_file(ctx.attr.name)
    ctx.actions.write(
        output = script,
        content = _template_script_apply.format(
            override_path=ctx.file._override.path
        )
    )

    return DefaultInfo(
        files = depset([script]),
        executable = script
    )

def apply_override(name):
    script_name = name + "-script"
    _apply_override(
        name = script_name,
        tags = ["manual"]
    )

    native.sh_binary(
        name = name,
        srcs = [script_name],
        data = ["@override//:override.json"],
        tags = ["manual"]
    )

def _rm_override_impl(ctx):
    script = ctx.actions.declare_file(ctx.attr.name)
    ctx.actions.write(
        output = script,
        content = _template_script_rm.format(
            override_path=ctx.file._override.path
        )
    )

    return DefaultInfo(
        files = depset([script]),
        executable = script
    )

def rm_override(name):
    script_name = name + "-script"
    _rm_override(
        name = script_name,
        tags = ["manual"]
    )

    native.sh_binary(
        name = name,
        srcs = [script_name],
        data = ["@override//:override.json"],
        tags = ["manual"]
    )

def _show_repos_impl(ctx):
    script = ctx.actions.declare_file(ctx.attr.name)
    ctx.actions.write(
        output = script,
        content = _template_script_show,
    )

    return DefaultInfo(
        files = depset([script]),
        executable = script
    )

def show_repos(name):
    script_name = name + "-script"
    _show_repos(
        name = script_name,
        tags = ["manual"]
    )

    native.sh_binary(
        name = name,
        srcs = [script_name],
        data = ["@agibot_repo_loader//:agibot_repo_loader.json"],
        tags = ["manual"]
    )

_apply_override = rule (
    implementation = _apply_override_impl,
    attrs = {
        '_override': attr.label(
            default = "@override//:override.json",
            allow_single_file = True,
        )
    },
    executable = True,
)

_rm_override = rule (
    implementation = _rm_override_impl,
    attrs = {
        '_override': attr.label(
            default = "@override//:override.json",
            allow_single_file = True,
        )
    },
    executable = True,
)

_show_repos = rule(
    implementation = _show_repos_impl,
)
