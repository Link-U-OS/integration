package(default_visibility = ["//visibility:public"])

cc_library(
    name = "pybind11",
    hdrs = glob(
        [
            "include/**/*.h",
            "include/**/*.hpp",
        ],
    ),
    includes = [
        "include",
        "include/pybind11",
    ],
    deps = ["@rules_python//python/cc:current_py_cc_headers"],
)
