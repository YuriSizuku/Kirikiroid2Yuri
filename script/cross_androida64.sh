# bash -c "export SKIP_PORTS=yes && ./cross_androida64.sh"
PLATFORM=androida64
BUILD_PATH=./../build_${PLATFORM}
CMAKELISTS_PATH=$(pwd)/..
PORTBUILD_PATH=$CMAKELISTS_PATH/thirdparty/build/arch_$PLATFORM
ANDROID_THIRDPARTY_PATH=$CMAKELISTS_PATH/src/onsyuri_android/app/cpp/thirdparty
CORE_NUM=$(cat /proc/cpuinfo | grep -c ^processor)
TARGETS=$@

function fetch_ports()
{
    # audio
    fetch_opus
    fetch_ogg
    fetch_vorbis
    fetch_opusfile
    fetch_oboe
    fetch_openal
    
    # video
    fetch_jpeg
    fetch_opencv
    fetch_ffmpeg

    # archive
    fetch_unrar
    fetch_lz4
    fetch_archive
    fetch_p7zip

    # others
    fetch_oniguruma
    fetch_syscall
    fetch_breakpad

    # framework
    fetch_sdl2
    fetch_cocos2dx    
}

function build_ports()
{
    # audio
    build_opus
    build_ogg
    build_vorbis
    build_opusfile
    build_oboe
    build_openal

    # video
    build_jpeg
    build_ffmpeg

    # archive
    build_unrar
    build_lz4
    build_archive
    build_p7zip

    # others
    build_oniguruma
    build_breakpad

    # framework
    build_sdl2
    build_cocos2dx
}

# prepare env, tested with ndk 25.2.9519653
if [ -z "$ANDROID_HOME" ]; then ANDROID_HOME=/d/Software/env/sdk/androidsdk; fi
NDK_HOME=$ANDROID_HOME/ndk/$(ls -A $ANDROID_HOME/ndk | tail -n 1)
PREBUILT_DIR=$NDK_HOME/toolchains/llvm/prebuilt
PREBUILT_DIR=$PREBUILT_DIR/$(ls -A $PREBUILT_DIR | tail -n 1)
PATH=$NDK_HOME/build:$PREBUILT_DIR/bin:$PATH
CC=$(which aarch64-linux-android21-clang)
CXX=$(which aarch64-linux-android21-clang++)
AR=$(which llvm-ar)
RANLIB=$(which llvm-ranlib)
NM=$(which llvm-nm)
STRIP=$(which llvm-strip)
NDKBUILD=$(which ndk-build)
SYSROOT=$PREBUILT_DIR/sysroot
echo "## ANDROID_HOME=$ANDROID_HOME"
echo "## NDK-BUILD=$NDKBUILD"
echo "## CC=$CC"
echo "## AR=$AR"

# fetch and build ports
# SKIP_PORTS="yes"
source ./_fetch.sh
source ./_$PLATFORM.sh
fetch_asset
if [ -z "$SKIP_PORTS" ]; then
    fetch_ports
    build_ports
fi

# config and build project
if [ -z "$BUILD_TYPE" ]; then BUILD_TYPE=MinSizeRel; fi
if [ -z "$TARGETS" ]; then TARGETS=all; fi

cmake -B $BUILD_PATH -S $CMAKELISTS_PATH \
    -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_TOOLCHAIN_FILE=$NDK_HOME/build/cmake/android.toolchain.cmake \
    -DANDROID_PLATFORM=21 -DANDROID_ABI=arm64-v8a \
    -DPORTBUILD_PATH=$PORTBUILD_PATH
make -C $BUILD_PATH $TARGETS -j$CORE_NUM
# make -C $BUILD_PATH $TARGETS -j1
# $STRIP $BUILD_PATH/libkrkr2yuri.so