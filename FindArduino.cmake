# Find the Arduino SDK and create the target libraries
#
# Once done, this module will define
#
#   ARDUINO_FOUND - system has Arduino
#   ARDUINO_VERSION - the version of Arduino found
#
###############################################################################

#
# Set the Arduino SDK configuration
#
set(ARDUINO_SDK_PATH "/usr/share/arduino"   CACHE FILEPATH  "Arduino SDK Path")
set(ARDUINO_VENDOR   "arduino"              CACHE STRING    "Arduino vendor")
set(ARDUINO_VARIANT  "standard"             CACHE STRING    "Arduino variant")

if (CMAKE_SYSTEM_PROCESSOR EQUAL "avr")
  set(ARDUINO_PLATFORM "avr"                CACHE STRING    "Arduino platform")
else()
  set(ARDUINO_PLATFORM "<unknown>"          CACHE STRING    "Arduino platform")
endif()

#
# Internal function: create the arduino and the external libaries in the SDK
#
function(_create_arduino_targets PLATFORM_PATH)
  file(GLOB ARDUINO_CORE_SRC_FILES
    "${PLATFORM_PATH}/cores/arduino/*.cpp"
    "${PLATFORM_PATH}/cores/arduino/*.c"
  )
  add_library(arduino STATIC EXCLUDE_FROM_ALL ${ARDUINO_CORE_SRC_FILES})
  target_include_directories(arduino PUBLIC
    "${PLATFORM_PATH}/cores/arduino"
  )
  target_include_directories(arduino PUBLIC
    "${PLATFORM_PATH}/variants/${ARDUINO_VARIANT}"
  )

  _create_arduino_library_targets("${PLATFORM_PATH}/libraries")
endfunction()

#
# Internal function: create all the external libaries in the Arduino SDK
#
function(_create_arduino_library_targets LIB_PATH)
  file(GLOB LIBS RELATIVE ${LIB_PATH} ${LIB_PATH}/*)
  foreach(LIB ${LIBS})
    set(LIB_SRC "${LIB_PATH}/${LIB}/src")
    if(IS_DIRECTORY ${LIB_SRC})
      set(LIB_NAME "arduino_${LIB}")

      file(GLOB_RECURSE SRC_FILES
        ${LIB_SRC}/*.cpp
        ${LIB_SRC}/*.c
      )

      file(GLOB HDR_FILES
        ${LIB_SRC}/*.h
      )

      if(SRC_FILES)
        add_library(${LIB_NAME} STATIC EXCLUDE_FROM_ALL
          ${SRC_FILES}
        )
        target_include_directories(${LIB_NAME} INTERFACE ${LIB_SRC})
        target_link_libraries(${LIB_NAME} arduino)
      elseif(HDR_FILES)
        add_library(${LIB_NAME} INTERFACE)
        target_sources(${LIB_NAME} INTERFACE ${HDR_FILES})
        target_include_directories(${LIB_NAME} INTERFACE ${LIB_SRC})
      endif()
    endif()
  endforeach()
endfunction()

#
# Internal function: set the variable VERSION_VAR from the Arduino version.txt
#   file
#
function(_detect_arduino_version VERSION_VAR ARDUINO_VERSION_FILE)
    file(READ ${ARDUINO_VERSION_FILE} RAW_VERSION)

    if("${RAW_VERSION}" MATCHES "([0-9]+\\.[0-9]+\\.[0-9]+)")
        set(PARSED_VERSION ${CMAKE_MATCH_1})
    elseif("${RAW_VERSION}" MATCHES "([0-9]+\\.[0-9]+)")
        set(PARSED_VERSION ${CMAKE_MATCH_1}.0)
    else()
        message(SEND_ERROR "Invalid Arduino version file: \"${ARDUINO_VERSION_FILE}\"")
    endif()

    set(${VERSION_VAR} "${PARSED_VERSION}" PARENT_SCOPE)

    string(REPLACE "." "" VERSION_DEFINITION ${PARSED_VERSION})
    add_definitions(-DARDUINO=${ARDUINO})
endfunction()

#
# Find the Arduino version file
#
set(VERSION_FILE "lib/version.txt")
find_file(ARDUINO_VERSION_FILE
  NAMES ${VERSION_FILE}
  PATHS ${ARDUINO_SDK_PATH}
  DOC "Path to Arduino version file."
)
set(VENDOR_PATH "${ARDUINO_SDK_PATH}/hardware/${ARDUINO_VENDOR}")
set(PLATFORM_PATH "${VENDOR_PATH}/${ARDUINO_PLATFORM}")

if (ARDUINO_VERSION_FILE)
  if (EXISTS "${VENDOR_PATH}")
    if (EXISTS "${PLATFORM_PATH}")
      _detect_arduino_version(Arduino_VERSION ${ARDUINO_VERSION_FILE})
      _create_arduino_targets(${PLATFORM_PATH})
      include(FindPackageHandleStandardArgs)
      FIND_PACKAGE_HANDLE_STANDARD_ARGS(Arduino
        REQUIRED_VARS ARDUINO_SDK_PATH Arduino_VERSION
        VERSION_VAR Arduino_VERSION
      )
    else()
      message(WARNING "Arduino platform \"${ARDUINO_PLATFORM}\" not found")
    endif()
  else()
    message(WARNING "Arduino vendor \"${ARDUINO_VENDOR}\" not found")
  endif()
else()
  message(WARNING "Arduino SDK not found on \"${ARDUINO_SDK_PATH}\"")
endif()
