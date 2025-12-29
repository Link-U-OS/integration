# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

# Provider for storing generated ROS2 RPC files information
ROS2RpcInfo = provider(fields = ["hdrs", "srcs", "srvs"])

def aimrt_cc_ros2_rpc(name, srv, plugin_path, pkg_name = "msg_interface", plugin_name = "aimrt_rpc", deps = [], copts = []):
    # Add aimrt as a required dependency
    all_deps = deps + [
        "@aimrt//src/interface/aimrt_module_cpp_interface",
        "@aimrt//src/interface/aimrt_module_ros2_interface",
    ]

    # Generate unique target names for intermediate outputs
    generate_name = "%s_ros2_cc" % name
    name_hdrs_cc = "%s_hdrs_cc" % name
    name_srcs_cc = "%s_srcs_cc" % name

    # Generate ROS2 RPC code using the plugin
    _ros2_rpc(
        name = generate_name,
        srv = srv,
        plugin_name = plugin_name,
        plugin_path = plugin_path,
        pkg_name = pkg_name,
    )

    # Extract header files from generated outputs
    _cc_package_ros2_rpc_hdrs(
        name = name_hdrs_cc,
        srcs = [generate_name],
        field = "hdrs",
    )

    # Extract source files from generated outputs
    _cc_package_ros2_rpc_srcs(
        name = name_srcs_cc,
        srcs = [generate_name],
        field = "srcs",
    )

    # Create final cc_library target with generated sources
    native.cc_library(
        name = name,
        srcs = [name_srcs_cc],
        hdrs = [name_hdrs_cc],
        deps = all_deps,
        copts = copts,
    )

def _ros2_rpc_impl(ctx):
    # Get required tools and inputs
    srv = ctx.file.srv
    plugin = ctx.executable.plugin_path
    pkg_name = ctx.attr.pkg_name
    plugin_name = ctx.attr.plugin_name

    # Setup output file paths
    filename_without_ext = (srv.basename).split(".")[0]
    final_filename = filename_without_ext
    if plugin_name == "aimrt_rpc":
        final_filename = "{}.{}.srv".format(filename_without_ext, plugin_name)
    gen_rpc_srv_cc = ctx.actions.declare_file("{}.cc".format(final_filename))
    gen_rpc_srv_hdr = ctx.actions.declare_file("{}.h".format(final_filename))

    # Track generated files
    output_hdrs = [gen_rpc_srv_hdr]
    output_srcs = [gen_rpc_srv_cc]

    # Build command line arguments
    args = [
        "--pkg_name={}".format(pkg_name),
    ]
    srv_dirname = ctx.file.srv.dirname
    args.append("--output_path={}".format(srv_dirname))

    # Execute RPC code generator plugin
    ctx.actions.run_shell(
        inputs = [srv, plugin],
        outputs = output_hdrs + output_srcs,
        command = "python3 {} {} --srv_file=$(readlink -f {})".format(
            plugin.path,
            " ".join(args),
            srv.path,
        ),
        tools = [plugin],
    )

    # Return provider with generated file information
    default_info = DefaultInfo(
        files = depset(output_hdrs),
    )
    rpc_cc_info = ROS2RpcInfo(
        srcs = depset(output_srcs),
        hdrs = depset(output_hdrs),
        srvs = depset([srv]),
    )

    return [default_info, rpc_cc_info]

# Rule for generating ROS2 RPC code from service definitions
_ros2_rpc = rule(
    implementation = _ros2_rpc_impl,
    attrs = {
        "srv": attr.label(
            mandatory = True,
            allow_single_file = [".srv"],
            doc = "Input ROS2 service definition file",
        ),
        "plugin_name": attr.string(
            default = "aimrt_rpc",
            doc = "Name of the RPC code generator plugin",
        ),
        "plugin_path": attr.label(
            mandatory = True,
            executable = True,
            cfg = "exec",
            allow_single_file = True,
            doc = "Path to the RPC code generator plugin executable",
        ),
        "pkg_name": attr.string(
            default = "msg_interface",
            doc = "Name of the ROS2 package",
        ),
    },
)

# Helper rule to extract files from generated outputs
def _cc_package_files_impl(ctx):
    files = []
    target_field = ctx.attr.field
    for src in ctx.attr.srcs:
        target_files = getattr(src[ROS2RpcInfo], target_field)
        files.extend(target_files.to_list())
    return [DefaultInfo(files = depset(files))]

# Rule for packaging generated header files
_cc_package_ros2_rpc_hdrs = rule(
    implementation = _cc_package_files_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            providers = [ROS2RpcInfo],
        ),
        "field": attr.string(
            mandatory = True,
        ),
    },
    doc = "Rule for extracting and packaging generated header files",
)

# Rule for packaging generated source files  
_cc_package_ros2_rpc_srcs = rule(
    implementation = _cc_package_files_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            providers = [ROS2RpcInfo],
        ),
        "field": attr.string(
            mandatory = True,
        ),
    },
    doc = "Rule for extracting and packaging generated source files",
)
