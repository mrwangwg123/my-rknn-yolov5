# Build Examples
# -------
#
# Compile each source file in the examples directory into a separate executable file
#

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../src)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include)

# Traverse through all source code files in the current directory
AUX_SOURCE_DIRECTORY(${CMAKE_CURRENT_SOURCE_DIR} srcs)

if(srcs)
    # Build each source file independently
    foreach(source ${srcs})
        get_filename_component(name ${source} NAME_WE)
        add_executable(${name} ${source})
        if(EXAMPLES_DEFINITIONS)
            target_compile_definitions(${name} PUBLIC ${EXAMPLES_DEFINITIONS})
        endif()
        if(EXAMPLES_CXX_FLAGS)
            target_compile_options(${name} PUBLIC ${EXAMPLES_CXX_FLAGS})
        endif()
        if(BUILD_MYLIB)
            target_link_libraries(${name} ${MYLIB_NAME})
        endif()
        if(FOUND_3RDPARTY)
            target_link_libraries(${name} "${3RDPARTY_LINK_LIBS}" "${3RDPARTY_LINK_STATIC_LIBS}")
        endif()
        # Set properties to target
        set_target_properties(${name} PROPERTIES LINK_FLAGS_RELEASE -s)
        set(EXAMPLES_NAMES "${EXAMPLES_NAMES} ${name}" PARENT_SCOPE)
        install(FILES ${srcs} DESTINATION ${CMAKE_INSTALL_PREFIX}/examples)
        set_target_properties(${name} PROPERTIES INSTALL_RPATH $ORIGIN:$ORIGIN/../lib)

        install(TARGETS ${name} DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
        # Configure install source file
        configure_file("../cmake/Templates/ExamplesCMakeLists.txt.in" "${PROJECT_BINARY_DIR}/CMakeLists.txt" @ONLY)
        install(FILES "${PROJECT_BINARY_DIR}/CMakeLists.txt" DESTINATION ${CMAKE_INSTALL_PREFIX}/examples)
    endforeach(source)
    set(BUILD_EXAMPLES ON PARENT_SCOPE)
endif()
