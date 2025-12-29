package(default_visibility = ["//visibility:public"])

genrule(
    name = "config_h",
    outs = ["config.h"],
    cmd = """
cat > $@ << 'EOF'
#ifndef CONFIG_H
#define CONFIG_H
#define PACKAGE "libsamplerate"
#define VERSION "0.2.2"
#define CPU_CLIPS_NEGATIVE 0
#define CPU_CLIPS_POSITIVE 0
#define CPU_IS_BIG_ENDIAN 0
#define CPU_IS_LITTLE_ENDIAN 1
#define HAVE_ALARM 1
#define HAVE_ALSA 0
#define HAVE_FFTW3 0
#define HAVE_LRINT 1
#define HAVE_LRINTF 1
#define HAVE_SIGALRM 1
#define HAVE_SIGNAL 1
#define HAVE_SNDFILE 0
#define HAVE_STDBOOL_H 1
#define HAVE_STDINT_H 1
#define HAVE_SYS_TIMES_H 1
#define HAVE_UNISTD_H 1
#define HAVE_VISIBILITY 1
#define ENABLE_SINC_FAST_CONVERTER 1
#define ENABLE_SINC_MEDIUM_CONVERTER 1
#define ENABLE_SINC_BEST_CONVERTER 1
#define SIZEOF_INT 4
#define SIZEOF_LONG 8
#endif
EOF
    """,
)

cc_library(
    name = "libsamplerate",
    srcs = [
        "src/samplerate.c",
        "src/src_sinc.c",
        "src/src_zoh.c",
        "src/src_linear.c",
        "src/common.h",
        "src/fastest_coeffs.h",
        "src/mid_qual_coeffs.h",
        "src/high_qual_coeffs.h",
        ":config_h",
    ],
    hdrs = [
        "include/samplerate.h",  
    ],
    copts = [
        "-DHAVE_CONFIG_H",
    ],
    includes = [
        "include",  
    ],
    local_defines = ["HAVE_VISIBILITY=1"],
)