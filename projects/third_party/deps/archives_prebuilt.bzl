load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def all_prebuilt_packages():
    http_archive(
        name = "patchelf",
        sha256 = "fa8b6ed3870d09b703a8e3fc45698849d3a8cf5ac123df8c031c9b92c6c1d816",
        strip_prefix = "patchelf-0.18.0",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/patchelf-0.18.0_x86_64.tar.gz"
        ],
        build_file = "@integration//projects/third_party:patchelf.BUILD",
    )

    http_archive(
        name = "mcap_cli_x86_64",
        sha256 = "202fcc7a140292683ecfdf455867851edd67990f620f3ec910aa7965823a588a",
        strip_prefix = "mcap_cli-v0.0.53/bin",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/mcap_cli-v0.0.53_x86_64.tar.gz"
        ],
        build_file = "@integration//projects/third_party:mcap_cli.BUILD",
    )

    http_archive(
        name = "mcap_cli_aarch64",
        sha256 = "3f99368b2261ed9ce1ac5156bac55e16c254b5d99e1b50615f90278b8c54013c",
        strip_prefix = "mcap_cli-v0.0.53/bin",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/mcap_cli-v0.0.53_aarch64.tar.gz"
        ],
        build_file = "@integration//projects/third_party:mcap_cli.BUILD",
    )

    http_archive(
        name = "archive_x86_64",
        sha256 = "28c32c184a88b525ab567aa862eb13a13f6ba88780631a370b42967e165b975c",
        strip_prefix = "libarchive-3.6.2",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/libarchive-3.6.2.tar.gz"
        ],
        build_file = "@integration//projects/third_party:archive.BUILD",
    )

    http_archive(
        name = "archive_aarch64",
        sha256 = "47be67112a191136b37b6aa4dff8e1f5dc4927662c543a3f5fd289afc760135a",
        strip_prefix = "libarchive-orin-4",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/libarchive-orin-4.tar.gz"
        ],
        build_file = "@integration//projects/third_party:archive.BUILD",
    )

    http_archive(
        name = "zenoh-c_x86_64",
        build_file = "@integration//projects/third_party:zenoh-c.BUILD",
        sha256 = "94b8700ce50ceb4f70b4ec495459e0292bb193ad134625a219ef669af743619f",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/zenoh-c-1.0.0.11_x86_64.tar.gz"
        ],
        strip_prefix = "zenoh-c-1.0.0.11",
    )

    http_archive(
        name = "zenoh-c_aarch64",
        build_file = "@integration//projects/third_party:zenoh-c.BUILD",
        sha256 = "97e2b3cebbbd187241581cd71f792c0d6fd018d455cf94c286c0667021d60ceb",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/zenoh-c-1.0.0.11_aarch64.tar.gz"
        ],
        strip_prefix = "zenoh-c-1.0.0.11",
    )

    http_archive(
        name = "boost_x86_64",
        build_file = "@integration//projects/third_party:boost.BUILD",
        sha256 = "3373c06a249f99149c0e394ef64f836893ce5acfe9434b5a6a02b52d2706a1fa",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/boost-1.82.0_x86_64.tar.gz"
        ],
        strip_prefix = "boost-1.82.0",
    )

    http_archive(
        name = "boost_aarch64",
        build_file = "@integration//projects/third_party:boost.BUILD",
        sha256 = "c58ccb6eb5e44e743ebc7343c5c8260d9ea89dab212f1d2f9d7b323da72eb36b",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/boost-1.82.0_aarch64.tar.gz"
        ],
        strip_prefix = "boost-1.82.0",
    )

    http_archive(
        name = "CURL_x86_64",
        build_file = "@integration//projects/third_party:curl.BUILD",
        sha256 = "e7e313de2dc2f483afe03bd7d06aef5400b4baea9c2b6e85881c53d31b5da16f",
        strip_prefix = "curl-7.81.0",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/curl-7.81.0_x86_64.tar.gz"
        ],
    )

    http_archive(
        name = "CURL_aarch64",
        build_file = "@integration//projects/third_party:curl.BUILD",
        sha256 = "ba6133855468adc787c1ed7f4c45b11853d48660224655cec30b0bf97a20c6da",
        strip_prefix = "curl-7.81.0",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/curl-7.81.0_aarch64.tar.gz"
        ],
    )
    http_archive(
        name = "OrbbecSDK_x86_64",
        build_file = "@integration//projects/third_party:OrbbecSDK.BUILD",
        sha256 = "93879386c8dfd0c4782b35a8aae384ad8669c5b994176545cf7d949c6b88eb14",
        strip_prefix = "OrbbecSDK-1.8.3",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/OrbbecSDK-1.8.3_x86_64.tar.gz"
        ],
    )

    http_archive(
        name = "OrbbecSDK_aarch64",
        build_file = "@integration//projects/third_party:OrbbecSDK.BUILD",
        sha256 = "38d21bdb42d9ef6932ae8cf1678351d5b408aed627f2095706ee7a2556454ec8",
        strip_prefix = "OrbbecSDK-1.8.3",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/OrbbecSDK-1.8.3_aarch64.tar.gz"
        ],
    )
    http_archive(
        name = "eigen_x86_64",
        build_file = "@integration//projects/third_party:eigen.BUILD",
        sha256 = "a5a67def361fe3b69684ba43cdf85338239f72644cb513ec9e2c049a8241719c",
        strip_prefix = "eigen_3.4.0",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/eigen_3.4.0_x86_64.tar.gz"
        ],
        patch_args = ["-p1"],
        patches = ["@integration//projects/third_party/patches:fix_eigen_half_convert_to_Float16.patch"],
    )

    http_archive(
        name = "eigen_aarch64",
        build_file = "@integration//projects/third_party:eigen.BUILD",
        sha256 = "1b46d7b9bb6068ed4356374ab42f84fe8b97ae8622f55221f34322ddb4f5b056",
        strip_prefix = "eigen_3.4.0",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/eigen_3.4.0_aarch64.tar.gz"
        ],
        patch_args = ["-p1"],
        patches = ["@integration//projects/third_party/patches:fix_eigen_half_convert_to_Float16.patch"],
    )

    http_archive(
        name = "elfutils_x86_64",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/elfutils-0.189_x86_64.tar.gz"
        ],
        sha256 = "256d2387c0446ac297ff2ae4edeb176c6c73192025c0c42bd66baf605e8ec5d8",
        strip_prefix = "elfutils-0.189",
        build_file = "@integration//projects/third_party:elfutils.BUILD",
    )

    http_archive(
        name = "elfutils_aarch64",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/elfutils-0.189_aarch64.tar.gz"
        ],
        sha256 = "8b9c48ee160e0abd2fb989f93bdf2608b9659be741fbf5e69c48ba4df2fea590",
        strip_prefix = "elfutils-0.189",
        build_file = "@integration//projects/third_party:elfutils.BUILD",
    )

    http_archive(
        name = "fastcdr_x86_64",
        build_file = "@integration//projects/third_party:fastcdr.BUILD",
        sha256 = "5c4cc8da67e8dd2223a11960916bcdefe2cf93f4ed81792a49b2392df46b9cea",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/Fast-CDR-2.2.5_x86_64.tar.gz"
        ],
        strip_prefix = "Fast-CDR-2.2.5",
    )

    http_archive(
        name = "fastcdr_aarch64",
        build_file = "@integration//projects/third_party:fastcdr.BUILD",
        sha256 = "3cc8f55ee1cf8f3677b449dda492f5a6dc994ad424d2ba223e97838ffce7aa8e",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/Fast-CDR-2.2.5_aarch64.tar.gz"
        ],
        strip_prefix = "Fast-CDR-2.2.5",
    )

    http_archive(
        name = "fastrtps_x86_64",
        build_file = "@integration//projects/third_party:fastrtps.BUILD",
        sha256 = "b652e9173f8a30b3db89620d7f5ec0c865bec5d020ea178d2803e8b919cc330c",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/Fast-DDS-2.14.5_x86_64.tar.gz"
        ],
        strip_prefix = "Fast-DDS-2.14.5",
    )

    http_archive(
        name = "fastrtps_aarch64",
        build_file = "@integration//projects/third_party:fastrtps.BUILD",
        sha256 = "cfce6aedab1d726db521c5fda0e045519869f5210263b1c769a050df8494a729",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/Fast-DDS-2.14.5_aarch64.tar.gz"
        ],
        strip_prefix = "Fast-DDS-2.14.5",
    )

    http_archive(
        name = "protobuf_x86_64",
        build_file = "@integration//projects/third_party:protobuf.BUILD",
        strip_prefix = "protobuf-30.0",
        sha256 = "0f42343336984a2390a7b231c9d9c9d97f372ba6e139fc5a71508be9a2beb91f",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/protobuf-30.0_test_x86_64.tar.gz"
        ],
    )

    http_archive(
        name = "protobuf_aarch64",
        build_file = "@integration//projects/third_party:protobuf.BUILD",
        strip_prefix = "protobuf-30.0",
        sha256 = "30469da249655b7ee7d06a24e7e41bfcc69f4b4cdff4259393db59f2c7e72532",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/protobuf-30.0_test_aarch64.tar.gz"
        ],
    )

    http_archive(
        name = "sqlcipher_x86_64",
        build_file = "@integration//projects/third_party:sqlcipher.BUILD",
        sha256 = "0108a242eeff00906ea5e6296f0f749ee27e0e25fed14c17cf0c4fd88338326b",
        strip_prefix = "sqlcipher-3.50.4",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/sqlcipher-3.50.4_x86_64.tar.gz"
        ],
    )

    http_archive(
        name = "sqlcipher_aarch64",
        build_file = "@integration//projects/third_party:sqlcipher.BUILD",
        sha256 = "e46ee5d62f89ab784c249609415fbd3fb1c0475ebe17bba79510b1e8d0391ca8",
        strip_prefix = "sqlcipher-3.50.4",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/sqlcipher-3.50.4_aarch64.tar.gz"
        ],
    )

    http_archive(
        name = "iceoryx_x86_64",
        sha256 = "00f5e346eea678d1fbb22f2b16916debc1e0591af84dff08aea8fdebbc0d4aa0",
        build_file = "@integration//projects/third_party:iceoryx.BUILD",
        strip_prefix = "iceoryx-2.95.4",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/iceoryx-2.95.4_x86_64_rc1.tar.gz"
        ],
    )

    http_archive(
        name = "iceoryx_aarch64",
        sha256 = "e9e7c62cba7f519c0c82ab26e11ff4736ac5c19f388ed2781149974d0b40feb8",
        build_file = "@integration//projects/third_party:iceoryx.BUILD",
        strip_prefix = "iceoryx-2.95.4",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/iceoryx-2.95.4_aarch64_rc1.tar.gz"
        ],
    )

    http_archive(
        name = "lz4_x86_64",
        sha256 = "7a88c462b3dc2f4d80f2d67dd482e71919b8ed14f4261ca9ba457e0ce55690f3",
        build_file = "@integration//projects/third_party:lz4.BUILD",
        strip_prefix = "lz4-1.10.0",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/lz4-1.10.0_x86_64.tar.gz"
        ],
    )

    http_archive(
        name = "lz4_aarch64",
        sha256 = "2b169f7fd25817ed21d6be7e42c2e3e2b7beaceb35ddbe218466733d06f36f34",
        build_file = "@integration//projects/third_party:lz4.BUILD",
        strip_prefix = "lz4-1.10.0",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/lz4-1.10.0_aarch64.tar.gz"
        ],
    )

    http_archive(
        name = "nghttp2_x86_64",
        build_file = "@integration//projects/third_party:nghttp2.BUILD",
        sha256 = "f8d32cdeb90fb124d4b89d0a5a92e5d4e4cefee7dc21c0940c1675073bf26e84",
        strip_prefix = "nghttp2-1.62.1",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/nghttp2-1.62.1_x86_64.tar.gz"
        ],
    )

    http_archive(
        name = "nghttp2_aarch64",
        build_file = "@integration//projects/third_party:nghttp2.BUILD",
        sha256 = "18b085c0c5c6c4bf9065f3347e2ad5bb095037eeb24d2322349426c0e58ad30e",
        strip_prefix = "nghttp2-1.62.1",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/nghttp2-1.62.1_aarch64.tar.gz"
        ],
    )

    http_archive(
        name = "opencv_x86_64",
        build_file = "@integration//projects/third_party:opencv.BUILD",
        sha256 = "3c8c225e36694a41832734fefde622cdc178563eac8430bb1a15a838f6a2b674",
        strip_prefix = "opencv-4.5.4",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/opencv-4.5.4_x86_64.tar.gz"
        ],
    )

    http_archive(
        name = "opencv_aarch64",
        build_file = "@integration//projects/third_party:opencv.BUILD",
        sha256 = "4a294321f3acea7945aca84072f63421c719ba8d0b5e1c81f15877f9bed382e3",
        strip_prefix = "opencv-4.5.4",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/opencv-4.5.4_aarch64.tar.gz"
        ],
    )

    http_archive(
        name = "openssl_x86_64",
        sha256 = "561cd338ede13db9cdfb544a5636846aadd059c1342ec14a8f08274c74e2b8d0",
        strip_prefix = "openssl-3.0.2",
        build_file = "@integration//projects/third_party:openssl.BUILD",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/openssl-3.0.2_x86_64.tar.gz"
        ],
    )

    http_archive(
        name = "openssl_aarch64",
        sha256 = "3d878d467b0c387a61fa46681fb36ba693255c88ea94ce3b3d831cf27d961acc",
        strip_prefix = "openssl-3.0.2",
        build_file = "@integration//projects/third_party:openssl.BUILD",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/openssl-3.0.2_arrch64.tar.gz"
        ],
    )

    http_archive(
        name = "lss",
        build_file = "@integration//projects/third_party:lss.BUILD",
        sha256 = "3880d4169e3d656ad5f00e1e4b03658beed79f0aa2be1b2a449a976b67a68c31",
        strip_prefix = "linux-syscall-support-ed31caa6",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/linux-syscall-support-ed31caa6.tar.gz"
        ],
    )


    http_archive(
        name = "unifex_x86_64",
        sha256 = "29f3871350c518cf739b7e050d55f6d02d63198600ebed055d43ec4ea06368d7",
        strip_prefix = "libunifex-591ec09e",
        build_file = "@integration//projects/third_party:unifex.BUILD",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/libunifex-591ec09e_x86_64.tar.gz"
        ],
    )

    http_archive(
        name = "unifex_aarch64",
        sha256 = "188df011d54a8b478c373b56430dcba1d654dba2bae780a06ba51569b6f8a4e4",
        strip_prefix = "libunifex-591ec09e",
        build_file = "@integration//projects/third_party:unifex.BUILD",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/libunifex-591ec09e_aarch64.tar.gz"
        ],
    )

    http_archive(
        name = "xz_x86_64",
        build_file = "@integration//projects/third_party:xz.BUILD",
        sha256 = "f75c04741ad9fac60c8cd937d198ad73a350c9a0e7d9391243690102a80733f7",
        strip_prefix = "xz-5.2.7",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/xz-5.2.7_x86_64.tar.gz"
        ],
    )

    http_archive(
        name = "xz_aarch64",
        build_file = "@integration//projects/third_party:xz.BUILD",
        sha256 = "782c3c5f7fff1ed28b82fd63abc3e1d528b52cda444b6ba84818528c4e981cda",
        strip_prefix = "xz-5.2.7",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/xz-5.2.7_aarch64.tar.gz"
        ],
    )

    http_archive(
        name = "zstd_x86_64",
        build_file = "@integration//projects/third_party:zstd.BUILD",
        sha256 = "360ff3f0d5c510ffa2aab853880548b4f8147b1ddd4a685ef3e142f88ce6889c",
        strip_prefix = "zstd-1.5.7",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/zstd-1.5.7_x86_64.tar.gz"
        ],
    )

    http_archive(
        name = "zstd_aarch64",
        build_file = "@integration//projects/third_party:zstd.BUILD",
        sha256 = "aae088a5d5d73e0ccd73b0571511be26281a2d9807c13e05fec04834812c0137",
        strip_prefix = "zstd-1.5.7",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/zstd-1.5.7_aarch64.tar.gz"
        ],
    )

    http_archive(
        name = "pybind11_x86_64",
        sha256 = "0c26b6b49bb4eaf4004a15c3238ad6727c9cec946be9a11bc99628698a6c0f0a",
        strip_prefix = "pybind11-2.13.1",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/pybind11-2.13.1_x86_64.tar.gz"
        ],
        build_file = "@integration//projects/third_party:pybind11.BUILD",
    )

    http_archive(
        name = "pybind11_aarch64",
        sha256 = "4dcacb86750136516637ac0fa072333e35f3fee846849f2a57bbaf27919b748a",
        strip_prefix = "pybind11-2.13.1",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/pybind11-2.13.1_aarch64.tar.gz"
        ],
        build_file = "@integration//projects/third_party:pybind11.BUILD",
    )

   
    http_archive(
        name = "com_google_protobuf_fix",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/protobuf-30.0-fix-20250630.tar.gz"
        ],
        strip_prefix = "protobuf-30.0-fix",
        sha256 = "c8afe36b34ef80260f5e215b92584a1e794cf9fd6625fe5bbd018ca50f047aae",
    )

    http_archive(
        name = "opentelemetry_cpp_x86_64",
        sha256 = "464049bfb6a2b25aff8851632f51330aed1c9fbc1d5610c0ef993fb4aa0620f1",
        strip_prefix = "opentelemetry-cpp-1.16.1",
        build_file = "@integration//projects/third_party:opentelemetry_cpp.BUILD",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/opentelemetry-cpp-1.16.1_x86_64.tar.gz"
        ],
    )
    http_archive(
        name = "opentelemetry_cpp_aarch64",
        sha256 = "4e058e70ace45a537f8031b78c2fa96e6b354b46d8f709913e050415da74a648",
        strip_prefix = "opentelemetry-cpp-1.16.1",
        build_file = "@integration//projects/third_party:opentelemetry_cpp.BUILD",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/opentelemetry-cpp-1.16.1_aarch64.tar.gz"
        ],
    )

    http_archive(
        name = "realsense2_aarch64",
        sha256 = "4638ce4b3411ae94a383e13fe9d0260dc6c1246fd24beeb7061e0c18ff7133cc",
        strip_prefix = "realsense-2.55.1",
        build_file = "@integration//projects/third_party:realsense2.BUILD",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/realsense-2.55.1_aarch64.tar.gz"
        ],
    )

    http_archive(
        name = "realsense2_tz_aarch64",
        sha256 = "b15f432f5acb6e7015b19f564ab6afc54f97986b387c2a199572d574a2f6511c",
        strip_prefix = "realsense-2.55.1",
        build_file = "@integration//projects/third_party:realsense2.BUILD",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/realsense-2.55.1_tz_aarch64_rc1.tar.gz"
        ],
    )

    http_archive(
        name = "tzcam_aarch64",
        sha256 = "911233374123e045d6fc5f52bb5dc0e86dee019e0164bdf90dff3dffc780bd15",
        strip_prefix = "tzcam_20250609",
        build_file = "@integration//projects/third_party:tzcam.BUILD",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.1/tzcam_20250609_aarch64.tar.gz"
        ],
    )
    
    http_archive(
        name = "paho_mqtt_c_x86_64",
        sha256 = "5fb4cd04a4a42fb31e073b59deee3c7c89fda7b2b9bc861bd18c78d6167ba4d4",
        strip_prefix = "paho.mqtt.c-1.3.13",
        build_file = "@integration//projects/third_party:paho_mqtt_c.BUILD",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/paho.mqtt.c-1.3.13_x86_64.tar.gz"
        ],
    )

    http_archive(
        name = "paho_mqtt_c_aarch64",
        sha256 = "8ae2ffe5e04e902c27dfc440697ada0ee7c0470a76977910ac140b6046f86917",
        strip_prefix = "paho.mqtt.c-1.3.13",
        build_file = "@integration//projects/third_party:paho_mqtt_c.BUILD",
        urls = [
            "https://github.com/Link-U-OS/aimrt_prebuilt/releases/download/1.0.0/paho.mqtt.c-1.3.13_aarch64.tar.gz"
        ],
    )
