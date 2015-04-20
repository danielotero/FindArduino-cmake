# FindArduino-cmake
Simple FindArduino CMake module for building and using Arduino as an external library

This allows using any IDE that supports CMake (eg. Qt Creator, KDevelop) to code, compile and upload Arduino-based applications.

As arduino is focused on embedded platforms, you'll probably also need and additional CMake toolchain file (eg. [mkleemann/cmake-avr](https://github.com/mkleemann/cmake-avr))

## Example
### CMakeLists.txt
```CMake
#=============================================================================#
#                              Cross-compile                                  #
#=============================================================================#
set(AVR_MCU atmega2560)
set(AVR_UPLOADTOOL_PORT "/dev/ttyACM0")
set(AVR_PROGRAMMER wiring)
set(AVR_UPLOADTOOL_OPTIONS "-D")
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/cmake/generic-gcc-avr.cmake")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake") # Folder where FindArduino.cmake is

#=============================================================================#
#                                 Project                                     #
#=============================================================================#
cmake_minimum_required(VERSION 2.8)

project(example
        LANGUAGES C CXX)

#=============================================================================#
#                                   Arduino                                   #
#=============================================================================#
set(ARDUINO_SDK_PATH /usr/share/arduino)
set(ARDUINO_VARIANT mega)
find_package(Arduino REQUIRED)

add_arduinocore_library()
add_arduino_library(Wire)

#=============================================================================#
#                                   AVR lib                                   #
#=============================================================================#
add_library(examplelib src/library.c)
target_link_libraries(examplelib STATIC arduinocore Wire)

#=============================================================================#
#                                  AVR image                                  #
#=============================================================================#
add_avr_executable(example src/main.c)
target_link_libraries(example examplelib)
```

### Linux Console:
```Bash
user@host build_dir $ cmake ../src_dir
user@host build_dir $ make upload_example
```

## Notes
- This code is young and has not been thoroughly tested.
- If you are interested in a more complete approach, see: [queezythegreat/arduino-cmake](https://github.com/queezythegreat/arduino-cmake)
