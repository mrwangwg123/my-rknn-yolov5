# Build Libraries
# -------
#
# Compile C/C++ program library, include static and dynamic libraries
#
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../src)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include)

# hide internal function symbols
# add 20201125
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -std=c++11")
# set(CMAKE_CXX_VISIBILITY_PRESET hidden)

# Collect source files
file(GLOB_RECURSE all_srcs ${CMAKE_CURRENT_SOURCE_DIR} *.h *.hpp *.cpp *.cu *.cc *.o)

# Get wrap source files and path (adding to include_directories).
set(srcs "")
set(srcs_path "")
foreach(item_ ${all_srcs})
    string(FIND "${item_}" "model_bin_holder.cpp" flag_)
    if ("${flag_}" LESS 0)
        list(APPEND srcs "${item_}")
        get_filename_component(path_ "${item_}" DIRECTORY)
        list(APPEND srcs_path "${path_}")
    endif()
endforeach()


# Remove duplicated path and add the paths into include_directories.
list(REMOVE_DUPLICATES srcs_path)
include_directories(${srcs_path})

# Fetch include path and add them into include_directories.
file(GLOB in_path LIST_DIRECTORIES true ${CMAKE_CURRENT_SOURCE_DIR} "*/include")
include_directories(${in_path})

# Provide for other tools' building.
set(ext_include_path ${srcs_path} PARENT_SCOPE)

if(srcs)
    if(MYLIB_USE_CUDA)
        find_package(CUDA QUIET REQUIRED)
        CUDA_ADD_LIBRARY(${MYLIB_NAME} SHARED ${srcs})
        link_directories(/usr/local/cuda/lib64)
        target_link_libraries(${MYLIB_NAME} -lcuda)
        target_link_libraries(${MYLIB_NAME} -lcudart)
    else()
        add_library(${MYLIB_NAME} SHARED ${srcs})
    endif()


    # Set version properties for libraries
   set_target_properties(${MYLIB_NAME} PROPERTIES VERSION ${MYLIB_VERSION} SOVERSION ${MYLIB_SOVERSION})

    if(FOUND_3RDPARTY)
        target_link_libraries(${MYLIB_NAME} "${3RDPARTY_LINK_LIBS}" "${3RDPARTY_LINK_STATIC_LIBS}")
    endif()

    target_include_directories(${MYLIB_NAME} PUBLIC ${srcs_path})
    target_include_directories(${MYLIB_NAME} PUBLIC ${in_path})

    if(MYLIB_DEFINITIONS)
        target_compile_definitions(${MYLIB_NAME} PUBLIC ${MYLIB_DEFINITIONS})
    endif()

    if(MYLIB_CXX_FLAGS)
        target_compile_options(${MYLIB_NAME} PUBLIC ${MYLIB_CXX_FLAGS})
    endif()

    set(BUILD_MYLIB ON PARENT_SCOPE)

    # Set install rpath
    set_target_properties(${MYLIB_NAME} PROPERTIES INSTALL_RPATH $ORIGIN)

    # Set properties to target
    set_target_properties(${MYLIB_NAME} PROPERTIES LINK_FLAGS_RELEASE -s)

    # Install Libraries
    if(MSVC)
        install(TARGETS ${MYLIB_NAME} RUNTIME DESTINATION lib)
        install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${MYLIB_NAME}.lib DESTINATION lib)
        install(FILES ${CMAKE_BINARY_DIR}/../src/krrface/krrface_api.h DESTINATION "include")
        install(FILES ${CMAKE_BINARY_DIR}/../src/krrface/krrface_def.h DESTINATION "include")
        install(FILES ${CMAKE_BINARY_DIR}/../src/krrface/krrface_version.h DESTINATION "include")
    else()
        install(TARGETS ${MYLIB_NAME} LIBRARY DESTINATION lib)
    endif()
   # Install Interface files
   install(DIRECTORY
          ${CMAKE_CURRENT_SOURCE_DIR}/../include
          DESTINATION ${CMAKE_INSTALL_PREFIX})
   # Install Resource files
#    file(GLOB ALL_RES ${CMAKE_CURRENT_SOURCE_DIR}/../assets)
#    install(DIRECTORY
#            ${ALL_RES}
#            DESTINATION ./)

endif()
