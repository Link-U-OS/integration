# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

load(
    "@com_github_mvukov_rules_ros2//ros2:interfaces.bzl",
    "cpp_ros2_interface_library",
    "ros2_interface_library",
)
load("@com_github_mvukov_rules_ros2//ros2:cc_defs.bzl", "ros2_cpp_library")
load("@integration//rules/rpc:ros2_rpc.bzl", "aimrt_cc_ros2_rpc")
load("@integration//rules/type_support:ros2_type_support.bzl", "aimrte_cc_ros2_type_support")
load("@bazel_skylib//rules:copy_file.bzl", "copy_file")

def get_msg_srv_name(msg_srv_path):
    msg_srv_file = msg_srv_path.split(":")[-1]
    msg_srv_name = msg_srv_file.split(".")[0]
    return msg_srv_name

def ros_utils(
        name,
        deps,
        interface_name,
        msgs = [],
        type_support_name = "",
        srv = "",
        only_aimrt_rpc = False):
    for msg in msgs:
        msg_name = get_msg_srv_name(msg)
        copy_file(
            name = msg_name + "_msg_copy",
            src = msg,
            out = msg_name + ".msg",
        )

    if srv:
        srv_name = get_msg_srv_name(srv)
        copy_file(
            name = srv_name + "_srv_copy",
            src = srv,
            out = srv_name + ".srv",
        )
        ros2_interface_library(
            name = interface_name,
            srcs = ([":" + msg_name + "_msg_copy" for msg_name in [get_msg_srv_name(msg) for msg in msgs]] if len(msgs) > 0 else []) +
                   [":" + srv_name + "_srv_copy"],
            deps = deps,
        )
    else:
        ros2_interface_library(
            name = interface_name,
            srcs = [":" + msg_name + "_msg_copy" for msg_name in [get_msg_srv_name(msg) for msg in msgs]],
            deps = deps,
        )

    cpp_ros2_interface_library(
        name = interface_name + "_cc_interface",
        deps = [":" + interface_name],
    )

    ros2_cpp_library(
        name = interface_name + "_lib",
        srcs = [],
        deps = [":" + interface_name + "_cc_interface", "@ros2_rclcpp//:rclcpp"],
    )

    if srv:
        aimrt_cc_ros2_rpc(
            name = "aimrt_" + interface_name + "_rpc",
            pkg_name = interface_name,
            plugin_path = "@integration//:aimrt_ros2_py_gen_aimrt_cpp_rpc",
            srv = ":" + srv_name + "_srv_copy",
            deps = [":" + interface_name + "_lib"],
        )

        if not only_aimrt_rpc:
            aimrt_cc_ros2_rpc(
                name = interface_name + "_rpc",
                pkg_name = interface_name,
                plugin_name = "aimrte_rpc",
                plugin_path = "@integration//rules/codegen:ros2_protocol_gen_aimrte_rpc",
                srv = ":" + srv_name + "_srv_copy",
                deps = [
                    "//src/ctx",
                    ":aimrt_" + interface_name + "_rpc",
                ],
            )
    if len(msgs) > 0 and not only_aimrt_rpc:
        aimrte_cc_ros2_type_support(
            name = type_support_name + "_type_support",
            dep_msgs =
                [":" + msg_name + "_msg_copy" for msg_name in [get_msg_srv_name(msg) for msg in msgs]],
            pkg_name = interface_name,
            plugin_path = "@integration//rules/codegen:protoc_plugin_gen_aimrt_cc_type_support_ros2",
            deps = [":" + interface_name + "_cc_interface"],
        )
