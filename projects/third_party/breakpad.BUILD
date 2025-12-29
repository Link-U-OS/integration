package(default_visibility = ["//visibility:public"])

#
# 第三方依赖：x86 反汇编库
#
cc_library(
    name = "libdisasm",
    srcs = [
        "src/third_party/libdisasm/ia32_implicit.c",
        "src/third_party/libdisasm/ia32_insn.c",
        "src/third_party/libdisasm/ia32_invariant.c",
        "src/third_party/libdisasm/ia32_modrm.c",
        "src/third_party/libdisasm/ia32_opcode_tables.c",
        "src/third_party/libdisasm/ia32_operand.c",
        "src/third_party/libdisasm/ia32_reg.c",
        "src/third_party/libdisasm/ia32_settings.c",
        "src/third_party/libdisasm/x86_disasm.c",
        "src/third_party/libdisasm/x86_format.c",
        "src/third_party/libdisasm/x86_imm.c",
        "src/third_party/libdisasm/x86_insn.c",
        "src/third_party/libdisasm/x86_misc.c",
        "src/third_party/libdisasm/x86_operand_list.c",
    ],
    hdrs = glob([
        "src/third_party/libdisasm/*.h",
    ]),
    includes = [
        "src",
        "src/third_party/libdisasm",
    ],
    strip_include_prefix = "src",
)

#
# 核心 Breakpad 处理器库
#
cc_library(
    name = "libbreakpad",
    srcs = [
        # 基础处理模块
        "src/processor/basic_code_modules.cc",
        "src/processor/basic_source_line_resolver.cc",
        "src/processor/call_stack.cc",
        "src/processor/cfi_frame_info.cc",
        "src/processor/convert_old_arm64_context.cc",
        "src/processor/dump_context.cc",
        "src/processor/dump_object.cc",
        "src/processor/fast_source_line_resolver.cc",
        "src/processor/logging.cc",
        "src/processor/module_comparer.cc",
        "src/processor/module_serializer.cc",
        "src/processor/pathname_stripper.cc",
        "src/processor/process_state.cc",
        "src/processor/simple_symbol_supplier.cc",
        "src/processor/source_line_resolver_base.cc",
        "src/processor/stack_frame_cpu.cc",
        "src/processor/stack_frame_symbolizer.cc",
        "src/processor/stackwalk_common.cc",
        "src/processor/symbolic_constants_win.cc",
        "src/processor/tokenize.cc",

        # 转储处理
        "src/processor/microdump.cc",
        "src/processor/microdump_processor.cc",
        "src/processor/minidump.cc",
        "src/processor/minidump_processor.cc",
        "src/processor/exploitability_linux.cc",
        "src/processor/proc_maps_linux.cc",
        "src/common/linux/scoped_pipe.cc",
        "src/common/linux/scoped_tmpfile.cc",
        "src/processor/disassembler_objdump.cc",
        "src/processor/stackwalker_address_list.cc",
    ] + select({
        "@integration//toolchains/platforms:is_aarch64": [
            "src/processor/stackwalker_arm64.cc",
        ],
         "//conditions:default": [
            "src/processor/stackwalker_amd64.cc",
        ],
    }),
    hdrs = glob([
        "src/google_breakpad/common/*.h",
        "src/google_breakpad/processor/*.h",
        "src/processor/*.h",
        "src/common/*.h",
        "src/common/linux/*.h"
    ]),
    copts = [
        "-DHAVE_CONFIG_H"
    ],
    includes = [
        "src",
    ],
    strip_include_prefix = "src",
    deps = [":config"] + select({
        "@integration//toolchains/platforms:is_aarch64": [
        ],
         "//conditions:default": [
            ":libdisasm", 
        ],
    })
)


cc_library(
    name = "breakpad_client",
    srcs = [
        # 崩溃生成和异常处理
        "src/client/linux/crash_generation/crash_generation_client.cc",
        "src/client/linux/crash_generation/crash_generation_server.cc",
        "src/client/linux/handler/exception_handler.cc", 
        "src/client/linux/handler/minidump_descriptor.cc",
        "src/client/linux/log/log.cc",
        
        # 转储写入
        "src/client/linux/dump_writer_common/thread_info.cc",
        "src/client/linux/dump_writer_common/ucontext_reader.cc",
        "src/client/linux/microdump_writer/microdump_writer.cc",
        "src/client/linux/minidump_writer/linux_core_dumper.cc",
        "src/client/linux/minidump_writer/linux_dumper.cc",
        "src/client/linux/minidump_writer/linux_ptrace_dumper.cc",
        "src/client/linux/minidump_writer/minidump_writer.cc",
        "src/client/linux/minidump_writer/pe_file.cc",
        "src/client/minidump_file_writer.cc",
        
        # 通用实用工具
        "src/common/convert_UTF.cc",
        "src/common/md5.cc",
        "src/common/string_conversion.cc",
        
        # Linux 特定实用工具
        "src/common/linux/elf_core_dump.cc",
        "src/common/linux/elfutils.cc", 
        "src/common/linux/file_id.cc",
        "src/common/linux/guid_creator.cc",
        "src/common/linux/linux_libc_support.cc",
        "src/common/linux/memory_mapped_file.cc",
        "src/common/linux/safe_readlink.cc",
    ] + select({
        # 如果系统不支持 getcontext，包含汇编实现
        "//conditions:default": ["src/common/linux/breakpad_getcontext.S"],
    }),
    hdrs = glob([
        "src/client/**/*.h",
        "src/common/*.h",
        "src/common/linux/*.h",
        "src/google_breakpad/common/*.h",
    ]),
    copts = [
        "-DHAVE_CONFIG_H",
        "-Isrc/common/android/include",
        "-Isrc/common/android/testing/include",
    ],
    includes = ["src"],
    linkopts = ["-lpthread"],  # 需要 pthread 支持
    strip_include_prefix = "src",
    target_compatible_with = ["@platforms//os:linux"],
    deps = [":libbreakpad", "@lss"],
)

genrule(
    name = "config_h",
    outs = ["src/config.h"],
    cmd = """
cat > $@ << 'EOF'
#ifndef BREAKPAD_CONFIG_H_
#define BREAKPAD_CONFIG_H_

#define HAVE_GETCONTEXT 1
#define HAVE_MEMFD_CREATE 1
#define PACKAGE_STRING "breakpad 0.1"
#define PACKAGE_VERSION "0.1"

#ifdef __linux__
#define BREAKPAD_LINUX_HOST 1
#endif

#ifdef __ANDROID__
#define BREAKPAD_ANDROID_HOST 1
#endif

#endif  // BREAKPAD_CONFIG_H_
EOF
""",
)

cc_library(
    name = "config",
    hdrs = [":config_h"],
    includes = ["src"],
    strip_include_prefix = "src",
)