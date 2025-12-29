package(default_visibility = ["//visibility:public"])

common_hdrs = glob([
    "include/librealsense2/**/*.h",
    "include/librealsense2/**/*.hpp",
])

common_srcs = glob([
    "lib/*.so*",
])

common_includes = [
    "include",
    "include/librealsense2",
]

cc_library(
    name = "realsense2",
    srcs = common_srcs,
    hdrs = common_hdrs,
    includes = common_includes,

)

cc_library(
    name = "realsense2_rsusb",
    srcs = common_srcs,
    hdrs = common_hdrs,
    includes = common_includes,
    linkopts = [
        "-l:librealsense2_rsusb.so",
    ],
)

