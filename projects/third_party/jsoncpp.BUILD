package(default_visibility = ["//visibility:public"])

cc_library(
    name = "jsoncpp",
    srcs = glob([
        "src/lib_json/*.cpp",
        "src/lib_json/*.inl",
        "src/lib_json/*.h",
    ]),
    hdrs = glob([
        "include/json/*.h",
    ]),
    includes = ["include"],
)

