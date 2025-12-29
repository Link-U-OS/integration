package(default_visibility = ["//visibility:public"])

cc_library(
    name = "iceoryx",
    srcs = glob(["lib/*.so*"]),
    hdrs = glob([
        "include/**/*.h",
        "include/**/*.hpp",
        "include/**/*.inl",
    ]),
    includes = [
        "include",
        "include/iceoryx",
        "include/iceoryx/v2.95.4",
        "include/iceoryx/v2.95.4/iceoryx_binding_c",
        "include/iceoryx/v2.95.4/iceoryx_hoofs",
        "include/iceoryx/v2.95.4/iceoryx_posh",
        "include/iceoryx/v2.95.4/iceoryx_platform",
        "include/iceoryx/v2.95.4/iox"
    ] + select({
        "@integration//toolchains/platforms:is_aarch64": [ 
        ],
        "//conditions:default": [
            "include/iceoryx/v2.95.4/iceoryx_introspection",
        ],
    }),
)


filegroup(
    name = "iox-roudi",
    srcs = ["bin/iox-roudi"],
)


