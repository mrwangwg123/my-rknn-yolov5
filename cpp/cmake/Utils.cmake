# Copied, modified and refered from: https://github.com/pytorch/pytorch/blob/master/cmake/Utils.cmake

function (prepend OUTPUT PREPEND)
    set(OUT "")
    foreach(ITEM ${ARGN})
        list(APPEND OUT "${PREPEND}${ITEM}")
    endforeach()
    set(${OUTPUT} ${OUT} PARENT_SCOPE)
endfunction(prepend)

################################################################################################
# Clears variables from list
# Usage:
#   ctemp_clear_vars(<variables_list>)
# [not used yet]
macro(ctemp_clear_vars)
    foreach(_var ${ARGN})
        unset(${_var})
    endforeach()
endmacro()

################################################################################################
# Prints list element per line
# Usage:
#   ctemp_print_list(<list>)
function(ctemp_print_list)
    foreach(e ${ARGN})
        message(STATUS ${e})
    endforeach()
endfunction()

function(ctemp_info_print_list notify info)
    foreach(e ${info})
        message(STATUS "${notify}: ${e}")
    endforeach()
endfunction()

################################################################################################
# Command for disabling warnings for different platforms (see below for gcc and VisualStudio)
# Usage:
#   ctemp_warnings_disable(<CMAKE_[C|CXX]_FLAGS[_CONFIGURATION]> -Wshadow /wd4996 ..,)
macro(ctemp_warnings_disable)
  set(_flag_vars "")
  set(_msvc_warnings "")
  set(_gxx_warnings "")

  foreach(arg ${ARGN})
    if(arg MATCHES "^CMAKE_")
      list(APPEND _flag_vars ${arg})
    elseif(arg MATCHES "^/wd")
      list(APPEND _msvc_warnings ${arg})
    elseif(arg MATCHES "^-W")
      list(APPEND _gxx_warnings ${arg})
    endif()
  endforeach()

  if(NOT _flag_vars)
    set(_flag_vars CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
  endif()

  if(MSVC AND _msvc_warnings)
    foreach(var ${_flag_vars})
      foreach(warning ${_msvc_warnings})
        set(${var} "${${var}} ${warning}")
      endforeach()
    endforeach()
  elseif((CMAKE_COMPILER_IS_GNUCXX OR CMAKE_COMPILER_IS_CLANGXX) AND _gxx_warnings)
    foreach(var ${_flag_vars})
      foreach(warning ${_gxx_warnings})
        if(NOT warning MATCHES "^-Wno-")
          string(REPLACE "${warning}" "" ${var} "${${var}}")
          string(REPLACE "-W" "-Wno-" warning "${warning}")
        endif()
        set(${var} "${${var}} ${warning}")
      endforeach()
    endforeach()
  endif()
  ctemp_clear_vars(_flag_vars _msvc_warnings _gxx_warnings)
endmacro()

###
# Helper function to print out everything that cmake knows about a target
#
# Copied from https://stackoverflow.com/questions/32183975/how-to-print-all-the-properties-of-a-target-in-cmake
# This isn't called anywhere, but it's very useful when debugging cmake
# NOTE: This doesn't work for INTERFACE_LIBRARY or INTERFACE_LINK_LIBRARY targets

function(print_target_properties tgt)
  if(NOT TARGET ${tgt})
    message("There is no target named '${tgt}'")
    return()
  endif()

  # Get a list of all cmake properties TODO cache this lazily somehow
  execute_process(COMMAND cmake --help-property-list OUTPUT_VARIABLE CMAKE_PROPERTY_LIST)
  STRING(REGEX REPLACE ";" "\\\\;" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")
  STRING(REGEX REPLACE "\n" ";" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")

  foreach (prop ${CMAKE_PROPERTY_LIST})
    string(REPLACE "<CONFIG>" "${CMAKE_BUILD_TYPE}" prop ${prop})
    get_property(propval TARGET ${tgt} PROPERTY ${prop} SET)
    if (propval)
      get_target_property(propval ${tgt} ${prop})
      message ("${tgt} ${prop} = ${propval}")
    endif()
  endforeach(prop)
endfunction(print_target_properties)
