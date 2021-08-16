# Install prerequisites libraries

function(copy_changed_file filename destination)
    set(_copy 1)
    set(_src_name ${filename})
    get_filename_component(_name ${_src_name} NAME)
    set(_dst_name ${destination}/${_name})

    # lock a file to ensure that no two cmake processes
    # try to copy the same file at the same time in parallel
    # builds

    # string(SHA1 _hash ${_dst_name})
    # set(_lock_file ${CMAKE_BINARY_DIR}/${_hash}.lock)
    # file(LOCK ${_lock_file} GUARD FUNCTION)

    if(EXISTS ${_dst_name})
        file(TIMESTAMP ${_dst_name} _dst_time)
        file(TIMESTAMP ${_src_name} _src_time)
        if(${_dst_time} STREQUAL ${_src_time})
            # skip this library if the destination and source
            # have the same time stamp
            return()
        else()
            # file has changed remove
            file(REMOVE ${_dst_name})
        endif()
    endif()

    if(_copy)
        message(STATUS "Copying ${_name} to ${destination}")
        file(COPY ${_src_name} DESTINATION ${destination})
    endif()
endfunction()

include(GetPrerequisites)

if (CMAKE_SYSTEM_NAME MATCHES "(Windows|WINDOWS)")
    file(GLOB FOUND_FILES ${CMAKE_BINARY_DIR}/src/*${MYLIB_NAME}.dll)
elseif(CMAKE_SYSTEM_NAME MATCHES "(Darwin|DARWIN)")
    file(GLOB FOUND_FILES ${CMAKE_BINARY_DIR}/src/*${MYLIB_NAME}.dylib)
else() # UNIX
    file(GLOB FOUND_FILES ${CMAKE_BINARY_DIR}/src/*${MYLIB_NAME}.so)
endif()

if (FOUND_FILES)
    if (CMAKE_SYSTEM_NAME MATCHES "(Windows|WINDOWS)")
        get_prerequisites(${FOUND_FILES} OUT 0 0 "" "$ENV{LD_LIBRARY_PATH}")
    else()
        get_prerequisites(${FOUND_FILES} OUT 1 1 "" "$ENV{LD_LIBRARY_PATH}")
    endif()

    if (OUT)
        foreach(_item ${OUT})
            gp_resolve_item("${FOUND_FILES}" "${_item}" "" "$ENV{LD_LIBRARY_PATH}" DEPENDENCY_PATH)
            get_filename_component(RESOLVED_DEPENDENCY_PATH "${DEPENDENCY_PATH}" REALPATH)
            foreach(_i ${DEPENDENCY_PATH})
                copy_changed_file("${_i}" "${CMAKE_INSTALL_PREFIX}/lib")
            endforeach(_i ${_item})  
            foreach(_i ${RESOLVED_DEPENDENCY_PATH})
                copy_changed_file("${_i}" "${CMAKE_INSTALL_PREFIX}/lib")
            endforeach(_i ${_item})  
        endforeach(_item)
    endif()
endif()
