# 代码仓管理

代码仓依赖指编译时所需的各个代码仓库，包括中间件仓库（如 aimrt）、协议仓库（如 aimrt_protocol）、公共接口仓库（如 aimrt_comm）、算法仓库（如 aima_sensor）和 Bazel ros2 仓（如 rules_ros2）。

## 版本定义

### 分支模式

在 `projects/defs/source_branch.yaml` 中定义各仓库的分支信息：

```yaml
aimrt:
  git:
    branch: main
    remote: git@github.com:Link-U-OS/aimrt.git
```

### 提交节点模式

在 `projects/defs/source_commit.yaml` 中定义各仓库的特定提交节点：

```yaml
aimrt:
  git:
    commit: 6386885d134bdf12777b15e7a9130c3c0f48c07c
    remote: git@github.com:Link-U-OS/aimrt.git
    shallow_since: 1761999534 +0800
```

## 版本选择优先级

通过 Bazel 编译参数指定使用的代码仓版本，按优先级从高到低排列：

**1. 本地源码覆盖（最高优先级）**

```bash
--override_repository $repoName=$repoToPath
```

强制使用指定的本地源码路径进行编译。

**2. 提交节点模式**

```bash
--config=commit
```

使用 `source_commit.yaml` 中定义的固定提交节点。

**3. 分支模式（默认）**

使用 `source_branch.yaml` 中定义的分支版本。