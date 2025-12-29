# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

def _patchelf_tar_impl(ctx):
    output = ctx.outputs.out
    input_tar = ctx.file.tar
    patchelf = ctx.executable._patchelf

    script = ctx.actions.declare_file(ctx.label.name + ".sh")
    script_content = """#!/bin/bash
        set -e
        
        # 创建临时目录
        TEMP_DIR=$(mktemp -d)
        
        # 解压tar包到临时目录
        tar -xf "{input_tar}" -C $TEMP_DIR
        
        # 对bin目录下所有文件执行patchelf
        if [ -d "$TEMP_DIR/bin" ]; then
            find $TEMP_DIR/bin -type f -exec "{patchelf}" --force-rpath --set-rpath '$ORIGIN' {{}} \\;
        fi
        
        # 重新打包
        tar -cf "{output}" -C $TEMP_DIR .
        
        # 清理临时目录
        rm -rf $TEMP_DIR
    """.format(
        input_tar = input_tar.path,
        patchelf = patchelf.path,
        output = output.path,
    )
    
    ctx.actions.write(script, script_content, is_executable = True)
    
    ctx.actions.run(
        inputs = [input_tar],
        outputs = [output],
        executable = script,
        tools = [patchelf],
        mnemonic = "PatchElfTar",
        progress_message = "Patching ELF files in tar archive %s" % input_tar.short_path,
    )

patchelf_tar = rule(
    implementation = _patchelf_tar_impl,
    attrs = {
        "tar": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "Input tar file to be patched",
        ),
        "out": attr.output(
            mandatory = True,
            doc = "Output patched tar file",
        ),
        "_patchelf": attr.label(
            default = Label("@patchelf//:patchelf"),
            executable = True,
            cfg = "exec",
            doc = "The patchelf tool",
        ),
    },
    doc = "Extracts a tar file, applies patchelf to all files in bin directory, and repacks",
)