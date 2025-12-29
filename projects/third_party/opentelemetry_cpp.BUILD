package(default_visibility = ["//visibility:public"])

cc_library(
    name = "opentelemetry_cpp",
    srcs = glob([
        "lib/*.so",
    ]),
    hdrs = glob([
        "include/opentelemetry/**/*.h",
    ]),
    includes = [
        "include",
        "include/opentelemetry",
    ],
    strip_include_prefix = "include",
)
