# Chip-Level Package Build

## Overview

This document describes the build configuration for x86 and Orin chip packages. The generated `x86_64_pkg_tar.tar` and `orin_pkg_tar.tar` reduce build time and chip package size by removing intermediate compilation files and redundant shared libraries.

## x86 Chip Package Definition

Define the x86 chip package build rules in the `BUILD` file:

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
            # Other source files...
        ],
    }),
    extension = "tar",
    mode = "0755",
    tags = ["tar"],
)

filegroup(
    name = "x86_64_a2_ultra_tar_list",
    srcs = [
        # Other dependencies...
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

## Orin Chip Package Definition

Define the Orin chip package build rules in the `BUILD` file:

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
            # Other source files...
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
