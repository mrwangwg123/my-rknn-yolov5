# Prints accumulated CTemp configuration summary

function (ctemp_print_configuration_summary)
  message(STATUS "****************** Summary ******************")
  message(STATUS "General:")

  message(STATUS "  CMake version                 : ${CMAKE_VERSION}")
  message(STATUS "  CMake command                 : ${CMAKE_COMMAND}")
  message(STATUS "  System                        : ${CMAKE_SYSTEM_NAME}")
  message(STATUS "  System version                : ${CMAKE_SYSTEM_VERSION}")
  message(STATUS "  System processor              : ${CMAKE_SYSTEM_PROCESSOR}")
  message(STATUS "  C++ compiler                  : ${CMAKE_CXX_COMPILER}")
  message(STATUS "  C++ compiler id               : ${CMAKE_CXX_COMPILER_ID}")
  message(STATUS "  C++ compiler version          : ${CMAKE_CXX_COMPILER_VERSION}")
  message(STATUS "  CXX flags                     : ${CMAKE_CXX_FLAGS}")
  message(STATUS "  CMAKE_BUILD_TYPE              : ${CMAKE_BUILD_TYPE}")
  message(STATUS "  CMAKE_INSTALL_PREFIX          : ${CMAKE_INSTALL_PREFIX}")
  message(STATUS "")

  message(STATUS "Configure:")

  message(STATUS " +BUILD_MYLIB                   : ${BUILD_MYLIB}")
  if(BUILD_MYLIB)
    message(STATUS "  MYLIB_COVERAGE                : ${MYLIB_COVERAGE}")
    message(STATUS "  MYLIB_CXX_FLAGS               : ${MYLIB_CXX_FLAGS}")
    message(STATUS "  MYLIB_DEFINITIONS             : ${MYLIB_DEFINITIONS}")
    message(STATUS "  MYLIB_3RD_PATH_ROOT           : ${MYLIB_3RD_PATH_ROOT}")
    message(STATUS "  MYLIB_3RD_EXCLUDE_PACKAGES    : ${MYLIB_3RD_EXCLUDE_PACKAGES}")
    message(STATUS "  MYLIB_3RD_IMPORT_MODULES      : ${MYLIB_3RD_IMPORT_MODULES}")
    message(STATUS "  MYLIB_NAME                    : ${MYLIB_NAME}")
    message(STATUS "  MYLIB_MODULE_NAME             : ${MYLIB_MODULE_NAME}")
    message(STATUS "  MYLIB_SOVERSION               : ${MYLIB_SOVERSION}")
    message(STATUS "  MYLIB_VERSION                 : ${MYLIB_VERSION}")
    message(STATUS "  MYLIB_WARNING_DISABLE         : ${MYLIB_WARN_DISABLE}")
    message(STATUS "  MYLIB_LINK_ARCHIVE_FIRST      : ${MYLIB_LINK_ARCHIVE_FIRST}")
    message(STATUS "  MYLIB_INTERFACE_CXX_FLAGS     : ${MYLIB_INTERFACE_CXX_FLAGS}")
  endif()

  message(STATUS " +BUILD_BENCHMARK               : ${BUILD_BENCHMARK}")
  if(BUILD_BENCHMARK)
    message(STATUS "  BENCHMARK_NAME                : ${BENCHMARK_NAME}")
    message(STATUS "  BENCHMARK_CXX_FLAGS           : ${BENCHMARK_CXX_FLAGS}")
    message(STATUS "  BENCHMARK_DEFINITIONS         : ${BENCHMARK_DEFINITIONS}")
  endif()

  message(STATUS " +BUILD_TEST                    : ${BUILD_TEST}")
  if(BUILD_TEST)
    message(STATUS "  TEST_NAME                     : ${TEST_NAME}")
    message(STATUS "  TEST_CXX_FLAGS                : ${TEST_CXX_FLAGS}")
    message(STATUS "  TEST_DEFINITIONS              : ${TEST_DEFINITIONS}")
  endif()

  message(STATUS " +BUILD_TOOLS                   : ${BUILD_TOOLS}")
  if(BUILD_TOOLS)
    message(STATUS "  TOOLS_NAMES                   : ${TOOLS_NAMES}")
    message(STATUS "  TOOLS_CXX_FLAGS               : ${TOOLS_CXX_FLAGS}")
    message(STATUS "  TOOLS_DEFINITIONS             : ${TOOLS_DEFINITIONS}")
  endif()

  message(STATUS " +BUILD_EXAMPLES                : ${BUILD_EXAMPLES}")
  if(BUILD_EXAMPLES)
    message(STATUS "  EXAMPLES_NAMES                : ${EXAMPLES_NAMES}")
    message(STATUS "  EXAMPLES_CXX_FLAGS            : ${EXAMPLES_CXX_FLAGS}")
    message(STATUS "  EXAMPLES_DEFINITIONS          : ${EXAMPLES_DEFINITIONS}")
  endif()

  message(STATUS "  All 3rdparty modules          : ${3RDPARTY_ALL_PACKAGES}")
  message(STATUS "  Static Dependencies           : ${3RDPARTY_LINK_STATIC_LIBS}")
  message(STATUS "  Dynamic Dependencies          : ${3RDPARTY_LINK_LIBS}")
endfunction()