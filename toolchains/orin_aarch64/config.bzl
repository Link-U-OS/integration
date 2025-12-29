# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

cfg = struct(
    # Should be in the form "@depenedency"
    toolchain_location = "@orin_aarch64_sdk",
    # The folder relative to the binary root where all the compiler
    # dependencies are located. It is possible to use wildcards.
    # It can be useful to include the minimum number of directories
    # required for a compilation.
    # e.g: ["bin/**", "libs/**"]
    compiler_deps = ["**/**", "!usr/**"],
    # The CPU is usually aarch64 or x86_64
    # A list can be found here:
    # https://github.com/bazelbuild/platforms/blob/main/cpu/BUILD
    # The CPU we build on.
    exec_cpu = "x86_64",
    # The CPU we wish to execute binaries on.
    target_cpu = "aarch64",
    # Set to gcc or clang.
    compiler = "gcc",
    # The OS is usually linux or qnx.
    # https://github.com/bazelbuild/platforms/blob/main/os/BUILD
    os = "linux",
    # Give this a name such as:
    # linux_gnu_x86
    # linux_xilinx_aarch64
    # qnx_x86
    toolchain_identifier = "orin_aarch64_toolchain",
    # Paths can be absolute if installed locally or relative to the package.
    tool_paths = {
        "ar": "bin/aarch64-buildroot-linux-gnu-ar",
        "cpp": "bin/aarch64-buildroot-linux-gnu-cpp",
        "gcc": "bin/aarch64-buildroot-linux-gnu-gcc",
        "g++": "bin/aarch64-buildroot-linux-gnu-g++",
        "gcov": "bin/aarch64-buildroot-linux-gnu-gcov",
        "ld": "bin/aarch64-buildroot-linux-gnu-ld",
        "nm": "bin/aarch64-buildroot-linux-gnu-nm",
        "objcopy": "bin/aarch64-buildroot-linux-gnu-objcopy",
        "objdump": "bin/aarch64-buildroot-linux-gnu-objdump",
        "strip": "bin/aarch64-buildroot-linux-gnu-strip",
        "as": "bin/aarch64-buildroot-linux-gnu-as",
        "dwp": "bin/aarch64-buildroot-linux-gnu-dwp",
        "readelf": "bin/aarch64-buildroot-linux-gnu-readelf",
        "size": "bin/aarch64-buildroot-linux-gnu-size",
        "strings": "bin/aarch64-buildroot-linux-gnu-strings",
        "llvm-cov": "None",
    },
    # Try to generate the includes, glibc and target_system by executing:
    # bazel run //toolchains/aarch64_j5/9.3.0:gen-info
    # What directories the toolchain includes.
    cxx_builtin_include_directories = [
    ],
    # setup sysroot
    builtin_sysroot = "/opt/nvidia/l4t-toolchain/aarch64--glibc--stable-2022.08-1/aarch64-buildroot-linux-gnu/sysroot",
    # glibc version
    glibc = "glibc_2.35",
    # Platforms
    # https://docs.bazel.build/versions/main/platforms.html
    # https://github.com/bazelbuild/platforms
    # What platform the build will execute with.
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    # What platform the binaries produced will execute on.
    target_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:linux",
        "@integration//toolchains/orin_aarch64/config:orin_aarch64",
    ],
    # Triplet name of what machine the code will build on.
    host_system_name = "",
    # Triplet name of what machine the binary will execute on.
    target_system_name = "",
    # The following flags will likely not change.
    # Please read through and check them first.
    family = "orin_aarch64",
    version = "3.0",
    # What CPU processor type is used. Generally k8.
    proc = "k8",
    compile_flags = [
        "-U_FORTIFY_SOURCE",
        "-Wall",
        "-fno-omit-frame-pointer",
        "-fstack-protector",
        "-DAIMRT_USE_FMT_LIB",
    ],
    opt_compile_flags = [
        "-g0",
        "-O2",
        "-D_FORTIFY_SOURCE=1",
        "-DNDEBUG",
        "-ffunction-sections",
        "-fdata-sections",
    ],
    dbg_compile_flags = [
        "-g",
    ],
    cxx_flags = ["-std=c++20"],
    link_flags = [
        "-Wl,-as-needed",
        "-Wl,-z,relro,-z,now",
        "-Wl,--allow-shlib-undefined",
        "-Wl,--build-id",
        "-B/opt/nvidia/l4t-toolchain/aarch64--glibc--stable-2022.08-1/bin",
        "--sysroot=/opt/nvidia/l4t-toolchain/aarch64--glibc--stable-2022.08-1/aarch64-buildroot-linux-gnu/sysroot",
        "-L/opt/nvidia/l4t-toolchain/aarch64--glibc--stable-2022.08-1/aarch64-buildroot-linux-gnu/sysroot/lib",
        "-L/opt/nvidia/l4t-toolchain/aarch64--glibc--stable-2022.08-1/aarch64-buildroot-linux-gnu/sysroot/lib64",
        "-L/opt/nvidia/l4t-toolchain/aarch64--glibc--stable-2022.08-1/aarch64-buildroot-linux-gnu/sysroot/usr/lib",
        "-L/opt/nvidia/l4t-toolchain/aarch64--glibc--stable-2022.08-1/aarch64-buildroot-linux-gnu/sysroot/usr/lib64",
    ],
    link_libs = [
        "-lstdc++",
        "-lm",
        "-lrt",
        "-lpthread",
        "-ldl",
    ],
    opt_link_flags = ["-Wl,--gc-sections"],
    unfiltered_compile_flags = [
        "-no-canonical-prefixes",
        "-Wno-builtin-macro-redefined",
        "-D__DATE__=\"redacted\"",
        "-D__TIMESTAMP__=\"redacted\"",
        "-D__TIME__=\"redacted\"",
    ],
    coverage_compile_flags = ["--coverage"],
    coverage_link_flags = ["--coverage"],
    supports_start_end_lib = False,
)
