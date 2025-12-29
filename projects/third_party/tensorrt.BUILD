package(default_visibility = ["//visibility:public"])

cc_library(
    name = "tensorrt",
    srcs = glob([
        # Not packaged, depends on cuda libraries in orin environment, remember to export LD_LIBRARY_PATH
    ]),
    hdrs = glob([
        "**/*.h",
        "**/*.hpp",
    ]),
    includes = select({
        "@integration//toolchains/platforms:is_aarch64": [
            "aarch64-linux-gnu",
            ".",
        ],
        "//conditions:default": [
            ".",
        ],
    }),
    linkopts = select({
        "@integration//toolchains/platforms:is_aarch64": [
            "-L/opt/nvidia/orin_sysroot/usr/lib/aarch64-linux-gnu",
        ],
        "//conditions:default": [
            "-L/usr/local/tensorrt/lib",
        ],
    }) + [
        "-lnvonnxparser",
        "-lnvinfer",
        "-lnvparsers",
        "-lnvinfer_plugin",
    ],
)
