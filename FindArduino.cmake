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
set(ARDUINO_BOARD    "uno"                  CACHE STRING    "Arduino board")

if (CMAKE_SYSTEM_PROCESSOR STREQUAL "avr")
  set(ARDUINO_ARCH   "avr"                CACHE STRING    "Arduino architecture")
else()
  set(ARDUINO_ARCH   "<unknown>"          CACHE STRING    "Arduino architecture")
endif()
mark_as_advanced(ARDUINO_ARCH)

#
# Create all the external libaries in given path.
# Optionally, add only the given libraries.
#
function(ADD_ARDUINO_LIBRARY_DIRECTORIES lib_path)
  list(LENGTH ARGN argn_size)
  if (${argn_size} GREATER 0)
    set(libs ${ARGN})
  else()
    file(GLOB libs RELATIVE ${lib_path} ${lib_path}/*)
  endif()

  foreach(lib ${libs})
    set(lib_src "${lib_path}/${lib}/src")
    if(IS_DIRECTORY ${lib_src})
      set(lib_name "arduino_${lib}")

      file(GLOB_RECURSE src_files
        ${lib_src}/*.cpp
        ${lib_src}/*.c
      )

      file(GLOB hdr_files
        ${lib_src}/*.h
      )

      if(src_files)
        add_library(${lib_name} STATIC EXCLUDE_FROM_ALL
          ${src_files}
        )
        target_include_directories(${lib_name} PUBLIC ${lib_src})
        target_link_libraries(${lib_name} arduino)
      elseif(hdr_files)
        add_library(${lib_name} INTERFACE)
        target_sources(${lib_name} INTERFACE ${hdr_files})
        target_include_directories(${lib_name} INTERFACE ${lib_src})
        target_link_libraries(${lib_name} arduino)
      endif()
    endif()
  endforeach()
endfunction()

#
# Internal function: create the arduino and the external libaries in the SDK
#
function(_CREATE_ARDUINO_TARGETS platform_path)
  file(GLOB arduino_core_src_files
    "${platform_path}/cores/arduino/*.cpp"
    "${platform_path}/cores/arduino/*.c"
  )
  add_library(arduino STATIC EXCLUDE_FROM_ALL ${arduino_core_src_files})
  target_include_directories(arduino PUBLIC
    "${platform_path}/cores/arduino"
  )
  target_include_directories(arduino PUBLIC
    "${platform_path}/variants/${ARDUINO_VARIANT}"
  )

  ADD_ARDUINO_LIBRARY_DIRECTORIES("${platform_path}/libraries")
endfunction()

#
# Internal function: set the variable version_var from the Arduino version.txt
#   file
#
function(_DETECT_ARDUINO_VERSION version_var arduino_version_file)
  file(READ ${arduino_version_file} RAW_VERSION)

  if("${RAW_VERSION}" MATCHES "([0-9]+\\.[0-9]+\\.[0-9]+)")
    set(parsed_version ${CMAKE_MATCH_1})
  elseif("${RAW_VERSION}" MATCHES "([0-9]+\\.[0-9]+)")
    set(parsed_version ${CMAKE_MATCH_1}.0)
  else()
    message(SEND_ERROR "Invalid Arduino version file: \"${arduino_version_file}\"")
  endif()

  set(${version_var} "${parsed_version}" PARENT_SCOPE)

  string(REPLACE "." "" version_definition ${parsed_version})
  string(TOUPPER "${ARDUINO_BOARD}" arduino_board_upper)
  string(TOUPPER "${ARDUINO_ARCH}" arduino_arch_upper)
  add_definitions(-DARDUINO=${version_definition})
  add_definitions(-DARDUINO_${arduino_board_upper})
  add_definitions(-DARDUINO_ARCH_${arduino_arch_upper})
endfunction()

#
# Find the Arduino version file
#
set(version_file "lib/version.txt")
find_file(arduino_version_file
  NAMES ${version_file}
  PATHS ${ARDUINO_SDK_PATH}
  DOC "Path to Arduino version file."
)
set(vendor_path "${ARDUINO_SDK_PATH}/hardware/${ARDUINO_VENDOR}")
set(platform_path "${vendor_path}/${ARDUINO_ARCH}")

if (arduino_version_file)
  if (EXISTS "${vendor_path}")
    if (EXISTS "${platform_path}")
      _DETECT_ARDUINO_VERSION(Arduino_VERSION ${arduino_version_file})
      _create_arduino_targets(${platform_path})
      include(FindPackageHandleStandardArgs)
      FIND_PACKAGE_HANDLE_STANDARD_ARGS(Arduino
        REQUIRED_VARS ARDUINO_SDK_PATH Arduino_VERSION
        VERSION_VAR Arduino_VERSION
      )
    else()
      message(WARNING "Arduino platform \"${ARDUINO_ARCH}\" not found")
    endif()
  else()
    message(WARNING "Arduino vendor \"${ARDUINO_VENDOR}\" not found")
  endif()
else()
  message(WARNING "Arduino SDK not found on \"${ARDUINO_SDK_PATH}\"")
endif()
