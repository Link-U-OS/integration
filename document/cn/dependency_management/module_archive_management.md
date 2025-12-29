# 模块压缩包管理

产品包构建时支持集成预编译的模块压缩包。这些压缩包存储在制品库中，构建过程会自动下载、校验并集成到最终产品包中。

## 快速开始

### 步骤 1：配置压缩包信息

在 `projects/defs/archives.yaml` 中定义需要集成的模块压缩包：

```yaml
rl_deploy_zip:
  http_file:
    url: https://xxx/rl_deploy_1d5dda87.zip
    sha256: a1b2c3d4e5f6...
```

**参数说明：**

| 参数 | 说明 |
|------|------|
| `url` | 制品库中的压缩包下载地址（支持 HTTP/HTTPS） |
| `sha256` | 文件 SHA256 校验值，用于验证下载文件的完整性和真实性 |

### 步骤 2：在产品包中引用

在 `BUILD` 文件中配置压缩包的解压和打包逻辑：

```python
# 解压 ZIP 文件并转换为 TAR 格式
extract_zip_to_tar(
    name = "rl_deploy",
    zip_file = ["@rl_deploy_zip//file"],
)

# 将转换后的 TAR 文件添加到产品包
filegroup(
    name = "x86_64_a2_ultra_tar_list",
    srcs = [
        ":rl_deploy_tar",
        # 添加其他模块...
    ],
)
```

## 工作流程

构建系统按以下步骤处理模块压缩包：

1. **下载** - 根据 `archives.yaml` 中的配置从制品库下载压缩包
2. **校验** - 使用 SHA256 哈希值验证下载文件的完整性
3. **解压** - 将 ZIP 压缩包解压并转换为 TAR 格式
4. **集成** - 将转换后的文件打包到指定的产品包目录中

