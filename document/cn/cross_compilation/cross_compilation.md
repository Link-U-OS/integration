# 交叉编译指南

## 快速开始

在 bazel build 命令中添加 `--config=orin_aarch64` 标志即可编译为 aarch64 架构：

```bash
bazel build //your/target --config=orin_aarch64
```

## 配置说明

### .bazelrc 配置

在项目根目录的 `.bazelrc` 中定义 orin_aarch64 构建配置：

```python
# Configuration for orin_aarch64 architecture
build:orin_aarch64 --extra_toolchains=@integration//toolchains/orin_aarch64/config:cc-toolchain
build:orin_aarch64 --platforms=@integration//toolchains/orin_aarch64/config:target_platform
build:orin_aarch64 --cxxopt="-fpermissive"
build:orin_aarch64 --copt -Wno-error=deprecated-declarations
build:orin_aarch64 --cxxopt -Wno-error=overloaded-virtual
build:orin_aarch64 --copt -Wno-error=ignored-qualifiers
build:orin_aarch64 --define orin_aarch64=true
build:orin_aarch64 --action_env=AGIBOT_PLATFORM="orin_aarch64"
build:orin_aarch64 --copt -DORIN_AARCH64
build:orin_aarch64 --action_env=ARCH=arm64
build:orin_aarch64 --copt -O3
build:orin_aarch64 --copt -DNDEBUG
build:orin_aarch64 --copt -g0
build:orin_aarch64 --@rules_cuda//cuda:archs=compute_87:compute_87,sm_87
build:orin_aarch64 --action_env=CUDA_HOME=/opt/nvidia/orin_sysroot/usr/local/cuda-12.2
build:orin_aarch64 --action_env=CUDA_PATH=/opt/nvidia/orin_sysroot/usr/local/cuda-12.2
```

## 非 GPU 库配置

### 定义交叉编译制品包

在 `integration/projects/third_party/deps/archives_prebuilt.bzl` 中定义预构建库的依赖：

```python
def all_archives():
    http_archive(
        name = "unifex_x86_64",
        sha256 = "29f3871350c518cf739b7e050d55f6d02d63198600ebed055d43ec4ea06368d7",
        strip_prefix = "libunifex-591ec09e",
        build_file = "@integration//projects/third_party:unifex.BUILD",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/libunifex-591ec09e_x86_64.tar.gz"
        ],
    )

    http_archive(
        name = "unifex_aarch64",
        sha256 = "188df011d54a8b478c373b56430dcba1d654dba2bae780a06ba51569b6f8a4e4",
        strip_prefix = "libunifex-591ec09e",
        build_file = "@integration//projects/third_party:unifex.BUILD",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/libunifex-591ec09e_aarch64.tar.gz"
        ],
    )
    # ... 其他库
```

### 平台选择别名

在 `integration/BUILD` 中使用 `select` 语句为不同架构选择相应的库：

```python
alias(
    name = "unifex",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@unifex_aarch64//:unifex",
        "//conditions:default": "@unifex_x86_64//:unifex",
    }),
)
```

### 在目标中使用

在 `aimrt/src/interface/aimrt_module_cpp_interface/BUILD` 中引用：

```python
package(default_visibility = ["//visibility:public"])

cc_library(
    name = "aimrt_module_cpp_interface",
    srcs = [],
    hdrs = glob(
        ["**/*.h"],
        exclude = ["**/*_test.h"],
    ),
    deps = [
        # ... 其他依赖
    ] + select({
        # ...
        "//conditions:default": ["@integration//:unifex"],
    }),
)
```

## GPU 库配置

本节以 TensorRT 和 CUDA 为例说明 GPU 库的交叉编译配置。

### 定义本地仓库

在 `integration/projects/third_party/deps.bzl` 中定义本地 GPU 库仓库：

```python
def local_deps():
    native.new_local_repository(
        name = "cuda_aarch64",
        build_file = "@integration//projects/third_party:cuda.BUILD",
        path = "/opt/nvidia/cuda-12.2",
    )
    
    native.new_local_repository(
        name = "tensorrt_aarch64",
        build_file = "@integration//projects/third_party:tensorrt.BUILD",
        path = "/opt/nvidia",
    )
```

### 平台选择别名

在 `integration/BUILD` 中配置 GPU 库别名：

```python
alias(
    name = "cuda",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@cuda_aarch64//:cuda",
    }),
)

alias(
    name = "tensorrt",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@tensorrt_aarch64//:tensorrt",
    }),
)
```

### TensorRT 库使用

```python
package(default_visibility = ["//visibility:public"])

cc_binary(
    name = "trtexec",
    srcs = ["trtexec.cpp"],
    deps = [
        "@integration//:tensorrt",
        # ... 其他依赖
    ],
)
```

### CUDA 库使用

**WORKSPACE 配置：**

```python
load("@rules_cuda//cuda:repositories.bzl", "register_detected_cuda_toolchains", "rules_cuda_dependencies")
rules_cuda_dependencies()
register_detected_cuda_toolchains()
```

**C++ 库示例 (Common/BUILD)：**

```python
package(default_visibility = ["//visibility:public"])

cc_library(
    name = "Common",
    srcs = glob(["**/*.cpp"], exclude = ["rendercheck_d3d11.cpp"]),
    hdrs = glob(["**/*.h"], exclude = ["rendercheck_d3d11.h"]),
    deps = ["@integration//:cuda"],
    includes = ["."],
)
```

**CUDA 二进制示例 (cudaTensorCoreGemm/BUILD)：**

```python
load("@rules_cuda//cuda:defs.bzl", "cuda_binary")

package(default_visibility = ["//visibility:public"])

cuda_binary(
    name = "cudaTensorCoreGemm",
    srcs = ["cudaTensorCoreGemm.cu"],
    deps = [
        # ... 其他依赖
        "@integration//:cuda",
    ],
)
```

## 最佳实践

- 使用 `select` 语句在 BUILD 文件中根据目标平台选择合适的依赖，避免硬编码架构信息
- 预构建库应为每个目标架构单独维护版本
- CUDA 环境变量应在 .bazelrc 中统一配置，便于管理多个 CUDA 版本
