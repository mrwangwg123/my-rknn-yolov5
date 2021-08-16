# Generate JNI wrap code based on the target platform.
# expose JNI_WRAP_HPP  JNI_WRAP_CPP

# TODO: checking existence of the file.
set(JNI_WRAP_HPP_TEMP "${CMAKE_SOURCE_DIR}/src/jniwrap/platform_jni_KRRFace.h.in")
set(JNI_WRAP_CPP_TEMP "${CMAKE_SOURCE_DIR}/src/jniwrap/platform_jni_KRRFace.cpp.in")

set(JAVA_INTERFACE_TEMP "${CMAKE_SOURCE_DIR}/src/jniwrap/KRRFace.java.in")

if(API_HANDLE_ADDR32)
    message("-- Using 32bits user interface.")
    set(JAVA_HANDLE_TYPE "int")  # Replace the type of `handle` in KRRFace.java.in .
else()
    set(API_HANDLE_ADDR32 OFF)
    set(JAVA_HANDLE_TYPE "long")  # Replace the type of `handle` in KRRFace.java.in .
endif()

if(ANDROID)
    set(PLATFORM_FLAG "android")
    # set(API_HANDLE_ADDR32 ON)     # Compatible with Android/Windows 32bits.
elseif(UNIX)
    set(PLATFORM_FLAG "linux")
else()
    set(PLATFORM_FLAG "windows")
endif()

# Set target file path.
set(JNI_WRAP_HPP "${CMAKE_BINARY_DIR}/${PLATFORM_FLAG}_jni_KRRFace.h")
set(JNI_WRAP_CPP "${CMAKE_BINARY_DIR}/${PLATFORM_FLAG}_jni_KRRFace.cpp")

set(JAVA_INTERFACE "${CMAKE_BINARY_DIR}/java/${PLATFORM_FLAG}/jni/KRRFace.java")

# Generate JNI wrap code.
configure_file("${JNI_WRAP_HPP_TEMP}" "${JNI_WRAP_HPP}")
configure_file("${JNI_WRAP_CPP_TEMP}" "${JNI_WRAP_CPP}")

# Generate Java Interface code.
configure_file("${JAVA_INTERFACE_TEMP}" "${JAVA_INTERFACE}")
install(FILES "${JAVA_INTERFACE}" DESTINATION "java/${PLATFORM_FLAG}/jni/")