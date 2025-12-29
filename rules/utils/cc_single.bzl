# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load("@rules_cc//cc:find_cc_toolchain.bzl", "find_cc_toolchain")
load(":pkg_lib.bzl", "TargetDepsInfo", "src_dep_aspect")

_template_static = '''#!/bin/bash
set -e

# Check if any object files are provided
if [[ "$#" == 0 ]]
then
    echo "ERROR: No object files provided to create static library"
    echo "This should not happen with the updated cc_single_library rule"
    exit 1
fi

# Create a temporary directory to copy all the object files to.
tmp_dir=__{name}_tmp_archives
mkdir "$tmp_dir"
for p in "$@"
do
    # Rename the object files to be the directory name.
    # This keeps them unique and stops ar from overwriting two objects with
    # the same name.
    filename=$(echo "$p" | sed 's#/#_#g')
    cp "$p" "$tmp_dir"/"$filename"
done

# Create the static library.
{ar} -qc {output_path} "$tmp_dir"/*.o
'''

_template_shared = '''#!/bin/bash
set -e

# Check if any object files are provided
if [[ "$#" == 0 ]]
then
    echo "ERROR: No object files provided to create shared library"
    echo "This should not happen with the updated cc_single_library rule"
    exit 1
fi

# Create a temporary directory to copy all the object files to.
tmp_dir=__{name}_tmp_archives
mkdir "$tmp_dir"
for p in "$@"
do
    # Rename the object files to be the directory name.
    # This keeps them unique and stops ar from overwriting two objects with
    # the same name.
    filename=$(echo "$p" | sed 's#/#_#g')
    cp "$p" "$tmp_dir"/"$filename"
done

# Create the shared library.
export PATH={linker}:$PATH
{compiler} -o {output_path} {default_link_flags} {linkopts} "$tmp_dir"/*.o
'''

def _cc_single_lib_impl(ctx):
    cc_toolchain = find_cc_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    # All sources to create an archive from.
    srcs_all = []
    srcs_all.extend(ctx.attr.deps)

    # Take the string of the label to check if we have visited it before.
    srcs_visited = []
    hdrs_visited = []
    objects_all = []
    objects_visited = []

    # Populate visited.
    for src in ctx.attr.deps:
        if not str(src.label) in srcs_visited:
            srcs_visited.append(str(src.label))

    deps_linkopts = []
    deps_cc_info = []
    deps_visited = []
    for src in ctx.attr.deps:
        for linkopts in src[TargetDepsInfo].linkopts:
            if linkopts not in deps_linkopts:
                deps_linkopts.append(linkopts)
        for dep in src[TargetDepsInfo].deps + src[TargetDepsInfo].transient_deps:
            if (ctx.label.workspace_name == dep.label.workspace_name or dep.label.workspace_name == ""):
                for linkopts in dep[TargetDepsInfo].linkopts:
                    if linkopts not in deps_linkopts:
                        deps_linkopts.append(linkopts)
                if not str(dep.label) in srcs_visited:
                    srcs_all.append(dep)
                    srcs_visited.append(str(dep.label))
            if (ctx.label.workspace_name != dep.label.workspace_name):
                if CcInfo in dep and not str(dep.label) in deps_visited:
                    deps_cc_info.append(dep[CcInfo])
                    deps_visited.append(str(dep.label))

        for inputs in src[CcInfo].linking_context.linker_inputs.to_list():
            if ctx.label.workspace_name == inputs.owner.workspace_name:
                for lib in inputs.libraries:
                    if ctx.attr.pic:
                        for o in lib.pic_objects:
                            if not str(o) in objects_visited:
                                objects_all.append(o)
                                objects_visited.append(str(o))
                    else:
                        for o in lib.objects:
                            if not str(o) in objects_visited:
                                objects_all.append(o)
                                objects_visited.append(str(o))

    # Now collect all the headers
    arguments = []
    object_files = []
    hdrs = []
    for src in srcs_all:
        for h in src[TargetDepsInfo].hdrs:
            for f in h.files.to_list():
                if ctx.label.workspace_name == f.owner.workspace_name:
                    if not str(f.path) in hdrs_visited:
                        hdrs.append(f)
                        hdrs_visited.append(str(f.path))
        if CcInfo in src:
            for f in src[CcInfo].compilation_context.headers.to_list():
                if ctx.label.workspace_name == f.owner.workspace_name:
                    if not str(f.path) in hdrs_visited:
                        hdrs.append(f)
                        hdrs_visited.append(str(f.path))

    # Collect all defines and includes from dependencies
    defines_all = []
    system_includes_all = []
    includes_all = []
    quote_includes_all = []
    framework_includes_all = []
    
    for src in srcs_all:
        if CcInfo in src:
            # Collect defines
            for define in src[CcInfo].compilation_context.defines.to_list():
                if define not in defines_all:
                    defines_all.append(define)
            # Collect includes
            for inc in src[CcInfo].compilation_context.system_includes.to_list():
                if inc not in system_includes_all:
                    system_includes_all.append(inc)
            for inc in src[CcInfo].compilation_context.includes.to_list():
                if inc not in includes_all:
                    includes_all.append(inc)
            for inc in src[CcInfo].compilation_context.quote_includes.to_list():
                if inc not in quote_includes_all:
                    quote_includes_all.append(inc)
            for inc in src[CcInfo].compilation_context.framework_includes.to_list():
                if inc not in framework_includes_all:
                    framework_includes_all.append(inc)

    for object in objects_all:
        arguments.append(object.path)
        object_files.append(object)

    # Check if we have any object files
    has_objects = len(object_files) > 0
    outputs = []
    linking_context = None

    if has_objects:
        # === Case 1: Has object files - generate library ===
        output_name = ctx.attr.name

        # Add prefix for agibot SDK library
        if ctx.attr.sdklib:
            lib_prefix = "libzy_"
            if output_name.startswith("lib"):
                output_name = output_name.replace("lib", lib_prefix, 1)
            else:
                output_name = lib_prefix + output_name

        def _run_script(_script_contents, _output, _output_name):
            script = ctx.actions.declare_file(_output_name + ".sh")  # Create the script.
            ctx.actions.write(
                output = script,
                content = _script_contents,
                is_executable = True,
            )
            ctx.actions.run(
                inputs = object_files + cc_toolchain.all_files.to_list(),
                outputs = [_output],
                executable = script,
                arguments = arguments,
                # For QNX, we need the environment variables passing in.
                use_default_shell_env = True,
            )

        # Generate static library
        static_output_name = output_name + ".a"
        static_output = ctx.actions.declare_file(static_output_name)

        static_script_contents = _template_static.format(
            name = ctx.attr.name,
            output_path = static_output.path,
            ar = cc_toolchain.ar_executable,
        )
        _run_script(static_script_contents, static_output, static_output_name)
        outputs.append(static_output)

        # Create library_to_link
        pic_static_library = None
        static_library = None
        shared_library = None

        if ctx.attr.pic:
            pic_static_library = static_output
        else:
            static_library = static_output

        # Generate shared library if needed
        if not ctx.attr.linkstatic:
            variables = cc_common.create_compile_variables(
                cc_toolchain = cc_toolchain,
                feature_configuration = feature_configuration,
            )
            default_link_flags = cc_common.get_memory_inefficient_command_line(
                feature_configuration = feature_configuration,
                action_name = ACTION_NAMES.cpp_link_dynamic_library,
                variables = variables,
            )
            default_link_flags_str = " ".join(default_link_flags)

            shared_output_name = output_name + ".so"
            shared_output = ctx.actions.declare_file(shared_output_name)
            linkopts_str = " ".join(ctx.attr.linkopts)
            shared_script_contents = _template_shared.format(
                name = ctx.attr.name,
                output_path = shared_output.path,
                linker = cc_toolchain.ld_executable,
                compiler = cc_toolchain.compiler_executable,
                default_link_flags = default_link_flags_str,
                linkopts = linkopts_str,
            )
            _run_script(shared_script_contents, shared_output, shared_output_name)
            shared_library = shared_output
            outputs.append(shared_output)

        library_to_link = cc_common.create_library_to_link(
            actions = ctx.actions,
            feature_configuration = feature_configuration,
            cc_toolchain = cc_toolchain,
            static_library = static_library,
            pic_static_library = pic_static_library,
            dynamic_library = shared_library,
        )
        linker_input = cc_common.create_linker_input(
            libraries = depset([library_to_link]),
            user_link_flags = depset(deps_linkopts),
            owner = ctx.label,
        )
        linking_context = cc_common.create_linking_context(
            linker_inputs = depset([linker_input]),
        )
    else:
        # === Case 2: No object files - header-only target ===
        print("INFO: Target %s contains only headers, no library will be generated" % ctx.label)

        # If there are linkopts to pass through to dependents
        if deps_linkopts:
            linker_input = cc_common.create_linker_input(
                owner = ctx.label,
                user_link_flags = depset(deps_linkopts),
            )
            linking_context = cc_common.create_linking_context(
                linker_inputs = depset([linker_input]),
            )
        else:
            # Create empty linking_context
            linking_context = cc_common.create_linking_context(
                linker_inputs = depset([]),
            )

    # Create compilation_context with collected headers and defines
    compilation_context = cc_common.create_compilation_context(
        headers = depset(hdrs),
        system_includes = depset(system_includes_all),
        includes = depset(includes_all),
        quote_includes = depset(quote_includes_all),
        framework_includes = depset(framework_includes_all),
        defines = depset(defines_all),
    )

    this_cc_info = CcInfo(
        compilation_context = compilation_context,
        linking_context = linking_context,
    )

    merged_cc_info = cc_common.merge_cc_infos(
        direct_cc_infos = [this_cc_info],
        cc_infos = deps_cc_info,
    )

    return [
        DefaultInfo(files = depset(outputs)),
        merged_cc_info,
    ]

cc_single_library = rule(
    implementation = _cc_single_lib_impl,
    attrs = {
        "deps": attr.label_list(
            allow_files = True,
            aspects = [src_dep_aspect],
            providers = [CcInfo],
            mandatory = True,
        ),
        "linkstatic": attr.bool(default = False),  # Build shared libraries or not.
        "pic": attr.bool(default = True),  # Build binaries with pic objects.
        "sdklib": attr.bool(default = True),  # Build agibot SDK lib, add prefix to lib name.
        "linkopts": attr.string_list(default = ["-Wl,--allow-multiple-definition"]),  # Additional linker options.
    },
    fragments = ["cpp"],
    toolchains = [
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
)

def process_cc_info_impl(ctx):
    cc_toolchain = find_cc_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    # Iterate over the transitive list of libraries we want to link,
    #   remove dynamic libraries from linker_inputs if owner of linker_inputs inside current Repo
    deps_cc_infos = cc_common.merge_cc_infos(
        cc_infos = [dep[CcInfo] for dep in ctx.attr.deps],
    )
    old_linker_inputs = deps_cc_infos.linking_context.linker_inputs.to_list()  # noqa
    new_linker_inputs = []
    for old_linker_input in old_linker_inputs:
        old_libraries = old_linker_input.libraries
        if ctx.label.workspace_name == old_linker_input.owner.workspace_name:
            new_libraries = []
            for old_library in old_libraries:
                if old_library.static_library or old_library.pic_static_library:
                    dynamic_library = None
                else:
                    dynamic_library = old_library.resolved_symlink_dynamic_library
                new_library = cc_common.create_library_to_link(
                    actions = ctx.actions,
                    feature_configuration = feature_configuration,
                    cc_toolchain = cc_toolchain,
                    static_library = old_library.static_library,
                    pic_static_library = old_library.pic_static_library,
                    dynamic_library = dynamic_library,
                    interface_library = old_library.resolved_symlink_interface_library,  # noqa
                    alwayslink = old_library.alwayslink,
                )
                new_libraries.append(new_library)
        else:
            new_libraries = old_libraries
        new_linker_input = cc_common.create_linker_input(
            owner = ctx.label,
            libraries = depset(direct = new_libraries),
            additional_inputs = depset(direct = old_linker_input.additional_inputs),  # noqa
            user_link_flags = depset(direct = old_linker_input.user_link_flags),  # noqa
        )
        new_linker_inputs.append(new_linker_input)

    linking_context = cc_common.create_linking_context(
        linker_inputs = depset(direct = new_linker_inputs, order = "topological"),
    )
    return [
        DefaultInfo(
            runfiles = ctx.runfiles(),
        ),
        CcInfo(
            compilation_context = deps_cc_infos.compilation_context,
            linking_context = linking_context,
        ),
    ]

process_cc_info = rule(
    implementation = process_cc_info_impl,
    attrs = {
        "deps": attr.label_list(
            providers = [CcInfo],
            mandatory = True,
        ),
    },
    fragments = ["cpp"],
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
)
