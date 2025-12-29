# Code Repository Management

Code repository dependencies refer to various code repositories required at compile time, including middleware repositories (such as aimrt), protocol repositories (such as aimrt_protocol), common interface repositories (such as aimrt_comm), algorithm repositories (such as aimrt_sensor), and Bazel ros2 repositories (such as rules_ros2).

## Version Definition

### Branch Mode

Define branch information for each repository in `projects/defs/source_branch.yaml`:

```yaml
aimrt:
  git:
    branch: main
    remote: git@github.com:Link-U-OS/aimrt.git
```

### Commit Mode

Define specific commit nodes for each repository in `projects/defs/source_commit.yaml`:

```yaml
aimrt:
  git:
    commit: 6386885d134bdf12777b15e7a9130c3c0f48c07c
    remote: git@github.com:Link-U-OS/aimrt.git
    shallow_since: 1761999534 +0800
```

## Version Selection Priority

Specify the code repository version to use through Bazel build parameters, ordered by priority from highest to lowest:

**1. Local Source Code Override (Highest Priority)**

```bash
--override_repository $repoName=$repoToPath
```

Force the use of a specified local source code path for compilation.

**2. Commit Mode**

```bash
--config=commit
```

Use the fixed commit node defined in `source_commit.yaml`.

**3. Branch Mode (Default)**

Use the branch version defined in `source_branch.yaml`.
