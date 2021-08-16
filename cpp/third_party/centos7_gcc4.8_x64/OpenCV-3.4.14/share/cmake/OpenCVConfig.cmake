# Find OpenCV
# -------
#
# Finds the OpenCV library
#
# This will define the following variables:
#
#   OPENCV_FOUND             -- True if the system has the OpenCV library
#   OPENCV_INCLUDE_DIRS      -- The include directories for OpenCV
#   OPENCV_LIBRARIES         -- Libraries to link against
#   OPENCV_LIBRARIES_ARCHIVE -- Libraries type is archive
#   OPENCV_CXX_FLAGS         -- Additional (required) compiler flags
#
# and the following imported targets:
#
#   opencv

include(FindPackageHandleStandardArgs)

if (DEFINED ENV{OPENCV_INSTALL_PREFIX})
  set(OPENCV_INSTALL_PREFIX $ENV{OPENCV_INSTALL_PREFIX})
else()
  # Assume we are in <install-prefix>/share/cmake/OpenCVConfig.cmake
  get_filename_component(CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
  get_filename_component(OPENCV_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)
endif()

# Include directories.
if (EXISTS "${OPENCV_INSTALL_PREFIX}/lib/include")
  set(OPENCV_INCLUDE_DIRS
    ${OPENCV_INSTALL_PREFIX}/lib/include)
else()
  set(OPENCV_INCLUDE_DIRS
    ${OPENCV_INSTALL_PREFIX}/include)
endif()

# set(OPENCV_LIBRARIES_ARCHIVE ON)

# Library dependencies.
if (1)
      find_library(OPENCV_WORLD_LIBRARY opencv_world NO_DEFAULT_PATH PATHS "${OPENCV_INSTALL_PREFIX}/lib")

endif()

set(OPENCV_LIBRARIES opencv_world)

# Create imported target opencv_world
add_library(opencv_world SHARED IMPORTED)

set_target_properties(opencv_world PROPERTIES
  IMPORTED_LOCATION "${OPENCV_WORLD_LIBRARY}"
  INTERFACE_INCLUDE_DIRECTORIES "${OPENCV_INCLUDE_DIRS}"
)

find_package_handle_standard_args(opencv_world DEFAULT_MSG OPENCV_WORLD_LIBRARY OPENCV_INCLUDE_DIRS)
