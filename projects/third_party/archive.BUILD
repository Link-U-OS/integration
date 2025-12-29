package(default_visibility = ["//visibility:public"])
load("@rules_cc//cc:defs.bzl", "cc_library")

cc_library(
    name = "archive",
    srcs = glob(["lib/*.so*"],exclude=["lib/liblz4.so*"]),
    hdrs = [
        "include/archive.h",
        "include/archive_entry.h",
    ],
    strip_include_prefix = "include",
    copts = ["-DHAVE_CONFIG_H"],
)