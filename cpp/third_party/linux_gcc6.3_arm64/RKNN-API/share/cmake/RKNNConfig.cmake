
include(FindPackageHandleStandardArgs)

if (DEFINED ENV{RKNN_INSTALL_PREFIX})
  set(RKNN_INSTALL_PREFIX $ENV{TORCH_INSTALL_PREFIX})
else()
  # Assume we are in <install-prefix>/share/cmake/NCNNConfig.cmake
  get_filename_component(CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
  get_filename_component(RKNN_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)
endif()

# Include directories.
set(RKNN_INCLUDE_DIRS ${RKNN_INSTALL_PREFIX}/include)
set(RKNN_LIBRARY ${RKNN_INSTALL_PREFIX}/lib)

find_library(RKNN_LIBRARY rknn_api NO_DEFAULT_PATH PATHS "${RKNN_INSTALL_PREFIX}/lib")

add_library(rknn_api SHARED IMPORTED)

set(RKNN_LIBRARIES rknn_api)

# When we build libtorch with the old GCC ABI, dependent libraries must too.
# set(RKNN_LIBRARIES_ARCHIVE ON)

set_target_properties(rknn_api PROPERTIES
    IMPORTED_LOCATION "${RKNN_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${RKNN_INCLUDE_DIRS}"
)
if (RKNN_CXX_FLAGS)
  set_property(TARGET rknn_api PROPERTY INTERFACE_COMPILE_OPTIONS "${RKNN_CXX_FLAGS}")
endif()

set(RKNN_FOUND TRUE)

find_package_handle_standard_args(rknn_api DEFAULT_MSG RKNN_LIBRARY RKNN_INCLUDE_DIRS)
