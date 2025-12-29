licenses([
    # Note: Eigen is an MPL2 library that includes GPL v3 and LGPL v2.1+ code.
    #       We've taken special care to not reference any restricted code.
    "reciprocal",  # MPL2
    "notice",  # Portions BSD
])

exports_files(["COPYING.MPL2"])

cc_library(
    name = "eigen",
    hdrs = glob([
        "include/eigen3/Eigen/*",
        "include/eigen3/Eigen/**/*.h",
        "include/eigen3/Eigen/**/*.inc",
        "include/eigen3/unsupported/Eigen/CXX11/**",
        "include/eigen3/unsupported/Eigen/src/FFT/**",
        "include/eigen3/unsupported/Eigen/src/KroneckerProduct/**",
        "include/eigen3/unsupported/Eigen/src/MatrixFunctions/**",
        "include/eigen3/unsupported/Eigen/src/NumericalDiff/**",
        "include/eigen3/unsupported/Eigen/src/NonLinearOptimization/**",
        "include/eigen3/unsupported/Eigen/src/SpecialFunctions/**",
        "include/eigen3/unsupported/Eigen/src/Polynomials/**",
    ]) + [
        "include/eigen3/unsupported/Eigen/FFT",
        "include/eigen3/unsupported/Eigen/KroneckerProduct",
        "include/eigen3/unsupported/Eigen/NonLinearOptimization",
        "include/eigen3/unsupported/Eigen/NumericalDiff",
        "include/eigen3/unsupported/Eigen/SpecialFunctions",
        "include/eigen3/unsupported/Eigen/Polynomials",
    ],
    defines = ["EIGEN_MPL2_ONLY"],
    includes = ["include", "include/eigen3", "include/eigen3/Eigen", "include/eigen3/unsupported/Eigen"],
    visibility = ["//visibility:public"],
)
