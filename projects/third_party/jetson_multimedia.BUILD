package(default_visibility = ["//visibility:public"])

cc_library(
    name = "jetson_multimedia",
    srcs = glob([
        "samples/common/classes/*.cpp",
    ]),
    hdrs = glob([
        "include/*.h",
        "include/**/*.h",
    ]),
    includes = [
        "include",
        "include/libjpeg-8b",
    ],
    linkopts = [
        "-lnvbufsurface",
        "-lnvjpeg",
        "-lnvbufsurftransform",
    ],
    deps = [
        "@integration//:X11",
    ],
)