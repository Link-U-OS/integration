package(default_visibility = ["//visibility:public"])

cc_library(
    name = "interactive_markers",
    srcs = glob([
        "src/*.cpp",
    ]),
    hdrs = glob(["include/**/*.hpp"]),
    defines = ["INTERACTIVE_MARKERS_BUILDING_LIBRARY"],
    includes = ["include", "include/interactive_markers"],
    deps = [
        "@ros2_rclcpp//:rclcpp",
        "@ros2_geometry2//:tf2",
        "@ros2_common_interfaces//:cpp_visualization_msgs",
        "@ros2_rmw//:rmw",
        "@ros2_geometry2//:cpp_tf2_geometry_msgs",
    ],
)
