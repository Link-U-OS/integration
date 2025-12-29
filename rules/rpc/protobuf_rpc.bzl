# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

# Provider for storing information about generated protobuf RPC files
load("@rules_proto//proto:defs.bzl", "ProtoInfo")

ProtobufRpcInfo = provider(fields = ["hdrs", "srcs", "protos"])

_template_script = '''#!/bin/bash
set -e

proto_path=%s

if [[ "$proto_path" == *"/external/"* ]]; then
  proto_dir=$(echo "$proto_path" | awk -F '/external/' '{split($2,a,"/"); print substr($0,0,index($0,"/external/")+9) a[1]}')
else
  proto_dir=$(echo "$proto_path" | awk '{sub("/bin.*","/bin"); print}')
fi


%s --proto_path="$proto_dir" %s "$proto_path"
'''


def aimrt_cc_protobuf_rpc(
        name,
        proto,
        plugin_path,
        plugin_name = "aimrt_rpc",
        includes = [],
        deps = [],
        copts = [],
        dep_protos = []):
    # Add required AIMRT dependencies
    all_deps = deps + [
        "@aimrt//src/interface/aimrt_module_cpp_interface",
        "@aimrt//src/interface/aimrt_module_protobuf_interface",
    ]

    # Create unique names for intermediate targets
    generate_name = "%s_pb_cc" % name
    name_hdrs_cc = "%s_hdrs_cc" % name
    name_srcs_cc = "%s_srcs_cc" % name

    # Generate RPC code from protobuf using the specified plugin
    _protobuf_rpc(
        name = generate_name,
        proto = proto,
        dep_protos = dep_protos,
        plugin_name = plugin_name,
        plugin_path = plugin_path,
        includes = includes,
    )

    # Extract generated header files
    _cc_package_protobuf_rpc_hdrs(
        name = name_hdrs_cc,
        srcs = [generate_name],
        field = "hdrs",
    )

    # Extract generated source files
    _cc_package_protobuf_rpc_srcs(
        name = name_srcs_cc,
        srcs = [generate_name],
        field = "srcs",
    )

    # Create final C++ library with generated code
    native.cc_library(
        name = name,
        srcs = [name_srcs_cc],
        hdrs = [name_hdrs_cc],
        deps = all_deps,
        copts = copts,
    )

def _protobuf_rpc_impl(ctx):
    # Retrieve tools and input files
    protoc = ctx.executable.protoc
    plugin = ctx.executable.plugin_path
    proto = ctx.file.proto
    dep_protos = ctx.attr.dep_protos
    plugin_name = ctx.attr.plugin_name
    filename_without_ext = (proto.basename).split(".")[0]

    # Configure output filenames
    final_filename = filename_without_ext
    if plugin_name == "aimrt_rpc":
        final_filename = "{}.{}.pb".format(filename_without_ext, plugin_name)
    gen_rpc_pb_cc = ctx.actions.declare_file("{}.cc".format(final_filename))
    gen_rpc_pb_hdr = ctx.actions.declare_file("{}.h".format(final_filename))

    # Collect output files
    output_hdrs = [gen_rpc_pb_hdr]
    output_srcs = [gen_rpc_pb_cc]

    # Construct protoc command arguments
    args = []
    for include_path in ctx.attr.includes:
        args.append("-I={}".format(include_path))

    output_dir = ctx.bin_dir.path
    if ctx.label.workspace_name:
        # Handle external repository path
        output_dir = "{}/external/{}".format(output_dir, ctx.label.workspace_name)
    args.append("--{}_out={}".format(plugin_name, output_dir))
    args.append("--plugin=protoc-gen-{}={}".format(plugin_name, plugin.path))
    proto_path = "$(readlink -f {})".format(proto.path)


    # Create shell script for execution
    sh_script = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(
        output = sh_script,
        content = _template_script % (
            proto_path,
            protoc.path,
            " ".join(args),
        ),
        is_executable = True,
    )
    all_protos = []
    for dep in dep_protos:
        if ProtoInfo in dep:
            all_protos.extend(dep[ProtoInfo].transitive_imports.to_list())

    # Execute protoc with plugin
    ctx.actions.run(
        inputs = [proto] + all_protos,
        tools = [protoc, plugin],
        outputs = output_hdrs + output_srcs,
        executable = sh_script,
        progress_message = "Generating protobuf RPC code for {}".format(proto.short_path),
        use_default_shell_env = True,
    )

    # Return providers with generated file information
    default_info = DefaultInfo(
        files = depset(output_hdrs),
    )
    rpc_cc_info = ProtobufRpcInfo(
        srcs = depset(output_srcs),
        hdrs = depset(output_hdrs),
        protos = depset([proto]),
    )

    return [default_info, rpc_cc_info]

# Rule definition for protobuf RPC code generation
_protobuf_rpc = rule(
    implementation = _protobuf_rpc_impl,
    attrs = {
        "proto": attr.label(
            mandatory = True,
            allow_single_file = [".proto"],
            doc = "Input .proto source file",
        ),
        "dep_protos": attr.label_list(
            default = [],
            providers = [ProtoInfo],
            doc = "Input dependent .proto source files",
        ),
        "protoc": attr.label(
            default = "@com_google_protobuf//:protoc",
            executable = True,
            cfg = "exec",
            doc = "Protoc compiler executable",
        ),
        "plugin_name": attr.string(
            default = "aimrt_rpc",
            doc = "Plugin name (prefix for protoc-gen-{name})",
        ),
        "plugin_path": attr.label(
            mandatory = True,
            executable = True,
            cfg = "exec",
            allow_single_file = True,
            doc = "Path to the plugin executable",
        ),
        "includes": attr.string_list(
            default = [],
            doc = "List of include directories",
        ),
    },
)

# Implementation for extracting specific file types from generated outputs
def _cc_package_files_impl(ctx):
    files = []
    target_field = ctx.attr.field
    for src in ctx.attr.srcs:
        target_files = getattr(src[ProtobufRpcInfo], target_field)
        files.extend(target_files.to_list())
    return [DefaultInfo(files = depset(files))]

# Rule for collecting and packaging header files
_cc_package_protobuf_rpc_hdrs = rule(
    implementation = _cc_package_files_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            providers = [ProtobufRpcInfo],
        ),
        "field": attr.string(
            mandatory = True,
        ),
    },
    doc = "Rule for extracting and packaging generated header files",
)

# Rule for collecting and packaging source files
_cc_package_protobuf_rpc_srcs = rule(
    implementation = _cc_package_files_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            providers = [ProtobufRpcInfo],
        ),
        "field": attr.string(
            mandatory = True,
        ),
    },
    doc = "Rule for extracting and packaging generated source files",
)
