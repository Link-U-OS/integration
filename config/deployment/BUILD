package(default_visibility = ["//visibility:public"])

filegroup(
    name = "deployment_config",
    srcs = select(
        {
            "//conditions:default": glob(["A2_ULTRA/**/*.yaml"]),
        },
    ),
)
