load("@agibot_repo_loader//:agibot_repo_loader.bzl", "agibot_repo_loader")
load("@integration//projects/third_party/deps:archives_prebuilt.bzl", "all_prebuilt_packages")
load("@integration//projects/third_party/deps:archives_source.bzl", "all_source_packages")

def deps():
    agibot_repo_loader()
    all_prebuilt_packages()
    all_source_packages()

def local_deps():
    native.new_local_repository(
        name = "orin_aarch64_sdk",
        build_file = "@integration//toolchains/orin_aarch64/cc:toolchain.BUILD",
        path = "/opt/nvidia/l4t-toolchain/aarch64--glibc--stable-2022.08-1",
    )

    native.new_local_repository(
        name = "cuda_aarch64",
        build_file = "@integration//projects/third_party:cuda.BUILD",
        path = "/opt/nvidia/orin_sysroot/usr/local/cuda-12.2",
    )

    native.new_local_repository(
        name = "cudnn_aarch64",
        build_file = "@integration//projects/third_party:cudnn.BUILD",
        path = "/opt/nvidia/orin_sysroot/usr/include/aarch64-linux-gnu",
    )

    native.new_local_repository(
        name = "tensorrt_aarch64",
        build_file = "@integration//projects/third_party:tensorrt.BUILD",
        path = "/opt/nvidia/orin_sysroot/usr/include",
    )

    native.new_local_repository(
        name = "vulkan_aarch64",
        build_file = "@integration//projects/third_party:vulkan.BUILD",
        path = "/opt/nvidia/orin_sysroot/usr/include",
    )

    native.new_local_repository(
        name = "sqlite3_aarch64",
        build_file = "@integration//projects/third_party:sqlite3.BUILD",
        path = "/opt/nvidia/orin_sysroot/usr/include",
    )

    native.new_local_repository(
        name = "sqlite3_x86_64",
        build_file = "@integration//projects/third_party:sqlite3.BUILD",
        path = "/usr/include",
    )
    native.new_local_repository(
        name = "nvbufsurftransform_aarch64",
        build_file = "@integration//projects/third_party:nvbufsurftransform.BUILD",
        path = "/opt/nvidia/orin_sysroot/usr/src/jetson_multimedia_api/include",
    )
    native.new_local_repository(
        name = "jetson_multimedia_aarch64",
        build_file = "@integration//projects/third_party:jetson_multimedia.BUILD",
        path = "/opt/nvidia/orin_sysroot/usr/src/jetson_multimedia_api",
    )
    native.new_local_repository(
        name = "X11_aarch64",
        build_file = "@integration//projects/third_party:X11.BUILD",
        path = "/opt/nvidia/orin_sysroot/usr/include",
    )
    native.new_local_repository(
        name = "vpi_aarch64",
        build_file = "@integration//projects/third_party:vpi.BUILD",
        path = "/opt/nvidia/orin_sysroot/opt/nvidia/vpi3/include",
    )

def all_deps():
    deps()
    local_deps()
