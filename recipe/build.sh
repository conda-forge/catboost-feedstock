#!/bin/bash

mkdir bin
ln -sf ${BUILD_PREFIX}/bin/{swig,ragel,yasm} bin/

if [[ "$target_platform" == "linux-"* ]]; then
  ln -sf $BUILD_PREFIX/bin/clang $BUILD_PREFIX/bin/${BUILD}-clang++
  ln -sf $BUILD_PREFIX/bin/clang $BUILD_PREFIX/bin/${BUILD}-clang
  ln -sf $BUILD_PREFIX/bin/clang $BUILD_PREFIX/bin/${HOST}-clang++
  ln -sf $BUILD_PREFIX/bin/clang $BUILD_PREFIX/bin/${HOST}-clang
  export CC=${HOST}-clang
  export CXX=${HOST}-clang++
  export CC_FOR_BUILD=${BUILD}-clang
  export CXX_FOR_BUILD=${BUILD}-clang++
  export NVCC_PREPEND_FLAGS="-ccbin=$BUILD_PREFIX/bin/${HOST}-clang++"
fi

if [[ "$target_platform" != "$build_platform" ]]; then
  (
    # Build command line tools for $build_platform
    mkdir native-build
    pushd native-build

    mkdir bin
    ln -sf ${BUILD_PREFIX}/bin/{swig,ragel,yasm} bin/

    export CC=$CC_FOR_BUILD
    export CXX=$CXX_FOR_BUILD
    export AR=$($CC_FOR_BUILD -print-prog-name=ar)
    export NM=$($CC_FOR_BUILD -print-prog-name=nm)
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${BUILD_PREFIX}/lib/pkgconfig

    # Unset these as they refer to PREFIX instead of BUILD_PREFIX
    unset CFLAGS
    unset CPPFLAGS
    unset CXXFLAGS
    unset CONDA_BUILD_SYSROOT

    cmake \
     -DCMAKE_PREFIX_PATH=${BUILD_PREFIX} \
     -DCMAKE_INSTALL_PREFIX=${BUILD_PREFIX} \
     -DCMAKE_TOOLCHAIN_FILE=${SRC_DIR}/build/toolchains/clang.toolchain \
     -DCMAKE_BUILD_TYPE=Release \
    ..

    # command line tools needed are given by https://github.com/catboost/catboost/blob/ee67179792ea2530ac531d20b6bb6fa6998f0a78/build/build_native.py#L50-L58
    make -j${CPU_COUNT} archiver, cpp_styleguide enum_parser flatc protoc rescompiler triecompiler
    popd
  )
  export CMAKE_ARGS="${CMAKE_ARGS} -DTOOLS_ROOT=$SRC_DIR/native-build"
fi

if [[ "$cuda_compiler_version" != "None" ]]; then
  if [[ "$cuda_compiler_version" != "11.8" ]]; then
    find . -name "CMakeLists*cuda.txt" -type f -print0 | xargs -0 sed -i -z "s/-gencode\s*arch=compute_35,code=sm_35//g"
  fi

  find . -name "CMakeLists*.txt" -type f -print0 | xargs -0 sed -i "s/-lcudart_static/-lcudart/g"
  find . -name "CMakeLists*.txt" -type f -print0 | xargs -0 sed -i "s/-lcudadevrt/-lcudart/g"
  find . -name "CMakeLists*.txt" -type f -print0 | xargs -0 sed -i "s/-lculibos/-lcudart/g"
  CMAKE_ARGS="${CMAKE_ARGS} -DHAVE_CUDA=ON"
fi

cmake ${CMAKE_ARGS} \
  -DCMAKE_POSITION_INDEPENDENT_CODE=On \
  -DCMAKE_TOOLCHAIN_FILE=${SRC_DIR}/build/toolchains/clang.toolchain \
  -DCMAKE_BUILD_TYPE=Release \
  -DCATBOOST_COMPONENTS="PYTHON-PACKAGE" \
  .

make -j${CPU_COUNT} _catboost _hnsw
cd catboost/python-package/

export YARN_ENABLE_IMMUTABLE_INSTALLS=false  # the lock file is updated by the build
pushd catboost/widget/js/
  yarn install
popd

$PYTHON setup.py bdist_wheel --with-hnsw --prebuilt-extensions-build-root-dir=${SRC_DIR} -vv
$PYTHON -m pip install dist/catboost*.whl
