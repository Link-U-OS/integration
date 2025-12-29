# 模块压缩包集成指南

产品构建系统支持从制品库集成预编译的模块压缩包。构建过程会自动完成下载、校验和集成,将模块无缝整合到最终产品包中。

## 集成步骤

### 1. 定义压缩包配置

在 `projects/defs/archives.yaml` 中声明需要集成的模块:

```yaml
rl_deploy_zip:
  http_file:
    url: https://xxx/rl_deploy_1d5dda87.zip
    sha256: a1b2c3d4e5f6...
```

**配置参数:**

| 参数 | 说明 |
|------|------|
| `url` | 压缩包下载地址,支持 HTTP/HTTPS 协议 |
| `sha256` | SHA256 校验值,确保文件完整性和安全性 |

### 2. 配置构建规则

在产品的 `BUILD` 文件中添加解压和打包规则:

```python
# 解压 ZIP 并转换为 TAR 格式
extract_zip_to_tar(
    name = "rl_deploy",
    zip_file = ["@rl_deploy_zip//file"],
)

# 将模块添加到产品包文件列表
filegroup(
    name = "x86_64_a2_ultra_tar_list",
    srcs = [
        ":rl_deploy_tar",
        # 其他模块...
    ],
)
```

### 3. 配置模块启动

编辑产品配置文件 `product/a2_ultra/addons/x86_64/entry/bin/cfg/run_agibot.yaml`,添加模块启动配置:

```yaml
process_manager:
  default_apps:
    # 在启动列表中添加模块
    [..., "mc", ...]
  apps:
    "mc":
      path: "${AGIBOT_HOME}/agibot/software/v0/rl_deploy/deploy_assets/scripts/start_rl_control_real.sh"
      sudo: false
```

## 构建流程

构建系统自动执行以下步骤:

1. **下载** → 从制品库获取压缩包
2. **校验** → 验证 SHA256 哈希值
3. **解压** → 提取并转换为 TAR 格式
4. **集成** → 打包到产品目录

## 注意事项

- 确保 SHA256 值准确无误,避免集成损坏的文件
- 模块路径配置需与解压后的实际目录结构一致
- 修改配置后需重新构建产品包使更改生效