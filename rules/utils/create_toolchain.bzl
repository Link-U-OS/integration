# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

_template_init_script = """#!/bin/bash

set -e
set -x

# Create template script.
# Take in two arguments for the family and version.

if [ "$#" -ne 2 ]; then
    echo "Expecting two arguments"
    echo "bazel run //rules/utils:init-toolchain intel dcp <family> <version>"
    exit -1
fi

family="$1"
version="$2"
dir="toolchains/$family/$version"

# Break the sandbox and find where this script is being called from.
workspace=$(readlink WORKSPACE)
cd "$(dirname $workspace)"
mkdir -p "$dir"
mkdir -p "$dir"/cc
mkdir -p "$dir"/config

cat > "$dir"/cc/BUILD << EOF
package(default_visibility = ["//visibility:public"])

exports_files(["toolchain.BUILD", "builtin_include_directory_paths"])
EOF

cat > "$dir"/cc/builtin_include_directory_paths << EOF
EOF

cat > "$dir"/BUILD << EOF
package(default_visibility = ['//visibility:public'])

load(":config.bzl", "cfg")
load("@integration//rules/utils:create_toolchain.bzl", "generate_info")

# Attempts to generate some toolchain information.
generate_info(
    name = "gen-info",
    family = cfg.family,
    version = cfg.version,
    compiler_deps = cfg.toolchain_location + "//:compiler_deps",
    tool_paths = cfg.tool_paths,
    os = cfg.os,
    exec_cpu = cfg.exec_cpu,
    target_cpu = cfg.target_cpu,
    compiler_name = cfg.compiler,
)

EOF

cat > "$dir"/config.bzl << EOF
cfg = struct(
    # Should be in the form "@depenedency"
    toolchain_location = "",
    # The folder relative to the binary root where all the compiler
    # dependencies are located. It is possible to use wildcards.
    # It can be useful to include the minimum number of directories
    # required for a compilation.
    # e.g: ["bin/**", "libs/**"]
    compiler_deps = ["**/**"],
    # The CPU is usually aarch64 or x86_64
    # A list can be found here:
    # https://github.com/bazelbuild/platforms/blob/main/cpu/BUILD
    # The CPU we build on.
    exec_cpu = "",
    # The CPU we wish to execute binaries on.
    target_cpu = "",
    # Set to gcc or clang.
    compiler  = "",
    # The OS is usually linux or qnx.
    # https://github.com/bazelbuild/platforms/blob/main/os/BUILD
    os = "",
    # Give this a name such as:
    # linux_gnu_x86
    # linux_xilinx_aarch64
    # qnx_x86
    toolchain_identifier  = "",
    # Paths can be absolute if installed locally or relative to the package.
    tool_paths = {
        "ar": "/bin/false",
        "as": "/bin/false",
        "ld": "/bin/false",
        "llvm-cov": "/bin/false",
        "cpp": "/bin/false",
        # Even if the tool is clang, bazel requires us to call it gcc.
        "gcc": "",
        "dwp": "/bin/false",
        "gcov": "/bin/false",
        "nm": "/bin/false",
        "objcopy": "/bin/false",
        "objdump": "/bin/false",
        "strip": "/bin/false"
    },
    # Try to generate the includes, glibc and target_system by executing:
    # bazel run //toolchains/$family/$version:gen-info
    # What directories the toolchain includes.
    cxx_builtin_include_directories  = [
    ],
    # glibc version
    glibc = "",
    # Platforms
    # https://docs.bazel.build/versions/main/platforms.html
    # https://github.com/bazelbuild/platforms
    # What platform the build will execute with.
    exec_compatible_with = [
    ],
    # What platform the binaries produced will execute on.
    target_compatible_with = [
    ],
    # Triplet name of what machine the code will build on.
    host_system_name = "",
    # Triplet name of what machine the binary will execute on.
    target_system_name = "",
    # The following flags will likely not change.
    # Please read through and check them first.
    family = "$1",
    version = "$2",
    # What CPU processor type is used. Generally k8.
    proc  = "k8",
    compile_flags = [
        "-U_FORTIFY_SOURCE",
        "-fstack-protector",
        "-Wall",
        "-Wthread-safety",
        "-Wself-assign",
        "-fcolor-diagnostics",
        "-fno-omit-frame-pointer"
    ],
    opt_compile_flags =[
        "-g0",
        "-O2",
        "-D_FORTIFY_SOURCE=1",
        "-DNDEBUG",
        "-ffunction-sections",
        "-fdata-sections"
    ],
    dbg_compile_flags = [
        "-g"
    ],
    cxx_flags = ["-std=c++0x"],
    link_flags = [
        "-fuse-ld=/usr/bin/ld.gold",
        "-Wl,-no-as-needed",
        "-Wl,-z,relro,-z,now",
        "-B/usr/local/bin"
    ],
    link_libs = [
        "-lstdc++",
        "-lm"
    ],
    opt_link_flags = ["-Wl,--gc-sections"],
    unfiltered_compile_flags  = [
        "-no-canonical-prefixes",
        "-Wno-builtin-macro-redefined",
        "-D__DATE__=\\"redacted\\"",
        "-D__TIMESTAMP__=\\"redacted\\"",
        "-D__TIME__=\\"redacted\\""
    ],
    coverage_compile_flags  = ["--coverage"],
    coverage_link_flags  = ["--coverage"],
    supports_start_end_lib = True,
)

EOF

cat > "$dir"/config/BUILD << EOF
load("@integration//toolchains/$family/$version:config.bzl", "cfg")

package(default_visibility = ["//visibility:public"])

toolchain(
    name = "cc-toolchain",
    exec_compatible_with = cfg.exec_compatible_with,
    target_compatible_with = cfg.target_compatible_with,
    toolchain = cfg.toolchain_location + "//:cc-toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

platform(
    name = "host_platform",
    constraint_values = cfg.exec_compatible_with,
    exec_properties = {
    },
)

platform(
    name = "target_platform",
    constraint_values = cfg.target_compatible_with,
    exec_properties = {
    },
)

constraint_setting(name = "sdk")

constraint_value(
    name = "$family-$version",
    constraint_setting = ":sdk",
)

EOF

cat > "$dir"/cc/toolchain.BUILD << EOF
package(default_visibility = ["//visibility:public"])

load("@integration//toolchains/$family/$version:config.bzl", "cfg")
load("@integration//toolchains:cc_toolchain_config.bzl", "cc_toolchain_config")
load("@rules_cc//cc:defs.bzl", "cc_toolchain", "cc_toolchain_suite")

licenses(["notice"])  # Apache 2.0

cc_library(
    name = "malloc",
)

filegroup(
    name = "empty",
    srcs = [],
)

filegroup(
    name = "compiler_deps",
    srcs = glob(cfg.compiler_deps, allow_empty = True) + ["@integration//toolchains/$family/$version/cc:builtin_include_directory_paths"],
)

cc_toolchain(
    name = "cc-toolchain",
    toolchain_identifier = cfg.toolchain_identifier,
    toolchain_config = ":toolchain-config",
    all_files = ":compiler_deps",
    ar_files = ":compiler_deps",
    as_files = ":compiler_deps",
    compiler_files = ":compiler_deps",
    dwp_files = ":empty",
    linker_files = ":compiler_deps",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 1,
    # module_map = ":module.modulemap",
)

cc_toolchain_config(
    name = "toolchain-config",
    cpu = cfg.proc,
    compiler = cfg.compiler,
    toolchain_identifier = cfg.toolchain_identifier,
    host_system_name = cfg.host_system_name,
    target_system_name = cfg.target_system_name,
    target_libc = cfg.glibc,
    abi_version = cfg.compiler,
    abi_libc_version = cfg.glibc,
    cxx_builtin_include_directories = cfg.cxx_builtin_include_directories,
    tool_paths = cfg.tool_paths,
    compile_flags = cfg.compile_flags,
    dbg_compile_flags = cfg.dbg_compile_flags,
    cxx_flags = cfg.cxx_flags,
    link_flags = cfg.link_flags,
    link_libs = cfg.link_libs,
    opt_link_flags = cfg.opt_link_flags,
    unfiltered_compile_flags = cfg.unfiltered_compile_flags,
    coverage_compile_flags = cfg.coverage_compile_flags,
    coverage_link_flags = cfg.coverage_link_flags,
    supports_start_end_lib = cfg.supports_start_end_lib,
)

EOF

cat > "$dir"/toolchain.bazelrc << EOF
# These are basic settings for Bazel to use the toolchain.
# There may be additional settings needed.
build:$family-$version --incompatible_enable_cc_toolchain_resolution
build:$family-$version --action_env=BAZEL_DO_NOT_DETECT_CPP_TOOLCHAIN=1
build:$family-$version --extra_toolchains=@integration//toolchains/$family/$version/config:cc-toolchain
build:$family-$version --platforms=@integration//toolchains/$family/$version/config:target_platform
build:$family-$version --host_platform=@integration//toolchains/$family/$version/config:host_platform
EOF

echo "Created toolchain files in $dir"

"""

_template_generate_info_script = """#!/bin/bash
set -e

# This script will try to find some defaults for the chosen toolchain.

echo "Tool generating defaults for"
echo "{compiler}"
echo "Please check they are correct."
echo ""

workspace=$(readlink WORKSPACE)
includes="$(dirname $workspace)"/toolchains/{family}/{version}/cc/builtin_include_directory_paths
: > "$includes"

# Bazel only accepts normalised paths.
while read -r line
do
    if [[ "$line" = /* ]]; then
        path=$(realpath "$line")
        echo "$path" >> "$includes"
    else
        path=$(realpath --relative-to=./ "$line")
        echo "$path" >> "$includes"
    fi
done < <({compiler}  -Wp,-v -x c++ - -fsyntax-only < /dev/null 2>&1 |
sed -e '/^#include <...>/,/^End of search/{{ //!b }};d' |
sed 's#.*/external/#external/#' | sed 's/ //')
# Alternate that should have worked...
# echo | {compiler} -xc++ - -E -Wp, -v 2>&1 | sed -n 's,^ ,,p' | sed '1d'

echo "    # What directories the toolchain includes."
echo "    cxx_builtin_include_directories = ["
while read l; do
    echo '        "'"$l"'",'
done <"$includes"
echo "    ],"

cat > main.c << EOF
#include <stdio.h>
#include <stdlib.h>
#include <gnu/libc-version.h>

int main(int argc, char *argv[]) {{
  printf("%s", gnu_get_libc_version());
}}
EOF
{compiler} main.c -o main
# We cannot execute cross-compiled binaries
# Instead we use objdump.
# glib=$(./main)
glib=$({objdump} -T main | grep -oP '(?<=GLIBC_)[0-9.]+' | head -1)
echo "    # glibc version"
echo "    glibc = \\"glibc_$glib\\","


machine=$({compiler} -dumpmachine)
cat << EOF
    # WARNING: For cross compilers, the following may not be generated correctly
    # Triplet name of what machine the code will build on.
    host_system_name = "$machine",
    # Triplet name of what machine the binary will execute on.
    target_system_name = "$machine",
EOF

cat << EOF
    # Platforms
    # https://docs.bazel.build/versions/main/platforms.html
    # https://github.com/bazelbuild/platforms
    # What platform the build will execute with.
    exec_compatible_with = [
        "@platforms//os:{os}",
        "@platforms//cpu:{exec_cpu}",
        "@bazel_tools//tools/cpp:{compiler_name}",
        "@integration//toolchains/{family}/{version}/config:{family}-{version}"
    ],
EOF

cat << EOF
    # What platform the binaries produced will execute on.
    target_compatible_with = [
        "@platforms//os:{os}",
        "@platforms//cpu:{target_cpu}",
        "@integration//toolchains/{family}/{version}/config:{family}-{version}"
    ],
EOF
"""

def _init_new_toolchain_impl(ctx):
    script = ctx.actions.declare_file(ctx.attr.name)
    ctx.actions.write(
        output = script,
        content = _template_init_script
    )

    return DefaultInfo(
        files = depset([script]),
        executable = script
    )

def init_new_toolchain(name):
    script_name = name + "-script"
    _init_new_toolchain(
        name = script_name,
        tags = ["manual"],
    )

    native.sh_binary(
        name = name,
        srcs = [script_name],
        data = ["//:WORKSPACE"],
        tags = ["manual"]
    )

_init_new_toolchain = rule (
    implementation = _init_new_toolchain_impl,
    attrs = {},
    executable = True
)

def _generate_info_impl(ctx):
    script = ctx.actions.declare_file(ctx.attr.name)
    compiler = ctx.attr.tool_paths["gcc"]
    if not compiler:
        fail("Did you forget to define the tool_paths?")
    if not compiler.startswith("/"):
        compiler = "{}/{}".format(
            ctx.attr.compiler_deps.label.workspace_root,
            compiler,
        )
    objdump = ctx.attr.tool_paths["objdump"]
    if not objdump:
        fail("Did you forget to define the tool_paths?")
    if not objdump.startswith("/"):
        objdump = "{}/{}".format(
            ctx.attr.compiler_deps.label.workspace_root,
            objdump,
        )
    ctx.actions.write(
        output = script,
        content = _template_generate_info_script.format(
            family = ctx.attr.family,
            version = ctx.attr.version,
            compiler = compiler,
            objdump = objdump,
            os = ctx.attr.os,
            exec_cpu = ctx.attr.exec_cpu,
            target_cpu = ctx.attr.target_cpu,
            compiler_name = ctx.attr.compiler_name,
        )
    )
    return DefaultInfo(
        files = depset([script]),
        executable = script
    )

def generate_info(
    name,
    family,
    version,
    compiler_deps,
    tool_paths,
    os,
    exec_cpu,
    target_cpu,
    compiler_name):
    script_name = name + "-script"
    _generate_info(
        name = script_name,
        family = family,
        version = version,
        compiler_deps = compiler_deps,
        tool_paths = tool_paths,
        os = os,
        exec_cpu = exec_cpu,
        target_cpu = target_cpu,
        compiler_name = compiler_name,
        tags = ["manual"],
    )

    native.sh_binary(
        name = name,
        srcs = [script_name],
        data = [compiler_deps, "//:WORKSPACE"],
        tags = ["manual"]
    )

_generate_info = rule (
    implementation = _generate_info_impl,
    attrs = {
        "family": attr.string(
            mandatory=True,
        ),
        "version": attr.string(
            mandatory=True,
        ),
        "compiler_deps": attr.label(
            mandatory = True,
        ),
        "tool_paths": attr.string_dict(
            mandatory = True,
        ),
        "os": attr.string(
            mandatory = True,
        ),
        "exec_cpu": attr.string(
            mandatory = True,
        ),
        "target_cpu": attr.string(
            mandatory = True,
        ),
        "compiler_name": attr.string(
            mandatory = True,
        )
    },
    executable = True
)
