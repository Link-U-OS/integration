# Product-Level Package Build

## Basic Usage

```bash
bash tools/build_package.sh [options]
```

## Parameter Description

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `-p` | Specify build platform | `A2_ULTRA` | `-p A2_ULTRA` |
| `-j` | Number of compile threads | `0` (auto) | `-j 8` |
| `-g` | Build debug version | Disabled | `-g` |
| `-o` | Use local source code to override specified repository | None | `-o aimrt_comm=../aimrt_comm` |
| `-c` | Clear build cache | Disabled | `-c` |
| `-e` | Pass additional build options | None | `-e "--config=commit"` |

## Build Modes

### Branch Mode (Default)

Use the branch source code specified in `projects/defs/source_branch.yaml`. If you need to automatically pull the latest code each time, execute first:

```bash
bazel clean --expunge
```

### Commit Mode

Use the specific commit node source code specified in `projects/defs/source_commit.yaml`, enabled by adding the following parameter:

```bash
-e "--config=commit"
```

## Common Scenarios

### Basic Build

```bash
bash tools/build_package.sh
```

### Debug Build

Compile debug version with 8 threads:

```bash
bash tools/build_package.sh -j 8 -g
```

### Clear Cache and Use Local Source Code

```bash
bash tools/build_package.sh -c -o aimrt_comm=../aimrt_comm
```

### Build Using Specific Commit Node

```bash
bash tools/build_package.sh -e "--config=commit"
```