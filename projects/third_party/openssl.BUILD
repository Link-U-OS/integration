package(default_visibility = ["//visibility:public"])

cc_library(
    name = "openssl",
    srcs = glob([
        "lib/**/*.so*",
    ]),
    hdrs = glob([
        "include/**/*.h",
    ]),
    includes = [
        "include",
        "include/openssl",
    ],
)
