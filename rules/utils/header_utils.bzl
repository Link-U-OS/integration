# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

def generate_top_header(name, exclude_hdrs = []):
    """Generate a top-level header file that includes all headers in the package.
    The generated header will include all .h, .hpp and .hxx files recursively.
    
    Args:
        name: Target name for the generated header
        exclude_hdrs: Headers to exclude from generation
    """
    if not name:
        fail("name must be specified")

    native.genrule(
        name = "gen_top_header",
        srcs = native.glob(
            [
                "**/*.h",
                "**/*.hpp",
                "**/*.hxx",
            ],
            exclude = exclude_hdrs,
        ),
        outs = [name + ".h"],
        cmd = """
            echo "// Auto-generated top level header" > $@
            for header in $(SRCS); do
                relative_path=$$(echo $$header | sed 's|^$$(pwd)/||')
                
                # Remove external/ and repository name from path if present
                if [[ $$relative_path == *"external/"* ]]; then
                    relative_path=$$(echo $$relative_path | sed 's|external/[^/]*/||')
                fi
                
                echo "#include \\"$$relative_path\\"" >> $@
            done
        """,
    )

def cc_library_with_top_header(name, srcs = [], hdrs = [], deps = [], exclude_hdrs= [], **kwargs):
    """Create a cc_library target with an auto-generated top-level header.
    The top header will include all headers in the package.
    
    Args:
        name: Target name for the cc_library
        srcs: Source files to compile
        hdrs: Additional headers to include
        deps: Library dependencies
        exclude_hdrs: Headers to exclude from top header generation
        **kwargs: Additional arguments passed to cc_library
    """
    if not name:
        fail("name must be specified")

    generate_top_header(
        name = name,
        exclude_hdrs = exclude_hdrs
    )

    tags = kwargs.get("tags", [])
    tags.append("has_top_header")
    kwargs["tags"] = tags

    native.cc_library(
        name = name,
        srcs = srcs,
        hdrs = hdrs + [":" + name + ".h"],
        deps = deps,
        **kwargs
    )
