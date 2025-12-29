package(default_visibility = ["//visibility:public"])

cc_library(
    name = "minizip",
    srcs = [
        "contrib/minizip/ioapi.c",
        "contrib/minizip/unzip.c",
        "contrib/minizip/zip.c",
    ] + glob([
        "*.c",
    ]),
    hdrs = [
        "contrib/minizip/ioapi.h",
        "contrib/minizip/unzip.h",
        "contrib/minizip/zip.h",
        "contrib/minizip/crypt.h",
    ] + glob([
        "*.h",
    ]),
    includes = [
        ".",
        "contrib/minizip",
    ],
)
