#!/bin/bash

# Define Result Variant
ENV_CHECK_RESULT="Environment tests pass"
# if not pass, replace it as "Failed environmental tests"

check_android_home() {
    if [ -z "$ANDROID_HOME" ]; 
    then 
        if [ -d "$HOME/Android/Sdk" ];
        then
            echo "ERROR: Android SDK not found"
            ENV_CHECK_RESULT="Failed environmental tests"
            exit 1
        else
            ANDROID_HOME=~/Android/Sdk; 
            echo "WARNING: ANDROID_HOME not configured!"
        fi
    fi
    echo "Android Home: $ANDROID_HOME"
}

check_and_select_ndk() {
    if [ -d "$ANDROID_HOME/ndk/25.2.9519653" ]; then
        # find ndk 25.2.9519653
        NDK_HOME="$ANDROID_HOME/ndk/25.2.9519653"
    else
        # not find ndk 25.2.9519653 and try to use other ndk
        if [ "$(find "$ANDROID_HOME/ndk" -type d -name '*' | wc -l)" -gt 0 ]; then
            echo "WARNING: Cannot find NDK 25.2.9519653. Versions that may be incompatible will be automatically used."
            NDK_HOME=$ANDROID_HOME/ndk/$(find "$ANDROID_HOME/ndk" -maxdepth 1 -type d -name '*' | tail -n 1)
        else
            echo "ERROR: No NDK found!"
            ENV_CHECK_RESULT="Failed environmental tests"
            exit 1
        fi
    fi
    echo "NDK: $NDK_HOME"
}

check_prebuild_dir() {
    if [ -d "$NDK_HOME/toolchains/llvm/prebuilt" ]; then
        PREBUILT_DIR=$NDK_HOME/toolchains/llvm/prebuilt
        PREBUILT_DIR=$(find "$PREBUILT_DIR" -maxdepth 1 -type d -name '*' | tail -n 1)
    else
        echo "ERROR: cannot find $NDK_HOME/toolchains/llvm/prebuilt !"
        ENV_CHECK_RESULT="Failed environmental tests"
        exit 1
    fi
    echo "Prebuild Dir: $PREBUILT_DIR"
}

check_android_home
check_and_select_ndk
check_prebuild_dir
PATH=$NDK_HOME/build:$PREBUILT_DIR/bin:$PATH

# check tool chain
function check_which() 
{
    TESTED=$(which "$1")
    if [ -n "$TESTED" ]; then 
        echo "find $1: $TESTED"
    else
        echo "ERROR: $1 not found!"
        ENV_CHECK_RESULT="Failed environmental tests"
    fi
}
# CC
check_which aarch64-linux-android21-clang
# CXX
check_which aarch64-linux-android21-clang++
# AR
check_which llvm-ar
# RANLIB
check_which llvm-ar
# NM 
check_which llvm-nm
# STRIP
check_which llvm-strip
# NDKBUILD
check_which ndk-build
# SYSROOT
if [ -d "$PREBUILT_DIR/sysroot" ]; then
    echo "find sysroot: $PREBUILT_DIR/sysroot"
else
    echo "ERROR: sysroot not found!"
    ENV_CHECK_RESULT="Failed environmental tests"
fi

# Check Commands
function check_command()
{
    if command -v "$1" &>/dev/null; then
        echo "$1 command is available."
    else
        echo "ERROR: $1 command not found."
        ENV_CHECK_RESULT="Failed environmental tests"
    fi
}

check_command wget
check_command tar
check_command git
check_command unzip
check_command "7z"
check_command cmake

if [ "$ENV_CHECK_RESULT" == "Failed environmental tests" ]; then
    echo -e "\033[97;41m FAILURE:\033[0m $ENV_CHECK_RESULT"
else
    echo -e "\033[97;42m SUCCESS:\033[0m $ENV_CHECK_RESULT"
fi