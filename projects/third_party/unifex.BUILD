package(default_visibility = ["//visibility:public"])

cc_library(
    name = "unifex",
    hdrs = glob(["include/unifex/**/*.hpp", "include/unifex/**/*.h"]),
    includes = ["include"],
    srcs = ["lib/libunifex.so", "lib/libunifex.so.0", "lib/libunifex.so.0.1.0"],
    linkopts = ["-lunifex"],
)