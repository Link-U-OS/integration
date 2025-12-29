# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

# Provider for generated protobuf type support files
load("@rules_proto//proto:defs.bzl", "ProtoInfo")

ProtobufTypeSupportInfo = provider(fields = ["srcs"])

# Shell script template for finding workspace root and executing protoc
_template_script = '''#!/bin/bash
set -e

proto_path=%s

if [[ "$proto_path" == *"/external/"* ]]; then
  proto_dir=$(echo "$proto_path" | awk -F '/external/' '{split($2,a,"/"); print substr($0,0,index($0,"/external/")+9) a[1]}')
else
  proto_dir=$(echo "$proto_path" | awk '{sub("/bin.*","/bin"); print}')
fi


%s --proto_path="$proto_dir" %s
'''

def aimrte_cc_protobuf_type_support(
        name,
        proto,
        plugin_path,
        includes = [],
        deps = [],
        copts = [],
        dep_protos = []):
    # Combine user-provided dependencies with required AIMRT interfaces
    all_deps = deps + [
        "@aimrt//src/interface/aimrt_type_support_pkg_c_interface",
        "@aimrt//src/interface/aimrt_module_protobuf_interface",
    ]

    # Create intermediate target names
    generate_name = "%s_type_support" % name
    name_srcs_cc = "%s_srcs_cc" % name

    # Generate type support code using protoc plugin
    _protobuf_type_support(
        name = generate_name,
        proto = proto,
        dep_protos = dep_protos,
        plugin_path = plugin_path,
        includes = includes,
    )

    # Package generated source files
    _cc_package_protobuf_type_support_srcs(
        name = name_srcs_cc,
        srcs = [generate_name],
        field = "srcs",
    )

    # Create shared library with type support implementation
    native.cc_binary(
        name = name,
        srcs = [name_srcs_cc],
        deps = all_deps,
        copts = copts,
        linkshared = True,
    )

def _protobuf_type_support_impl(ctx):
    # Extract tools and input files
    protoc = ctx.executable.protoc
    plugin = ctx.executable.plugin_path
    proto = ctx.file.proto
    dep_protos = ctx.attr.dep_protos
    filename_without_ext = (proto.basename).split(".")[0]

    # Define output file path for type support implementation
    type_support_pkg_main_file = ctx.actions.declare_file("{}/type_support/type_support_pkg_main.cc".format(filename_without_ext))

    # Track all generated source files
    output_srcs = [type_support_pkg_main_file]

    # Construct protoc command arguments
    args = []
    for include_path in ctx.attr.includes:
        args.append("-I={}".format(include_path))
    args.append("--aimrt_type_support_out={}".format(type_support_pkg_main_file.dirname))
    args.append("--plugin=protoc-gen-aimrt_type_support={}".format(plugin.path))
    args.append("$(readlink -f {})".format(proto.path))
    proto_path = "$(readlink -f {})".format(proto.path)

    all_protos = []
    for dep in dep_protos:
        if ProtoInfo in dep:
            proto_files = dep[ProtoInfo].transitive_imports.to_list()
            all_protos.extend(proto_files)
            for proto_file in proto_files:
                args.append("$(readlink -f {})".format(proto_file.path))

    # Create execution script
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

    # Run protoc with type support plugin
    ctx.actions.run(
        inputs = [proto] + all_protos,
        tools = [protoc, plugin],
        outputs = output_srcs,
        executable = sh_script,
        progress_message = "Generating protobuf type support code for {}".format(proto.short_path),
        use_default_shell_env = True,
    )

    # Return providers with generated file information
    default_info = DefaultInfo(
        files = depset(output_srcs),
    )
    type_support_info = ProtobufTypeSupportInfo(
        srcs = depset(output_srcs),
    )
    return [default_info, type_support_info]

# Rule definition for protobuf type support generation
_protobuf_type_support = rule(
    implementation = _protobuf_type_support_impl,
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

# Implementation for extracting files from provider
def _cc_package_files_impl(ctx):
    files = []
    target_field = ctx.attr.field
    for src in ctx.attr.srcs:
        target_files = getattr(src[ProtobufTypeSupportInfo], target_field)
        files.extend(target_files.to_list())
    return [DefaultInfo(files = depset(files))]

# Rule for collecting and packaging generated source files
_cc_package_protobuf_type_support_srcs = rule(
    implementation = _cc_package_files_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            providers = [ProtobufTypeSupportInfo],
        ),
        "field": attr.string(
            mandatory = True,
        ),
    },
    doc = "Rule for extracting and packaging generated source files",
)
