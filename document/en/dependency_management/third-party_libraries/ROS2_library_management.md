# ROS2 Library Management

## Introduction

[mvukov/rules_ros2](https://github.com/mvukov/rules_ros2) is an open-source project that provides a comprehensive solution for building ROS 2 with Bazel. We maintain an enhanced version based on this project at [Link-U-OS/rules_ros2](https://github.com/Link-U-OS/rules_ros2) to support project-specific requirements.

## Core Features

- **Dependency-Free Build**: Build ROS 2 projects with Bazel without requiring system packages installed via apt
- **Multi-Language Support**: Support for C++, Python, and Rust nodes
- **Automatic Code Generation**: Generate language-specific code for messages, services, and actions
- **Runtime Macros**: Provide `ros2_launch` and `ros2_test` macros for deployment and testing
- **Plugin Management**: Manage ROS 2 plugins through the `ros2_plugin` macro
- **Middleware Integration**: Support for CycloneDDS, with zero-copy shared memory transport achievable through iceoryx
- **Logging Support**: Support for spdlog and syslog backends

## Workspace Integration

Configure the following dependencies in your project's `WORKSPACE` file:

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

## Dependency References

When referencing ROS 2 libraries in Bazel targets, use predefined targets from `Link-U-OS/rules_ros2`. The following example demonstrates how to use them in a C++ library:

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

In this way, you can easily integrate ROS 2 dependencies into any Bazel build target.
