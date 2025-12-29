def repackage_tar(name, srcs, prefix):
    """
    将现有tar包解压并添加前缀后重新打包

    Args:
        name: 规则名称
        src: 源tar包
        prefix: 要添加的前缀路径
    """

    # 解压命令
    filegroup_name = name + "_fg"
    native.filegroup(
        name = filegroup_name,
        srcs = srcs,
    )
    native.genrule(
        name = name + "_extract",
        srcs = [":" + filegroup_name],
        outs = [name + "_extracted.tar"],  # 改为tar文件而不是目录
        cmd = """
            mkdir -p tmp_extract
            tar xf $(SRCS) -C tmp_extract
            tar cf $(OUTS) -C tmp_extract .
        """,
    )

    # 移动文件并添加前缀
    native.genrule(
        name = name + "_prefix",
        srcs = [":" + name + "_extract"],
        outs = [name + "_with_prefix.tar"],  # 同样改为tar文件
        cmd = """
            mkdir -p tmp_prefix/%s
            tar xf $(location :%s_extract) -C tmp_prefix/%s
            tar cf $(OUTS) -C tmp_prefix .
        """ % (prefix, name, prefix),
    )

    # 最终打包
    native.genrule(
        name = name,
        srcs = [":" + name + "_prefix"],
        outs = [name + ".tar"],
        cmd = """
            cp $(location :%s_prefix) $(OUTS)
        """ % (name),
    )
