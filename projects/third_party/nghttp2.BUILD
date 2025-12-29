package(default_visibility = ["//visibility:public"])

cc_library(
    name = "nghttp2",
    srcs = [
        "lib/libnghttp2.so",
        "lib/libnghttp2.so.14",
        "lib/libnghttp2.so.14.28.1",   
    ],
    hdrs = glob([
        "include/nghttp2/*.h",
    ]),
    includes = ["include"],
)
