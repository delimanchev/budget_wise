@echo off
"D:\\Android\\SDK\\cmake\\3.22.1\\bin\\cmake.exe" ^
  "-HC:\\Users\\ovila\\dev\\flutter\\packages\\flutter_tools\\gradle\\src\\main\\groovy" ^
  "-DCMAKE_SYSTEM_NAME=Android" ^
  "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" ^
  "-DCMAKE_SYSTEM_VERSION=23" ^
  "-DANDROID_PLATFORM=android-23" ^
  "-DANDROID_ABI=x86" ^
  "-DCMAKE_ANDROID_ARCH_ABI=x86" ^
  "-DANDROID_NDK=D:\\Android\\SDK\\ndk\\27.0.12077973" ^
  "-DCMAKE_ANDROID_NDK=D:\\Android\\SDK\\ndk\\27.0.12077973" ^
  "-DCMAKE_TOOLCHAIN_FILE=D:\\Android\\SDK\\ndk\\27.0.12077973\\build\\cmake\\android.toolchain.cmake" ^
  "-DCMAKE_MAKE_PROGRAM=D:\\Android\\SDK\\cmake\\3.22.1\\bin\\ninja.exe" ^
  "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=D:\\Fakultet\\2 godina\\2 semestar kidamooooo\\Praktikum\\2\\budget_wise\\android\\app\\build\\intermediates\\cxx\\Debug\\1a6r6w59\\obj\\x86" ^
  "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=D:\\Fakultet\\2 godina\\2 semestar kidamooooo\\Praktikum\\2\\budget_wise\\android\\app\\build\\intermediates\\cxx\\Debug\\1a6r6w59\\obj\\x86" ^
  "-DCMAKE_BUILD_TYPE=Debug" ^
  "-BD:\\Fakultet\\2 godina\\2 semestar kidamooooo\\Praktikum\\2\\budget_wise\\android\\app\\.cxx\\Debug\\1a6r6w59\\x86" ^
  -GNinja ^
  -Wno-dev ^
  --no-warn-unused-cli
