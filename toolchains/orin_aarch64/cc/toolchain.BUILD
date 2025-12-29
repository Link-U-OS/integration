package(default_visibility = ["//visibility:public"])

load("@integration//toolchains/orin_aarch64:config.bzl", "cfg")
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
    srcs = glob(
        cfg.compiler_deps,
        allow_empty = True,
    ) + ["@integration//toolchains/orin_aarch64/cc:builtin_include_directory_paths"],
)

cc_toolchain(
    name = "cc-toolchain",
    all_files = ":compiler_deps",
    ar_files = ":compiler_deps",
    as_files = ":compiler_deps",
    compiler_files = ":compiler_deps",
    dwp_files = ":empty",
    linker_files = ":compiler_deps",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 1,
    toolchain_config = ":toolchain-config",
    toolchain_identifier = cfg.toolchain_identifier,
    # module_map = ":module.modulemap",
)

cc_toolchain_config(
    name = "toolchain-config",
    abi_libc_version = cfg.glibc,
    abi_version = cfg.compiler,
    compile_flags = cfg.compile_flags,
    compiler = cfg.compiler,
    coverage_compile_flags = cfg.coverage_compile_flags,
    coverage_link_flags = cfg.coverage_link_flags,
    cpu = cfg.proc,
    cxx_builtin_include_directories = cfg.cxx_builtin_include_directories,
    cxx_flags = cfg.cxx_flags,
    dbg_compile_flags = cfg.dbg_compile_flags,
    host_system_name = cfg.host_system_name,
    link_flags = cfg.link_flags,
    link_libs = cfg.link_libs,
    opt_link_flags = cfg.opt_link_flags,
    supports_start_end_lib = cfg.supports_start_end_lib,
    target_libc = cfg.glibc,
    target_system_name = cfg.target_system_name,
    tool_paths = cfg.tool_paths,
    toolchain_identifier = cfg.toolchain_identifier,
    unfiltered_compile_flags = cfg.unfiltered_compile_flags,
)
