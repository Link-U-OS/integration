package(default_visibility = ['//visibility:public'])

load(":config.bzl", "cfg")
load("@integration//rules/utils:create_toolchain.bzl", "generate_info")

# Attempts to generate some toolchain information.
generate_info(
    name = "gen-info",
    family = cfg.family,
    version = cfg.version,
    compiler_deps = cfg.toolchain_location + ":compiler_deps",
    tool_paths = cfg.tool_paths,
    os = cfg.os,
    exec_cpu = cfg.exec_cpu,
    target_cpu = cfg.target_cpu,
    compiler_name = cfg.compiler,
)

