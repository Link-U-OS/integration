load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "artifact_name_pattern",
    "env_entry",
    "env_set",
    "feature",
    "feature_set",
    "flag_group",
    "flag_set",
    "make_variable",
    "tool",
    "tool_path",
    "variable_with_value",
    "with_feature_set",
)

load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")

all_compile_actions = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.clif_match,
    ACTION_NAMES.lto_backend,
]

all_cpp_compile_actions = [
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.clif_match,
]

preprocessor_compile_actions = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.preprocess_assemble,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.clif_match,
]

codegen_compile_actions = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.lto_backend,
]

all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]

lto_index_actions = [
    ACTION_NAMES.lto_index_for_executable,
    ACTION_NAMES.lto_index_for_dynamic_library,
    ACTION_NAMES.lto_index_for_nodeps_dynamic_library,
]

def _impl(ctx):
    toolchain_identifier = ctx.attr.toolchain_identifier

    host_system_name = ctx.attr.host_system_name

    target_system_name = ctx.attr.target_system_name

    target_cpu = ctx.attr.target_cpu

    target_libc = ctx.attr.target_libc

    compiler = ctx.attr.compiler

    abi_version = ctx.attr.abi_version

    abi_libc_version = ctx.attr.abi_libc_version

    cc_target_os = None

    builtin_sysroot = ctx.attr.builtin_sysroot if ctx.attr.builtin_sysroot else None
    action_configs = []

    cxx_builtin_include_directories = ctx.attr.cxx_builtin_include_directories
    artifact_name_patterns = []

    make_variables = []

    random_seed_feature = feature(
        name = "random_seed",
        enabled = ctx.attr.random_seed
    )
    supports_pic_feature = feature(
        name = "supports_pic",
        enabled = ctx.attr.supports_pic
    )
    supports_dynamic_linker_feature = feature(
        name = "supports_dynamic_linker",
        enabled = ctx.attr.supports_dynamic_linker
    )

    default_compile_flags_feature = feature(
        name = "default_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = ([
                    flag_group(
                        flags = ctx.attr.compile_flags,
                    ),
                ] if ctx.attr.compile_flags else []),
            ),
            flag_set(
                actions = all_compile_actions,
                flag_groups = ([
                    flag_group(
                        flags = ctx.attr.dbg_compile_flags,
                    ),
                ] if ctx.attr.dbg_compile_flags else []),
                with_features = [with_feature_set(features = ["dbg"])],
            ),
            flag_set(
                actions = all_compile_actions,
                flag_groups = ([
                    flag_group(
                        flags = ctx.attr.opt_compile_flags,
                    ),
                ] if ctx.attr.opt_compile_flags else []),
                with_features = [with_feature_set(features = ["opt"])],
            ),
            flag_set(
                actions = all_cpp_compile_actions + [ACTION_NAMES.lto_backend],
                flag_groups = ([
                    flag_group(
                        flags = ctx.attr.cxx_flags,
                    ),
                ] if ctx.attr.cxx_flags else []),
            ),
        ],
    )

    default_link_flags_feature = feature(
        name = "default_link_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_link_actions + lto_index_actions,
                flag_groups = ([
                    flag_group(
                        flags = ctx.attr.link_flags,
                    ),
                ] if ctx.attr.link_flags else []),
            ),
            flag_set(
                actions = all_link_actions + lto_index_actions,
                flag_groups = ([
                    flag_group(
                        flags = ctx.attr.opt_link_flags,
                    ),
                ] if ctx.attr.opt_link_flags else []),
                with_features = [with_feature_set(features = ["opt"])],
            ),
        ],
    )

    shared_flag_feature = feature(
        name = "shared_flag",
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.cpp_link_dynamic_library,
                    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ACTION_NAMES.lto_index_for_dynamic_library,
                    ACTION_NAMES.lto_index_for_nodeps_dynamic_library,
                ],
                flag_groups = [flag_group(flags = ["-shared"])],
            ),
        ],
    )

    features = [
        shared_flag_feature,
        default_compile_flags_feature,
        default_link_flags_feature,
        random_seed_feature,
        supports_pic_feature,
        supports_dynamic_linker_feature,
    ]

    tool_paths = [
        tool_path(
            name = "gcc",
            path = ctx.attr.gcc
        ),
        tool_path(
            name = "ld",
            path = ctx.attr.ld,
        ),
        tool_path(
            name = "ar",
            path = ctx.attr.ar,
        ),
        tool_path(
            name = "cpp",
            path = ctx.attr.cpp,
        ),
        tool_path(
            name = "gcov",
            path = ctx.attr.gcov,
        ),
        tool_path(
            name = "nm",
            path = ctx.attr.nm,
        ),
        tool_path(
            name = "objdump",
            path = ctx.attr.objdump,
        ),
        tool_path(
            name = "strip",
            path = ctx.attr.strip,
        ),
    ]

    out = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(out, "Fake executable")
    return [
        cc_common.create_cc_toolchain_config_info(
            ctx = ctx,
            features = features,
            action_configs = action_configs,
            artifact_name_patterns = artifact_name_patterns,
            cxx_builtin_include_directories = cxx_builtin_include_directories,
            toolchain_identifier = toolchain_identifier,
            host_system_name = host_system_name,
            target_system_name = target_system_name,
            target_cpu = target_cpu,
            target_libc = target_libc,
            compiler = compiler,
            abi_version = abi_version,
            abi_libc_version = abi_libc_version,
            tool_paths = tool_paths,
            make_variables = make_variables,
            builtin_sysroot = builtin_sysroot,
            cc_target_os = cc_target_os,
        ),
        DefaultInfo(
            executable = out,
        ),
    ]

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        'gcc': attr.string(
            default = "/bin/false",
        ),
        'ld': attr.string(
            default = "/bin/false",
        ),
        'ar': attr.string(
            default = "/bin/false",
        ),
        'cpp': attr.string(
            default = "/bin/false",
        ),
        'gcov': attr.string(
            default = "/bin/false",
        ),
        'nm': attr.string(
            default = "/bin/false",
        ),
        'objdump': attr.string(
            default = "/bin/false",
        ),
        'strip': attr.string(
            default = "/bin/false",
        ),
        'random_seed' : attr.bool(
            default = True
        ),
        'supports_pic' : attr.bool(
            default = True
        ),
        'supports_dynamic_linker' : attr.bool(
            default = True
        ),
        'cxx_builtin_include_directories': attr.string_list(),
        'toolchain_identifier': attr.string(),
        'host_system_name': attr.string(),
        'target_system_name': attr.string(),
        'target_cpu': attr.string(),
        'target_libc': attr.string(),
        'compiler': attr.string(),
        'abi_version': attr.string(),
        'abi_libc_version': attr.string(),
        'builtin_sysroot': attr.string(),
        'compile_flags' : attr.string_list(),
        'dbg_compile_flags' : attr.string_list(),
        'opt_compile_flags' : attr.string_list(),
        'cxx_flags' : attr.string_list(),
        'link_flags' : attr.string_list(),
        'opt_link_flags' : attr.string_list(),
    },
    provides = [CcToolchainConfigInfo],
    executable = True,
)