package(default_visibility = ["//visibility:public"])

cc_library(
    name = "eigen_stl_containers",
    hdrs = glob([
        "include/**/*.h",
    ]),
    includes = [
        "include",
        "include/eigen_stl_containers",
    ],
    deps = [
        "@integration//:eigen",
    ],
)
