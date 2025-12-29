# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

# Provider containing information about generated ROS2 type support files
ROS2TypeSupportInfo = provider(fields = ["srcs"])

def aimrte_cc_ros2_type_support(name, dep_msgs, plugin_path, pkg_name, deps = [], copts = []):
    # Add aimrt as a required dependency
    all_deps = deps + [
        "@aimrt//src/interface/aimrt_type_support_pkg_c_interface",
        "@aimrt//src/interface/aimrt_module_ros2_interface",
    ]

    # Generate unique target names for intermediate outputs
    generate_name = "%s_type_support" % name
    name_srcs_cc = "%s_srcs_cc" % name

    # Generate ROS2 type support code using the plugin
    _ros2_type_support(
        name = generate_name,
        dep_msgs = dep_msgs,
        plugin_path = plugin_path,
        pkg_name = pkg_name,
    )

    _cc_package_ros2_type_support_srcs(
        name = name_srcs_cc,
        srcs = [generate_name],
        field = "srcs",
    )

    native.cc_binary(
        name = name,
        srcs = [name_srcs_cc],
        deps = all_deps,
        copts = copts,
        linkshared = True,
    )

def _ros2_type_support_impl(ctx):
    # Get required tools and inputs
    plugin = ctx.executable.plugin_path
    dep_msgs = ctx.files.dep_msgs
    pkg_name = ctx.attr.pkg_name

    # Setup output file paths
    type_support_pkg_main_file = ctx.actions.declare_file("{}/type_support/type_support_main.cpp".format(pkg_name))

    # Track generated files
    output_srcs = [type_support_pkg_main_file]

    # Build protoc command arguments
    args = []
    args.append("--pkg_name={}".format(pkg_name))
    args.append("--output={}".format(type_support_pkg_main_file.dirname))
    msg_files = []
    for dep_msg in dep_msgs:
        msg_files.append("$(readlink -f {})".format(dep_msg.path))

    # Execute RPC code generator plugin
    ctx.actions.run_shell(
        inputs = [plugin] + dep_msgs,
        outputs = output_srcs,
        command = "python3 {} {} --msg_files={}".format(
            plugin.path,
            " ".join(args),
            ",".join(msg_files),
        ),
        tools = [plugin],
    )

    # Return provider with generated file information
    default_info = DefaultInfo(
        files = depset(output_srcs),
    )
    type_support_info = ROS2TypeSupportInfo(
        srcs = depset(output_srcs),
    )

    return [default_info, type_support_info]

_ros2_type_support = rule(
    implementation = _ros2_type_support_impl,
    attrs = {
        "dep_msgs": attr.label_list(
            default = [],
            allow_files = [".msg"],
            doc = "Input dependent .msg source files",
        ),
        "plugin_path": attr.label(
            mandatory = True,
            executable = True,
            cfg = "exec",
            allow_single_file = True,
            doc = "Path to the plugin executable",
        ),
        "pkg_name": attr.string(
            default = "msg_interface",
            doc = "Name of the ROS2 package",
        ),
    },
)

# Helper rule to extract header files from generated outputs
def _cc_package_files_impl(ctx):
    files = []
    target_field = ctx.attr.field
    for src in ctx.attr.srcs:
        target_files = getattr(src[ROS2TypeSupportInfo], target_field)
        files.extend(target_files.to_list())
    return [DefaultInfo(files = depset(files))]

# Rule for packaging generated source files
_cc_package_ros2_type_support_srcs = rule(
    implementation = _cc_package_files_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            providers = [ROS2TypeSupportInfo],
        ),
        "field": attr.string(
            mandatory = True,
        ),
    },
    doc = "Rule for extracting and packaging generated source files",
)
