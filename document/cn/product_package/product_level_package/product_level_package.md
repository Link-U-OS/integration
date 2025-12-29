# 产品级包构建

## 基本用法

```bash
bash tools/build_package.sh [参数]
```

## 参数说明

| 参数 | 说明 | 默认值 | 示例 |
|------|------|--------|------|
| `-p` | 指定编译平台 | `A2_ULTRA` | `-p A2_ULTRA` |
| `-j` | 编译线程数 | `0` (自动) | `-j 8` |
| `-g` | 编译调试版本 | 关闭 | `-g` |
| `-o` | 使用本地源码覆盖指定仓库 | 无 | `-o aimrt_comm=../aimrt_comm` |
| `-c` | 清除编译缓存 | 关闭 | `-c` |
| `-e` | 传递额外编译选项 | 无 | `-e "--config=commit"` |

## 编译模式

### 分支模式（默认）

使用 `projects/defs/source_branch.yaml` 中指定的分支源码。若需每次自动拉取最新代码，请先执行：

```bash
bazel clean --expunge
```

### 节点模式

使用 `projects/defs/source_commit.yaml` 中指定的提交节点源码，通过添加以下参数启用：

```bash
-e "--config=commit"
```

## 常见场景

### 基本编译

```bash
bash tools/build_package.sh
```

### 调试编译

使用 8 线程编译调试版本：

```bash
bash tools/build_package.sh -j 8 -g
```

### 清除缓存并使用本地源码

```bash
bash tools/build_package.sh -c -o aimrt_comm=../aimrt_comm
```

### 使用特定提交节点编译

```bash
bash tools/build_package.sh -e "--config=commit"
```