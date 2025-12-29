package(default_visibility = ["//visibility:public"])

cc_library(
    name = "OrbbecSDK",
    srcs = glob([
        "lib/*so*"
    ]),
    hdrs = glob([
        "include/**/*.h",
        "include/**/*.hpp"
    ]),
    includes = [
        "include",
        "include/libobsensor",
        "include/libobsensor/h",
        "include/libobsensor/hpp",
    ],
)
