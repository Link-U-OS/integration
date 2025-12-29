# 芯片级包构建

## 概述

本文档描述了 x86 和 Orin 芯片包的构建配置。生成的 `x86_64_pkg_tar.tar` 和 `orin_pkg_tar.tar` 通过移除编译中间文件和冗余共享库，减少编译时间和芯片包大小。

## x86 芯片包定义

在 `BUILD` 文件中定义 x86 芯片包构建规则：

```python
config_setting(
    name = "is_a2_ultra",
    define_values = {"product": "A2_ULTRA"},
)

pkg_files(
    name = "x86_64_a2_ultra_addons_pkg_files",
    srcs = glob([
        "product/a2_ultra/addons/x86_64/**",
    ]),
    attributes = pkg_attributes(
        mode = "0755",
    ),
    strip_prefix = "product/a2_ultra/addons/x86_64",
)

pkg_tar(
    name = "x86_64_addons_tar",
    srcs = select({
        "//conditions:default": [
            ":x86_64_a2_ultra_addons_pkg_files",
            # 其他源文件...
        ],
    }),
    extension = "tar",
    mode = "0755",
    tags = ["tar"],
)

filegroup(
    name = "x86_64_a2_ultra_tar_list",
    srcs = [
        # 其他依赖...
        "@aimrt_process_manager//:process_manager_tar",
    ],
)

alias(
    name = "x86_64_target_tar_list",
    actual = select({
        ":is_a2_ultra": ":x86_64_a2_ultra_tar_list",
        "//conditions:default": ":x86_64_a2_ultra_tar_list",
    }),
)

pkg_tar(
    name = "x86_64_pkg_origin_tar",
    srcs = [],
    include_runfiles = 1,
    mode = "0755",
    strip_prefix = ".",
    tags = ["tar"],
    deps = [
        ":x86_64_addons_tar",
        ":x86_64_target_tar_list",
    ],
)

patchelf_tar(
    name = "x86_64_pkg_tar",
    out = "x86_64_pkg_tar.tar",
    tar = ":x86_64_pkg_origin_tar",
)
```

## Orin 芯片包定义

在 `BUILD` 文件中定义 Orin 芯片包构建规则：

```python
config_setting(
    name = "is_a2_ultra",
    define_values = {"product": "A2_ULTRA"},
)

pkg_files(
    name = "orin_a2_ultra_addons_pkg_file",
    srcs = glob([
        "product/a2_ultra/addons/orin/**",
    ]),
    strip_prefix = "product/a2_ultra/addons/orin",
)

pkg_tar(
    name = "orin_addons_tar",
    srcs = select({
        "//conditions:default": [
            ":orin_a2_ultra_addons_pkg_file",
            # 其他源文件...
        ],
    }),
    extension = "tar",
    mode = "0755",
    tags = ["tar"],
)

alias(
    name = "orin_target_tar_list",
    actual = select({
        ":is_a2_ultra": ":orin_a2_ultra_tar_list",
        "//conditions:default": ":orin_a2_ultra_tar_list",
    }),
)

pkg_tar(
    name = "orin_pkg_origin_tar",
    srcs = [],
    include_runfiles = 1,
    mode = "0755",
    strip_prefix = ".",
    tags = ["tar"],
    deps = [
        ":orin_addons_tar",
        ":orin_target_tar_list",
    ],
)

patchelf_tar(
    name = "orin_pkg_tar",
    out = "orin_pkg_tar.tar",
    tar = ":orin_pkg_origin_tar",
)
```
