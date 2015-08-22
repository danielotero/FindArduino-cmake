# FindArduino
# -----------
#
# Try to find Arduino
#
# Once done this will define
#
# ::
#
#   ARDUINO_FOUND - system has Arduino
#   ARDUINO_VERSION - the version of Arduino found
#
# Example usage:
#
# ::
#
#    find_package(Arduino REQUIRED)
#
#    add_arduinocore_library()
#    add_arduino_libraries(Wire EEPROM)
#
#    add_executable(example src/example.c)
#    target_link_libraries(example STATIC arduinocore Wire EEPROM)

#=============================================================================
# The MIT License (MIT)
#
# Copyright (c) 2015 Daniel Otero
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#=============================================================================

#=============================================================================
# add_arduinocore_library()
#
# Generates and adds the "arduinocore" library to the current project
#=============================================================================
function(add_arduinocore_library)
    file(GLOB ARDUINO_CORE_SRC_FILES
        "${ARDUINO_SDK_PATH}/hardware/arduino/${ARDUINO_PLATFORM}/cores/arduino/*.cpp"
        "${ARDUINO_SDK_PATH}/hardware/arduino/${ARDUINO_PLATFORM}/cores/arduino/*.c"
    )
    add_library(arduinocore STATIC ${ARDUINO_CORE_SRC_FILES})

    target_include_directories(arduinocore PUBLIC
        "${ARDUINO_SDK_PATH}/hardware/arduino/${ARDUINO_PLATFORM}/cores/arduino")
    target_include_directories(arduinocore PUBLIC
        "${ARDUINO_SDK_PATH}/hardware/arduino/${ARDUINO_PLATFORM}/variants/${ARDUINO_VARIANT}")
endfunction()


#=============================================================================
# add_arduino_library(LIB_NAME)
#
# Generates the requested Arduino library name LIB_NAME
#=============================================================================
function(add_arduino_libraries)
    foreach(LIB_NAME ${ARGN})
      set(LIB_PATH "${ARDUINO_SDK_PATH}/hardware/arduino/${ARDUINO_PLATFORM}/libraries/${LIB_NAME}")

      set(HDR_SEARCH_LIST
          ${LIB_PATH}/*.h
          ${LIB_PATH}/*.hh
          ${LIB_PATH}/*.hxx)

      set(SRC_SEARCH_LIST
          ${LIB_PATH}/*.cpp
          ${LIB_PATH}/*.c
          ${LIB_PATH}/*.cc
          ${LIB_PATH}/*.cxx)

      file(GLOB_RECURSE HDR_FILES ${HDR_SEARCH_LIST})
      file(GLOB_RECURSE SRC_FILES ${SRC_SEARCH_LIST})

      if(SRC_FILES OR HDR_FILES)
          add_library(${LIB_NAME} STATIC ${SRC_FILES} ${HDR_FILES})
          set_target_properties(${LIB_NAME} PROPERTIES LINKER_LANGUAGE CXX)
          target_include_directories(${LIB_NAME} PRIVATE
              "${ARDUINO_SDK_PATH}/hardware/arduino/${ARDUINO_PLATFORM}/cores/arduino")
          target_include_directories(${LIB_NAME} PRIVATE
              "${ARDUINO_SDK_PATH}/hardware/arduino/${ARDUINO_PLATFORM}/variants/${ARDUINO_VARIANT}")
      else()
          message(FATAL_ERROR "Library ${LIB_NAME} in ${LIB_PATH} not found.")
      endif()

      if(HDR_FILES)
          set(DIR_LIST "")
          foreach(FILE_PATH ${HDR_FILES})
              get_filename_component(DIR_PATH ${FILE_PATH} PATH)
              set(DIR_LIST ${DIR_LIST} ${DIR_PATH})
          endforeach()
          list(REMOVE_DUPLICATES DIR_LIST)

          target_include_directories(${LIB_NAME} PUBLIC ${DIR_LIST})
      endif()
    endforeach()
endfunction()


#=============================================================================#
# detect_arduino_version(ARDUINO_VERSION_PATH)                                #
#                                                                             #
#       ARDUINO_VERSION_PATH - Arduino version file                           #
#                                                                             #
# Detect Arduino version and declare ARDUINO_VERSION and ARDUINO              #
#=============================================================================#
function(detect_arduino_version ARDUINO_VERSION_PATH)
    file(READ ${ARDUINO_VERSION_PATH} RAW_VERSION)

    if("${RAW_VERSION}" MATCHES "([0-9]+[.][0-9]+[.][0-9]+)")
        set(PARSED_VERSION ${CMAKE_MATCH_1})
    elseif("${RAW_VERSION}" MATCHES "([0-9]+[.][0-9]+)")
        set(PARSED_VERSION ${CMAKE_MATCH_1}.0)
    else()
        message(FATAL_ERROR "Unable to autodetect Arduino version")
    endif()

    string(REPLACE "." "" VERSION_DEF ${PARSED_VERSION})

    set(ARDUINO_VERSION "${PARSED_VERSION}" PARENT_SCOPE)
    set(ARDUINO ${VERSION_DEF} PARENT_SCOPE)
    add_definitions(-DARDUINO=${ARDUINO})
endfunction()

#=============================================================================#
#                            Default variables                                #
#=============================================================================#
if(NOT ARDUINO_VARIANT)
    set(ARDUINO_VARIANT standard CACHE STRING "Arduino variant")
endif()

if(NOT ARDUINO_PLATFORM)
    set(ARDUINO_PLATFORM avr CACHE STRING "Arduino platform")
endif()

#=============================================================================#
#                                Initialization                               #
#=============================================================================#
if(NOT ARDUINO_SDK_PATH)
    message(FATAL_ERROR "Could not find Arduino SDK (set ARDUINO_SDK_PATH)!")
endif()

find_file(ARDUINO_VERSION_PATH
    NAMES lib/version.txt
    PATHS ${ARDUINO_SDK_PATH}
    DOC "Path to Arduino version file.")

detect_arduino_version(${ARDUINO_VERSION_PATH})

FIND_PACKAGE_HANDLE_STANDARD_ARGS(Arduino "Invalid Arduino SDK path"
    ARDUINO_VERSION)
