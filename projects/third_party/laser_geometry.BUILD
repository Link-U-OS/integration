package(default_visibility = ["//visibility:public"])

cc_library(
    name = "laser_geometry",
    srcs = ["src/laser_geometry.cpp"],
    hdrs = glob(["include/**/*.hpp"]),
    defines = ["LASER_GEOMETRY_BUILDING_LIBRARY"],
    includes = ["include"],
    deps = [
        "@integration//:eigen",
        "@ros2_common_interfaces//:cpp_sensor_msgs",
        "@ros2_geometry2//:tf2",
        "@ros2_rclcpp//:rclcpp",
    ],
)
