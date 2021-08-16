# Copied, modified and refered from: https://github.com/BVLC/caffe/blob/master/cmake/ConfigGen.cmake

################################################################################################
# Function for generation CTemp install- tree export config files
# Usage:
#  ctemp_generate_export_configs()
function(ctemp_generate_export_configs)
    set(install_cmake_suffix "share/cmake")

    # ---[ Configure install-tree CaffeConfig.cmake file ]---
    configure_file("cmake/Templates/CTempConfig.cmake.in" "${PROJECT_BINARY_DIR}/cmake/${MYLIB_MODULE_NAME}Config.cmake" @ONLY)

    # Install the CaffeConfig.cmake and export set to use with install-tree
    install(FILES "${PROJECT_BINARY_DIR}/cmake/${MYLIB_MODULE_NAME}Config.cmake" DESTINATION ${install_cmake_suffix})

    # ---[ Configure and install version file ]---
    configure_file("cmake/Templates/CTempConfigVersion.cmake.in" "${PROJECT_BINARY_DIR}/cmake/${MYLIB_MODULE_NAME}ConfigVersion.cmake" @ONLY)
    install(FILES "${PROJECT_BINARY_DIR}/cmake/${MYLIB_MODULE_NAME}ConfigVersion.cmake" DESTINATION ${install_cmake_suffix})

    # ---[ Configure build information file
    # TODO
endfunction()
