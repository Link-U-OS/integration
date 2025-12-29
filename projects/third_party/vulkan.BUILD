package(default_visibility = ["//visibility:public"])

cc_library(
    name = "vulkan",
    srcs = glob([
    ]),
    hdrs = glob([
        "vulkan/**/*.h",
        "vulkan/**/*.hpp",
    ]),
    includes = [
        "vulkan",
    ],
    linkopts = [
        "-L/opt/nvidia/orin_sysroot/usr/lib/aarch64-linux-gnu ",
        "-lvulkan",
    ],
)
