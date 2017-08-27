# FindArduino-cmake
Simple FindArduino CMake module for building and using Arduino as an external
library.

This allows using any IDE that supports CMake (eg. Qt Creator) to code,
compile and upload Arduino-based applications.

As arduino is focused on embedded platforms, you'll probably also need and
additional CMake toolchain file (eg.
[Generic-avr.cmake](https://github.com/danielotero/Generic-avr.cmake) or
[cmake-avr](https://github.com/mkleemann/cmake-avr)).

## Example
### CMakeLists.txt
```CMake
#=============================================================================#
#                              Cross-compile                                  #
#=============================================================================#
set(DEFAULT_AVR_MCU atmega2560  CACHE STRING "")
set(AVRDUDE_PORT "/dev/ttyACM0" CACHE STRING "")
set(AVRDUDE_PROGRAMMER "wiring" CACHE STRING "")

set(CMAKE_TOOLCHAIN_FILE "cmake/Generic-avr.cmake")
list(APPEND CMAKE_MODULE_PATH "cmake/modules") # Where FindArduino.cmake is

#=============================================================================#
#                                 Project                                     #
#=============================================================================#
cmake_minimum_required(VERSION 3.0)

project(example
  VERSION 0.0.1
  LANGUAGES C CXX
)

#=============================================================================#
#                                   Arduino                                   #
#=============================================================================#
set(ARDUINO_SDK_PATH /usr/share/arduino CACHE PATH   "")
set(ARDUINO_VARIANT mega                CACHE STRING "")
find_package(Arduino REQUIRED)

#=============================================================================#
#                                   AVR lib                                   #
#=============================================================================#
add_library(examplelib STATIC src/library.c)
target_link_libraries(examplelib arduino arduino_Wire)

#=============================================================================#
#                                  AVR image                                  #
#=============================================================================#
add_executable(example src/main.c)
target_link_libraries(example examplelib arduino_EEPROM)
add_avr_firmware(example)
```

### Linux Console:
```Bash
user@host build_dir $ cmake <path_to>/src_dir
user@host build_dir $ make upload_example
```

## Notes
- This code is young and has not been thoroughly tested.
- If you are interested in a more complete approach, see: [queezythegreat/arduino-cmake](https://github.com/queezythegreat/arduino-cmake)
