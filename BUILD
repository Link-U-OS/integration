load("@rules_pkg//pkg:mappings.bzl", "pkg_attributes", "pkg_files")
load("@rules_pkg//pkg:pkg.bzl", "pkg_tar")
load("@integration//rules/utils:pkg_lib.bzl", "pkg_lib")
load("//rules/utils:override.bzl", "apply_override", "rm_override", "show_repos")
load("@integration//rules/utils:patchelf_tar.bzl", "patchelf_tar")
load("@integration//rules/utils:extract_zip.bzl", "extract_zip_to_tar")
load("@integration//rules/utils:repackage_tar.bzl", "repackage_tar")

package(default_visibility = ["//visibility:public"])

apply_override(
    name = "apply_override",
)

rm_override(
    name = "rm_override",
)

show_repos(
    name = "show",
)

config_setting(
    name = "is_a2_ultra",
    define_values = {"product": "A2_ULTRA"},
)

config_setting(
    name = "use_fmt_lib",
    define_values = {"USE_FMT_LIB": "on"},
)

config_setting(
    name = "use_stdexec",
    define_values = {"USE_STDEXEC": "on"},
)

config_setting(
    name = "use_global_logger",
    define_values = {"AIMRT_USE_GLOBAL_LOGGER": "on"},
)

pkg_files(
    name = "deployment_config",
    srcs = [
        "//config/deployment:deployment_config",
    ],
    prefix = "config/deployment",
)

alias(
    name = "iceoryx",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@iceoryx_aarch64//:iceoryx",
        "//conditions:default": "@iceoryx_x86_64//:iceoryx",
    }),
)

alias(
    name = "iox-roudi",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@iceoryx_aarch64//:iox-roudi",
        "//conditions:default": "@iceoryx_x86_64//:iox-roudi",
    }),
)

alias(
    name = "realsense2",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@realsense2_aarch64//:realsense2",
    }),
)

alias(
    name = "realsense2_rsusb",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@realsense2_tz_aarch64//:realsense2_rsusb",
    }),
)


alias(
    name = "unifex",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@unifex_aarch64//:unifex",
        "//conditions:default": "@unifex_x86_64//:unifex",
    }),
)


alias(
    name = "nghttp2",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@nghttp2_aarch64//:nghttp2",
        "//conditions:default": "@nghttp2_x86_64//:nghttp2",
    }),
)

alias(
    name = "archive",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@archive_aarch64//:archive",
        "//conditions:default": "@archive_x86_64//:archive",
    }),
)

alias(
    name = "pybind11",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@pybind11_aarch64//:pybind11",
        "//conditions:default": "@pybind11_x86_64//:pybind11",
    }),
)

alias(
    name = "OrbbecSDK",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@OrbbecSDK_aarch64//:OrbbecSDK",
        "//conditions:default": "@OrbbecSDK_x86_64//:OrbbecSDK",
    }),
)

alias(
    name = "lz4",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@lz4_aarch64//:lz4",
        "//conditions:default": "@lz4_x86_64//:lz4",
    }),
)

alias(
    name = "zenoh-c",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@zenoh-c_aarch64//:zenoh-c",
        "//conditions:default": "@zenoh-c_x86_64//:zenoh-c",
    }),
)

alias(
    name = "boost",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@boost_aarch64//:boost",
        "//conditions:default": "@boost_x86_64//:boost",
    }),
)

alias(
    name = "openssl",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@openssl_aarch64//:openssl",
        "//conditions:default": "@openssl_x86_64//:openssl",
    }),
)


alias(
    name = "xz",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@xz_aarch64//:xz",
        "//conditions:default": "@xz_x86_64//:xz",
    }),
)

alias(
    name = "zstd",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@zstd_aarch64//:zstd",
        "//conditions:default": "@zstd_x86_64//:zstd",
    }),
)

alias(
    name = "elfutils",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@elfutils_aarch64//:elfutils",
        "//conditions:default": "@elfutils_x86_64//:elfutils",
    }),
)


alias(
    name = "aimrt_protoc_plugin_cpp_gen_aimrt_cpp_rpc",
    actual = select({
        "//conditions:default": "@aimrt//:protoc_plugin_cpp_gen_aimrt_cpp_rpc",
    }),
)

alias(
    name = "aimrt_ros2_py_gen_aimrt_cpp_rpc",
    actual = select({
        "//conditions:default": "@aimrt//:ros2_py_gen_aimrt_cpp_rpc",
    }),
)


alias(
    name = "cuda",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@cuda_aarch64//:cuda",
    }),
)


alias(
    name = "nvbufsurftransform",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@nvbufsurftransform_aarch64//:nvbufsurftransform",
    }),
)

alias(
    name = "cudnn",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@cudnn_aarch64//:cudnn",
    }),
)

alias(
    name = "CURL",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@CURL_aarch64//:CURL",
        "//conditions:default": "@CURL_x86_64//:CURL",
    }),
)

alias(
    name = "paho_mqtt_c",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@paho_mqtt_c_aarch64//:paho_mqtt_c",
        "//conditions:default": "@paho_mqtt_c_x86_64//:paho_mqtt_c",
    }),
)

alias(
    name = "tensorrt",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@tensorrt_aarch64//:tensorrt",
    }),
)

alias(
    name = "vpi",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@vpi_aarch64//:vpi",
    }),
)

alias(
    name = "vulkan",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@vulkan_aarch64//:vulkan",
    }),
)

alias(
    name = "opencv",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@opencv_aarch64//:opencv",
        "//conditions:default": "@opencv_x86_64//:opencv",
    }),
)

alias(
    name = "fastrtps",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@fastrtps_aarch64//:fastrtps",
        "//conditions:default": "@fastrtps_x86_64//:fastrtps",
    }),
)


alias(
    name = "eigen",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@eigen_aarch64//:eigen",
        "//conditions:default": "@eigen_x86_64//:eigen",
    }),
)

alias(
    name = "fastcdr",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@fastcdr_aarch64//:fastcdr",
        "//conditions:default": "@fastcdr_x86_64//:fastcdr",
    }),
)

alias(
    name = "sqlite3",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@sqlite3_aarch64//:sqlite3",
        "//conditions:default": "@sqlite3_x86_64//:sqlite3",
    }),
)

alias(
    name = "sqlcipher",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@sqlcipher_aarch64//:sqlcipher",
        "//conditions:default": "@sqlcipher_x86_64//:sqlcipher",
    }),
)


alias(
    name = "protobuf",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@protobuf_aarch64//:protobuf",
        "//conditions:default": "@protobuf_x86_64//:protobuf",
    }),
)


alias(
    name = "opentelemetry_cpp",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@opentelemetry_cpp_aarch64//:opentelemetry_cpp",
        "//conditions:default": "@opentelemetry_cpp_x86_64//:opentelemetry_cpp",
    }),
)


alias(
    name = "tzcam",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@tzcam_aarch64//:tzcam",
    }),
)

alias(
    name = "jetson_multimedia",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@jetson_multimedia_aarch64//:jetson_multimedia",
    }),
)

alias(
    name = "X11",
    actual = select({
        "@integration//toolchains/platforms:is_aarch64": "@X11_aarch64//:X11",
    }),
)


repackage_tar(
    name = "aima_protocol_ros2_package_tar",
    srcs = select({
        "@integration//toolchains/platforms:is_aarch64": ["@aima_protocol//:ros2_package_aarch64"],
        "//conditions:default": ["@aima_protocol//:ros2_package_x86"],
    }),
    prefix = "share/ros2_package/aima_protocol_ros2_package",
)

filegroup(
    name = "ros2_package_tar_list",
    srcs = [
        ":aima_protocol_ros2_package_tar",
    ],
)

pkg_files(
    name = "x86_64_a2_ultra_addons_pkg_files",
    srcs = glob([
        "product/a2_ultra/addons/x86_64/**",
    ]),
    attributes = pkg_attributes(
        mode = "0755",
    ),
    strip_prefix = "product/a2_ultra/addons/x86_64",
)

pkg_tar(
    name = "x86_64_addons_tar",
    srcs = select({
        "//conditions:default": [
            ":x86_64_a2_ultra_addons_pkg_files",
        ],
    }),
    extension = "tar",
    mode = "0755",
    tags = ["tar"],
    deps = [
    ],
)

pkg_files(
    name = "orin_a2_ultra_addons_pkg_file",
    srcs = glob([
        "product/a2_ultra/addons/orin/**",
    ]),
    attributes = pkg_attributes(
        mode = "0755",
    ),
    strip_prefix = "product/a2_ultra/addons/orin",
)

pkg_tar(
    name = "orin_addons_tar",
    srcs = select({
        "//conditions:default": [
            ":orin_a2_ultra_addons_pkg_file",
        ],
    }),
    extension = "tar",
    mode = "0755",
    tags = ["tar"],
)

pkg_lib(
    name = "mcap_cli_tar",
    srcs = select({
        "@integration//toolchains/platforms:is_aarch64": ["@mcap_cli_aarch64//:mcap_cli"],
        "//conditions:default": ["@mcap_cli_x86_64//:mcap_cli"],
    }),
    prefix = "tools/record_playback",
)


extract_zip_to_tar(
    name = "rl_deploy",
    zip_file = ["@rl_deploy_zip//file"],
)

extract_zip_to_tar(
    name = "hal_ethercat",
    zip_file = ["@hal_ethercat_zip//file"],
)

pkg_tar(
    name = "all_plugins_tar",
    srcs = [
        ":deployment_config",
    ],
    extension = "tar",
    mode = "0755",
    strip_prefix = ".",
    tags = ["tar"],
    deps = [
        "@aimrt//:aimrt_plugins_flatten_tar",
        "@aimrt_comm//:aimrte_plugins_flatten_tar",
        "@aimrt_viz//:aimrt_viz_flatten_tar",
    ],
)

pkg_tar(
    name = "all_typesupport_tar",
    srcs = [
    ],
    extension = "tar",
    mode = "0755",
    strip_prefix = ".",
    tags = ["tar"],
    deps = [
        "@aimrt//:aimrt_typesupport_flatten_tar",
        "@aimrt_comm//:aimrte_typesupport_flatten_tar",
    ],
)

filegroup(
    name = "x86_64_a2_ultra_tar_list",
    srcs = [
        ":rl_deploy_tar",
        ":hal_ethercat_tar",
        ":ros2_package_tar_list",
        "@aimrt_comm//:record_playback_module_tar",
        "@@aimrt_health_monitor//:health_monitor_tar",
        "@aimrt_process_manager//:process_manager_tar",
    ],
)

alias(
    name = "x86_64_target_tar_list",
    actual = select({
        ":is_a2_ultra": ":x86_64_a2_ultra_tar_list",
        "//conditions:default": ":x86_64_a2_ultra_tar_list",
    }),
)

filegroup(
    name = "orin_a2_ultra_tar_list",
    srcs = [
        ":ros2_package_tar_list",
        "@aima_sensor//:tzcamera_tar",
        "@aimrt_comm//:record_playback_module_tar",
        "@aimrt_health_monitor//:health_monitor_tar",
        "@aimrt_process_manager//:process_manager_tar",
        "@aimrt_viz//:viz_tar",
    ],
)

alias(
    name = "orin_target_tar_list",
    actual = select({
        ":is_a2_ultra": "orin_a2_ultra_tar_list",
        "//conditions:default": "orin_a2_ultra_tar_list",
    }),
)

pkg_tar(
    name = "x86_64_pkg_origin_tar",
    srcs = [
    ],
    include_runfiles = 1,
    mode = "0755",
    strip_prefix = ".",
    tags = ["tar"],
    deps = [
        ":x86_64_addons_tar",
        ":x86_64_target_tar_list",
    ],
)

patchelf_tar(
    name = "x86_64_pkg_tar",
    out = "x86_64_pkg_tar.tar",
    tar = ":x86_64_pkg_origin_tar",
)

pkg_tar(
    name = "orin_pkg_origin_tar",
    srcs = [],
    include_runfiles = 1,
    mode = "0755",
    strip_prefix = ".",
    tags = ["tar"],
    deps = [
        ":orin_addons_tar",
        ":orin_target_tar_list",
    ],
)

patchelf_tar(
    name = "orin_pkg_tar",
    out = "orin_pkg_tar.tar",
    tar = ":orin_pkg_origin_tar",
)
