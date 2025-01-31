#!/bin/bash

if [ -z "$CMAKELISTS_PATH" ]; then
    # CHANGE IT WHEN MOVE THIS FILE
    CMAKELISTS_PATH=$(pwd)/..
fi

# Skip?
if [ -d "$CMAKELISTS_PATH/thirdparty/port" ] || [ -d "$CMAKELISTS_PATH/thirdparty/build" ]; then
    echo "It seems that you have fetched the ports, would you like to delete before redo? (Y/n)"
    read -r user_input

    if [[ "$user_input" == "Y" || "$user_input" == "y" ]]; then
        rm -rf "$CMAKELISTS_PATH/thirdparty/port"
        rm -rf "$CMAKELISTS_PATH/thirdparty/build"
    fi
fi

# prepare dirs
mkdir -p "$CMAKELISTS_PATH/thirdparty/port";
mkdir -p "$CMAKELISTS_PATH/thirdparty/build/arch_androida32";
mkdir -p "$CMAKELISTS_PATH/thirdparty/build/arch_androida64";

# Define Result Variant
FETCH_RESULT="All dependencies are fetched."
# if failed, replace it as "Dependency not satisfied"
FAILED_FETCH_ARRAY=()

# fetch by wget
function fetch_port() # urlbase, name
{
    if ! [ -d "$CMAKELISTS_PATH/thirdparty/port/$2" ]; then
        echo "## fetch_port $1 $2"
        wget "$1/$2.tar.gz" -O "$CMAKELISTS_PATH/thirdparty/port/$2.tar.gz"
        if ! [ -f "$CMAKELISTS_PATH/thirdparty/port/$2.tar.gz" ]; then 
            FAILED_FETCH_ARRAY+=("$2")
            echo -e "\033[97;41mERROR: \033[0m$CMAKELISTS_PATH/thirdparty/port/$2.tar.gz download failed"
        fi
        tar -zxf "$CMAKELISTS_PATH/thirdparty/port/$2.tar.gz" -C "$CMAKELISTS_PATH/thirdparty/port"
    fi
    
}

# fetch by git
function fetch_port2() # github_url, name, tag?
{
    if ! [ -d "$CMAKELISTS_PATH/thirdparty/port/$2" ]; then
        inpath=$1/$2.git
        outpath=$CMAKELISTS_PATH/thirdparty/port/$2
        tag=$3
        echo "## fetch_port $inpath $tag"
        git config --global url.https://github.com/.insteadOf git://github.com/
        if [ -n "$tag" ]; then 
            git clone --recursive --depth 1 --branch "$tag" "$inpath" "$outpath" 
        else
            git clone --recursive --depth 1 "$inpath" "$outpath"
        fi
    fi
    if [ -z "$(find "$CMAKELISTS_PATH/thirdparty/port/$2" -mindepth 1 -maxdepth 1)" ]; then 
        FAILED_FETCH_ARRAY+=("$2")
        echo -e "\033[97;41mERROR: \033[0mFailed to clone into $CMAKELISTS_PATH/thirdparty/port/$2 !"
    fi
}

# wget ports
function fetch_vorbis()
{
    VORBIS_NAME=libvorbis-1.3.7
    export VORBIS_SRC=$CMAKELISTS_PATH/thirdparty/port/$VORBIS_NAME
    fetch_port https://downloads.xiph.org/releases/vorbis $VORBIS_NAME
}

function fetch_opus()
{
    OPUS_NAME=opus-1.3.1
    export OPUS_SRC=$CMAKELISTS_PATH/thirdparty/port/$OPUS_NAME
    fetch_port https://archive.mozilla.org/pub/opus $OPUS_NAME
}

function fetch_ogg()
{
    OGG_NAME=libogg-1.3.5
    export OGG_SRC=$CMAKELISTS_PATH/thirdparty/port/$OGG_NAME
    fetch_port https://downloads.xiph.org/releases/ogg $OGG_NAME
}

function fetch_opusfile()
{
    OPUSFILE_NAME=opusfile-0.12
    export OPUSFILE_SRC=$CMAKELISTS_PATH/thirdparty/port/$OPUSFILE_NAME
    fetch_port https://downloads.xiph.org/releases/opus $OPUSFILE_NAME
}

function fetch_unrar()
{
    UNRAR_NAME=unrarsrc-6.0.7
    UNRAR_SRC=$CMAKELISTS_PATH/thirdparty/port/$UNRAR_NAME
    fetch_port https://www.rarlab.com/rar $UNRAR_NAME
    if [ -d "$CMAKELISTS_PATH/thirdparty/port/unrar" ]; then
        mv "$CMAKELISTS_PATH/thirdparty/port/unrar" "$UNRAR_SRC"
    fi
}

function fetch_p7zip()
{
    P7ZIP_NAME=p7zip_16.02
    P7ZIP_SRC=$CMAKELISTS_PATH/thirdparty/port/$P7ZIP_NAME
    if ! [ -d "$P7ZIP_SRC" ]; then
        echo "## fetch_port $P7ZIP_NAME"
        wget https://sourceforge.net/projects/p7zip/files/p7zip/16.02/p7zip_16.02_src_all.tar.bz2 \
            -O "$CMAKELISTS_PATH/thirdparty/port/$P7ZIP_NAME.tar.bz2"
        tar jxf "$CMAKELISTS_PATH/thirdparty/port/$P7ZIP_NAME.tar.bz2" \
            -C "$CMAKELISTS_PATH/thirdparty/port"
    fi 
    if ! [ -d "$CMAKELISTS_PATH/thirdparty/port/p7zip_16.02" ]; then
        FAILED_FETCH_ARRAY+=("p7zip")
        echo -e "\033[97;41mERROR: \033[0mFailed to fetch p7zip"
        return
    fi
    if [ -z "$(find "$CMAKELISTS_PATH/thirdparty/port/p7zip_16.02" -mindepth 1 -maxdepth 1 )" ]; then
        FAILED_FETCH_ARRAY+=("p7zip")
        echo -e "\033[97;41mERROR: \033[0mFailed to fetch p7zip"
    fi
}

function fetch_sdl2()
{
    SDL2_NAME=SDL2-2.0.14
    export SDL2_SRC=$CMAKELISTS_PATH/thirdparty/port/$SDL2_NAME
    fetch_port https://www.libsdl.org/release $SDL2_NAME
}

# git ports
function fetch_openal()
{
    OPENAL_NAME=openal-soft
    OPENAL_VERSION=1.23.0
    export OPENAL_SRC=$CMAKELISTS_PATH/thirdparty/port/$OPENAL_NAME
    fetch_port2 https://github.com/kcat $OPENAL_NAME $OPENAL_VERSION
}

function fetch_oboe()
{
    OBOE_NAME=oboe
    OBOE_VERSION=1.7.0
    export OBOE_SRC=$CMAKELISTS_PATH/thirdparty/port/$OBOE_NAME
    fetch_port2 https://github.com/google $OBOE_NAME $OBOE_VERSION
}

function fetch_jpeg()
{
    JPEG_NAME=libjpeg-turbo
    export JPEG_SRC=$CMAKELISTS_PATH/thirdparty/port/$JPEG_NAME
    JPEG_VERSION=2.1.5.1
    fetch_port2 https://github.com/libjpeg-turbo $JPEG_NAME $JPEG_VERSION
}

function fetch_opencv()
{
    OPENCV_NAME=opencv
    OPENCV_VERSION=4.7.0
    export OPENCV_SRC=$CMAKELISTS_PATH/thirdparty/port/$OPENCV_NAME
    fetch_port2 https://github.com/opencv $OPENCV_NAME $OPENCV_VERSION
}

function fetch_ffmpeg()
{
    FFMPEG_NAME=ffmpeg
    export FFMPEG_SRC=$CMAKELISTS_PATH/thirdparty/port/$FFMPEG_NAME
    fetch_port2 https://github.com/zeas2 $FFMPEG_NAME
    pushd "$FFMPEG_SRC" || FAILED_FETCH_ARRAY+=("ffmpeg")
        git apply "$CMAKELISTS_PATH/thirdparty/patch/ffmpeg/android_ffmpeg.diff"
    popd || FAILED_FETCH_ARRAY+=("ffmpeg")
}

function fetch_lz4()
{
    LZ4_NAME=lz4
    LZ4_VERSION=v1.9.4
    export LZ4_SRC=$CMAKELISTS_PATH/thirdparty/port/$LZ4_NAME
    fetch_port2 https://github.com/lz4 $LZ4_NAME $LZ4_VERSION
}

function fetch_archive()
{
    ARCHIVE_NAME=libarchive
    ARCHIVE_VERSION=v3.6.2
    export ARCHIVE_SRC=$CMAKELISTS_PATH/thirdparty/port/$ARCHIVE_NAME
    fetch_port2 https://github.com/libarchive $ARCHIVE_NAME $ARCHIVE_VERSION
}

function fetch_oniguruma()
{
    ONIGURUMA_NAME=oniguruma
    export ONIGURUMA_SRC=$CMAKELISTS_PATH/thirdparty/port/$ONIGURUMA_NAME
    fetch_port2 https://github.com/krkrz $ONIGURUMA_NAME
}

function fetch_syscall()
{
    SYSCALL_NAME=linux-syscall-support
    export SYSCALL_SRC=$CMAKELISTS_PATH/thirdparty/port/$SYSCALL_NAME
    fetch_port2 https://github.com/adelshokhy112 $SYSCALL_NAME
}

function fetch_breakpad()
{
    BREAKPAD_NAME=breakpad
    export BREAKPAD_SRC=$CMAKELISTS_PATH/thirdparty/port/$BREAKPAD_NAME
    fetch_port2 https://github.com/google $BREAKPAD_NAME
}

function fetch_cocos2dx()
{
    COCOS2DX_NAME=cocos2d-x
    COCOS2DX_VERSION=cocos2d-x-3.17.2
    COCOS2DX_SRC=$CMAKELISTS_PATH/thirdparty/port/$COCOS2DX_NAME
    fetch_port2 https://github.com/cocos2d $COCOS2DX_NAME $COCOS2DX_VERSION

    local file_count
    file_count=$(find "$COCOS2DX_SRC/external" -maxdepth 1 -type f | wc -l)
    if [ "$file_count" -eq 1 ]; then 
        pushd "$COCOS2DX_SRC/external/" || FAILED_FETCH_ARRAY+=("cocos2d-x")
        wget -c -O "deps.zip" "https://github.com/cocos2d/cocos2d-x-3rd-party-libs-bin/archive/v3-deps-158.zip"
        unzip -o "deps.zip"
        mv cocos2d-x-3rd-party-libs-bin-3-deps-158/* ./
        rm -rf cocos2d-x-3rd-party-libs-bin-3-deps-158
        rm -f "deps.zip"
    popd || FAILED_FETCH_ARRAY+=("cocos2d-x")
    fi

    file_count=$(find "$COCOS2DX_SRC/external" -maxdepth 1 -type f | wc -l)
    if [ "$file_count" -eq 1 ]; then 
        FAILED_FETCH_ARRAY+=("cocos2d-x")
        echo -e "\033[97;41mERROR: \033[0mFailed to get deps of cocos2d-x !"
    fi
}

# android 
function fetch_asset()
{
    if ! [ -d "$CMAKELISTS_PATH/assets" ]; then
        wget https://github.com/YuriSizuku/Kirikiroid2Yuri/releases/download/1.3.9_yuri/Kirikiroid2_yuri_1.3.9.apk \
            -O "$CMAKELISTS_PATH/thirdparty/port/Kirikiroid2_yuri_release_1.3.9.apk"
        7z x -o"$CMAKELISTS_PATH" "$CMAKELISTS_PATH/thirdparty/port/Kirikiroid2_yuri_1.3.9.apk assets"
    fi
}

# notused  ports
function fetch_bpg()
{
    BPG_NAME=android-bpg
    export BPG_SRC=$CMAKELISTS_PATH/thirdparty/port/$BPG_NAME
    fetch_port2 https://github.com/alexandruc $BPG_NAME
}

function fetch_jxr()
{
    JXR_NAME=jxrlib
    export JXR_SRC=$CMAKELISTS_PATH/thirdparty/port/$JXR_NAME
    fetch_port2 https://github.com/krkrz $JXR_NAME
}

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

fetch_ports

if [ -z "${FAILED_FETCH_ARRAY[*]}" ]; then
    echo -e "\033[97;42m SUCCESS:\033[0m $FETCH_RESULT"
else
    FETCH_RESULT="Dependency not satisfied"
    echo -e "\033[97;41m FAILURE:\033[0m $FETCH_RESULT"
    echo "These dependencies are not satisfied:"
    for element in "${FAILED_FETCH_ARRAY[@]}"; do
        echo "$element"
    done
fi