# Cross-Compilation Guide

## Quick Start

Add the `--config=orin_aarch64` flag to the bazel build command to compile for aarch64 architecture:

```bash
bazel build //your/target --config=orin_aarch64
```

## Configuration

### .bazelrc Configuration

Define the orin_aarch64 build configuration in `.bazelrc` at the project root:

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

## Non-GPU Library Configuration

### Defining Cross-Compilation Artifact Packages

Define dependencies for prebuilt libraries in `integration/projects/third_party/deps/archives_prebuilt.bzl`:

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
    # ... other libraries
```

### Platform Selection Aliases

Use `select` statements in `integration/BUILD` to choose corresponding libraries for different architectures:

```python
alias(
    name = "unifex",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@unifex_aarch64//:unifex",
        "//conditions:default": "@unifex_x86_64//:unifex",
    }),
)
```

### Using in Targets

Reference in `aimrt/src/interface/aimrt_module_cpp_interface/BUILD`:

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
        # ... other dependencies
    ] + select({
        # ...
        "//conditions:default": ["@integration//:unifex"],
    }),
)
```

## GPU Library Configuration

This section demonstrates GPU library cross-compilation configuration using TensorRT and CUDA as examples.

### Defining Local Repositories

Define local GPU library repositories in `integration/projects/third_party/deps.bzl`:

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

### Platform Selection Aliases

Configure GPU library aliases in `integration/BUILD`:

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

### TensorRT Library Usage

```python
package(default_visibility = ["//visibility:public"])

cc_binary(
    name = "trtexec",
    srcs = ["trtexec.cpp"],
    deps = [
        "@integration//:tensorrt",
        # ... other dependencies
    ],
)
```

### CUDA Library Usage

**WORKSPACE Configuration:**

```python
load("@rules_cuda//cuda:repositories.bzl", "register_detected_cuda_toolchains", "rules_cuda_dependencies")
rules_cuda_dependencies()
register_detected_cuda_toolchains()
```

**C++ Library Example (Common/BUILD):**

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

**CUDA Binary Example (cudaTensorCoreGemm/BUILD):**

```python
load("@rules_cuda//cuda:defs.bzl", "cuda_binary")

package(default_visibility = ["//visibility:public"])

cuda_binary(
    name = "cudaTensorCoreGemm",
    srcs = ["cudaTensorCoreGemm.cu"],
    deps = [
        # ... other dependencies
        "@integration//:cuda",
    ],
)
```

## Best Practices

- Use `select` statements in BUILD files to choose appropriate dependencies based on the target platform, avoiding hardcoded architecture information
- Maintain separate versions of prebuilt libraries for each target architecture
- Configure CUDA environment variables in .bazelrc for centralized management of multiple CUDA versions
