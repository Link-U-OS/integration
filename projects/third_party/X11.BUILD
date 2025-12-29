package(default_visibility = ["//visibility:public"])

cc_library(
    name = "X11",
    hdrs = glob([
        "X11/*.h",
        "X11/**/*.h",
        "xf86*.h",
        "drm/*.h",
        "linux/v4l2-*.h",
        "linux/video*.h",
    ]),
    includes = [
        "X11",
        ".",
        "drm",
        "linux",
    ],
    linkopts = [
        "-L/opt/nvidia/orin_sysroot/usr/lib/aarch64-linux-gnu",
        "-lX11",
        "-lv4l2"
    ],
)