load("@integration//toolchains/orin_aarch64:config.bzl", "cfg")

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
    name = "orin_aarch64",
    constraint_setting = ":sdk",
)

