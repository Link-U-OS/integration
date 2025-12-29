package(default_visibility = ["//visibility:public"])

cc_library(
    name = "nvbufsurftransform",
    hdrs = [
        "nvbufsurface.h",
        "nvbufsurftransform.h",
    ],
    includes = [
    ],
    linkopts = [
        "-L/opt/nvidia/orin_sysroot/usr/lib/aarch64-linux-gnu/nvidia",
        "-lnvbufsurface",
        "-lnvbufsurftransform",
    ],
)
