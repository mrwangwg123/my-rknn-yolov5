#!/bin/bash

set -ex

# --- User configure
MAIN_NAME="YoloDetector"
PLATFORM=centos7_gcc4.8_x64
MODULE=WF${MAIN_NAME}Module
LIB_NAME=WF${MAIN_NAME}Module
BUILD_DIR=build-linux-x64
INSTALL_DIR_NAME=install
UNITTEST_BIN_NAME=API-TEST
BENCHMARK_BIN_NAME=BENCHMARK-TEST
VERSION="0.1.0"
SOVERSION="0"
USE_ENCRYPT_DOG=OFF
JNI_SO_NAME=WF${MAIN_NAME}JNIWrap

THIRD_PARTY_PATH="third_party/${PLATFORM}"

# VERSION=`cat VERSION | cut -d "_" -f1`

export VERBOSE=1

# --- Platform dependence check
if [ ! -n ${JAVA_HOME} ]; then
  echo "ERROR: Found JAVA_HOME is NULL!"
  exit -1
else
  echo "Found JAVA_HOME=${JAVA_HOME}"
fi

# --- It is recommended that you do not modify the following code!
PACKAGE_NAME=${MODULE}-${PLATFORM}-${VERSION}
PACKAGE_NAME_TAR=${PACKAGE_NAME}.tar

BUILD_SCRIPTS_PATH=$(cd "$(dirname "$0")";pwd)

PROJECT_PATH=${BUILD_SCRIPTS_PATH}

SRC_PATH=${PROJECT_PATH}/src
INCLUDE_PATH=${PROJECT_PATH}/include
TOOLS_PATH=${PROJECT_PATH}/tools
EXAMPLES_PATH=${PROJECT_PATH}/examples
BENCHMARK_PATH=${PROJECT_PATH}/benchmark

# --- Clean build workspace
echo ""
echo " >>> CLEAN BUILD WORKSPACE..."
if [ -d ${BUILD_DIR} ]; then
#  rm -r ${BUILD_DIR}/*
  echo "${BUILD_DIR} Existed!"
else
  mkdir -p ${BUILD_DIR}
fi
mkdir -p ${BUILD_DIR}
echo " <<< DONE IT!"
echo ""

pushd ${BUILD_DIR}

# --- Configure release mode
echo ""
echo " >>> START CMAKE CONFIGURE..."
INSTALL_PATH="`pwd`/${INSTALL_DIR_NAME}/${PLATFORM}/${MODULE}-${VERSION}"
cmake -DCMAKE_INSTALL_PREFIX="${INSTALL_PATH}" \
      -DCMAKE_BUILD_TYPE=release \
      -DMYLIB_COVERAGE=OFF \
      -DMYLIB_MODULE_NAME="${MODULE}" \
      -DMYLIB_NAME="${LIB_NAME}" \
      -DBENCHMARK_NAME="${BENCHMARK_BIN_NAME}" \
      -DMYLIB_3RD_PATH_ROOT="${THIRD_PARTY_PATH}" \
      -DMYLIB_VERSION="${VERSION}" \
      -DMYLIB_SOVERSION="${SOVERSION}" \
      ..

echo " <<< DONE IT!"

# --- Build release files
echo ""
echo " >>> START CODES BUILD..."
make -j4
echo " <<< DONE IT!"

echo ""
echo " >>> START RELEASE TARGET FILES..."
# --- Install release files
make install
make install-deps
echo " <<< DONE IT!"
echo ""

popd  # ${PROJECT_PATH}

echo ""
echo "All is Done!!!"

exit 0

