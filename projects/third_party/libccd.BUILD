package(default_visibility = ["//visibility:public"])

cc_library(
    name = "ccd",
    srcs = [
        "src/alloc.h",
        "src/ccd.c",
        "src/dbg.h",
        "src/list.h",
        "src/mpr.c",
        "src/polytope.c",
        "src/polytope.h",
        "src/simplex.h",
        "src/support.c",
        "src/support.h",
        "src/vec3.c",
    ],
    hdrs = [
        "src/ccd/ccd.h",
        "src/ccd/ccd_export.h",
        "src/ccd/compiler.h",
        "src/ccd/quat.h",
        "src/ccd/vec3.h",
    ],
    copts = [
        "-Wall",
        "-pedantic",
        "-Wfloat-equal",
        "-Wshadow",
        "-DLINUX",
        "-DCCD_DOUBLE",
    ],
    includes = ["."],
    local_defines = [],
    strip_include_prefix = ".",
)
