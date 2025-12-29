package(default_visibility = ["//visibility:public"])

cc_library(
    name = "fastrtps",
    srcs = glob([
        "lib/*so*",
    ]),
    hdrs = glob([
        "include/**/*.h",
        "include/**/*.hpp",
    ]),
    includes = [
        "include",
        "include/dds",
        "include/fastdds",
        "include/fastrtps",
    ],
    deps = [
        "@integration//:fastcdr",
        "@tinyxml2",
    ],
)