package(default_visibility = ["//visibility:public"])

cc_library(
    name = "opencv",
    srcs = glob([
        "lib/*.so*",
    ]),
    hdrs = glob([
        "include/opencv4/opencv2/**/*.h",
        "include/opencv4/opencv2/**/*.hpp",
    ]),
    includes = [
        "include/opencv4",
        "include/opencv4/opencv2",
    ],
   
)
