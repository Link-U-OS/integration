# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

load("@rules_pkg//pkg:tar.bzl", "pkg_tar")

def extract_zip_to_tar(
        name,
        zip_file,
        output_dir_name = None,
        remove_outer_dir = False,
        visibility = None):
    """从zip文件提取内容并创建tar包

    Args:
        name: 规则名称，将用作生成的tar包的基础名称
        zip_file: 要提取的zip文件路径（通常是外部依赖），支持select语句
        output_dir_name: 提取后的目录名称，如果不指定则使用name
        remove_outer_dir: 如果为True，则从输出目录内部创建tar，否则包含目录本身
        visibility: 可见性设置
    """
    if output_dir_name == None:
        output_dir_name = name

    # 创建一个filegroup来处理select语句
    # 注意：zip_file已经是一个select表达式，其中每个分支都是一个列表
    # 我们直接使用它，不需要额外的处理
    zip_filegroup_name = name + "_zip_file"
    native.filegroup(
        name = zip_filegroup_name,
        srcs = zip_file,  # 直接使用zip_file，它已经是正确格式的select表达式
    )

    extract_name = "extract_" + name
    tar_name = name + "_tar"
    tar_file = name + ".tar"

    # 根据remove_outer_dir参数决定tar命令的路径
    tar_cmd = "tar -cf $(OUTS) -C $$TMP_DIR/ " + output_dir_name
    if remove_outer_dir:
        tar_cmd = "tar -cf $(OUTS) -C $$TMP_DIR/" + output_dir_name + " ."

    # 创建genrule来提取zip文件
    native.genrule(
        name = extract_name,
        srcs = [":" + zip_filegroup_name],  # 使用filegroup
        outs = [tar_file],
        cmd = """
            TMP_DIR=$$(mktemp -d)
            trap 'rm -rf "$$TMP_DIR"' EXIT  # 确保清理临时目录
            
            # 解压文件
            unzip -q $(SRCS) -d "$$TMP_DIR"  # 添加 -q 使输出更清晰
            
            # 查找解压后的目录
            EXTRACTED_DIR=$$(find "$$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -1)
            TARGET_DIR="$$TMP_DIR/""" + output_dir_name + """"
            
            # 如果找到目录且与目标目录不同，则移动
            if [ -n "$$EXTRACTED_DIR" ] && [ "$$EXTRACTED_DIR" != "$$TARGET_DIR" ]; then
                mv "$$EXTRACTED_DIR" "$$TARGET_DIR"
            fi
            
            # 创建tar包
            """ + tar_cmd + """
            rm -rf $$TMP_DIR
        """,
    )

    pkg_tar(
        name = tar_name,
        srcs = [],
        extension = "tar",
        mode = "0755",
        tags = ["tar"],
        deps = [":" + extract_name],
        visibility = visibility,
    )

    return tar_name
