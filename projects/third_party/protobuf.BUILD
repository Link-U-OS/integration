package(default_visibility = ["//visibility:public"])

cc_library(
    name = "protobuf",
    srcs = glob([
        "lib/*.so*",
    ]),
    copts = [
        "-DGOOGLE_PROTOBUF_NO_RTTI",
    ],
    deps = [
        "@com_google_protobuf_fix//:protobuf",
        "@com_google_protobuf_fix//src/google/protobuf/compiler:code_generator",
        "@com_google_protobuf_fix//src/google/protobuf/json",
        "@com_google_protobuf_fix//src/google/protobuf/util:json_util",
    ],
)
