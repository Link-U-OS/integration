package(default_visibility = ["//visibility:public"])

cc_library(
    name = "cudnn",
    srcs = glob([
        # Not packaged, depends on cuda libraries in orin environment, remember to export LD_LIBRARY_PATH
    ]),
    hdrs = glob([
        "cudnn*.h",
        "cudnn*.hpp",
    ]),
    linkopts = select({
        "@integration//toolchains/platforms:is_aarch64": [
            "-L/opt/nvidia/orin_sysroot/usr/lib/aarch64-linux-gnu",
        ],
        "//conditions:default": [
            "-L/usr/local/cudnn/lib",
        ],
    }) + [
        "-lcudnn_adv_infer",
        "-lcudnn_adv_train",
        "-lcudnn_cnn_infer",
        "-lcudnn_cnn_train",
        "-lcudnn_ops_infer",
        "-lcudnn_ops_train",
        "-lcudnn",
    ],
)
