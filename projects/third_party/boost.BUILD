package(default_visibility = ["//visibility:public"])

licenses(["notice"])

cc_library(
    name = "boost",
    srcs = glob(
        include = [
            "lib/*.so*",
        ],
        exclude = [
            "lib/libboost_python*.so*",
            "lib/*test*",
        ],
    ),
    hdrs = glob(
        include = [
            "include/boost/**/*.hpp",
            "include/boost/**/*.h",
            "include/boost/**/*.ipp",
        ],
    ),
    includes = ["include"],
)
