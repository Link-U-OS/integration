#!/bin/bash
set -e
    
# Print usage information for the script
Usage() {
    cat <<EOF
Usage: bash build_package.sh [options]
       [-o override_repository] (Support multiple code repos override)
       [-p product name] (set product: A2_ULTRA)
       [-j job] (specify the number of concurrent jobs to run during the build process)
       [-g debug] (set --copt=dbg)
       [-c clean_cache] (clean the local bazel cache)
       [-e extra_options] (extra options)
       [-h help] (get usage)
EOF
    exit 1
}

# Get current timestamp for logging
function get_time() {
    local time=$(date "+%H:%M:%S")
    echo "($time)"
}

# Parse command line arguments
ARGS=$(getopt -o p:hgco:j:e: --long product:,help,debug,clean_cache,override_repository:,jobs:,extra_options: -n "$0" -- "$@")
if [ $? != 0 ]; then
    Usage
fi

eval set -- "${ARGS}"
echo $(get_time) INFO: formatted parameters=[$@]

# Check if a command exists
command_exists() {
    command -v "$@" >/dev/null 2>&1
}
OVERRIDE_OPTION=""
PRODUCT="A2_ULTRA"

# Process command line options
while true; do
    case "$1" in
    -p | --product)
        PRODUCT=${2}
        echo "$(get_time) INFO: product is: $PRODUCT"
        shift 2
        ;;
    -e | --extra_options)
        echo "$(get_time) INFO: Building with extra options: $2"
        EXTRA_OPTIONS=${2}
        if [[ $EXTRA_OPTIONS == *"--config=source"* ]]; then
            CONFIG_SOURCE="--config=source"
        fi
        shift 2
        ;;
    -j | --jobs)
        echo "$(get_time) INFO: Building using jobs: $2"
        JOBS_OPTIONS="--jobs=$2"
        shift 2
        ;;
    -c | --clean_cache)
        echo "$(get_time) INFO: Building with cleaning cache first"
        CLEAN_CACHE_FLAG=true
        shift
        ;;
    -o | --override_repository)
        echo "$(get_time) INFO: Building using local repo: $2"
        override+="--override_repository $2 "
        shift 2
        ;;
    -g | --debug)
        GDB_FLAG='--copt=-g --copt=-O0'
        echo "$(get_time) INFO: debug mode is: $GDB_FLAG"
        shift
        ;;
    --)
        shift
        break
        ;;
    -h | --help)
        Usage
        ;;
    *)
        Usage
        ;;
    esac
done

# Validate required product parameter
if [ -z "$PRODUCT" ]; then
    echo "$(get_time) ERROR: product must be specified, please use -p parameter"
    Usage
fi

# Prepare workspace and clean cache if needed
function prepare_workspace() {
    if [ "${CLEAN_CACHE_FLAG}" == true ]; then
        set -x
        bazel clean --expunge || true
        set +x
    fi

    # Setup directories for build artifacts
    LOCAL_SNAPSHOT_DIR=~/.local/share/local_snapshot/
    if [ -d ${LOCAL_SNAPSHOT_DIR} ]; then
        rm -r ${LOCAL_SNAPSHOT_DIR} || true
    fi
    mkdir -p "$LOCAL_SNAPSHOT_DIR"
    VERSION_FILE_PATH=$LOCAL_SNAPSHOT_DIR/version
    BAZEL_BIN=$(bazel info bazel-bin)
    ARTIFACTS_DIR=$(bazel info output_base)/artifacts/
    if [ -d ${ARTIFACTS_DIR} ]; then
        rm -r ${ARTIFACTS_DIR} || true
    fi
    mkdir -p ${ARTIFACTS_DIR}
}

# Generate manifest file with build metadata
function set_manifest() {
    protobuf_ver="30.0"
    ros2_ver="release-humble-20241205"
    BAZEL_BIN_PACKAGE_DIR=${BAZEL_BIN}
    
    # Generate manifest in JSON format
    jq --null-input \
        --argjson repolist "$(<$(bazel info output_base)/external/agibot_repo_loader/agibot_repo_loader.json)" \
        --arg protobuf_version $protobuf_ver \
        --arg ros2_version $ros2_ver \
        --arg version $version \
        '{"repo_list": $repolist, "protobuf_version": $protobuf_version, "ros2_version": $ros2_version, "version": $version}' >${ARTIFACTS_DIR}/metadata.json
    
    # Convert JSON to YAML if yq is available
    if command_exists yq; then
        yq -y '.' ${ARTIFACTS_DIR}/metadata.json > ${ARTIFACTS_DIR}/metadata.yaml
        ln -sf metadata.yaml ${ARTIFACTS_DIR}/metadata
    else
        echo "$(get_time) WARNING: yq tool not installed, using JSON format for manifest"
        cp ${ARTIFACTS_DIR}/metadata.json ${ARTIFACTS_DIR}/metadata
    fi
    
    # Display manifest contents
    if [ -f ${ARTIFACTS_DIR}/metadata.yaml ]; then
        cat ${ARTIFACTS_DIR}/metadata.yaml
    else
        cat ${ARTIFACTS_DIR}/metadata
    fi
}

# Generate version string for snapshot
function get_snapshot_version() {
    git_describe_tag=$(git describe --always --tags --long --abbrev=9)
    date_ts=$(date "+%y%m%d%H%M")
    if [[ "x$git_describe_tag" == "x" ]]; then
        git_describe_tag=v0.0.0
    fi

    version=${PRODUCT}-${git_describe_tag}-${date_ts}
    echo "$(get_time) INFO: verson: ${version}"
    echo ${version} >${VERSION_FILE_PATH}
    OTA_PACKAGE_DIR=${LOCAL_SNAPSHOT_DIR}/${version}/ota_package
    mkdir -p ${OTA_PACKAGE_DIR}
}

# Build x86_64 package
function build_x86_64_pkg() {
    echo "$(get_time) INFO: Build x86_64 pkg"
    SHELL_FOLDER=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    pushd "$SHELL_FOLDER"/../ || exit
    set -x
        bazel build \
            --config=x86_64 \
            --define=product=${PRODUCT} \
            ${GDB_FLAG} \
            ${OVERRIDE_OPTION} \
            ${JOBS_OPTIONS} \
            ${EXTRA_OPTIONS} \
            :x86_64_pkg_tar
    set +x
    popd || exit

    # Package x86_64 firmware
    pushd ${OTA_PACKAGE_DIR}
        echo "$(get_time) INFO: Create archive for x86_64 pkg"
        mkdir -p soc0_temp
        tar -xf ${BAZEL_BIN_PACKAGE_DIR}/x86_64_pkg_tar.tar -C soc0_temp
        cp ${ARTIFACTS_DIR}/metadata.yaml soc0_temp/
        mkdir -p soc0
        mv soc0_temp/* soc0/
        zip -r -q soc0.zip soc0
        rm -rf soc0_temp soc0
    popd
}

# Build Orin package
function build_orin_pkg() {
    echo "$(get_time) INFO: Build orin pkg"
    SHELL_FOLDER=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    pushd "$SHELL_FOLDER"/../ || exit
        set -x
        bazel build \
            --config=orin_aarch64 \
            --define=product=${PRODUCT} \
            ${GDB_FLAG} \
            ${OVERRIDE_OPTION} \
            ${JOBS_OPTIONS} \
            ${EXTRA_OPTIONS} \
            :orin_pkg_tar
        set +x
    popd || exit

    # Package Orin firmware
    pushd ${OTA_PACKAGE_DIR}
        echo "$(get_time) INFO: Create archive for orin pkg"
        mkdir -p soc1_temp
        tar -xf ${BAZEL_BIN_PACKAGE_DIR}/orin_pkg_tar.tar -C soc1_temp
        cp ${ARTIFACTS_DIR}/metadata.yaml soc1_temp/
        mkdir -p soc1
        mv soc1_temp/* soc1/
        zip -r -q soc1.zip soc1
        rm -rf soc1_temp soc1
    popd
}

# Create final snapshot package
function create_snapshot_pkg() {
    echo "$(get_time) INFO: Create snapshot pkg"
    pushd ${LOCAL_SNAPSHOT_DIR}/
        cp ${ARTIFACTS_DIR}/metadata.yaml ${version}/ota_package/
        tar -cf ${version}.tar -C ${version} .
    popd
    echo "$(get_time) INFO: Snapshot created: ${version}.tar"
}

OVERRIDE_OPTION=$(printf "%s" "${override[@]}")
# Initialize build environment
prepare_workspace
get_snapshot_version
set_manifest

# Build packages based on product
if [ "${PRODUCT}"x == "A2_ULTRA"x ]; then
    build_orin_pkg
    build_x86_64_pkg
    create_snapshot_pkg
else
    echo "$(get_time) ERROR: Invalid product: ${PRODUCT}"
    Usage
    exit 1
fi

echo -e "\n###################################################################\n"
echo -e "$(get_time) INFO: Build snapshot: '${version}' SUCCESS"
echo -e "$(get_time) INFO: Snapshot in: '${LOCAL_SNAPSHOT_DIR}${version}.tar'"
