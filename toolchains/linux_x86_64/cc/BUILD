package(default_visibility = ["//visibility:public"])

exports_files(["builtin_include_directory_paths"])

load("@integration//toolchains/linux_x86_64:config.bzl", "cfg")
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
    srcs = glob(cfg.compiler_deps, allow_empty = True) + ["@integration//toolchains/linux_x86_64/cc:builtin_include_directory_paths"],
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
    module_map = None,
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
    opt_compile_flags = cfg.opt_compile_flags,
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
