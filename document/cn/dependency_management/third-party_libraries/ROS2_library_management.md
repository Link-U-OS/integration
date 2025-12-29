# ROS2库管理

## 简介

[mvukov/rules_ros2](https://github.com/mvukov/rules_ros2) 是一个开源项目，提供了使用 Bazel 构建 ROS 2 的完整解决方案。我们基于该项目维护了增强版本 [Link-U-OS/rules_ros2](https://github.com/Link-U-OS/rules_ros2)，以支持项目的特定需求。

## 核心功能

- **无依赖构建**：使用 Bazel 构建 ROS 2 项目，无需通过 apt 安装系统包
- **多语言支持**：支持 C++、Python 和 Rust 节点
- **自动代码生成**：为消息、服务和动作生成对应语言的代码
- **运行时宏**：提供 `ros2_launch` 和 `ros2_test` 宏用于部署和测试
- **插件管理**：通过 `ros2_plugin` 宏管理 ROS 2 插件
- **中间件集成**：支持 CycloneDDS，可通过 iceoryx 实现零拷贝共享内存传输
- **日志支持**：支持 spdlog 和 syslog 后端

## 工作区集成

在项目的 `WORKSPACE` 文件中配置以下依赖：

```python
load("@com_github_mvukov_rules_ros2//repositories:repositories.bzl", "ros2_repositories", "ros2_workspace_repositories")

ros2_workspace_repositories()
ros2_repositories()

load("@com_github_mvukov_rules_ros2//repositories:deps.bzl", "ros2_deps")
ros2_deps()

python_register_toolchains(
    name = "rules_ros2_python",
    python_version = "3.10",
)

load("@rules_python//python:pip.bzl", "pip_parse")

pip_parse(
    name = "rules_ros2_pip_deps",
    python_interpreter_target = "@rules_ros2_python_host//:python",
    requirements_lock = "@com_github_mvukov_rules_ros2//:requirements_lock.txt",
)

load(
    "@rules_ros2_pip_deps//:requirements.bzl",
    install_rules_ros2_pip_deps = "install_deps",
)

install_rules_ros2_pip_deps()
```

## 依赖引用

在 Bazel target 中引用 ROS 2 库时，使用 `Link-U-OS/rules_ros2` 中预定义的目标。以下示例展示如何在 C++ 库中使用：

```python
cc_library(
    name = "base_perception",
    srcs = glob(["*.cc"]),
    hdrs = glob(["*.h"]),
    deps = [
        "@ros2_rclcpp//:rclcpp",
        "@ros2_common_interfaces//:cpp_std_msgs",
        "@ros2_common_interfaces//:cpp_sensor_msgs",
        "@ros2_common_interfaces//:cpp_nav_msgs",
        "@ros2_common_interfaces//:cpp_visualization_msgs",
        "@ros2_message_filters//:message_filters",
    ],
)
```

通过这种方式，可以轻松在任何 Bazel 构建目标中集成 ROS 2 依赖。