#!/bin/bash

# must use after fetch.sh

FAILED_BUILD_ARRAY=()

# audio
build_opus() 
{
    mkdir -p "$OPUS_SRC/build_$PLATFORM"
    
    pushd "$OPUS_SRC/build_$PLATFORM" || FAILED_BUILD_ARRAY+=("opus")
    ../configure --host=aarch64-linux-android \
        CC=aarch64-linux-android21-clang  AR=llvm-ar \
        CXX=aarch64-linux-android21-clang++ \
        "--prefix=$PORTBUILD_PATH" --with-pic
    make "-j$CORE_NUM" &&  make install
    popd || FAILED_BUILD_ARRAY+=("opus")

    if ! [ -d "$PORTBUILD_PATH/include/opus" ]; then
        FAILED_BUILD_ARRAY+=("opus")
    fi
}

build_ogg() 
{
    mkdir -p "$OGG_SRC/build_$PLATFORM"
    
    pushd "$OGG_SRC/build_$PLATFORM" || FAILED_BUILD_ARRAY+=("ogg")
    ../configure --host=aarch64-linux-android \
        CC=aarch64-linux-android21-clang  AR=llvm-ar \
        CXX=aarch64-linux-android21-clang++ \
        --prefix="$PORTBUILD_PATH" --with-pic
    make "-j$CORE_NUM" &&  make install
    popd || FAILED_BUILD_ARRAY+=("ogg")

    if ! [ -d "$PORTBUILD_PATH/include/ogg" ]; then
        FAILED_BUILD_ARRAY+=("ogg")
    fi
}

build_vorbis() 
{
    mkdir -p "$VORBIS_SRC/build_$PLATFORM"
    
    pushd "$VORBIS_SRC/build_$PLATFORM" || FAILED_BUILD_ARRAY+=("vorbis")
    ../configure --host=aarch64-linux-android \
        CC=aarch64-linux-android21-clang  AR=llvm-ar \
        CXX=aarch64-linux-android21-clang++ \
        --prefix="$PORTBUILD_PATH" --with-pic \
        --with-ogg="$PORTBUILD_PATH"
    make "-j$CORE_NUM" &&  make install
    popd || FAILED_BUILD_ARRAY+=("vorbis")

    if ! [ -d "$PORTBUILD_PATH/include/vorbis" ]; then
        FAILED_BUILD_ARRAY+=("vorbis")
    fi
}

build_opusfile() # after ogg, opus, vorbits
{
    mkdir -p "$OPUSFILE_SRC/build_$PLATFORM"
    
    pushd "$OPUSFILE_SRC/build_$PLATFORM" || FAILED_BUILD_ARRAY+=("opus")
    ../configure --host=aarch64-linux-android \
        CC=aarch64-linux-android21-clang  AR=llvm-ar \
        CXX=aarch64-linux-android21-clang++ \
        --prefix="$PORTBUILD_PATH" --with-pic \
        DEPS_CFLAGS="-I$PORTBUILD_PATH/include -I$PORTBUILD_PATH/include/opus" \
        DEPS_LIBS="-L$PORTBUILD_PATH/lib -logg -lopus" \
        --disable-http --disable-examples
    make "-j$CORE_NUM" &&  make install
    
    cp -rf "$CMAKELISTS_PATH/thirdparty/patch/opus/opusfile.h" "$PORTBUILD_PATH/include/opus/opusfile.h"
    
    popd || FAILED_BUILD_ARRAY+=("opus")

    if ! [ -d "$PORTBUILD_PATH/include/opus" ]; then
        FAILED_BUILD_ARRAY+=("opus")
    fi
}

build_oboe()
{
    mkdir -p "$OBOE_SRC/build_$PLATFORM"
    
    pushd "$OBOE_SRC/build_$PLATFORM" || FAILED_BUILD_ARRAY+=("oboe")
    cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_HOME/build/cmake/android.toolchain.cmake" \
        -DANDROID_PLATFORM=21 -DANDROID_ABI=arm64-v8a \
        -DCMAKE_C_FLAGS="-fPIC" -DCMAKE_CXX_FLAGS="-fPIC" \
        -DCMAKE_INSTALL_PREFIX="$PORTBUILD_PATH" \
        -DLIBTYPE=STATIC
    make "-j$CORE_NUM" &&  make install 

    mv -f "$PORTBUILD_PATH/lib/arm64-v8a/liboboe.a" "$PORTBUILD_PATH/lib/liboboe.a"

    popd || FAILED_BUILD_ARRAY+=("oboe")

    if ! [ -e "$PORTBUILD_PATH/lib/liboboe.a" ]; then
        FAILED_BUILD_ARRAY+=("oboe")
    fi
}

build_openal()
{
    mkdir -p "$OPENAL_SRC/build_$PLATFORM"

    pushd "$OPENAL_SRC/build_$PLATFORM" || FAILED_BUILD_ARRAY+=("openal")
    cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_HOME/build/cmake/android.toolchain.cmake" \
        -DANDROID_PLATFORM=21 -DANDROID_ABI=arm64-v8a \
        -DCMAKE_C_FLAGS="-fPIC" -DCMAKE_CXX_FLAGS="-fPIC" \
        -DCMAKE_INSTALL_PREFIX="$PORTBUILD_PATH" \
        -DLIBTYPE=STATIC
    make "-j$CORE_NUM" &&  make install 
    popd || FAILED_BUILD_ARRAY+=("openal")

    if ! [ -d "$PORTBUILD_PATH/include/AL" ]; then
        FAILED_BUILD_ARRAY+=("openal")
    fi
}

# video
build_jpeg() 
{
    mkdir -p "$JPEG_SRC/build_$PLATFORM"
    
    pushd "$JPEG_SRC/build_$PLATFORM" || FAILED_BUILD_ARRAY+=("libjpeg")
    NDK_PATH=$NDK_HOME
    TOOLCHAIN=clang
    ANDROID_VERSION=21
    cmake .. -G "Unix Makefiles" \
        -DANDROID_ABI=arm64-v8a \
        -DANDROID_ARM_MODE=arm \
        -DANDROID_PLATFORM=android-${ANDROID_VERSION} \
        -DANDROID_TOOLCHAIN=${TOOLCHAIN} \
        -DCMAKE_ASM_FLAGS="--target=aarch64-linux-android${ANDROID_VERSION}" \
        -DCMAKE_TOOLCHAIN_FILE="${NDK_PATH}/build/cmake/android.toolchain.cmake" \
        -DCMAKE_INSTALL_PREFIX="$PORTBUILD_PATH"
    make "-j$CORE_NUM" &&  make install
    popd || FAILED_BUILD_ARRAY+=("libjpeg")

    if ! [ -e "$PORTBUILD_PATH/lib/libjpeg.a" ]; then
        FAILED_BUILD_ARRAY+=("libjpeg")
    fi
}

build_opencv()
{
    mkdir -p "$OPENCV_SRC/build_$PLATFORM"

    pushd "$OPENCV_SRC/build_$PLATFORM" || FAILED_BUILD_ARRAY+=("opencv")
    cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_HOME/build/cmake/android.toolchain.cmake" \
        -DANDROID_PLATFORM=21 -DANDROID_ABI=arm64-v8a \
        -DCMAKE_INSTALL_PREFIX="$PORTBUILD_PATH" \
        -DWITH_CUDA=OFF -DWITH_MATLAB=OFF -DBUILD_ANDROID_EXAMPLES=OFF \
        -DBUILD_DOCS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF \
        -DBUILD_opencv_video=OFF -DBUILD_opencv_videoio=OFF -DBUILD_opencv_features2d=OFF \
        -DBUILD_opencv_flann=OFF -DBUILD_opencv_highgui=OFF -DBUILD_opencv_ml=OFF \
        -DBUILD_opencv_dnn=OFF -DBUILD_opencv_gapi=OFF -DBUILD_opencv_hal=ON \
        -DBUILD_opencv_photo=OFF -DBUILD_opencv_python=OFF -DBUILD_opencv_shape=OFF \
        -DBUILD_opencv_stitching=OFF -DBUILD_opencv_superres=OFF -DWITH_ITT=OFF \
        -DBUILD_opencv_ts=OFF -DBUILD_opencv_videostab=OFF -DBUILD_ANDROID_PROJECTS=OFF
    make "-j$CORE_NUM" &&  make install
    
    cp -rf  $PORTBUILD_PATH/sdk/native/3rdparty/libs/arm64-v8a/*.a "$PORTBUILD_PATH/lib"
    cp -rf  $PORTBUILD_PATH/sdk/native/staticlibs/arm64-v8a/*.a "$PORTBUILD_PATH/lib"
    
    popd || FAILED_BUILD_ARRAY+=("opencv")

    if ! [ -e "$PORTBUILD_PATH/sdk/native/jni/include/opencv2/opencv.hpp" ]; then
        FAILED_BUILD_ARRAY+=("opencv")
    fi
}

build_ffmpeg() 
{
    mkdir -p "$FFMPEG_SRC/build_$PLATFORM"
    
    pushd "$FFMPEG_SRC" || FAILED_BUILD_ARRAY+=("ffmpeg")
    cd "build_$PLATFORM" || FAILED_BUILD_ARRAY+=("ffmpeg")
    ../configure --enable-cross-compile --cross-prefix=aarch64-linux-android- \
        --cc=aarch64-linux-android21-clang  --ar=llvm-ar \
        --cxx=aarch64-linux-android21-clang++ --ranlib=llvm-ranlib \
        --strip=llvm-strip --prefix="$PORTBUILD_PATH" \
        --arch=aarch64 --target-os=android --enable-pic --disable-asm \
        --enable-static --enable-shared --enable-small --enable-swscale \
        --disable-ffmpeg --disable-ffplay --disable-ffprobe \
        --disable-avdevice --disable-programs --disable-doc --enable-stripping

    # use sh directory is not available in windows (absolute path), must use msys2 shell
    make "-j$CORE_NUM" &&  make install
    popd || FAILED_BUILD_ARRAY+=("ffmpeg")
    if ! [ -d "$PORTBUILD_PATH/include/libavcodec" ] || ! [ -d "$PORTBUILD_PATH/include/libavfilter" ] || ! [ -d "$PORTBUILD_PATH/include/libavformat" ] || ! [ -d "$PORTBUILD_PATH/include/libavutil" ] ; then
        FAILED_BUILD_ARRAY+=("ffmpeg")
    fi
}

# archive
build_unrar() 
{   
    cp -rf "$CMAKELISTS_PATH/thirdparty/patch/unrar/android_ulinks.cpp" "$UNRAR_SRC/ulinks.cpp"
    
    pushd "$UNRAR_SRC" || FAILED_BUILD_ARRAY+=("unrar")
    make clean
    make lib "-j$CORE_NUM" \
        CXX=aarch64-linux-android21-clang++ \
        AR=llvm-ar STRIP=llvm-strip \
        DESTDIR="$PORTBUILD_PATH"  
    
    mkdir -p "$PORTBUILD_PATH/include/unrar"
    cp -rf ./*.a "$PORTBUILD_PATH/lib"
    cp -rf ./*.hpp "$PORTBUILD_PATH/include/unrar"
    
    popd || FAILED_BUILD_ARRAY+=("unrar")

    if ! [ -d "$PORTBUILD_PATH/include/unrar" ]; then
        FAILED_BUILD_ARRAY+=("unrar")
    fi
}

build_lz4()
{
    pushd "$LZ4_SRC" || FAILED_BUILD_ARRAY+=("lz4")
    make clean
    make lib -j$CORE_NUM \
        CC=aarch64-linux-android21-clang \
        CXX=aarch64-linux-android21-clang++ \
        AR=llvm-ar STRIP=llvm-strip \
        WINBASED=no
    
    mkdir -p "$PORTBUILD_PATH/include/lz4"
    cp -rp lib/*.a "$PORTBUILD_PATH/lib"
    cp -rp lib/*.h "$PORTBUILD_PATH/include/lz4"
    
    popd || FAILED_BUILD_ARRAY+=("lz4")

    if ! [ -d "$PORTBUILD_PATH/include/lz4" ]; then
        FAILED_BUILD_ARRAY+=("lz4")
    fi
}

build_archive()
{
    mkdir -p "$ARCHIVE_SRC/build_$PLATFORM"
    cp -rf "$CMAKELISTS_PATH/thirdparty/patch/android_android_lf.h" "$ARCHIVE_SRC/libarchive/android_lf.h"
    
    pushd "$ARCHIVE_SRC/build_$PLATFORM" || FAILED_BUILD_ARRAY+=("libarchive")
    cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_HOME/build/cmake/android.toolchain.cmake" \
        -DANDROID_PLATFORM=21 -DANDROID_ABI=arm64-v8a \
        -DENABLE_OPENSSL=OFF -DENABLE_TEST=OFF \
        -DCMAKE_INSTALL_PREFIX="$PORTBUILD_PATH"
    make "-j$CORE_NUM" &&  make install

    mkdir -p "$PORTBUILD_PATH/include/libarchive"
    mv -f "$PORTBUILD_PATH/include/archive.h" "$PORTBUILD_PATH/include/libarchive" 
    mv -f "$PORTBUILD_PATH/include/archive_entry.h" "$PORTBUILD_PATH/include/libarchive" 
    
    popd || FAILED_BUILD_ARRAY+=("libarchive")

    if ! [ -e "$PORTBUILD_PATH/lib/libarchive.a" ]; then
        FAILED_BUILD_ARRAY+=("libarchive")
    fi
}

build_p7zip()
{
    mkdir -p "$P7ZIP_SRC/build_$PLATFORM"
    cp -rf "$CMAKELISTS_PATH"/thirdparty/patch/p7zip/7z* "$P7ZIP_SRC/C"
    cp -rf "$CMAKELISTS_PATH/thirdparty/patch/p7zip/android_p7zip.cmake" "$P7ZIP_SRC/CPP/ANDROID/7za/jni/CMakeLists.txt"

    pushd "$P7ZIP_SRC/build_$PLATFORM" || FAILED_BUILD_ARRAY+=("p7zip")
    cmake ../CPP/ANDROID/7za/jni -G "Unix Makefiles" \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DANDROID_PLATFORM=21 -DANDROID_ABI=arm64-v8a \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_HOME/build/cmake/android.toolchain.cmake"
    make "-j$CORE_NUM"
    
    mkdir -p "$PORTBUILD_PATH/include/p7zip/C" 
    mkdir -p "$PORTBUILD_PATH/include/p7zip/CPP"
    cp -rf lib7za.a "$PORTBUILD_PATH/lib"
    cp -rf ../C/*.h  "$PORTBUILD_PATH/include/p7zip/C"
    cp -rf ../CPP  "$PORTBUILD_PATH/include/p7zip"
    rm -rf "$PORTBUILD_PATH/include/p7zip/CPP/**/*.cpp"
    rm -rf "$PORTBUILD_PATH/include/p7zip/CPP/**/**/*.cpp"
    rm -rf "$PORTBUILD_PATH/include/p7zip/CPP/**/**/**/*.cpp"
    rm -rf "$PORTBUILD_PATH/include/p7zip/CPP/**/**/**/**/*.cpp"
    rm -rf "$PORTBUILD_PATH/include/p7zip/CPP/ANDROID/7za/obj"

    popd || FAILED_BUILD_ARRAY+=("p7zip")

    if ! [ -d "$PORTBUILD_PATH/include/p7zip" ]; then
        FAILED_BUILD_ARRAY+=("p7zip")
    fi
}

# others
build_oniguruma()
{
    mkdir -p "$ONIGURUMA_SRC/build_$PLATFORM"
    cp -rf "$CMAKELISTS_PATH/thirdparty/patch/oniguruma/oniguruma.cmake" "$ONIGURUMA_SRC/CMakeLists.txt"
    
    pushd "$ONIGURUMA_SRC/build_$PLATFORM" || FAILED_BUILD_ARRAY+=("oniguruma")
    cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_HOME/build/cmake/android.toolchain.cmake" \
        -DANDROID_PLATFORM=21 -DANDROID_ABI=arm64-v8a \
        -DCMAKE_INSTALL_PREFIX="$PORTBUILD_PATH"
    make "-j$CORE_NUM" &&  make install 
    popd || FAILED_BUILD_ARRAY+=("oniguruma")

    if ! [ -e "$PORTBUILD_PATH/include/oniguruma.h" ]; then
        FAILED_BUILD_ARRAY+=("oniguruma")
    fi
}

build_breakpad() # after linux-syscall
{
    mkdir -p "$BREAKPAD_SRC/build_$PLATFORM"
    cp -rf "$SYSCALL_SRC/lss" "$BREAKPAD_SRC/src/third_party/"
    
    pushd "$BREAKPAD_SRC/build_$PLATFORM" || FAILED_BUILD_ARRAY+=("breakpad")
    ../configure --host=aarch64-linux-android \
        CC=aarch64-linux-android21-clang  AR=llvm-ar \
        CXX=aarch64-linux-android21-clang++ STRIP=llvm-strip \
        --prefix="$PORTBUILD_PATH" \
        --disable-tools
    make "-j$CORE_NUM" &&  make install-strip
    popd || FAILED_BUILD_ARRAY+=("breakpad")

    if ! [ -d "$PORTBUILD_PATH/include/breakpad" ]; then
        FAILED_BUILD_ARRAY+=("breakpad")
    fi
}

# framework
build_sdl2()
{
    mkdir -p "$SDL2_SRC/build_$PLATFORM"
    cp -rf "$CMAKELISTS_PATH/thirdparty/patch/sdl2/android_SDL_android.c"  "$SDL2_SRC/src/core/android/SDL_android.c"
    
    pushd "$SDL2_SRC/build_$PLATFORM" || FAILED_BUILD_ARRAY+=("sdl2")
    cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_HOME/build/cmake/android.toolchain.cmake" \
        -DANDROID_PLATFORM=21 -DANDROID_ABI=arm64-v8a \
        -DANDROID=ON -DCMAKE_SYSTEM_NAME=Linux \
        -DCMAKE_INSTALL_PREFIX="$PORTBUILD_PATH" \
        -DHIDAPI=OFF -DHAVE_GCC_WDECLARATION_AFTER_STATEMENT=OFF
    make "-j$CORE_NUM" &&  make install 
    popd || FAILED_BUILD_ARRAY+=("sdl2")

    if ! [ -d "$PORTBUILD_PATH/include/SDL2" ]; then
        FAILED_BUILD_ARRAY+=("sdl2")
    fi
}

build_cocos2dx()
{
    mkdir -p "$COCOS2DX_SRC/build_$PLATFORM"
    cp "$CMAKELISTS_PATH/thirdparty/patch/cocos2d-x/android_cocos2dx.cmake" "$COCOS2DX_SRC/CMakeLists.txt"
    cp "$CMAKELISTS_PATH/thirdparty/patch/cocos2d-x/android_CCFileUtils-android.h" "$COCOS2DX_SRC/cocos/platform/android/CCFileUtils-android.h"
    cp "$CMAKELISTS_PATH/thirdparty/patch/cocos2d-x/android_CCFileUtils-android.cpp" "$COCOS2DX_SRC/cocos/platform/android/CCFileUtils-android.cpp"
    cp "$CMAKELISTS_PATH/thirdparty/patch/cocos2d-x/android_Java_org_cocos2dx_lib_Cocos2dxHelper.h" "$COCOS2DX_SRC/cocos/platform/android/jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
    cp "$CMAKELISTS_PATH/thirdparty/patch/cocos2d-x/android_Java_org_cocos2dx_lib_Cocos2dxHelper.cpp" "$COCOS2DX_SRC/cocos/platform/android/jni/Java_org_cocos2dx_lib_Cocos2dxHelper.cpp"

    pushd "$COCOS2DX_SRC/build_$PLATFORM" || FAILED_BUILD_ARRAY+=("cocos2d-x")
    cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_HOME/build/cmake/android.toolchain.cmake" \
        -DANDROID_PLATFORM=21 -DANDROID_ABI=arm64-v8a \
        -DCMAKE_INSTALL_PREFIX="$PORTBUILD_PATH" \
        -DBUILD_TESTS=OFF -DBUILD_LUA_LIBS=OFF -DBUILD_JS_LIBS=OFF
    make "-j$CORE_NUM" || FAILED_BUILD_ARRAY+=("cocos2d-x")

    if [ -z "$(find "$COCOS2DX_SRC/build_$PLATFORM" -mindepth 1 -maxdepth 1)" ]; then 
        FAILED_BUILD_ARRAY+=("cocos2d-x")
    fi
    
    cp -rf lib/libcocos2d.a "$PORTBUILD_PATH/lib/"
    cp -rf lib/libext_*.a "$PORTBUILD_PATH/lib/"
    cp -rf engine/cocos/android/libcpp_android_spec.a "$PORTBUILD_PATH/lib/"
    cp -rf ../external/zlib/prebuilt/android/arm64-v8a/*.a "$PORTBUILD_PATH/lib/"
    cp -rf ../external/png/prebuilt/android/arm64-v8a/*.a "$PORTBUILD_PATH/lib/"
    cp -rf ../external/tiff/prebuilt/android/arm64-v8a/*.a "$PORTBUILD_PATH/lib/"
    cp -rf ../external/webp/prebuilt/android/arm64-v8a/*.a "$PORTBUILD_PATH/lib/"
    cp -rf ../external/freetype2/prebuilt/android/arm64-v8a/*.a "$PORTBUILD_PATH/lib/"
    cp -rf ../external/chipmunk/prebuilt/android/arm64-v8a/*.a "$PORTBUILD_PATH/lib/"
    cp -rf ../external/bullet/prebuilt/android/arm64-v8a/*.a "$PORTBUILD_PATH/lib/"
    
    popd || FAILED_BUILD_ARRAY+=("cocos2d-x")
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
    build_opencv
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

if [ "$FETCH_RESULT" == "All dependencies are fetched." ]; then
    echo "==============================================================="
    echo -e "\033[43m WARNING: The process of compiling, prone to potential errors, will start after 5 seconds. \033[0m"
    echo -e "You can find the log in ./ports_build.log"
    echo "==============================================================="

    sleep 5

    build_ports

    if [ -z "${FAILED_BUILD_ARRAY[*]}" ]; then
        echo -e "\033[97;42m SUCCESS:\033[0m Kirikiroid2 ports build successful"
    else
        echo -e "\033[97;41m FAILURE:\033[0m Build Failed"
        echo "These are not successful:"
        for element in "${FAILED_BUILD_ARRAY[@]}"; do
            echo "$element"
        done
    fi
else
    echo -e "\033[97;41m ERROR:\033[0m Dependency not satisfied"
fi