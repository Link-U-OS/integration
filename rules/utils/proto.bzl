# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

load("@integration//rules/rpc:protobuf_rpc.bzl", "aimrt_cc_protobuf_rpc")
load("@integration//rules/type_support:protobuf_type_support.bzl", "aimrte_cc_protobuf_type_support")
load("@bazel_skylib//rules:copy_file.bzl", "copy_file")

def get_proto_name(proto_path):
    proto_file = proto_path.split(":")[-1]
    proto_name = proto_file.split(".")[0]
    return proto_name

def protobuf_utils(name, proto, dep_protos, output_proto_name="", type_support_name="", is_rpc = False, rpc_need_type_support = False, only_aimrt_rpc = False):
    proto_name = get_proto_name(proto)
    output_proto_name = output_proto_name or proto_name
    copy_file(
        name = proto_name + "_proto_copy",
        src = proto,
        out = output_proto_name + ".proto",
    )

    native.proto_library(
        name = proto_name + "_proto",
        srcs = [":" + proto_name + "_proto_copy"],
        deps = dep_protos,
    )

    native.cc_proto_library(
        name = proto_name + "_cc_proto",
        deps = [":" + proto_name + "_proto"],
    )

    if is_rpc:
        dep_cc_protos = []
        for dep in dep_protos:
            dep_name = get_proto_name(dep)
            dep_cc_protos.append(dep.replace("_proto", "_cc_proto"))

        native.cc_library(
            name = proto_name + "_lib",
            srcs = [":" + proto_name + "_cc_proto"],
            hdrs = [":" + proto_name + "_cc_proto"],
            deps = dep_cc_protos + [":" + proto_name + "_cc_proto", "@integration//:protobuf"],
        )

        aimrt_cc_protobuf_rpc(
            name = "aimrt_" + proto_name + "_rpc",
            dep_protos = dep_protos + [":" + proto_name + "_proto"],
            plugin_path = "@integration//:aimrt_protoc_plugin_cpp_gen_aimrt_cpp_rpc",
            proto = ":" + output_proto_name + ".proto",
            deps = [":" + proto_name + "_lib"],
        )

        if not only_aimrt_rpc:
            aimrt_cc_protobuf_rpc(
                name = proto_name + "_rpc",
                plugin_name = "aimrte_rpc",
                plugin_path = "@integration//rules/codegen:protoc_plugin_gen_aimrte_rpc",
                proto = ":" + output_proto_name + ".proto",
                deps = [
                    "//src/ctx",
                    ":aimrt_" + proto_name + "_rpc",
                ],
                dep_protos = dep_protos + [":" + proto_name + "_proto"],
            )

    if type_support_name:
        if (is_rpc and rpc_need_type_support) or not is_rpc:
            aimrte_cc_protobuf_type_support(
                name = type_support_name + "_type_support",
                plugin_path = "@integration//rules/codegen:protoc_plugin_gen_aimrt_cc_type_support",
                proto = ":" + output_proto_name + ".proto",
                deps = [":" + proto_name + "_cc_proto"],
                dep_protos = dep_protos,
            )
