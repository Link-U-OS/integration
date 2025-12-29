# 三方库Archive包管理

在Bazel项目中,大部分第三方依赖通过`http_archive`规则引入archive包,并配合自定义BUILD文件进行编译集成。Archive包主要分为两类:源码包和预编译二进制包。

---

## 源码包

源码包通过下载第三方库的源代码,使用自定义BUILD文件编译生成目标产物。

### 示例:集成jsoncpp库

#### 1. 引入archive包

在 `projects/third_party/deps/archives_source.bzl` 中定义:
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

**参数说明:**
- `name`: 外部依赖的名称,后续通过 `@jsoncpp` 引用
- `build_file`: 指定自定义BUILD文件路径
- `sha256`: 包的校验和,确保下载完整性
- `strip_prefix`: 解压后移除的目录前缀
- `urls`: 下载地址列表

#### 2. 编写jsoncpp.BUILD

在 `projects/third_party/jsoncpp.BUILD` 中定义编译规则:
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

**关键配置:**
- `srcs`: 源文件和内部头文件
- `hdrs`: 对外暴露的公共头文件
- `includes`: 头文件搜索路径

---

## 预编译二进制包

预编译包直接使用已编译好的二进制文件,无需重新编译源码,适合大型库或交叉编译场景。

### 示例:集成boost库

#### 1. 引入多架构二进制包

在 `projects/third_party/deps/archives_prebuilt.bzl` 中定义:
```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def all_prebuilt_packages():
    # x86_64架构
    http_archive(
        name = "boost_x86_64",
        build_file = "@integration//projects/third_party:boost.BUILD",
        sha256 = "3373c06a249f99149c0e394ef64f836893ce5acfe9434b5a6a02b52d2706a1fa",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/boost-1.82.0_x86_64.tar.gz",
        ],
        strip_prefix = "boost-1.82.0",
    )

    # aarch64架构
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

#### 2. 编写boost.BUILD

在 `projects/third_party/boost.BUILD` 中定义:
```python
package(default_visibility = ["//visibility:public"])

cc_library(
    name = "boost",
    srcs = glob(
        include = ["lib/*.so*"],
        exclude = [
            "lib/libboost_python*.so*",  # 排除Python相关库
            "lib/*test*",                # 排除测试库
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

## 最佳实践

1. **版本管理**: 在URL中明确指定版本号,便于追溯和升级
2. **SHA校验**: 务必提供 `sha256` 值,防止包被篡改
3. **镜像源**: 配置多个 `urls`,提高下载可靠性
4. **架构区分**: 预编译包需为不同架构创建独立的 `http_archive` 规则
5. **可见性控制**: 根据需要设置 `visibility`,避免不必要的依赖暴露