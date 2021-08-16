## Compile and inject the real model data buffer with each placeholder xxx_model_bin_holder.cpp .

set(model_src_path "${CMAKE_SOURCE_DIR}/src/")
set(obj_dir "${CMAKE_BINARY_DIR}/model_objs")
set(inject_tool "${CMAKE_SOURCE_DIR}/scripts/model_buffer_inject.py")
set(model_objs "")

set(obj_ext "o")
if (MSVC)
    set(obj_ext "obj")
endif()

# Find all the placeholder source files.
file(GLOB_RECURSE srcs RELATIVE "${model_src_path}" *_model_bin_holder.cpp)

# Each placeholder source file is separately compiled into a object file.
foreach(module_src ${srcs})
    # Get the module name i.e. <module_name>/<module_name>_model_bin_holder.cpp .
    string(REGEX REPLACE /.*_model_bin_holder.cpp "" module_name ${module_src})
    string(CONCAT obj_name ${module_name} "_obj")
    # Generate a separate object file for each source file.
    add_library(${obj_name} OBJECT "${model_src_path}/${module_src}")
    # target_include_directories(${LIBNAME_OBJ} PUBLIC "include")
    target_compile_options(${obj_name} PUBLIC "-fPIC")

    # Copy out the object file.
    set(target_obj_path ${obj_dir}/${module_name}.${obj_ext})
    add_custom_command(OUTPUT "${target_obj_path}.holder"
        DEPENDS ${obj_name}
        COMMAND ${CMAKE_COMMAND} -E make_directory "${obj_dir}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different 
        $<TARGET_OBJECTS:${obj_name}> "${target_obj_path}.holder")

    file(GLOB_RECURSE proto_file "${model_src_path}/${module_name}" ${module_name}_proto.bin)
    # Inject model data into each object file.
    # Usage: python model_buffer_inject.py <origin_model_file> <object_file> <target_file> <signature>
    if(proto_file)
        add_custom_command(OUTPUT "${target_obj_path}.in.proto"
            DEPENDS "${target_obj_path}.holder"
            COMMAND python ${inject_tool} ${target_obj_path}.holder ${proto_file} ${target_obj_path}.in.proto "__PROTO_SIGNATURE__")
    endif()

    file(GLOB_RECURSE weight_file "${model_src_path}/${module_name}" ${module_name}_weight.bin)
    # Inject model data into each object file.
    # Usage: python model_buffer_inject.py <origin_model_file> <object_file> <target_file> <signature>
    if(weight_file)
        add_custom_command(OUTPUT "${target_obj_path}"
            DEPENDS "${target_obj_path}.in.proto"
            COMMAND python ${inject_tool} ${target_obj_path}.in.proto ${weight_file} ${target_obj_path} "__WEIGHT_SIGNATURE__")
    endif()

    # Import the modified model object files.
    add_library(${obj_name}_modified OBJECT IMPORTED GLOBAL)
    set_target_properties(${obj_name}_modified PROPERTIES IMPORTED_OBJECTS ${target_obj_path})
    add_dependencies(${obj_name}_modified  "${target_obj_path}")

    list(APPEND model_objs "$<TARGET_OBJECTS:${obj_name}_modified>")
endforeach(module_src)

add_library(model_static STATIC "${model_objs}")
# LINKER_LANGUAGE property needs to be specified otherwise an error (CMake Error: Cannot
# determine link language for target "xxx".) will be reported.
set_target_properties(model_static PROPERTIES LINKER_LANGUAGE CXX)