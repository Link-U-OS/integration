# Module Archive Integration Guide

The product build system supports integrating precompiled module archives from the artifact repository. The build process automatically handles downloading, verification, and integration, seamlessly incorporating modules into the final product package.

## Integration Steps

### 1. Define Archive Configuration

Declare the modules to be integrated in `projects/defs/archives.yaml`:
```yaml
rl_deploy_zip:
  http_file:
    url: https://xxx/rl_deploy_1d5dda87.zip
    sha256: a1b2c3d4e5f6...
```

**Configuration Parameters:**

| Parameter | Description |
|-----------|-------------|
| `url` | Archive download URL, supports HTTP/HTTPS protocols |
| `sha256` | SHA256 checksum to ensure file integrity and security |

### 2. Configure Build Rules

Add extraction and packaging rules in the product's `BUILD` file:
```python
# Extract ZIP and convert to TAR format
extract_zip_to_tar(
    name = "rl_deploy",
    zip_file = ["@rl_deploy_zip//file"],
)

# Add module to product package file list
filegroup(
    name = "x86_64_a2_ultra_tar_list",
    srcs = [
        ":rl_deploy_tar",
        # Other modules...
    ],
)
```

### 3. Configure Module Startup

Edit the product configuration file `product/a2_ultra/addons/x86_64/entry/bin/cfg/run_agibot.yaml` and add module startup configuration:
```yaml
process_manager:
  default_apps:
    # Add module to startup list
    [..., "mc", ...]
  apps:
    "mc":
      path: "${AGIBOT_HOME}/agibot/software/v0/rl_deploy/deploy_assets/scripts/start_rl_control_real.sh"
      sudo: false
```

## Build Workflow

The build system automatically executes the following steps:

1. **Download** → Fetch archive from artifact repository
2. **Verify** → Validate SHA256 hash
3. **Extract** → Unpack and convert to TAR format
4. **Integrate** → Package into product directory

## Notes

- Ensure SHA256 value is accurate to avoid integrating corrupted files
- Module path configuration must match the actual directory structure after extraction
- Rebuild the product package after modifying configuration for changes to take effect