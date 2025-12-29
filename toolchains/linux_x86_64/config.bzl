# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

cfg = struct(
    # Should be in the form "@depenedency"
    toolchain_location = "@integration//toolchains/linux_x86_64/cc",
    # The folder relative to the binary root where all the compiler
    # dependencies are located. It is possible to use wildcards.
    # It can be useful to include the minimum number of directories
    # required for a compilation.
    # e.g: ["bin/**", "libs/**"]
    compiler_deps = ["extra_tools/**"],
    # The CPU is usually aarch64 or x86_64
    # A list can be found here:
    # https://github.com/bazelbuild/platforms/blob/main/cpu/BUILD
    # The CPU we build on.
    exec_cpu = "x86_64",
    # The CPU we wish to execute binaries on.
    target_cpu = "x86_64",
    # Set to gcc or clang.
    compiler = "gcc",
    # The OS is usually linux or qnx.
    # https://github.com/bazelbuild/platforms/blob/main/os/BUILD
    os = "linux",
    # Give this a name such as:
    # linux_gnu_x86
    toolchain_identifier = "local",
    # Paths can be absolute if installed locally or relative to the package.
    tool_paths = {
        "ar": "/usr/bin/ar",
        "ld": "/usr/bin/ld",
        "llvm-cov": "None",
        "cpp": "/usr/bin/cpp",
        "gcc": "/usr/bin/gcc",
        "g++": "/usr/bin/g++",
        "dwp": "/usr/bin/dwp",
        "gcov": "/usr/bin/gcov",
        "nm": "/usr/bin/nm",
        "objcopy": "/usr/bin/objcopy",
        "objdump": "/usr/bin/objdump",
        "strip": "/usr/bin/strip",
    },
    # Try to generate the includes, glibc and target_system by executing:
    # bazel run //toolchains/linux_x86_64/local:gen-info
    # What directories the toolchain includes.
    cxx_builtin_include_directories = [
        "/usr/lib/gcc/x86_64-linux-gnu/13/include",
        "/usr/local/include",
        "/usr/lib/gcc/x86_64-linux-gnu/13/include-fixed",
        "/usr/include/x86_64-linux-gnu",
        "/usr/include",
        "/usr/include/c++/13",
        "/usr/include/x86_64-linux-gnu/c++/13",
        "/usr/include/c++/13/backward",
    ],
    # glibc version
    glibc = "local",
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
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    # Triplet name of what machine the code will build on.
    host_system_name = "local",
    # Triplet name of what machine the binary will execute on.
    target_system_name = "local",
    # The following flags will likely not change.
    # Please read through and check them first.
    family = "linux_x86_64",
    version = "local",
    # What CPU processor type is used. Generally k8.
    proc = "k8",
    compile_flags = [
        "-U_FORTIFY_SOURCE",
        "-fstack-protector",
        "-Wall",
        "-Wunused-but-set-parameter",
        "-Wno-free-nonheap-object",
        "-fno-omit-frame-pointer",
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
        # "-fuse-ld=gold",
        "-Wl,-z,relro,-z,now",
        "-B/usr/bin",
        "-pass-exit-codes",
    ],
    link_libs = [
        "-lstdc++",
        "-lm",
    ],
    opt_link_flags = ["-Wl,--gc-sections"],
    unfiltered_compile_flags = [
        "-fno-canonical-system-headers",
        "-Wno-builtin-macro-redefined",
        "-D__DATE__=\"redacted\"",
        "-D__TIMESTAMP__=\"redacted\"",
        "-D__TIME__=\"redacted\"",
    ],
    # --coverage
    # This option is used to compile and link code instrumented for coverage analysis.
    # The option is a synonym for -fprofile-arcs -ftest-coverage (when compiling) and -lgcov (when linking).
    coverage_compile_flags = ["--coverage"],
    coverage_link_flags = ["--coverage"],
    supports_start_end_lib = False,
)
