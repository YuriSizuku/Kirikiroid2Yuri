# Krikiroid2-Yuri  

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/YuriSizuku/Kirikiroid2Yuri?color=green&label=krkr2yuri&style=flat-square7&logo=4chan)  ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/YuriSizuku/Kirikiroid2Yuri/build_android.yml?label=android%28aarch64%29&style=flat-square)

☘️ A krikiroid2 project matained by Yurisizuku.  
Support the newer android device and more format.  

New features :  

- develop  
  - [x] clear camke project structure
  - [x] well documention for develop and usage
  - [x] scripts to compile or cross compile without pain
  - [x] vscode and android studio project for multi enviroment
  - [x] ci in github action to automaticly build
- platform
  - android
    - [x] SDK level above 21 (android 5.1, Lolipop)
    - [x] bypass scoped storage
    - [ ] access extern sdcard by saf
  - windows
  - linux
- render  
- game support
  - [ ] recent krkr game decryption support

(This project is heavily relying on cocos. As I am not familiar with cocos, I am looking forward for your contribute to improve this project)

## 1. usage  

Although now the apk build from source is runable, it is not perfect. Beta version has some problems due to the cocos version change, incomplecate of some code. Currently the beta version is only aimed for debug. Please use [Kirikiroid2_yuri_1.3.9.apk](https://github.com/YuriSizuku/Kirikiroid2Yuri/releases/download/1.3.9_yuri/Kirikiroid2_yuri_1.3.9.apk) instead.  

## 2. Build  

I add some futures by reverse engine before, and now this project can be build from source.  This is really a very hard work, because there are so many dependencies, lack of files, code not compatible problems.  

### (1) prepare  

- wget, 7z, git, make, cmake  
- python2(for cocos2d-x v3), msys2 (if windows)  
- thirdparty depedency (see `_fetch.sh` in detail)  

``` shell
# wget 
https://downloads.xiph.org/releases/vorbis/libvorbis-1.3.7.tar.gz
https://archive.mozilla.org/pub/opus/opus-1.3.1.tar.gz
https://downloads.xiph.org/releases/ogg/libogg-1.3.5.tar.gz
https://downloads.xiph.org/releases/opus/opusfile-0.12.tar.gz
https://www.rarlab.com/rar/unrarsrc-6.0.7.tar.gz
https://www.libsdl.org/release/SDL2-2.0.14.tar.gz

# git
https://github.com/krkrz/oniguruma
https://github.com/google/breakpad
https://github.com/zeas2/FFmpeg

# git with version
https://github.com/google/oboe/archive/refs/tags/1.7.0.tar.gz
https://github.com/kcat/openal-soft/archive/refs/tags/1.23.0.tar.gz
https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/2.1.5.1.tar.gz
https://github.com/opencv/opencv/archive/refs/tags/4.7.0.tar.gz
https://github.com/lz4/lz4/archive/refs/tags/v1.9.4.tar.gz
https://github.com/libarchive/libarchive/archive/refs/tags/v3.6.2.tar.gz
https://github.com/cocos2d/cocos2d-x/archive/refs/tags/cocos2d-x-3.17.2.tar.gz
```

In windows, you must use msys2 to build ffmpeg port.  
You can also download the prebuild ports from [thirdparty_ports.tar.gz](https://github.com/YuriSizuku/Kirikiroid2Yuri/releases/download/deps/thirdparty_ports.tar.gz"), [thirdparty_build.tar.gz](https://github.com/YuriSizuku/Kirikiroid2Yuri/releases/download/deps/thirdparty_build.tar.gz).  

## (2) android  

- android sdk with `ANDROID_HOME` variable in env  
- android ndk 25.2.9519653  

Use `script/check_environment.sh` to to check if the environment is properly configured.
See `_compile_ports.sh` for how to build dependencies.
Use `script/build.sh` to build ports and the use `project/android/gradlew assembleDebug` to build apk.

The `script/fetch.sh` script fetch the dependencies automatically. If there is an interruption such as a network problem during the process, you can just re-run the script without deleting the part that has already been pulled (manually deleting the damaged part if needed).

The compilation scripts of third-party dependencies (`_compile_ports.sh`) are not perfect in determining whether they compile properly or not. So when running the `build.sh` again, you only have the option of starting over or skipping the whole compile process.

## 3. Compatibility  

|game|version|status|description|
|----|-------|------|-----------|

## 4. Issues (including solved)

(build from souce, beta version)  

major:  

- title path button click position is not correct
- crash in game menu form  
- game alert window button can not click  
- member GdiPlus does not exist
- global preference can not save

minor:  

- ~~android studio buildDir not worked and it make dir at root~~ fixed by cmake `add_subdirectory` build dir

## 5. Todo

___
Original information about kirikiroid2 bellow, also refered some dependencies from [ningshanwutuobang](https://github.com/ningshanwutuobang/Kirikiroid2).  

## Kirikiroid2 - A cross-platform port of Kirikiri2/KirikiriZ  

==========================================================

Based on most code from [Kirikiri2](http://kikyou.info/tvp/) and [KirikiriZ](https://github.com/krkrz/krkrz)

Video playback module modified from [kodi](https://github.com/xbmc/xbmc)

Some string code from [glibc](https://www.gnu.org/s/libc) and [Apple Libc](https://opensource.apple.com/source/Libc).

Real-time texture codec modified from [etcpak](https://bitbucket.org/wolfpld/etcpak.git), [pvrtccompressor](https://bitbucket.org/jthlim/pvrtccompressor), [astcrt](https://github.com/daoo/astcrt)

Android storage accessing code from [AmazeFileManager](https://github.com/arpitkh96/AmazeFileManager)
