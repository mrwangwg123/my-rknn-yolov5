# Copied, modified and refered from: Pytorch https://github.com/pytorch/pytorch/blob/master/cmake/MiscCheck.cmake
# TODO

if (UNIX)
  # prevent Unknown CMake command "check_function_exists".
  include(CheckFunctionExists)
endif()
include(CheckIncludeFile)
include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckCCompilerFlag)
include(CheckCXXSourceCompiles)
include(CheckCXXCompilerFlag)
include(CMakePushCheckState)

# ---[ If running on CentOS 7, check system version and compiler version.
# Ref: https://www.cnblogs.com/flylinux/p/7498327.html  TODO: CentOS 6
if(EXISTS "/etc/os-release")
  execute_process(COMMAND
    "sed" "-ne" "s/^ID=\\([a-z]\\+\\)$/\\1/p" "/etc/os-release"
    OUTPUT_VARIABLE OS_RELEASE_ID
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  execute_process(COMMAND
    "sed" "-ne" "s/^VERSION_ID=\"\\([0-9\\.]\\+\\)\"$/\\1/p" "/etc/os-release"
    OUTPUT_VARIABLE OS_RELEASE_VERSION_ID
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  if(OS_RELEASE_ID STREQUAL "ubuntu")
    if(OS_RELEASE_VERSION_ID VERSION_GREATER "17.04")
      if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "6.0.0")
          message(FATAL_ERROR
            "Please use GCC 6 or higher on Ubuntu 17.04 and higher. "
            "For more information, see: "
            "https://github.com/caffe2/caffe2/issues/1633"
            )
        endif()
      endif()
    endif()
  endif()
endif()

# ---[ If running on Ubuntu, check system version and compiler version.
if(EXISTS "/usr/lib/os-release")
  execute_process(COMMAND
    "sed" "-ne" "s/^ID=\\([a-z]\\+\\)$/\\1/p" "/usr/lib/os-release"
    OUTPUT_VARIABLE OS_RELEASE_ID
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  execute_process(COMMAND
    "sed" "-ne" "s/^VERSION_ID=\"\\([0-9\\.]\\+\\)\"$/\\1/p" "/usr/lib/os-release"
    OUTPUT_VARIABLE OS_RELEASE_VERSION_ID
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  if(OS_RELEASE_ID STREQUAL "ubuntu")
    if(OS_RELEASE_VERSION_ID VERSION_GREATER "17.04")
      if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "6.0.0")
          message(FATAL_ERROR
            "Please use GCC 6 or higher on Ubuntu 17.04 and higher. "
            "For more information, see: "
            "https://github.com/caffe2/caffe2/issues/1633"
            )
        endif()
      endif()
    endif()
  endif()
endif()

if (NOT BUILD_ATEN_MOBILE)
  # ---[ Check that our programs run.  This is different from the native CMake
  # compiler check, which just tests if the program compiles and links.  This is
  # important because with ASAN you might need to help the compiled library find
  # some dynamic libraries.
  cmake_push_check_state(RESET)
  CHECK_C_SOURCE_RUNS("
  int main() { return 0; }
  " COMPILER_WORKS)
  if (NOT COMPILER_WORKS)
    # Force cmake to retest next time around
    unset(COMPILER_WORKS CACHE)
    message(FATAL_ERROR
        "Could not run a simple program built with your compiler. "
        "If you are trying to use -fsanitize=address, make sure "
        "libasan is properly installed on your system (you can confirm "
        "if the problem is this by attempting to build and run a "
        "small program.)")
  endif()
  cmake_pop_check_state()
endif()

if (NOT BUILD_ATEN_MOBILE)
  # ---[ Check if certain std functions are supported. Sometimes
  # _GLIBCXX_USE_C99 macro is not defined and some functions are missing.
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_FLAGS "-std=c++11")
  CHECK_CXX_SOURCE_COMPILES("
  #include <cmath>
  #include <string>
  int main() {
    int a = std::isinf(3.0);
    int b = std::isnan(0.0);
    std::string s = std::to_string(1);
    return 0;
    }" SUPPORT_GLIBCXX_USE_C99)
  if (NOT SUPPORT_GLIBCXX_USE_C99)
    # Force cmake to retest next time around
    unset(SUPPORT_GLIBCXX_USE_C99 CACHE)
    message(FATAL_ERROR
        "The C++ compiler does not support required functions. "
        "This is very likely due to a known bug in GCC 5 "
        "(and maybe other versions) on Ubuntu 17.10 and newer. "
        "For more information, see: "
        "https://github.com/pytorch/pytorch/issues/5229")
  endif()
  cmake_pop_check_state()
endif()

# ---[ Check if std::exception_ptr is supported.
cmake_push_check_state(RESET)
set(CMAKE_REQUIRED_FLAGS "-std=c++11")
CHECK_CXX_SOURCE_COMPILES(
    "#include <string>
    #include <exception>
    int main(int argc, char** argv) {
      std::exception_ptr eptr;
      try {
          std::string().at(1);
      } catch(...) {
          eptr = std::current_exception();
      }
    }" EXCEPTION_PTR_SUPPORTED)

if (EXCEPTION_PTR_SUPPORTED)
#  message(STATUS "std::exception_ptr is supported.")
  set(USE_EXCEPTION_PTR 1)
else()
  message(STATUS "std::exception_ptr is NOT supported.")
endif()
cmake_pop_check_state()
