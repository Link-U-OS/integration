package(default_visibility = ["//visibility:public"])

cc_library(
    name = "CURL",
    srcs = [
        "lib/libcurl.so",
    ],
    hdrs = glob([
        "include/curl/*.h",
    ]),
    includes = [
        "include",
        "include/curl",
    ],
    strip_include_prefix = "include",
)
