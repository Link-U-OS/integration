# Local Installation Library Management

Some dependencies may already be pre-installed in the local environment (such as aimde), for example CUDA libraries on Orin. These libraries can be referenced directly without requiring recompilation.

## CUDA Library Integration Example

### 1. Define Local Repository in `projects/deps.bzl`

```python
def local_deps():
    native.new_local_repository(
        name = "cuda_aarch64",
        build_file = "@integration//projects/third_party:cuda.BUILD",
        path = "/opt/nvidia/orin_sysroot/usr/local/cuda-12.2",
    )
```

### 2. Define Compilation Rules in `projects/third_party/cuda.BUILD`

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

## Important Notes

- Dynamic libraries already exist in the local environment and do not need to be packaged in `srcs`
- Adjust the `path` parameter according to the actual installation path
- Adjust the library list in `linkopts` according to project requirements
