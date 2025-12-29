package(default_visibility = ["//visibility:public"])

cc_library(
    name = "cv_bridge",
    srcs = [
        "src/cv_bridge.cpp",
        "src/rgb_colors.cpp",
    ],
    hdrs = glob([
        "include/**/*.h",
        "include/**/*.hpp",
        "src/*.hpp",
    ]),
    includes = [
        "include",
        "include/cv_bridge",
        "src",
    ],
    deps = [
        "@integration//:boost",
        "@integration//:opencv",
        "@ros2_common_interfaces//:cpp_sensor_msgs",
        "@ros2_rclcpp//:rclcpp",
        "@ros2_rcpputils//:rcpputils",
    ],
)
