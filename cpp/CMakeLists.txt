# CMake Main Profile Entry # ------- #
# Cross-platform Compatible C/C++ Project Templates (CTemp for short)
#

if(NOT DEFINED CMAKE_INSTALL_PREFIX)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Installation Directory")
endif()

cmake_minimum_required(VERSION 3.5)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE release CACHE STRING "Choose the type of build" FORCE)
endif()

# CTemp
project(CTemp)

add_definitions(-DEXPORT_API)

# add 20210203
# set(CMAKE_CXX_VISIBILITY_PRESET hidden)

if (NOT MSVC)
    set(CMAKE_CXX_STANDARD 14)   # using c++11
endif()

# ---[ Flags
if(NOT APPLE AND NOT MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-variable -Wno-unused-but-set-variable -Wno-return-type -Wno-sign-compare -Wno-missing-field-initializers -Wno-unused-parameter -fpermissive -fopenmp -fPIC -Wall")
endif()
if (APPLE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fpermissive -fPIC -Wall")
endif()

if (MSVC)
    add_definitions(-w)
    set(CompilerFlags
        CMAKE_CXX_FLAGS
        CMAKE_CXX_FLAGS_DEBUG
        CMAKE_CXX_FLAGS_RELEASE
        CMAKE_C_FLAGS
        CMAKE_C_FLAGS_DEBUG
        CMAKE_C_FLAGS_RELEASE
        )
    foreach(CompilerFlag ${CompilerFlags})
        string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
    endforeach()
endif(MSVC)

# If enabled, generates a 'compile_commands.json' file containing the exact compiler calls
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

### User configures:
set(MYLIB_USE_ENCRYPT_DOG         OFF CACHE BOOL "Open encryption")
set(MYLIB_COVERAGE                OFF CACHE BOOL "Set coverage for test")
set(MYLIB_USE_CUDA                OFF CACHE BOOL "Build CUDA code")
set(MYLIB_CXX_FLAGS               "" CACHE STRING "Set target library c++ compile flags")
set(MYLIB_DEFINITIONS             "" CACHE STRING "Set target library c++ compile definitions")
set(MYLIB_3RD_PATH_ROOT           "third_party" CACHE STRING "")
set(MYLIB_3RD_EXCLUDE_PACKAGES    "" CACHE STRING "")
set(MYLIB_NAME                    "CTemp" CACHE STRING "")
set(MYLIB_MODULE_NAME             "CTemp" CACHE STRING "")
set(MYLIB_SOVERSION               "0" CACHE STRING "")
set(MYLIB_VERSION                 "0.0" CACHE STRING "")
set(MYLIB_WARNING_DISABLE         "" CACHE STRING "")
set(MYLIB_LINK_ARCHIVE_FIRST      ON CACHE BOOL "")
set(MYLIB_INTERFACE_CXX_FLAGS     "" CACHE STRING "")
set(MYLIB_INTERFACE_LINK_FLAGS    "" CACHE STRING "")
set(BENCHMARK_NAME                "banchmark" CACHE STRING "")
set(BENCHMARK_CXX_FLAGS           "" CACHE STRING "")
set(BENCHMARK_DEFINITIONS         "" CACHE STRING "")
set(TEST_NAME                     "API-TEST" CACHE STRING "")
set(TEST_CXX_FLAGS                "" CACHE STRING "")
set(TEST_DEFINITIONS              "" CACHE STRING "")
set(TOOLS_CXX_FLAGS               "" CACHE STRING "")
set(TOOLS_DEFINITIONS             "" CACHE STRING "")
set(EXAMPLES_CXX_FLAGS            "" CACHE STRING "")
set(EXAMPLES_DEFINITIONS          "" CACHE STRING "")

string(TOUPPER ${MYLIB_MODULE_NAME} MYLIB_MODULE_NAME_UPPER)

# Set global variables
set(FOUND_3RDPARTY OFF)
set(BUILD_MYLIB OFF)
set(BUILD_TOOLS OFF)
set(BUILD_EXAMPLES OFF)
set(BUILD_TEST OFF)
set(BUILD_BENCHMARK OFF)

if(MYLIB_LINK_ARCHIVE_FIRST)
    set(BUILD_SHARED_LIBS OFF)
endif()

# ---[ Utils
include(cmake/Utils.cmake)
# ---[ Misc checks to cope with various compiler modes TODO: there are some bugs when use cross-compiler
# include(cmake/MiscCheck.cmake)
# ---[ Generate target CMake files
include(cmake/ConfigGen.cmake)
# ---[ Load dependencies
include(cmake/Dependencies.cmake)
# ---[ Summary and show all vars infomation
include(cmake/Summary.cmake)

# ---[ Warnings
ctemp_warnings_disable(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-ignored-qualifiers -Wno-sign-compare -Wno-uninitialized")

if(MYLIB_COVERAGE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fprofile-arcs -ftest-coverage")
endif()

# Add common flags for Windows platform
if(WIN32)
    add_definitions(-D_SCL_SECURE_NO_WARNINGS -D_CRT_SECURE_NO_DEPRECATE)
    add_definitions(-DNOMINMAX -DEXPORT_API)
else()
    add_definitions(-Wall -Wextra -Wno-unused-function)
    add_definitions(-fPIC)
    if(CMAKE_BUILD_TYPE MATCHES "(Release|RELEASE|release)")
        add_definitions(-Ofast)
        add_definitions(-ffast-math)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -fPIC")
    else()
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DDEBUG -g -O0")
    endif()
endif()

# ---[ Puts prerequisites to install deps-libs
add_custom_target(install-deps COMMAND ${CMAKE_COMMAND} -DCMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DMYLIB_NAME=${MYLIB_NAME} -P ${PROJECT_SOURCE_DIR}/cmake/Prerequisites.cmake)

# ---[ Add sub cmake module
add_subdirectory(src)

# If using GNU GCC and the version is too old (usually lower than 4.9)
set(TOO_OLD_GNU_COMPILER 0)
if(${CMAKE_CXX_COMPILER_ID} MATCHES "GNU" AND ${CMAKE_CXX_COMPILER_VERSION} LESS "4.9")
    set(TOO_OLD_GNU_COMPILER 1)
endif()

if(NOT MSVC AND NOT ANDROID)
    add_subdirectory(test)
endif()

if(NOT MYLIB_COVERAGE)
    add_subdirectory(examples)
else()
    add_subdirectory(benchmark)
endif()

# ---[ Configuration summary
ctemp_print_configuration_summary()

# ---[ Export configs generation
ctemp_generate_export_configs()

