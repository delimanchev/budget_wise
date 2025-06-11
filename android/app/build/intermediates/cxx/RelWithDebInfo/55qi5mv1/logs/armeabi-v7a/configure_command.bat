@echo off
"D:\\Android\\SDK\\cmake\\3.22.1\\bin\\cmake.exe" ^
  "-HC:\\Users\\ovila\\dev\\flutter\\packages\\flutter_tools\\gradle\\src\\main\\groovy" ^
  "-DCMAKE_SYSTEM_NAME=Android" ^
  "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" ^
  "-DCMAKE_SYSTEM_VERSION=23" ^
  "-DANDROID_PLATFORM=android-23" ^
  "-DANDROID_ABI=armeabi-v7a" ^
  "-DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a" ^
  "-DANDROID_NDK=D:\\Android\\SDK\\ndk\\27.0.12077973" ^
  "-DCMAKE_ANDROID_NDK=D:\\Android\\SDK\\ndk\\27.0.12077973" ^
  "-DCMAKE_TOOLCHAIN_FILE=D:\\Android\\SDK\\ndk\\27.0.12077973\\build\\cmake\\android.toolchain.cmake" ^
  "-DCMAKE_MAKE_PROGRAM=D:\\Android\\SDK\\cmake\\3.22.1\\bin\\ninja.exe" ^
  "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=D:\\Fakultet\\2 godina\\2 semestar kidamooooo\\Praktikum\\2\\budget_wise\\android\\app\\build\\intermediates\\cxx\\RelWithDebInfo\\55qi5mv1\\obj\\armeabi-v7a" ^
  "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=D:\\Fakultet\\2 godina\\2 semestar kidamooooo\\Praktikum\\2\\budget_wise\\android\\app\\build\\intermediates\\cxx\\RelWithDebInfo\\55qi5mv1\\obj\\armeabi-v7a" ^
  "-DCMAKE_BUILD_TYPE=RelWithDebInfo" ^
  "-BD:\\Fakultet\\2 godina\\2 semestar kidamooooo\\Praktikum\\2\\budget_wise\\android\\app\\.cxx\\RelWithDebInfo\\55qi5mv1\\armeabi-v7a" ^
  -GNinja ^
  -Wno-dev ^
  --no-warn-unused-cli
