#!/bin/bash

PLATFORM=androida64

# CHANGE IT WHEN MOVE THIS FILE
BUILD_PATH=$(pwd)/../build/build_${PLATFORM}
CMAKELISTS_PATH=$(pwd)/..
# Set relative path variables
PORTBUILD_PATH=$CMAKELISTS_PATH/thirdparty/build/arch_$PLATFORM
ANDROID_THIRDPARTY_PATH=$CMAKELISTS_PATH/src/onsyuri_android/app/cpp/thirdparty
# Set compilation options
CORE_NUM=$(grep -c ^processor < /proc/cpuinfo)
TARGETS=$@

# Check the environment
source "check_environment.sh"
if [ "$ENV_CHECK_RESULT" == "Failed environmental tests" ]; then
    exit 1
fi

# Set toolchain path
PATH=$NDK_HOME/build:$PREBUILT_DIR/bin:$PATH
CC=$(which aarch64-linux-android21-clang)
export CC
CXX=$(which aarch64-linux-android21-clang++)
export CXX
AR=$(which llvm-ar)
export AR
RANLIB=$(which llvm-ranlib)
export RANLIB
NM=$(which llvm-nm)
export NM
STRIP=$(which llvm-strip)
export STRIP
NDKBUILD=$(which ndk-build)
export NDKBUILD
export SYSROOT=$PREBUILT_DIR/sysroot

# fetch ports
source "fetch.sh"
if [ "$FETCH_RESULT" == "Dependency not satisfied" ]; then
    exit 1
fi

build_ports() {
    source "_compile_ports.sh"
}
# Skip?
if [ -d "$PORTBUILD_PATH/bin" ]; then
    echo "It seems that you have built the ports, would you like to skip? (Y/n)"
    read -r user_input
    
    if [[ "$user_input" == "Y" || "$user_input" == "y" ]]; then
        echo "Build ports skipped!"
    else
        build_ports | tee ports_build.log
        if [ -n "${FAILED_BUILD_ARRAY[*]}" ]; then
            exit 1
        fi
    fi
else
    build_ports | tee ports_build.log
    if [ -n "${FAILED_BUILD_ARRAY[*]}" ]; then
        exit 1
    fi
fi

build_yuri() {
    # config and build project
    if [ -z "$BUILD_TYPE" ]; then BUILD_TYPE=MinSizeRel; fi
    if [ -z "$TARGETS" ]; then TARGETS=all; fi
    cmake -B $BUILD_PATH -S "$CMAKELISTS_PATH" \
    -G "Unix Makefiles" -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_HOME/build/cmake/android.toolchain.cmake" \
    -DANDROID_PLATFORM=21 -DANDROID_ABI=arm64-v8a \
    -DPORTBUILD_PATH="$PORTBUILD_PATH"
    make -C $BUILD_PATH "$TARGETS" "-j$CORE_NUM"
}


echo "==============================================================="
echo -e "\033[43m WARNING: The process of compiling, prone to potential errors, will start after 5 seconds. \033[0m"
echo -e "You can find the log in ./yuri_build.log"
echo "==============================================================="
sleep 5

build_yuri | tee yuri_build.log

if [ -e "$CMAKELISTS_PATH/build/build_$PLATFORM/libkrkr2yuri.so" ]; then
    echo -e "\033[97;42m SUCCESS:\033[0m Kirikiroid2 yuri build successful"
    echo "Now, you can use 'project/android/gradlew assembleDebug' to build apk"
else
    echo -e "\033[97;41m FAILURE:\033[0m Build Failed"
fi