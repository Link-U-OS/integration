package(default_visibility = ["//visibility:public"])

cc_library(
    name = "asio",
    hdrs = glob([
        "asio/include/**/*.hpp",
        "asio/include/**/*.ipp",
    ]),
    includes = ["asio/include"],
    defines = [
        "ASIO_STANDALONE",
        "ASIO_NO_DEPRECATED",
    ],
    copts = select({
        "//conditions:default": [],
        "@platforms//os:windows": [
            "/DWIN32_LEAN_AND_MEAN",
            "/D_WIN32_WINNT=0x0600",  # or appropriate Windows version
        ],
    }),
    linkopts = select({
        "//conditions:default": ["-lpthread"],
        "@platforms//os:windows": [],
    }),
)