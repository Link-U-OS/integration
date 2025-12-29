package(default_visibility = ["//visibility:public"])
load("@rules_cc//cc:defs.bzl", "cc_library")
cc_library(
    name = "zip",
    srcs = glob(["lib/libzip.so.*"]),
    strip_include_prefix = "include",
    hdrs = glob(["include/*.h"]),
)
