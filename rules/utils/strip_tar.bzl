"""
Bazel rule to strip symbols from binaries in a tar package.

This rule takes a tar package as input, extracts it, strips debug symbols
from all binaries and shared libraries in the bin/ directory, and outputs two tar packages:
1. The original structure with stripped binaries
2. A tar package containing only debug symbol files

Supports both x86_64 and aarch64 architectures.
"""

def _strip_tar_impl(ctx):
    input_tar = ctx.file.src
    stripped_tar = ctx.outputs.stripped_tar
    debug_tar = ctx.outputs.debug_tar
    target_arch = ctx.attr.target_arch
    
    # Create temporary directories for processing
    # Use temporary paths relative to output files instead of declare_directory
    # since these are intermediate directories that should be cleaned up
    base_path = stripped_tar.dirname
    extract_dir_path = base_path + "/_extract_" + ctx.label.name
    stripped_dir_path = base_path + "/_stripped_" + ctx.label.name  
    debug_dir_path = base_path + "/_debug_" + ctx.label.name
    
    # Get toolchain binaries based on target architecture
    objcopy = None
    tar = "tar"
    
    if target_arch == "aarch64":
        # Use cross-compilation toolchain for aarch64
        objcopy = "/opt/nvidia/l4t-toolchain/aarch64--glibc--stable-2022.08-1/aarch64-buildroot-linux-gnu/bin/objcopy"
    else:
        # For x86_64 or other architectures, try to find objcopy from toolchain
        if hasattr(ctx.toolchains, "@bazel_tools//tools/cpp:toolchain_type"):
            cc_toolchain = ctx.toolchains["@bazel_tools//tools/cpp:toolchain_type"]
            if hasattr(cc_toolchain, "objcopy_executable"):
                objcopy = cc_toolchain.objcopy_executable
        
        # Fallback to system objcopy for x86_64
        if not objcopy:
            objcopy = "objcopy"
    
    ctx.actions.run_shell(
        inputs = [input_tar],
        outputs = [stripped_tar, debug_tar],
        command = """
set -e

INPUT_TAR="{input_tar}"
EXTRACT_DIR="{extract_dir}"
STRIPPED_DIR="{stripped_dir}"
DEBUG_DIR="{debug_dir}"
STRIPPED_TAR="{stripped_tar}"
DEBUG_TAR="{debug_tar}"
OBJCOPY="{objcopy}"
TAR="{tar}"
TARGET_ARCH="{target_arch}"

# Validate target architecture
case "$TARGET_ARCH" in
    "x86_64"|"aarch64")
        echo "Processing binaries for target architecture: $TARGET_ARCH"
        ;;
    *)
        echo "Error: Unsupported target architecture: $TARGET_ARCH"
        echo "Supported architectures: x86_64, aarch64"
        exit 1
        ;;
esac

# Create working directories
mkdir -p "$EXTRACT_DIR" "$STRIPPED_DIR" "$DEBUG_DIR/bin"

# Extract the input tar to extraction directory
"$TAR" -xf "$INPUT_TAR" -C "$EXTRACT_DIR"

# Copy the entire structure to stripped directory
cp -r "$EXTRACT_DIR"/. "$STRIPPED_DIR/"

# Function to determine if a file should be processed
should_process_file() {{
    local file="$1"
    local file_info
    
    # Check if file exists and is readable
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
        return 1
    fi
    
    file_info=$(file "$file")
    
    # Check if file is an ELF binary or shared library
    if echo "$file_info" | grep -q "ELF"; then
        # For aarch64, check if it's actually an ARM64 binary
        if [ "$TARGET_ARCH" = "aarch64" ]; then
            if echo "$file_info" | grep -q "ARM aarch64\\|aarch64"; then
                return 0
            else
                echo "Skipping non-aarch64 binary: $file"
                return 1
            fi
        # For x86_64, check if it's an x86-64 binary
        elif [ "$TARGET_ARCH" = "x86_64" ]; then
            if echo "$file_info" | grep -q "x86-64\\|x86_64"; then
                return 0
            else
                echo "Skipping non-x86_64 binary: $file"
                return 1
            fi
        else
            # For other architectures, process all ELF files
            return 0
        fi
    fi
    
    return 1
}}

# Find all files in bin directory and process binaries and shared libraries
if [ -d "$EXTRACT_DIR/bin" ]; then
    # Find executable files and shared libraries
    find "$EXTRACT_DIR/bin" -type f \\( -executable -o -name "*.so" -o -name "*.so.*" \\) | while read -r file; do
        if should_process_file "$file"; then
            echo "Processing $TARGET_ARCH binary/library: $file"
            
            # Get relative path from extract dir
            rel_file="${{file#$EXTRACT_DIR/}}"
            
            # Extract debug symbols
            debug_file="$DEBUG_DIR/${{rel_file}}.debug"
            mkdir -p "$(dirname "$debug_file")"
            
            # Check if objcopy exists and is executable
            if [ ! -x "$OBJCOPY" ] && ! command -v "$OBJCOPY" > /dev/null 2>&1; then
                echo "Error: objcopy tool not found or not executable: $OBJCOPY"
                exit 1
            fi
            
            # Extract debug symbols
            if "$OBJCOPY" --only-keep-debug "$file" "$debug_file" 2>/dev/null; then
                echo "Extracted debug symbols to $debug_file"
                
                # Strip the binary and add debug link
                stripped_file="$STRIPPED_DIR/$rel_file"
                if "$OBJCOPY" --strip-debug --strip-unneeded "$stripped_file" 2>/dev/null; then
                    echo "Stripped symbols from $stripped_file"
                    
                    # Add debug link (best effort, don't fail if this doesn't work)
                    "$OBJCOPY" --add-gnu-debuglink="$debug_file" "$stripped_file" 2>/dev/null || echo "Warning: Could not add debug link to $stripped_file"
                else
                    echo "Warning: Failed to strip symbols from $stripped_file"
                fi
            else
                echo "Warning: Failed to extract debug symbols from $file"
            fi
        fi
    done
fi

# Create the stripped tar (preserving original structure)
"$TAR" -cf "$STRIPPED_TAR" -C "$STRIPPED_DIR" .

# Create the debug tar (only bin directory with .debug files)
if [ -d "$DEBUG_DIR/bin" ] && [ -n "$(find "$DEBUG_DIR/bin" -name "*.debug" 2>/dev/null)" ]; then
    "$TAR" -cf "$DEBUG_TAR" -C "$DEBUG_DIR" bin
else
    # Create an empty tar if no debug files
    "$TAR" -cf "$DEBUG_TAR" --files-from /dev/null
fi
        """.format(
            input_tar = input_tar.path,
            extract_dir = extract_dir_path,
            stripped_dir = stripped_dir_path,
            debug_dir = debug_dir_path,
            stripped_tar = stripped_tar.path,
            debug_tar = debug_tar.path,
            objcopy = objcopy,
            tar = tar,
            target_arch = target_arch,
        ) + """

# Clean up temporary directories (allow failures)
echo "Cleaning up temporary directories..."
rm -rf "$EXTRACT_DIR" || true
rm -rf "$STRIPPED_DIR" || true  
rm -rf "$DEBUG_DIR" || true
echo "Cleanup completed"
        """,
        progress_message = "Stripping symbols from %s binaries in %s" % (target_arch, input_tar.short_path),
        use_default_shell_env = True,
    )
    
    return [DefaultInfo(files = depset([stripped_tar, debug_tar]))]

strip_tar = rule(
    implementation = _strip_tar_impl,
    attrs = {
        "src": attr.label(
            allow_single_file = [".tar", ".tar.gz", ".tgz"],
            mandatory = True,
            doc = "Input tar package to strip symbols from",
        ),
        "target_arch": attr.string(
            default = "x86_64",
            doc = "Target architecture for the binaries (x86_64 or aarch64). Supports select() statements.",
        ),
    },
    outputs = {
        "stripped_tar": "%{name}_stripped.tar",
        "debug_tar": "%{name}_debug.tar",
    },
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
    doc = """
Strip debug symbols from binaries and shared libraries in a tar package.

This rule extracts the input tar, finds all executable files and shared libraries (.so files) 
in the bin/ directory, strips their debug symbols using the appropriate objcopy tool based on 
target architecture, and creates separate debug symbol files.

Supports both x86_64 and aarch64 architectures:
- x86_64: Uses system objcopy or toolchain objcopy
- aarch64: Uses cross-compilation objcopy from /opt/nvidia/l4t-toolchain/

Outputs:
- stripped_tar: Original tar structure with stripped binaries
- debug_tar: Tar containing only debug symbol files in bin/ directory

Example usage:
    load("//rules/utils:strip_tar.bzl", "strip_tar")
    
    # Strip x86_64 binaries
    strip_tar(
        name = "my_package_x86_64_tar",
        src = ":my_package_x86_64.tar",
        target_arch = "x86_64",
    )
    
    # Strip aarch64 binaries
    strip_tar(
        name = "my_package_aarch64_tar", 
        src = ":my_package_aarch64.tar",
        target_arch = "aarch64",
    )
    
    # Use select() to choose architecture based on platform
    strip_tar(
        name = "my_package_tar",
        src = ":my_package.tar",
        target_arch = select({
            "@integration//toolchains/platforms:is_aarch64": "aarch64",
            "//conditions:default": "x86_64",
        }),
    )
""",
)