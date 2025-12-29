package(default_visibility = ["//visibility:public"])

cc_library(
    name = "elfutils",
    srcs = glob([
        "lib/*.so*",
    ]),
    hdrs = glob([
        "include/**/*.h",
    ]),
    includes = [
        "include",
        "include/elfutils",
    ],
    deps = [
        "@integration//:xz",
        "@integration//:zstd",
        "@zlib"
    ],
)
