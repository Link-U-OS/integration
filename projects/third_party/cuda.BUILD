package(default_visibility = ["//visibility:public"])

cc_library(
    name = "cuda",
    srcs = glob([
        # Not packaged, depends on cuda libraries in orin environment, remember to export LD_LIBRARY_PATH
    ]),
    hdrs = glob([
        "include/**",
    ]),
    includes = ["include"],
    linkopts = select({
        "@integration//toolchains/platforms:is_aarch64": [
            "-L/opt/nvidia/orin_sysroot/usr/local/cuda-12.2/lib64",
            "-L/opt/nvidia/orin_sysroot/usr/local/cuda-12.2/lib64/stubs",
        ],
    }) + [
       "-lcudart",
        "-lcublas",
        "-lcuda",
        "-lnvidia-ml",
        "-lnppig",
        "-lnppif",
        "-lnppial",
        "-lnppc",
        "-lnppicc",
        "-lnppim",
        "-lnppidei",
        "-lnppisu",
        "-lnppitc",
        "-lnvToolsExt",
    ],
)
