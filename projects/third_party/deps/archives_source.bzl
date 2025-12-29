load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def all_source_packages():
    http_archive(
        name = "asio",
        build_file = "@integration//projects/third_party:asio.BUILD",
        sha256 = "755bd7f85a4b269c67ae0ea254907c078d408cce8e1a352ad2ed664d233780e8",
        urls = [
            "https://github.com/chriskohlhoff/asio/archive/refs/tags/asio-1-30-2.tar.gz"
        ],
        strip_prefix = "asio-asio-1-30-2",
    )

    http_archive(
        name = "benchmark",
        sha256 = "409075176168dc46bbb81b74c1b4b6900385b5d16bfc181d678afb060d928bd3",
        strip_prefix = "benchmark-1.9.2",
        urls = [
            "https://github.com/google/benchmark/archive/refs/tags/v1.9.2.tar.gz"
        ],
    )
    http_archive(
        name = "buildifier_prebuilt",
        sha256 = "481f220bee90024f4e63d3e516a5e708df9cd736170543ceab334064fa773f41",
        strip_prefix = "buildifier-prebuilt-7.1.2",
        urls = [
            "https://github.com/keith/buildifier-prebuilt/archive/refs/tags/7.1.2.tar.gz"
        ],
    )

    http_archive(
        name = "concurrentqueue",
        build_file = "@integration//projects/third_party:concurrentqueue.BUILD",
        sha256 = "87fbc9884d60d0d4bf3462c18f4c0ee0a9311d0519341cac7cbd361c885e5281",
        strip_prefix = "concurrentqueue-1.0.4",
        urls = [
            "https://github.com/cameron314/concurrentqueue/archive/refs/tags/v1.0.4.tar.gz"
        ],
    )

    http_archive(
        name = "fast-cpp-csv-parser",
        build_file = "@integration//projects/third_party:fast-cpp-csv-parser.BUILD",
        sha256 = "e5997fc7cb143bfb3a4fec1abd1d803f3eda49f4c38b053474cdeb22425fc893",
        strip_prefix = "fast-cpp-csv-parser-master",
        urls = [
            "https://github.com/ben-strasser/fast-cpp-csv-parser/archive/refs/heads/master.zip"
        ],
    )

    http_archive(
        name = "com_github_gflags_gflags",
        sha256 = "34af2f15cf7367513b352bdcd2493ab14ce43692d2dcd9dfc499492966c64dcf",
        strip_prefix = "gflags-2.2.2",
        urls = [
            "https://github.com/gflags/gflags/archive/refs/tags/v2.2.2.tar.gz"
        ],
    )

    http_archive(
        name = "cpptoml",
        build_file = "@integration//projects/third_party:cpptoml.BUILD",
        sha256 = "11b1c07132d23e85071cef3d0fe9bc605de731fcd1b1c3f3d43ed09a6fd7a850",
        urls = [
            "https://github.com/skystrife/cpptoml/archive/refs/tags/v0.1.0.tar.gz"
        ],
        strip_prefix = "cpptoml-0.1.0",
        patch_cmds = [
            "sed -i 's/#include <cstring>/#include <limits>/' include/cpptoml.h",
        ],
    )

    http_archive(
        name = "cv_bridge",
        build_file = "@integration//projects/third_party:cv_bridge.BUILD",
        sha256 = "bf8a18770ffe3335e9bf96cb89be886a846be10382e67c2dc93cd4e387b2c3f9",
        strip_prefix = "vision_opencv-3.2.1/cv_bridge",
        urls = [
            "https://github.com/ros-perception/vision_opencv/archive/refs/tags/3.2.1.tar.gz"
        ],
        patch_args = ["-p1"],
        patches = ["@integration//projects/third_party/patches:add_cv_bridge_export_header.patch"],
    )

    http_archive(
        name = "tabulate",
        build_file = "@integration//projects/third_party:tabulate.BUILD",
        sha256 = "76a615106095fa3ca780e0204e169e5c7ebaaba0504d415f1ac443f6d0e593ee",
        strip_prefix = "tabulate-1.5",
        urls = [
            "https://github.com/p-ranav/tabulate/archive/refs/tags/v1.5.tar.gz"
        ],
    )
    http_archive(
        name = "fmt",
        build_file = "@integration//projects/third_party:fmt.BUILD",
        sha256 = "5dea48d1fcddc3ec571ce2058e13910a0d4a6bab4cc09a809d8b1dd1c88ae6f2",
        strip_prefix = "fmt-9.1.0",
        urls = [
            "https://github.com/fmtlib/fmt/archive/refs/tags/9.1.0.tar.gz"
        ],
    )

    http_archive(
        name = "glog",
        sha256 = "375106b5976231b92e66879c1a92ce062923b9ae573c42b56ba28b112ee4cc11",
        strip_prefix = "glog-0.7.0",
        urls = [
            "https://github.com/google/glog/archive/refs/tags/v0.7.0.tar.gz"
        ],
    )
    http_archive(
        name = "spdlog",
        urls = [
            "https://github.com/gabime/spdlog/archive/refs/tags/v1.15.0.tar.gz"
        ],
        sha256 = "9962648c9b4f1a7bbc76fd8d9172555bad1871fdb14ff4f842ef87949682caa5",
        strip_prefix = "spdlog-1.15.0",
        build_file = "@integration//projects/third_party:spdlog.BUILD",
    )
    http_archive(
        name = "jsoncpp",
        build_file = "@integration//projects/third_party:jsoncpp.BUILD",
        sha256 = "f409856e5920c18d0c2fb85276e24ee607d2a09b5e7d5f0a371368903c275da2",
        strip_prefix = "jsoncpp-1.9.5",
        urls = [
            "https://github.com/open-source-parsers/jsoncpp/archive/refs/tags/1.9.5.tar.gz"
        ],
    )

    http_archive(
        name = "laser_geometry",
        sha256 = "fe836029a0e960d8b2095b2cd3ce993b556fc2dd6ce73df5dfe266f90ba62017",
        strip_prefix = "laser_geometry-2.4.0",
        build_file = "@integration//projects/third_party:laser_geometry.BUILD",
        urls = [
            "https://github.com/ros-perception/laser_geometry/archive/refs/tags/2.4.0.tar.gz"
        ],
    )

    http_archive(
        name = "magic_enum",
        urls = [
            "https://github.com/Neargye/magic_enum/archive/refs/tags/v0.9.7.tar.gz"

        ],
        sha256 = "c047bc7ca0b76752168140e7ae9a4a30d72bf6530c196fdfbf5105a39d40cc46",
    )

    http_archive(
        name = "eigen_stl_containers",
        build_file = "@integration//projects/third_party:eigen_stl_containers.BUILD",
        sha256 = "75f92ead9cd97e7ac54a4c148cf1d419c1facf087d702b0241e3e5a968c1590e",
        strip_prefix = "eigen_stl_containers-1.1.0",
        urls = [
            "https://github.com/ros/eigen_stl_containers/archive/refs/tags/1.1.0.tar.gz"
        ],
    )

    http_archive(
        name = "qhull",
        build_file = "@integration//projects/third_party:qhull.BUILD",
        sha256 = "59356b229b768e6e2b09a701448bfa222c37b797a84f87f864f97462d8dbc7c5",
        strip_prefix = "qhull-2020.2",
        urls = [
            "https://github.com/qhull/qhull/archive/refs/tags/2020.2.tar.gz"
        ],
    )
    http_archive(
        name = "interactive_markers",
        build_file = "@integration//projects/third_party:interactive_markers.BUILD",
        sha256 = "5e532f93f82e88d669d0883911d3f8d21b33f289970abd19a5cd7392a89bf69d",
        urls = [
            "https://github.com/ros-visualization/interactive_markers/archive/refs/tags/2.3.2.tar.gz"
        ],
        strip_prefix = "interactive_markers-2.3.2",
        patch_args = ["-p1"],
        patches = ["@integration//projects/third_party/patches:fix_interactive_markers_rclcpp_time.patch"],
    )

    http_archive(
        name = "nlohmann_json",
        sha256 = "0d8ef5af7f9794e3263480193c491549b2ba6cc74bb018906202ada498a79406",
        urls = [
            "https://github.com/nlohmann/json/archive/refs/tags/v3.11.3.tar.gz"
        ],
        strip_prefix = "json-3.11.3",
    )

    http_archive(
        name = "reflectcpp",
        build_file = "@integration//projects/third_party:reflectcpp.BUILD",
        sha256 = "d2c8876d993ddc8c57c5804e767786bdb46a2bdf1a6cd81f4b14f57b1552dfd7",
        strip_prefix = "reflect-cpp-0.10.0",
        urls = [
            "https://github.com/getml/reflect-cpp/archive/refs/tags/v0.10.0.tar.gz"
        ],
    )

    http_archive(
        name = "stdexec",
        urls = [
            "https://github.com/NVIDIA/stdexec/archive/refs/tags/nvhpc-23.09.rc4.tar.gz",
        ],
        sha256 = "896ac953bb797d03bdf7369966e12e7ac636606043a2c7cac81250d327929a2b",
        strip_prefix = "stdexec-nvhpc-23.09.rc4",
        build_file = "@integration//projects/third_party:stdexec.BUILD",
    )


    http_archive(
        name = "random_numbers",
        build_file = "@integration//projects/third_party:random_numbers.BUILD",
        sha256 = "41b69506b1c2e29c003cb5ffb4082e79275f99ad36a1b67ef873698fcfda94b2",
        strip_prefix = "random_numbers-2.0.4",
        urls = [
            "https://github.com/moveit/random_numbers/archive/refs/tags/2.0.4.tar.gz"
        ],
    )
    http_archive(
        name = "libccd",
        build_file = "@integration//projects/third_party:libccd.BUILD",
        urls = [
            "https://github.com/danfis/libccd/archive/refs/tags/v2.1.tar.gz"
        ],
        sha256 = "542b6c47f522d581fbf39e51df32c7d1256ac0c626e7c2b41f1040d4b9d50d1e",
        strip_prefix = "libccd-2.1",
    )

    http_archive(
        name = "poco",
        build_file = "@integration//projects/third_party:poco.BUILD",
        sha256 = "8a7bfd0883ee95e223058edce8364c7d61026ac1882e29643822ce9b753f3602",
        strip_prefix = "poco-poco-1.11.0-release",
        urls = [
            "https://github.com/pocoproject/poco/archive/refs/tags/poco-1.11.0-release.tar.gz"
        ],
    )
    http_archive(
        name = "yaml-cpp",
        sha256 = "fbe74bbdcee21d656715688706da3c8becfd946d92cd44705cc6098bb23b3a16",
        strip_prefix = "yaml-cpp-0.8.0",
        urls = [
            "https://github.com/jbeder/yaml-cpp/archive/refs/tags/0.8.0.tar.gz"
        ],
    )

    http_archive(
        name = "breakpad",
        build_file = "@integration//projects/third_party:breakpad.BUILD",
        sha256 = "b1940cd9231822f1d332d1776456afa8d452e59799cbeef70641885c39547b28",
        strip_prefix = "breakpad-2024.02.16",
        urls = [
            "https://github.com/google/breakpad/archive/refs/tags/v2024.02.16.tar.gz"
        ],
        patch_args = ["-p1"],
        patches = ["@integration//projects/third_party/patches:fix_linux_syscall_support_header.patch"],
    )
    http_archive(
        name = "zlib",
        urls = [
            "https://github.com/madler/zlib/archive/refs/tags/v1.3.1.tar.gz"
        ],
        sha256 = "17e88863f3600672ab49182f217281b6fc4d3c762bde361935e436a95214d05c",
        strip_prefix = "zlib-1.3.1",
        build_file = "@integration//projects/third_party:zlib.BUILD",
    )

    http_archive(
        name = "tbb",
        urls = [
            "https://github.com/uxlfoundation/oneTBB/archive/refs/tags/v2021.13.0.tar.gz"
        ],
        sha256 = "3ad5dd08954b39d113dc5b3f8a8dc6dc1fd5250032b7c491eb07aed5c94133e1",
        strip_prefix = "oneTBB-2021.13.0",
        build_file = "@integration//projects/third_party:tbb.BUILD",
    )

    http_archive(
        name = "libsamplerate",
        urls = [
            "https://github.com/libsndfile/libsamplerate/archive/refs/tags/0.2.2.tar.gz"
        ],
        sha256 = "16e881487f184250deb4fcb60432d7556ab12cb58caea71ef23960aec6c0405a",
        strip_prefix = "libsamplerate-0.2.2",
        build_file = "@integration//projects/third_party:libsamplerate.BUILD",
    )

    http_archive(
        name = "minizip",
        urls = [
            "https://github.com/madler/zlib/archive/refs/tags/v1.3.1.tar.gz"
        ],
        sha256 = "17e88863f3600672ab49182f217281b6fc4d3c762bde361935e436a95214d05c",
        strip_prefix = "zlib-1.3.1",
        build_file = "@integration//projects/third_party:minizip.BUILD",
    )
    http_archive(
        name = "platforms",
        sha256 = "852b71bfa15712cec124e4a57179b6bc95d59fdf5052945f5d550e072501a769",
        urls = [
            "https://github.com/bazelbuild/platforms/archive/refs/tags/1.0.0.tar.gz"
        ],
        strip_prefix = "platforms-1.0.0",
        patch_cmds = [
            "echo 'workspace(name = \"platforms\")' > WORKSPACE",
        ],
    )

    http_archive(
        name = "tinyxml2",
        sha256 = "3bdf15128ba16686e69bce256cc468e76c7b94ff2c7f391cc5ec09e40bff3839",
        strip_prefix = "tinyxml2-10.0.0",
        urls = [
            "https://github.com/leethomason/tinyxml2/archive/refs/tags/10.0.0.tar.gz"
        ],
        build_file = "@integration//projects/third_party:tinyxml2.BUILD",
    )

    http_archive(
        name = "rules_cuda",
        sha256 = "13353b7ba740a7e29272b5cf2c697f616d1b83d7f9f50b3278e19246e1d9746b",
        strip_prefix = "rules_cuda-0.2.5",
        urls = [
            "https://github.com/bazel-contrib/rules_cuda/archive/refs/tags/v0.2.5.tar.gz"
        ],
        patch_cmds = [
            "echo 'workspace(name = \"rules_cuda\")' > WORKSPACE",
        ],
    )

    http_archive(
        name = "rules_pkg",
        sha256 = "e110311d898c1ff35f39829ae3ec56e39c0ef92eb44de74418982a114f51e132",
        urls = [
            "https://github.com/bazelbuild/rules_pkg/archive/refs/tags/0.7.0.tar.gz"
        ],
        strip_prefix = "rules_pkg-0.7.0",
        patch_cmds = [
            "echo 'workspace(name = \"rules_pkg\")' > WORKSPACE",
        ],
    )

    http_archive(
        name = "rules_python",
        sha256 = "2ef40fdcd797e07f0b6abda446d1d84e2d9570d234fddf8fcd2aa262da852d1c",
        strip_prefix = "rules_python-1.2.0",
        urls = [
            "https://github.com/bazel-contrib/rules_python/archive/refs/tags/1.2.0.tar.gz"
        ],
        patch_cmds = [
            "echo 'workspace(name = \"rules_python\")' > WORKSPACE",
            "sed -i 's/default = False/default = True/g' python/private/python_repository.bzl",
        ],
    )
    http_archive(
        name = "com_google_protobuf",
        urls = [
            "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v30.0.tar.gz"
        ],
        strip_prefix = "protobuf-30.0",
        sha256 = "9df0e9e8ebe39f4fbbb9cf7db3d811287fe3616b2f191eb2bf5eaa12539c881f",
    )
    http_archive(
        name = "ros2",
        urls = [
            "https://github.com/ros2/ros2/archive/refs/tags/release-humble-20241205.tar.gz"
        ],
        sha256 = "67757489197ea587d1832cccc2318f38468a760dfcf7627cffd78e2a4e25ac4a",
        strip_prefix = "ros2-release-humble-20241205",
        build_file = "@com_github_mvukov_rules_ros2//repositories:ros2.BUILD.bazel",
    )

    http_archive(
        name = "ros2_rmw_fastrtps",
        urls = [
            "https://github.com/ros2/rmw_fastrtps/archive/refs/tags/6.2.6.tar.gz"
        ],
        sha256 = "8967d63778ab3422666ab8cdf37a97cb00bc765a448c2e5b32e7708de1509c23",
        strip_prefix = "rmw_fastrtps-6.2.6",
        build_file = "@com_github_mvukov_rules_ros2//repositories:rmw_fastrtps.BUILD.bazel",
        patch_args = ["-p1"],
        patches = ["@com_github_mvukov_rules_ros2//repositories/patches:fix_ros2_rmw_DDS_CDR_enum.patch"],
    )
    http_archive(
        name = "osrf_pycommon",
        urls = [
            "https://github.com/osrf/osrf_pycommon/archive/refs/tags/2.1.4.tar.gz"
        ],
        sha256 = "a5c57a1021d1620cfe4620c4f1611e040de86e7afcce53509e968a4098ce1fa2",
        strip_prefix = "osrf_pycommon-2.1.4",
        build_file = "@com_github_mvukov_rules_ros2//repositories:osrf_pycommon.BUILD.bazel",
    )
    http_archive(
        name = "ros2_message_filters",
        urls = [
            "https://github.com/ros2/message_filters/archive/refs/tags/4.3.5.tar.gz"
        ],
        sha256 = "fd64677763d15583a8f5efcdf45dd43548afb3f4e4bf1fb79eed55351d6b983b",
        strip_prefix = "message_filters-4.3.5",
        build_file = "@com_github_mvukov_rules_ros2//repositories:message_filters.BUILD.bazel",
    )
    http_archive(
        name = "ros2_navigation",
        urls = [
            "https://github.com/ros-planning/navigation_msgs/archive/refs/tags/2.1.0.tar.gz"
        ],
        sha256 = "4de38585745387d0a6557c28c66cca88dd4cfdf9d2e15871669fa8ecd2657f03",
        strip_prefix = "navigation_msgs-2.1.0",
        build_file = "@com_github_mvukov_rules_ros2//repositories:navigation.BUILD.bazel",
    )
    http_archive(
        name = "ros2_pcl_msgs",
        urls = [
            "https://github.com/ros-perception/pcl_msgs/archive/refs/tags/1.0.0.tar.gz"
        ],
        sha256 = "9a3256d5bd44a2e99526c5cf4ed16198471d2b43c63be74a5fcf8d0dcbb29489",
        strip_prefix = "pcl_msgs-1.0.0",
        build_file = "@com_github_mvukov_rules_ros2//repositories:pcl_msgs.BUILD.bazel",
    )
    http_archive(
        name = "rules_java",
        urls = [
            "https://github.com/bazelbuild/rules_java/archive/refs/tags/8.6.1.tar.gz"
        ],
        sha256 = "b2519fabcd360529071ade8732f208b3755489ed7668b118f8f90985c0e51324",
        strip_prefix = "rules_java-8.6.1",
        patch_cmds = [
            "echo 'workspace(name = \"rules_java\")' > WORKSPACE",
        ],
    )
    http_archive(
        name = "ros2_rosidl_typesupport_fastrtps",
        urls = [
            "https://github.com/ros2/rosidl_typesupport_fastrtps/archive/refs/tags/2.2.2.tar.gz"
        ],
        sha256 = "3c62ba6e0ff9182365abb55e245a8972605f17b7a0b81f8212af590f43ac6ce2",
        strip_prefix = "rosidl_typesupport_fastrtps-2.2.2",
        build_file = "@com_github_mvukov_rules_ros2//repositories:rosidl_typesupport_fastrtps.BUILD.bazel",
        patch_args = ["-p1"],
        patches = ["@com_github_mvukov_rules_ros2//repositories/patches:fix_rosidl_typesupport_fastrtps.patch"],
    )

    http_archive(
        name = "ros2_rmw_dds_common",
        urls = [
            "https://github.com/ros2/rmw_dds_common/archive/refs/tags/1.6.0.tar.gz"
        ],
        sha256 = "85dd9f586d53b658e5389a388fe3d99a884ba06f567a59f9908ecb96e29132ef",
        strip_prefix = "rmw_dds_common-1.6.0",
        build_file = "@com_github_mvukov_rules_ros2//repositories:rmw_dds_common.BUILD.bazel",
    )
    http_archive(
        name = "rules_foreign_cc",
        urls = [
            "https://github.com/bazel-contrib/rules_foreign_cc/archive/refs/tags/0.13.0.tar.gz"
        ],
        sha256 = "8e5605dc2d16a4229cb8fbe398514b10528553ed4f5f7737b663fdd92f48e1c2",
        strip_prefix = "rules_foreign_cc-0.13.0",
    )
    http_archive(
        name = "googletest",
        sha256 = "7b42b4d6ed48810c5362c265a17faebe90dc2373c885e5216439d37927f02926",
        strip_prefix = "googletest-1.15.2",
        urls = [
            "https://github.com/google/googletest/archive/refs/tags/v1.15.2.tar.gz"
        ],
    )

    http_archive(
        name = "bazel_features",
        urls = [
            "https://github.com/bazel-contrib/bazel_features/archive/refs/tags/v1.10.0.tar.gz"
        ],
        sha256 = "95fb3cfd11466b4cad6565e3647a76f89886d875556a4b827c021525cb2482bb",
        strip_prefix = "bazel_features-1.10.0",
    )
    http_archive(
        name = "bazel_skylib",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/archive/refs/tags/1.7.0.tar.gz"
        ],
        sha256 = "79488428983d1fac331a248bca8666071447e0582595a54a5386b9ade13e7815",
        strip_prefix = "bazel-skylib-1.7.0",
        patch_cmds = [
            "echo 'workspace(name = \"bazel-skylib\")' > WORKSPACE",
        ],
    )
    http_archive(
        name = "rules_cc",
        urls = [
            "https://github.com/bazelbuild/rules_cc/archive/refs/tags/0.0.16.tar.gz"
        ],
        sha256 = "bbf1ae2f83305b7053b11e4467d317a7ba3517a12cef608543c1b1c5bf48a4df",
        strip_prefix = "rules_cc-0.0.16",
    )
    http_archive(
        name = "rules_license",
        urls = [
            "https://github.com/bazelbuild/rules_license/archive/refs/tags/1.0.0.tar.gz"
        ],
        sha256 = "75759939aef3aeb726e801417a883deefadadb7fea49946a1f5bb74a5162e81e",
        strip_prefix = "rules_license-1.0.0",
        patch_cmds = [
            "echo 'workspace(name = \"rules_license\")' > WORKSPACE",
        ],
    )

    http_archive(
        name = "ros2_common_interfaces",
        urls = [
            "https://github.com/ros2/common_interfaces/archive/refs/tags/4.2.4.tar.gz"
        ],
        sha256 = "d4aeb9f5aa2d5af9938ac4e32c6b7878586096951036c08f1e46fcacdc577c97",
        strip_prefix = "common_interfaces-4.2.4",
        build_file = "@com_github_mvukov_rules_ros2//repositories:common_interfaces.BUILD.bazel",
    )

    http_archive(
        name = "ros2_diagnostics",
        urls = [
            "https://github.com/ros/diagnostics/archive/9f402787ea2c9b3dd4d7e51a9986810e8a3400ba.zip"
        ],
        sha256 = "a723dae7acf0f00ee643c076c7c81299be0254919f29225ec7a89dc14cb8ea6f",
        strip_prefix = "diagnostics-9f402787ea2c9b3dd4d7e51a9986810e8a3400ba",
        build_file = "@com_github_mvukov_rules_ros2//repositories:diagnostics.BUILD.bazel",
    )

    http_archive(
        name = "ros2_navigation2",
        urls = [
            "https://github.com/ros-navigation/navigation2/archive/refs/tags/1.1.15.tar.gz"
        ],
        sha256 = "ef7f5b18ee534eea12c6c2217665240f836cbb07c1b058b5d248b0f47b754b5b",
        strip_prefix = "navigation2-1.1.15",
        build_file = "@com_github_mvukov_rules_ros2//repositories:navigation2.BUILD.bazel",
    )

    http_archive(
        name = "ros2_geometry2",
        urls = [
            "https://github.com/ros2/geometry2/archive/refs/tags/0.25.9.tar.gz"
        ],
        sha256 = "5c273ff836ab9268c01ad240e0d31aca6765b44c3759fce0e87b700381feddfd",
        strip_prefix = "geometry2-0.25.9",
        patches = ["@com_github_mvukov_rules_ros2//repositories/patches:geometry2_fix-use-after-free-bug.patch"],
        patch_args = ["-p1"],
        build_file = "@com_github_mvukov_rules_ros2//repositories:geometry2.BUILD.bazel",
    )

    http_archive(
        name = "ros2_gps_umd",
        urls = [
            "https://github.com/swri-robotics/gps_umd/archive/fc782811804fafb12ee479a48a2aa2e9ee942e2d.tar.gz"
        ],
        sha256 = "64a96f93053d0d59e8fcccceab5408a7d666dd813d4c12df139ef24d916f49ab",
        strip_prefix = "gps_umd-fc782811804fafb12ee479a48a2aa2e9ee942e2d",
        build_file = "@com_github_mvukov_rules_ros2//repositories:gps_umd.BUILD.bazel",
    )

    http_archive(
        name = "ros2_image_common",
        urls = [
            "https://github.com/ros-perception/image_common/archive/refs/tags/3.1.9.tar.gz"
        ],
        sha256 = "0433ed59cb813f14072c83511889d6950af0c223e346cd7ff95916274a3135cd",
        strip_prefix = "image_common-3.1.9",
        build_file = "@com_github_mvukov_rules_ros2//repositories:image_common.BUILD.bazel",
    )

    http_archive(
        name = "ros2_kdl_parser",
        urls = [
            "https://github.com/ros/kdl_parser/archive/refs/tags/2.6.4.tar.gz"
        ],
        sha256 = "f28da9bd7eaa8995f4b67bc9c8321d7467043aa43e01b918aa239b8b9971bf56",
        strip_prefix = "kdl_parser-2.6.4",
        build_file = "@com_github_mvukov_rules_ros2//repositories:kdl_parser.BUILD.bazel",
    )

    http_archive(
        name = "ros2_keyboard_handler",
        urls = [
            "https://github.com/ros-tooling/keyboard_handler/archive/refs/tags/0.0.5.tar.gz",
        ],
        sha256 = "36e64e9e1927a6026e1b45cafc4c8efd32db274bfab5da0edd273a583f3c73f4",
        strip_prefix = "keyboard_handler-0.0.5",
        build_file = "@com_github_mvukov_rules_ros2//repositories:keyboard_handler.BUILD.bazel",
    )

    http_archive(
        name = "ros2_launch",
        urls = [
            "https://github.com/ros2/launch/archive/refs/tags/1.0.7.tar.gz",
        ],
        sha256 = "16c29a3774ed13e09195c9f3d58f4199fa0913a324b8e67f3de2a2da676ce4c7",
        strip_prefix = "launch-1.0.7",
        build_file = "@com_github_mvukov_rules_ros2//repositories:launch.BUILD.bazel",
    )

    http_archive(
        name = "ros2_launch_ros",
        urls = [
            "https://github.com/ros2/launch_ros/archive/refs/tags/0.19.8.tar.gz",
        ],
        sha256 = "fa7f6b4e32260629ea8752a50f3d97650fe79b589255bc6cd20b0f08d0cfc3f1",
        strip_prefix = "launch_ros-0.19.8",
        build_file = "@com_github_mvukov_rules_ros2//repositories:launch_ros.BUILD.bazel",
    )

    http_archive(
        name = "ros2_libstatistics_collector",
        urls = [
            "https://github.com/ros-tooling/libstatistics_collector/archive/refs/tags/1.3.4.tar.gz",
        ],
        sha256 = "f16eb49c77a37db2b5344a6100d9697b19a55692e36118fb28817089a8d34351",
        strip_prefix = "libstatistics_collector-1.3.4",
        build_file = "@com_github_mvukov_rules_ros2//repositories:libstatistics_collector.BUILD.bazel",
    )

    http_archive(
        name = "ros2_pluginlib",
        urls = [
            "https://github.com/ros/pluginlib/archive/refs/tags/5.1.0.tar.gz",
        ],
        sha256 = "74188b886f9bbe7e857d21f3bb50b480e7c0e5adab97c10563dc17013600198b",
        strip_prefix = "pluginlib-5.1.0",
        build_file = "@com_github_mvukov_rules_ros2//repositories:pluginlib.BUILD.bazel",
    )

    http_archive(
        name = "ros2_rcl",
        urls = [
            "https://github.com/ros2/rcl/archive/refs/tags/5.3.9.tar.gz",
        ],
        sha256 = "81519ac2fff7cd811604514e64f97c85933b7729e090eb60a6278355ed30f13f",
        strip_prefix = "rcl-5.3.9",
        patches = ["@com_github_mvukov_rules_ros2//repositories/patches:fix-null-allocator-and-racy-condition.-1188.patch"],
        build_file = "@com_github_mvukov_rules_ros2//repositories:rcl.BUILD.bazel",
    )

    http_archive(
        name = "ros2_rcl_interfaces",
        urls = [
            "https://github.com/ros2/rcl_interfaces/archive/refs/tags/1.2.1.tar.gz",
        ],
        sha256 = "e267048c9f78aabed4b4be11bb028c8488127587e5065c3b3daff3550df25875",
        strip_prefix = "rcl_interfaces-1.2.1",
        build_file = "@com_github_mvukov_rules_ros2//repositories:rcl_interfaces.BUILD.bazel",
    )

    http_archive(
        name = "ros2_rosbag2",
        urls = [
            "https://github.com/ros2/rosbag2/archive/refs/tags/0.15.13.tar.gz",
        ],
        sha256 = "035f4346bdc4bee7b86fed277658bc045b627f5517085fdf3a453285b274ee3c",
        strip_prefix = "rosbag2-0.15.13",
        patches = ["@com_github_mvukov_rules_ros2//repositories/patches:rosbag2_relax_plugin_errors.patch"],
        patch_args = ["-p1"],
        build_file = "@com_github_mvukov_rules_ros2//repositories:rosbag2.BUILD.bazel",
    )

    http_archive(
        name = "ros2_rosidl",
        urls = [
            "https://github.com/ros2/rosidl/archive/refs/tags/3.1.6.tar.gz",
        ],
        sha256 = "5ff212dd63e3ea99521f323a871641e40aee3f7f896f377a467c19b94e80d01c",
        strip_prefix = "rosidl-3.1.6",
        patches = ["@com_github_mvukov_rules_ros2//repositories/patches:rosidl_rm_unnecessary_asserts.patch"],
        patch_args = ["-p1"],
        build_file = "@com_github_mvukov_rules_ros2//repositories:rosidl.BUILD.bazel",
    )

    http_archive(
        name = "ros2_rosidl_python",
        urls = [
            "https://github.com/ros2/rosidl_python/archive/refs/tags/0.14.4.tar.gz",
        ],
        sha256 = "4bb38b6718a0c23aa6d799548c4cfd021ba320294673e75eaf3137821e1234d1",
        strip_prefix = "rosidl_python-0.14.4",
        patches = ["@com_github_mvukov_rules_ros2//repositories/patches:rosidl_python_fix_imports.patch"],
        patch_args = ["-p1"],
        build_file = "@com_github_mvukov_rules_ros2//repositories:rosidl_python.BUILD.bazel",
    )

    http_archive(
        name = "ros2_rosidl_runtime_py",
        urls = [
            "https://github.com/ros2/rosidl_runtime_py/archive/refs/tags/0.9.3.tar.gz",
        ],
        sha256 = "4006ed60e2544eb390a6231c3e7a676d1605601260417b4b207ef94424a38b26",
        strip_prefix = "rosidl_runtime_py-0.9.3",
        build_file = "@com_github_mvukov_rules_ros2//repositories:rosidl_runtime_py.BUILD.bazel",
    )

    http_archive(
        name = "ros2_rosidl_typesupport",
        urls = [
            "https://github.com/ros2/rosidl_typesupport/archive/refs/tags/2.0.2.tar.gz",
        ],
        sha256 = "b330a869ce00eeb5345488fcd4c894464d5a5e3de601c553a9aaad78d2f5b34c",
        strip_prefix = "rosidl_typesupport-2.0.2",
        patches = ["@com_github_mvukov_rules_ros2//repositories/patches:rosidl_typesupport_fix_support_fastrtps.patch"],
        patch_args = ["-p1"],
        build_file = "@com_github_mvukov_rules_ros2//repositories:rosidl_typesupport.BUILD.bazel",
    )

    http_archive(
        name = "ros2_rpyutils",
        urls = [
            "https://github.com/ros2/rpyutils/archive/refs/tags/0.2.1.tar.gz",
        ],
        sha256 = "f87d8c0a2b1a5c28b722f168d7170076e6d82e68c5cb31cff74f15a9fa251fb9",
        strip_prefix = "rpyutils-0.2.1",
        build_file = "@com_github_mvukov_rules_ros2//repositories:rpyutils.BUILD.bazel",
    )

    http_archive(
        name = "ros2_tracing",
        urls = [
            "https://github.com/ros2/ros2_tracing/archive/refs/tags/4.1.1.tar.gz",
        ],
        sha256 = "261672e689e583c90b35d97ccea90ffec649ac55a0f045da46cbc3f69b657c5a",
        strip_prefix = "ros2_tracing-4.1.1",
        build_file = "@com_github_mvukov_rules_ros2//repositories:ros2_tracing.BUILD.bazel",
    )
    http_archive(
        name = "ros2cli",
        urls = [
            "https://github.com/ros2/ros2cli/archive/refs/tags/0.18.11.tar.gz",
        ],
        sha256 = "b7a1f137839f426fbcbb45727d8cbee9ee60ee9949502e5daf4288513397cefa",
        strip_prefix = "ros2cli-0.18.11",
        build_file = "@com_github_mvukov_rules_ros2//repositories:ros2cli.BUILD.bazel",
        patches = ["@com_github_mvukov_rules_ros2//repositories/patches:ros2cli_replace-netifaces.patch"],
    )

    http_archive(
        name = "ros2_unique_identifier_msgs",
        urls = [
            "https://github.com/ros2/unique_identifier_msgs/archive/refs/tags/2.2.1.tar.gz",
        ],
        sha256 = "ccedcb7c2b6d927fc4f654cceab299a8cb55082953867754795c6ea2ccdd68a9",
        strip_prefix = "unique_identifier_msgs-2.2.1",
        build_file = "@com_github_mvukov_rules_ros2//repositories:unique_identifier_msgs.BUILD.bazel",
    )

    http_archive(
        name = "ros2_urdf",
        urls = [
            "https://github.com/UniversalRobots/Universal_Robots_ROS2_Description/archive/refs/tags/2.6.0.tar.gz"
        ],
        sha256 = "a762eb57dc7f60b9ada0240fd7c609f0dc5028ef0b4b65972daf91e009e52cf6",
        strip_prefix = "urdf-2.6.0",
        patches = ["@com_github_mvukov_rules_ros2//repositories/patches:urdf_plugin_dynamic_loader_fix.patch"],
        patch_args = ["-p1"],
        build_file = "@com_github_mvukov_rules_ros2//repositories:urdf.BUILD.bazel",
    )

    http_archive(
        name = "ros2_urdfdom",
        urls = [
            "https://github.com/ros/urdfdom/archive/refs/tags/3.0.2.tar.gz",
        ],
        sha256 = "1072b2a304295eb299ed70d99914eb2fbf8843c3257e5e51defc5dd457ee6211",
        strip_prefix = "urdfdom-3.0.2",
        build_file = "@com_github_mvukov_rules_ros2//repositories:urdfdom.BUILD.bazel",
    )

    http_archive(
        name = "ros2_urdfdom_headers",
        urls = [
            "https://github.com/ros/urdfdom_headers/archive/refs/tags/1.0.6.tar.gz",
        ],
        sha256 = "1acd50b976f642de9dc0fde532eb8d77ea09f4de12ebfbd9d88b0cd2891278fd",
        strip_prefix = "urdfdom_headers-1.0.6",
        build_file = "@com_github_mvukov_rules_ros2//repositories:urdfdom_headers.BUILD.bazel",
    )

    http_archive(
        name = "ros2_xacro",
        urls = [
            "https://github.com/ros/xacro/archive/refs/tags/2.0.9.tar.gz"
        ],
        sha256 = "a8802a5b48f7479bae1238e822ac4ebb47660221eb9bc40a608e899d60f3f7e4",
        strip_prefix = "xacro-2.0.9",
        build_file = "@com_github_mvukov_rules_ros2//repositories:xacro.BUILD.bazel",
    )
    http_archive(
        name = "ros2_rmw",
        urls = [
            "https://github.com/ros2/rmw/archive/refs/tags/6.1.2.tar.gz"
        ],
        sha256 = "fc5eb606c44773a585f6332b33b8fe56c103821cd91e3b95c31a7ab57d38fa0e",
        strip_prefix = "rmw-6.1.2",
        patches = ["@com_github_mvukov_rules_ros2//repositories/patches:rmw_initialize-the-null-strucutre-with-static-value.-378.patch"],
        build_file = "@com_github_mvukov_rules_ros2//repositories:rmw.BUILD.bazel",
    )

    http_archive(
        name = "ros2_rmw_cyclonedds",
        urls = [
            "https://github.com/ros2/rmw_cyclonedds/archive/refs/tags/1.3.4.tar.gz"
        ],
        sha256 = "58ef4fe3fd18eb723906df77eb10df1e69222b451e479c6ec85426ba48e16a8a",
        strip_prefix = "rmw_cyclonedds-1.3.4",
        build_file = "@com_github_mvukov_rules_ros2//repositories:rmw_cyclonedds.BUILD.bazel",
    )
    http_archive(
        name = "ros2_rmw_implementation",
        urls = [
            "https://github.com/ros2/rmw_implementation/archive/refs/tags/2.8.4.tar.gz"
        ],
        sha256 = "c8a4d8160b27aa290eb90f756b6d656011329411a496feab7fb6cf976f964c93",
        strip_prefix = "rmw_implementation-2.8.4",
        patches = ["@com_github_mvukov_rules_ros2//repositories/patches:rmw_implementation_library_path.patch"],
        patch_args = ["-p1"],
        build_file = "@com_github_mvukov_rules_ros2//repositories:rmw_implementation.BUILD.bazel",
    )
    http_archive(
        name = "ros2_robot_state_publisher",
        urls = [
            "https://github.com/ros/robot_state_publisher/archive/refs/tags/3.0.3.tar.gz"
        ],
        sha256 = "74235a379ae3bcaf6a6236ddd36feccea6463749057b09f3409bcbced0c047f9",
        strip_prefix = "robot_state_publisher-3.0.3",
        build_file = "@com_github_mvukov_rules_ros2//repositories:robot_state_publisher.BUILD.bazel",
    )
    http_archive(
        name = "ros2_foxglove",
        urls = [
            "https://github.com/ros2-gbp/ros_foxglove_msgs-release/archive/refs/tags/release/humble/foxglove_msgs/2.3.0-1.tar.gz"
        ],
        sha256 = "72943b94ffe0bf7bda862b750338fcd061f30c2405f35275d4e34ab91f72b517",
        strip_prefix = "ros_foxglove_msgs-release-release-humble-foxglove_msgs-2.3.0-1",
        build_file = "@com_github_mvukov_rules_ros2//repositories:foxglove.BUILD.bazel",
    )

    http_archive(
        name = "ros2_rclcpp",
        urls = [
            "https://github.com/ros2/rclcpp/archive/refs/tags/16.0.11.tar.gz"
        ],
        sha256 = "f2102798b3fd7c11eba2728b35f5aca34add9acc7beb42d0a7e9cfcda12eea3d",
        strip_prefix = "rclcpp-16.0.11",
        patches = ["@com_github_mvukov_rules_ros2//repositories/patches:rclcpp_do-not-allocate-in-signal-handler.patch", "@com_github_mvukov_rules_ros2//repositories/patches:rclcpp_fix-maybe-uninitialized-warning.patch", "@com_github_mvukov_rules_ros2//repositories/patches:rclcpp_ts_libs_ownership.patch"],
        patch_args = ["-p1"],
        patch_cmds = ["patch"],
        build_file = "@com_github_mvukov_rules_ros2//repositories:rclcpp.BUILD.bazel",
    )
    http_archive(
        name = "ros2_rclpy",
        urls = [
            "https://github.com/ros2/rclpy/archive/refs/tags/3.3.15.tar.gz"
        ],
        sha256 = "2dadc5b7f05d3993c487a8e721e612d62e82b96fa7d243ccd84f048b1a123a41",
        strip_prefix = "rclpy-3.3.15",
        build_file = "@com_github_mvukov_rules_ros2//repositories:rclpy.BUILD.bazel",
    )
    http_archive(
        name = "console_bridge",
        urls = [
            "https://github.com/ros/console_bridge/archive/refs/tags/1.0.2.tar.gz"
        ],
        sha256 = "303a619c01a9e14a3c82eb9762b8a428ef5311a6d46353872ab9a904358be4a4",
        strip_prefix = "console_bridge-1.0.2",
        build_file = "@com_github_mvukov_rules_ros2//repositories:console_bridge.BUILD.bazel",
    )
    http_archive(
        name = "mcap",
        urls = [
            "https://github.com/foxglove/mcap/archive/refs/tags/releases/cpp/v2.0.0.tar.gz"
        ],
        sha256 = "064ff3a99b06e93cba1fe6ed61fbada1e47b9a0b1a03b73a0864eedeaaf80f28",
        strip_prefix = "mcap-releases-cpp-v2.0.0/cpp/mcap",
        build_file = "@com_github_mvukov_rules_ros2//repositories:mcap.BUILD.bazel",
        patch_args = ["-p1"],
        patches = ["@com_github_mvukov_rules_ros2//repositories/patches:mcap_replace_fflush.patch"],
    )
    http_archive(
        name = "readerwriterqueue",
        urls = [
            "https://github.com/cameron314/readerwriterqueue/archive/refs/tags/v1.0.6.tar.gz"
        ],
        sha256 = "fc68f55bbd49a8b646462695e1777fb8f2c0b4f342d5e6574135211312ba56c1",
        strip_prefix = "readerwriterqueue-1.0.6",
        build_file = "@com_github_mvukov_rules_ros2//repositories:readerwriterqueue.BUILD.bazel",
    )
    http_archive(
        name = "ros2_rcl_logging_syslog",
        urls = [
            "https://github.com/fujitatomoya/rcl_logging_syslog/archive/e63257f2d5ca693f286bbcedf2b23720675b7f73.zip"
        ],
        sha256 = "89039a8d05d1d14ccb85a3d065871d54cce831522bd8aa687e27eb6afd333d07",
        strip_prefix = "rcl_logging_syslog-e63257f2d5ca693f286bbcedf2b23720675b7f73",
        build_file = "@com_github_mvukov_rules_ros2//repositories:rcl_logging_syslog.BUILD.bazel",
    )
    http_archive(
        name = "boringssl",
        urls = [
            "https://github.com/hedronvision/boringssl/archive/266308793d4d0d1f20c817efda8da00bf393bfd6.tar.gz"
        ],
        sha256 = "d38af313617ce2e952a7af6ba80e2cd87520b5c1c355316ea4222a2a3edbcd21",
        strip_prefix = "boringssl-266308793d4d0d1f20c817efda8da00bf393bfd6",
    )

    http_archive(
        name = "orocos_kdl",
        urls = [
            "https://github.com/orocos/orocos_kinematics_dynamics/archive/507de66205e14b12c8c65f25eafc05c4dc66e21e.tar.gz"
        ],
        sha256 = "22df47f63d91d014af2675029c23da83748575c12a6481fda3ed9235907cc259",
        strip_prefix = "orocos_kinematics_dynamics-507de66205e14b12c8c65f25eafc05c4dc66e21e",
        build_file = "@com_github_mvukov_rules_ros2//repositories:orocos_kdl.BUILD.bazel",
    )
    http_archive(
        name = "ros2_rcutils",
        urls = [
            "https://github.com/ros2/rcutils/archive/refs/tags/5.1.6.tar.gz",
        ],
        sha256 = "b64c3077162bc845a7c410180bc6c78e63e3a7562285b74c0982eee101ea0f28",
        strip_prefix = "rcutils-5.1.6",
        patches = ["@com_github_mvukov_rules_ros2//repositories/patches:rcutils_fix-setting-allocator-to-null.-478.patch"],
        build_file = "@com_github_mvukov_rules_ros2//repositories:rcutils.BUILD.bazel",
    )
    http_archive(
        name = "ros2_rcpputils",
        urls = [
            "https://github.com/ros2/rcpputils/archive/refs/tags/2.4.4.tar.gz",
        ],
        sha256 = "40554ef269f40e242175c3f17ae88e77d2bd1768eb4c5a8d0d01b94f59d28948",
        strip_prefix = "rcpputils-2.4.4",
        build_file = "@com_github_mvukov_rules_ros2//repositories:rcpputils.BUILD.bazel",
    )
    http_archive(
        name = "ros2_resource_retriever",
        urls = [
            "https://github.com/ros/resource_retriever/archive/refs/tags/3.1.2.tar.gz",
        ],
        sha256 = "5b4e1411ed955c0562f4609d9025143bf9199d405cbc471484b83f3cbab59162",
        strip_prefix = "resource_retriever-3.1.2",
        build_file = "@com_github_mvukov_rules_ros2//repositories:resource_retriever.BUILD.bazel",
    )
    http_archive(
        name = "ros2_class_loader",
        urls = [
            "https://github.com/ros/class_loader/archive/refs/tags/2.2.0.tar.gz",
        ],
        sha256 = "a85a99b93fcad7c8d9686672b8e3793200b1da9d8feab7ab3a9962e34ab1f675",
        strip_prefix = "class_loader-2.2.0",
        build_file = "@com_github_mvukov_rules_ros2//repositories:class_loader.BUILD.bazel",
    )

    http_archive(
        name = "rules_shell",
        urls = [
            "https://github.com/bazelbuild/rules_shell/archive/refs/tags/v0.2.0.tar.gz"
        ],
        sha256 = "410e8ff32e018b9efd2743507e7595c26e2628567c42224411ff533b57d27c28",
        strip_prefix = "rules_shell-0.2.0",
    )
    http_archive(
        name = "rules_proto",
        urls = [
            "https://github.com/bazelbuild/rules_proto/archive/refs/tags/5.3.0-21.7.tar.gz"
        ],
        sha256 = "dc3fb206a2cb3441b485eb1e423165b231235a1ea9b031b4433cf7bc1fa460dd",
        strip_prefix = "rules_proto-5.3.0-21.7",
    )
    http_archive(
        name = "cyclonedds",
        urls = [
            "https://github.com/eclipse-cyclonedds/cyclonedds/archive/refs/tags/0.10.5.tar.gz"
        ],
        sha256 = "ec3ec898c52b02f939a969cd1a276e219420e5e8419b21cea276db35b4821848",
        strip_prefix = "cyclonedds-0.10.5",
        build_file = "@com_github_mvukov_rules_ros2//repositories:cyclonedds.BUILD.bazel",
    )
    http_archive(
        name = "ros2_ament_index",
        urls = [
            "https://github.com/ament/ament_index/archive/refs/tags/1.4.0.tar.gz"
        ],
        sha256 = "e66896e255653508cb2bdecd7789f8dd5a03d7d2b4a1dd37445821a5679c447c",
        strip_prefix = "ament_index-1.4.0",
        build_file = "@com_github_mvukov_rules_ros2//repositories:ament_index.BUILD.bazel",
    )
    http_archive(
        name = "tinyxml",
        urls = [
            "http://archive.ubuntu.com/ubuntu/pool/universe/t/tinyxml/tinyxml_2.6.2.orig.tar.gz"
        ],
        sha256 = "15bdfdcec58a7da30adc87ac2b078e4417dbe5392f3afb719f9ba6d062645593",
        build_file = "@com_github_mvukov_rules_ros2//repositories:tinyxml.BUILD.bazel",
    )
    http_archive(
        name = "websocketpp",
        urls = [
            "https://github.com/zaphoyd/websocketpp/archive/refs/tags/0.8.2.tar.gz"
        ],
        sha256 = "6ce889d85ecdc2d8fa07408d6787e7352510750daa66b5ad44aacb47bea76755",
        strip_prefix = "websocketpp-0.8.2",
        build_file = "@com_github_mvukov_rules_ros2//repositories:websocketpp.BUILD.bazel",
    )
    http_archive(
        name = "ros2_rcl_logging",
        urls = [
            "https://github.com/ros2/rcl_logging/archive/refs/tags/2.3.1.tar.gz"
        ],
        sha256 = "f711a7677cb68c927650e5e9f6bbb5d013dd9ae30736209f9b70f9c6485170f6",
        strip_prefix = "rcl_logging-2.3.1",
        build_file = "@com_github_mvukov_rules_ros2//repositories:rcl_logging.BUILD.bazel",
    )

    http_archive(
        name = "libyaml",
        urls = [
            "https://github.com/yaml/libyaml/archive/refs/tags/0.2.5.tar.gz"
        ],
        sha256 = "fa240dbf262be053f3898006d502d514936c818e422afdcf33921c63bed9bf2e",
        strip_prefix = "libyaml-0.2.5",
        build_file = "@com_github_mvukov_rules_ros2//repositories:libyaml.BUILD.bazel",
    )
