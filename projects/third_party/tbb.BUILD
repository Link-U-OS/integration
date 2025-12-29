package(
    default_visibility = ["//visibility:public"],
)

cc_library(
    name = "tbb",
    srcs = glob([
        "src/tbb/*.cpp",
        "src/tbb/*.h",
    ]) + select({
        "@platforms//cpu:x86_64": glob(["src/tbb/tools_api/**/*.h"]),
        "//conditions:default": [],
    }),
    hdrs = glob([
        "include/tbb/*.h",
        "include/oneapi/*.h",
        "include/oneapi/tbb/*.h",
        "include/oneapi/tbb/detail/*.h",
    ]),
    copts = ["-w"] + select({
        "@integration//toolchains/platforms:is_aarch64": [""],
        "//conditions:default": ["-mwaitpkg"],
    }),
    defines =
        select({
            "@platforms//cpu:x86_64": ["__TBB_NO_IMPLICIT_LINKAGE"],
            "//conditions:default": [
                "USE_PTHREAD",
            ],
        }),
    includes = [
        "include",
    ],
    linkopts =
        select({
            "@platforms//os:linux": [
                "-ldl",
                "-pthread",
                "-lrt",
            ],
        }),
    local_defines = select({
        "@platforms//cpu:x86_64": [
            "__TBB_USE_ITT_NOTIFY",
        ],
        "//conditions:default": [],
    }) + [
        "__TBB_BUILD",
    ],
    textual_hdrs = select({
        "@platforms//cpu:x86_64": [
            "src/tbb/tools_api/ittnotify_static.c",
        ],
        "//conditions:default": [],
    }),
    deps = [
        ":tbbmalloc",
    ],
)

cc_library(
    name = "tbbmalloc",
    srcs =
        glob([
            "src/tbbmalloc/*.h",
            "src/tbb/*.h",
            "src/tbbmalloc_proxy/*.h",
        ]) + [
            "src/tbbmalloc/backend.cpp",
            "src/tbbmalloc/backref.cpp",
            "src/tbbmalloc/frontend.cpp",
            "src/tbbmalloc/large_objects.cpp",
            "src/tbbmalloc/tbbmalloc.cpp",
        ],
    hdrs = glob([
        "include/tbb/*.h",
        "include/oneapi/tbb/detail/*.h",
        "include/oneapi/tbb/*.h",
    ]),
    includes = [
        "include",
    ],
    local_defines = [
        "__TBBMALLOC_BUILD",
    ],
)

cc_library(
    name = "tbbmalloc_proxy",
    srcs = [
        "src/tbbmalloc_proxy/function_replacement.cpp",
        "src/tbbmalloc_proxy/proxy.cpp",
    ],
    deps = [
        ":tbbmalloc",
    ],
)

