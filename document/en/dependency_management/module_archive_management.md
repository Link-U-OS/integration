# Module Archive Package Management

Product package builds support the integration of precompiled module archives. These archives are stored in artifact repositories, and the build process automatically downloads, verifies, and integrates them into the final product package.

## Quick Start

### Step 1: Configure Archive Information

Define the module archives to be integrated in `projects/defs/archives.yaml`:

```yaml
rl_deploy_zip:
  http_file:
    url: https://xxx/rl_deploy_1d5dda87.zip
    sha256: a1b2c3d4e5f6...
```

**Parameter Description:**

| Parameter | Description |
|-----------|-------------|
| `url` | Download URL for the archive in the artifact repository (supports HTTP/HTTPS) |
| `sha256` | SHA256 checksum of the file, used to verify the integrity and authenticity of the downloaded file |

### Step 2: Reference in Product Package

Configure the extraction and packaging logic for archives in the `BUILD` file:

```python
# Extract ZIP file and convert to TAR format
extract_zip_to_tar(
    name = "rl_deploy",
    zip_file = ["@rl_deploy_zip//file"],
)

# Add the converted TAR file to the product package
filegroup(
    name = "x86_64_a2_ultra_tar_list",
    srcs = [
        ":rl_deploy_tar",
        # Add other modules...
    ],
)
```

## Workflow

The build system processes module archives in the following steps:

1. **Download** - Download archives from the artifact repository according to the configuration in `archives.yaml`
2. **Verify** - Verify the integrity of downloaded files using SHA256 hash values
3. **Extract** - Extract ZIP archives and convert them to TAR format
4. **Integrate** - Package the converted files into the specified product package directory
