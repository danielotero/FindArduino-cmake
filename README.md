# FindArduino-cmake
Simple FindArduino CMake module for building and using Arduino as an external
library.

This allows using any IDE that supports CMake (eg. Qt Creator) to code,
compile and upload Arduino-based applications.

As arduino is focused on embedded platforms, you'll probably also need and
additional CMake toolchain file (the following examples uses
[Generic-avr.cmake](https://github.com/danielotero/Generic-avr.cmake)).

## Example
### CMakeLists.txt
```CMake
#=============================================================================#
#                             Initial variables                               #
#=============================================================================#
set(DEFAULT_AVR_MCU     atmega2560          CACHE STRING "")
set(AVRDUDE_PORT        "/dev/ttyACM0"      CACHE STRING "")
set(AVRDUDE_PROGRAMMER  wiring              CACHE STRING "")
set(ARDUINO_SDK_PATH    /usr/share/arduino  CACHE PATH   "")
set(ARDUINO_VARIANT     mega                CACHE STRING "")
set(ARDUINO_BOARD       AVR_MEGA2560        CACHE STRING "")

#=============================================================================#
#                              Cross-compile                                  #
#=============================================================================#
set(CMAKE_TOOLCHAIN_FILE "cmake/Generic-avr.cmake")
list(APPEND CMAKE_MODULE_PATH "cmake/modules") # Where FindArduino.cmake is
add_definitions(-DF_CPU=16000000L)

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
find_package(Arduino REQUIRED)
add_arduino_library_directories("$ENV{HOME}/Arduino/libraries" Servo)

#=============================================================================#
#                                   AVR lib                                   #
#=============================================================================#
add_library(examplelib STATIC src/library.c)
target_link_libraries(examplelib arduino arduino_Wire arduino_Servo)

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
- This code has not been thoroughly tested.
- Right now, only supports Arduino on AVR architecture.

## TODO:
 - [ ] Create a working out of the box example.
 - [ ] Set the `DEFAULT_AVR_MCU` and `AVRDUDE_PROGRAMMER` variables based on the
 `ARDUINO_BOARD`.
 - [ ] Set the `F_CPU` definition based on the `ARDUINO_BOARD` variable.
 - [ ] Set the `ARDUINO_VARIANT` variable based on the `ARDUINO_BOARD` one.
 - [ ] Set the `ARDUINO_ARCH` variable based on the `ARDUINO_BOARD` one.

## See also
- A more complete Arduino CMake module: [queezythegreat/arduino-cmake](https://github.com/queezythegreat/arduino-cmake)
