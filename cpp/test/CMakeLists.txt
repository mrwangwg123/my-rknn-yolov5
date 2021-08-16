# Build API Unit-Test
# -------
#
# Compile unit test code and generate an executable file
#

set(TEST_BIN "API-TEST" CACHE STRING "Executable test file name")

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../src)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include)

# Fetch include path and add them into include_directories
# file(GLOB in_path LIST_DIRECTORIES true ${CMAKE_CURRENT_SOURCE_DIR} "*/include")
# include_directories(${in_path})

# Traverse through all source code files in the current directory
# AUX_SOURCE_DIRECTORY(${CMAKE_CURRENT_SOURCE_DIR} srcs)
file(GLOB_RECURSE srcs *.cpp *.cu *.cc)

# link_directories(/usr/local/cuda/lib64)
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../third_party/LTK-1.0.0/lib)

if(srcs)
    add_executable(${TEST_NAME} ${srcs})
    if(TEST_DEFINITIONS)
        target_compile_definitions(${TEST_NAME} PUBLIC ${TEST_DEFINITIONS})
    endif()
    if(TEST_CXX_FLAGS)
        target_compile_options(${TEST_NAME} PUBLIC ${TEST_CXX_FLAGS})
    endif()
    if(BUILD_MYLIB)
        target_link_libraries(${TEST_NAME} ${MYLIB_NAME} pthread)
    endif()
    if(FOUND_3RDPARTY)
        target_link_libraries(${TEST_NAME} "${3RDPARTY_LINK_LIBS}" "${3RDPARTY_LINK_STATIC_LIBS}")
    endif()
    set(BUILD_TEST ON PARENT_SCOPE)
endif()
