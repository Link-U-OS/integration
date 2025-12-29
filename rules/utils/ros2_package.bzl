"""
Custom Bazel rules for building ROS2 packages.
"""

def _ros2_colcon_package_impl(ctx):
    """Implementation for the ros2_colcon_package rule."""

    # Declare the intermediate output directories for colcon.

    src_dir = ctx.actions.declare_directory(ctx.attr.name + "_src")

    # Declare the final output file (the tarball).
    output_tar = ctx.actions.declare_file(ctx.attr.name + ".tar")

    # --- Handle architecture-specific build arguments ---
    cmake_args = ""
    action_inputs = depset([ctx.file.src_tar])
    target_arch = "x86_64"

    if ctx.attr.aarch_type == "aarch64":
        target_arch = "aarch64"
        toolchain_file = ctx.actions.declare_file(ctx.attr.name + "_ros2_aarch64.cmake")
        ctx.actions.write(
            output = toolchain_file,
            content = """set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_C_COMPILER /usr/bin/aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER /usr/bin/aarch64-linux-gnu-g++)
set(CMAKE_SYSROOT /opt/nvidia/orin_sysroot)
set(CMAKE_FIND_ROOT_PATH /opt/nvidia/orin_sysroot/opt/ros/humble /opt/nvidia/orin_sysroot/usr)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(PYTHON_SOABI cpython-310-aarch64-linux-gnu)
""",
        )
        cmake_args = "--cmake-args -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -DCMAKE_TOOLCHAIN_FILE=$EXEC_ROOT/" + toolchain_file.path
        action_inputs = depset(transitive = [action_inputs, depset([toolchain_file])])

    commands = """
        set -e
        TARGET_ARCH=\"{target_arch}\"
        SRC_DIR=\"{src_dir}\"
        SRC_TAR_PATH=\"{src_tar_path}\"
        OUTPUT_TAR=\"{output_tar}\" 

        mkdir -p \"$SRC_DIR\"
        tar -xf \"$SRC_TAR_PATH\" -C \"$SRC_DIR\"
        if [ \"$TARGET_ARCH\" = \"x86_64\" ]; then
            ROS_SETUP_SCRIPT=\"/opt/ros/humble/setup.bash\"
        elif [ \"$TARGET_ARCH\" = \"aarch64\" ]; then
            ROS_SETUP_SCRIPT=\"/opt/nvidia/orin_sysroot/opt/ros/humble/setup.bash\"
        else
            # For other architectures, skip
            return 0
        fi
        source \"$ROS_SETUP_SCRIPT\"

        EXEC_ROOT=$(pwd)
        cd \"$SRC_DIR\"

        # The user's original command, adapted for the Bazel action environment.
        # Instead of hardcoded 'build/log' and 'build/install', we use the paths
        # to the directories we declared above.
        echo \"Building in $(pwd)\" 
        colcon --log-base build/log build \
            --symlink-install \
            --merge-install \
            --install-base build/install \
            --cmake-force-configure \
            {cmake_args}

        # Create the final tarball from the contents of the install directory.
        # -C changes the directory to the install_dir before adding files.
        # '.' adds all files from that directory.
        tar -cf $EXEC_ROOT/\"$OUTPUT_TAR\" -C build/install .

    """.format(
        src_tar_path = ctx.file.src_tar.path,
        src_dir = src_dir.path,
        output_tar = output_tar.path,
        target_arch = target_arch,
        cmake_args = cmake_args,
    )

    # --- Define the action ---
    ctx.actions.run_shell(
        outputs = [output_tar, src_dir],
        inputs = action_inputs,
        command = commands,
        # Provide a progress message for the user during the build.
        progress_message = "\033[1;32mBuilding ROS2 packages with colcon and creating tarball: %s, please waiting ...\033[0m" % ctx.attr.name,
    )

    # --- Return the provider ---
    # The DefaultInfo provider tells Bazel what the default outputs of this rule are.
    return [DefaultInfo(files = depset([output_tar]))]

ros2_colcon_package = rule(
    implementation = _ros2_colcon_package_impl,
    attrs = {
        "src_tar": attr.label(
            doc = "A tarball of source files for the ROS2 packages.",
            allow_single_file = True,
        ),
        "aarch_type": attr.string(
            doc = "If specified, indicates the ARM architecture type (e.g., 'x86_64', 'aarch64').",
            default = "x86_64",
        ),
    },
    doc = "Builds ROS2 packages using colcon and packages the result into a .tar.gz file. Supports native (e.g., x86) and cross-compilation (e.g., ARM) builds.",
)
