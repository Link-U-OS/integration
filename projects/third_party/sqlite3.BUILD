package(default_visibility = ["//visibility:public"])

cc_library(
    name = "sqlite3",
    hdrs = [
        "sqlite3.h",
        "sqlite3ext.h",
    ],
    linkopts = select({
        "@integration//toolchains/platforms:is_aarch64": [
            "-L/opt/nvidia/orin_sysroot/usr/lib/aarch64-linux-gnu",
        ],
        "//conditions:default": [
            "-L/usr/lib/x86_64-linux-gnu",
        ],
    }) + [
        "-lsqlite3",
    ],
)
