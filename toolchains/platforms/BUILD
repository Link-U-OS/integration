package(default_visibility = ["//visibility:public"])

# Various configs and constraint values consumed by platforms.
constraint_setting(name = "sdk")

constraint_value(
    name = "orin_aarch64",
    constraint_setting = ":sdk",
)

config_setting(
    name = "is_orin_aarch64",
    constraint_values = [
        "@platforms//cpu:aarch64",
        "@platforms//os:linux",
        "@integration//toolchains/orin_aarch64/config:orin_aarch64",
    ],
    define_values = {
        "orin_aarch64": "true",
    },
)

config_setting(
    name = "is_aarch64",
    constraint_values = [
        "@platforms//cpu:aarch64",
        "@platforms//os:linux",
    ],
)

config_setting(
    name = "is_ut_on",
    values = {
        "define": "ut=on",
    },
)

config_setting(
    name = "is_local_debug_on",
    values = {
        "define": "local_debug=on",
    },
)

config_setting(
    name = "is_debug_mode",
    values = {
        "compilation_mode": "dbg",
    },
)
