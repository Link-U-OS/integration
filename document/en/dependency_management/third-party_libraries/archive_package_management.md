# Third-Party Library Archive Package Management

In Bazel projects, most third-party dependencies are introduced through the `http_archive` rule combined with custom BUILD files for compilation and integration. Archive packages are primarily divided into two categories: source packages and precompiled binary packages.

---

## Source Packages

Source packages are obtained by downloading third-party library source code and using custom BUILD files to compile and generate target artifacts.

### Example: Integrating jsoncpp Library

#### 1. Importing Archive Package

Define in `projects/third_party/deps/archives_source.bzl`:
```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def all_source_packages():
    http_archive(
        name = "jsoncpp",
        build_file = "@integration//projects/third_party:jsoncpp.BUILD",
        sha256 = "f409856e5920c18d0c2fb85276e24ee607d2a09b5e7d5f0a371368903c275da2",
        strip_prefix = "jsoncpp-1.9.5",
        urls = [
            "https://github.com/open-source-parsers/jsoncpp/archive/refs/tags/1.9.5.tar.gz",
        ],
    )
```

**Parameter Description:**
- `name`: Name of the external dependency, referenced later as `@jsoncpp`
- `build_file`: Path to the custom BUILD file
- `sha256`: Checksum of the package to ensure download integrity
- `strip_prefix`: Directory prefix to remove after extraction
- `urls`: List of download URLs

#### 2. Writing jsoncpp.BUILD

Define compilation rules in `projects/third_party/jsoncpp.BUILD`:
```python
package(default_visibility = ["//visibility:public"])

cc_library(
    name = "jsoncpp",
    srcs = glob([
        "src/lib_json/*.cpp",
        "src/lib_json/*.inl",
        "src/lib_json/*.h",
    ]),
    hdrs = glob([
        "include/json/*.h",
    ]),
    includes = ["include"],
)
```

**Key Configuration:**
- `srcs`: Source files and internal header files
- `hdrs`: Public header files exposed to external consumers
- `includes`: Header file search paths

---

## Precompiled Binary Packages

Precompiled packages directly use already-compiled binary files without requiring recompilation of source code. This approach is suitable for large libraries or cross-compilation scenarios.

### Example: Integrating boost Library

#### 1. Importing Multi-Architecture Binary Packages

Define in `projects/third_party/deps/archives_prebuilt.bzl`:
```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def all_prebuilt_packages():
    # x86_64 architecture
    http_archive(
        name = "boost_x86_64",
        build_file = "@integration//projects/third_party:boost.BUILD",
        sha256 = "3373c06a249f99149c0e394ef64f836893ce5acfe9434b5a6a02b52d2706a1fa",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/boost-1.82.0_x86_64.tar.gz",
        ],
        strip_prefix = "boost-1.82.0",
    )

    # aarch64 architecture
    http_archive(
        name = "boost_aarch64",
        build_file = "@integration//projects/third_party:boost.BUILD",
        sha256 = "c58ccb6eb5e44e743ebc7343c5c8260d9ea89dab212f1d2f9d7b323da72eb36b",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/boost-1.82.0_aarch64.tar.gz",
        ],
        strip_prefix = "boost-1.82.0",
    )
```

#### 2. Writing boost.BUILD

Define in `projects/third_party/boost.BUILD`:
```python
package(default_visibility = ["//visibility:public"])

cc_library(
    name = "boost",
    srcs = glob(
        include = ["lib/*.so*"],
        exclude = [
            "lib/libboost_python*.so*",  # Exclude Python-related libraries
            "lib/*test*",                # Exclude test libraries
        ],
    ),
    hdrs = glob([
        "include/boost/**/*.hpp",
        "include/boost/**/*.h",
        "include/boost/**/*.ipp",
    ]),
    includes = ["include"],
)
```

---

## Best Practices

1. **Version Management**: Explicitly specify version numbers in URLs for easy tracking and upgrades
2. **SHA Verification**: Always provide `sha256` values to prevent package tampering
3. **Mirror Sources**: Configure multiple `urls` to improve download reliability
4. **Architecture Differentiation**: Create separate `http_archive` rules for precompiled packages targeting different architectures
5. **Visibility Control**: Set `visibility` appropriately based on requirements to avoid unnecessary dependency exposure
