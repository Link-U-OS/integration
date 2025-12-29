# 本地三方库管理

某些依赖可能已预装在本地环境（如 aimde）中，例如 Orin 上的 CUDA 库。这些库可以直接引用，无需重新编译。

## CUDA 库集成示例

### 1. 在 `projects/deps.bzl` 中定义本地仓库

```python
def local_deps():
    native.new_local_repository(
        name = "cuda_aarch64",
        build_file = "@integration//projects/third_party:cuda.BUILD",
        path = "/opt/nvidia/orin_sysroot/usr/local/cuda-12.2",
    )
```

### 2. 在 `projects/third_party/cuda.BUILD` 中定义编译规则

```python
package(default_visibility = ["//visibility:public"])

cc_library(
    name = "cuda",
    hdrs = glob(["include/**"]),
    includes = ["include"],
    linkopts = [
        "-L/opt/nvidia/orin_sysroot/usr/local/cuda-12.2/lib64",
        "-L/opt/nvidia/orin_sysroot/usr/local/cuda-12.2/lib64/stubs",
        "-lcudart",
        "-lcublas",
        "-lcuda",
        "-lnvidia-ml",
        "-lnppc",
        "-lnppicc",
        "-lnppim",
        "-lnppidei",
        "-lnppisu",
        "-lnppitc",
        "-lnvToolsExt",
    ],
)
```

## 注意事项

- 动态库已存在于本地环境中，无需在 `srcs` 中打包
- 根据实际安装路径调整 `path` 参数
- 根据项目需求调整 `linkopts` 中的库列表