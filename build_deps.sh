#!/bin/bash

PROJECT_ROOT=$(pwd)
BUILD_ROOT=${PROJECT_ROOT}/build
OUT_ROOT=${BUILD_ROOT}/out
LIB_ROOT=${BUILD_ROOT}/lib
DEPS_ROOT=${PROJECT_ROOT}/deps

function build_dep_for_platform() {
  local DEP=$1
  local TARGET=$2
  local ARCH=$3
  local PLATFORM=$4

  local BUILD_PATH=${OUT_ROOT}/${PLATFORM}/deps/${DEP}
  test -d ${BUILD_PATH} || mkdir -p ${BUILD_PATH}
  cd ${BUILD_PATH}

  cmake \
      -GXcode \
      -DCMAKE_TOOLCHAIN_FILE=${PROJECT_ROOT}/toolchains/ios.cmake \
      -DIOS_ARCH=${ARCH} \
      ${DEPS_ROOT}/$1
  
  local SDK=$(echo ${PLATFORM} | tr '[:upper:]' '[:lower:]')

  xcodebuild \
      ARCHS=${ARCH} \
      -sdk $SDK \
      -configuration Release \
      -parallelizeTargets \
      -jobs 16 \
      -target ALL_BUILD
}

function build_dep() {
  local DEP=$1
  local TARGET=$2

  build_dep_for_platform $DEP $TARGET x86_64 iPhoneSimulator
  build_dep_for_platform $DEP $TARGET arm64 iPhoneOS
}

function ln_deps() {
  local PLATFORM=$1

  local LIB_DIR=${LIB_ROOT}/${PLATFORM}
  test -d ${LIB_DIR} || mkdir -p ${LIB_DIR}

  find ${OUT_ROOT}/${PLATFORM} -name lib*.a | while read S_FILE; do
    ln -s ${S_FILE} ${LIB_DIR}/
  done 
}

# deps
build_dep cmus-client-cpp cmusclient

ln_deps iPhoneOS
ln_deps iPhoneSimulator

cd $PROJECT_ROOT
