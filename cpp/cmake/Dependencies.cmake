# These lists are later turned into target properties on main library target
set(3RDPARTY_ALL_PACKAGES "")
set(3RDPARTY_LINK_LIBS "")
set(3RDPARTY_LINK_STATIC_LIBS "")
set(3RDPARTY_INCLUDE_DIRS "")
set(3RDPARTY_CXX_FLAGS "")

# Add third-party configure

file(GLOB platforms_paths "${MYLIB_3RD_PATH_ROOT}")
foreach(item_ ${platforms_paths})
    file(GLOB module_path "${item_}/*")
    list(APPEND 3rd_modules_paths ${module_path})
    list(APPEND CMAKE_FIND_ROOT_PATH "${module_path}")
endforeach(item_)

foreach(item_ ${3rd_modules_paths})
    get_filename_component(module ${item_} NAME)
    list(APPEND 3RDPARTY_ALL_PACKAGES ${module})

    foreach(exclude_item_ ${MYLIB_3RD_EXCLUDE_PACKAGES})
        list(REMOVE_ITEM module "${exclude_item_}")
    endforeach(exclude_item_)

    string(REPLACE "-" ";" name_version ${module})
    list(GET name_version 0 module_name)
    find_package(${module_name} NO_DEFAULT_PATH PATHS "${item_}/" "${item_}/share")
    if(${module_name}_FOUND)
        string(TOUPPER ${module_name} module)
        list(APPEND MYLIB_3RD_IMPORT_MODULES ${module_name})
        if(MYLIB_LINK_ARCHIVE_FIRST)
            if(${${module}_LIBRARIES_ARCHIVE})
                list(APPEND 3RDPARTY_LINK_STATIC_LIBS "${${module}_LIBRARIES}") 
            else()
                list(APPEND 3RDPARTY_LINK_LIBS "${${module}_LIBRARIES}") 
            endif()
        endif()
        list(APPEND 3RDPARTY_INCLUDE_DIRS "${${module}_INCLUDE_DIRS}")
        set(3RDPARTY_CXX_FLAGS "${3RDPARTY_CXX_FLAGS} ${${module}_CXX_FLAGS}")
        set(FOUND_3RDPARTY ON)
    endif()
endforeach(item_)

## If a static library depends on other static libraries, other dependent
## libraries should also be managed within that static library.
## So there's no need to doublely links here.
# list(APPEND 3RDPARTY_LINK_LIBS ${3RDPARTY_LINK_LIBS})
# list(APPEND 3RDPARTY_LINK_STATIC_LIBS ${3RDPARTY_LINK_STATIC_LIBS})
