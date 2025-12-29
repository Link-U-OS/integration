package(default_visibility = ["//visibility:public"])

cc_library(
    name = "vpi",
    srcs = glob([
    ]),
    hdrs = glob([
        "vpi/**/*.h",
        "vpi/**/*.hpp",
    ]),
    includes = [
        ".",
        "vpi",
        "vpi/algo",
        "vpi/detail",
        "vpi/experimental",
    ],
    linkopts = [
        "-L/opt/nvidia/orin_sysroot/usr/lib/aarch64-linux-gnu",
        "-lnvvpi",
    ],
)