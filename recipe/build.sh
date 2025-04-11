#!/bin/bash

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

    if [[ "$build_platform" == "linux-"* ]]; then
      export CONDA_BUILD_SYSROOT=${BUILD_PREFIX}/${CONDA_TOOLCHAIN_BUILD}/sysroot
    fi

    cmake \
     -DCMAKE_PREFIX_PATH=${BUILD_PREFIX} \
     -DCMAKE_INSTALL_PREFIX=${BUILD_PREFIX} \
     -DCMAKE_TOOLCHAIN_FILE=${SRC_DIR}/build/toolchains/clang.toolchain \
     -DCMAKE_BUILD_TYPE=Release \
     -DCATBOOST_COMPONENTS= \
    ..

    # command line tools needed are given by https://github.com/catboost/catboost/blob/ee67179792ea2530ac531d20b6bb6fa6998f0a78/build/build_native.py#L50-L58
    make -j${CPU_COUNT} archiver cpp_styleguide enum_parser flatc protoc rescompiler triecompiler
    popd
  )
  export CMAKE_ARGS="${CMAKE_ARGS} -DTOOLS_ROOT=$SRC_DIR/native-build"
fi

Python3_INCLUDE_DIR="$(python -c 'import sysconfig; print(sysconfig.get_path("include"))')"
Python3_NumPy_INCLUDE_DIR="$(python -c 'import numpy;print(numpy.get_include())')"
CMAKE_ARGS="${CMAKE_ARGS} -DPython3_EXECUTABLE:PATH=${PYTHON}"
CMAKE_ARGS="${CMAKE_ARGS} -DPython3_INCLUDE_DIR:PATH=${Python3_INCLUDE_DIR}"
CMAKE_ARGS="${CMAKE_ARGS} -DPython3_NumPy_INCLUDE_DIR=${Python3_NumPy_INCLUDE_DIR}"

if [[ "$cuda_compiler_version" != "None" ]]; then
  if [[ "$cuda_compiler_version" != "11.8" ]]; then
    find . -name "CMakeLists*cuda.txt" -type f -print0 | xargs -0 sed -i -z -r "s/-gencode\s*=?arch=compute_35,code=sm_35//g"
  fi

  # Link with shared version of `cudart` library instead of static.
  # cudadevrt and culibos are dependencies of libcudart_static.a and therefore need to be linked to if you are using the static version.
  # When using libcudart.so it has all the symbols of libcudart_static.a, libcudadevrt.a, libculibos.a and therefore all three can be replaced by the shared version.
  # TODO: make it configurable using CMake flags
  find . -name "CMakeLists*.txt" -type f -print0 | xargs -0 sed -i "s/-lcudart_static/-lcudart/g"
  find . -name "CMakeLists*.txt" -type f -print0 | xargs -0 sed -i "s/-lcudadevrt/-lcudart/g"
  find . -name "CMakeLists*.txt" -type f -print0 | xargs -0 sed -i "s/-lculibos/-lcudart/g"
  CMAKE_ARGS="${CMAKE_ARGS} -DHAVE_CUDA=ON"
fi

# restrict CUDA compilation parallelism
cp ci/cmake/cuda.cmake cmake/cuda.cmake

(
  mkdir cmake_build
  pushd cmake_build

  mkdir bin
  ln -sf ${BUILD_PREFIX}/bin/{swig,ragel,yasm} bin/

  cmake ${CMAKE_ARGS} \
    -DCMAKE_POSITION_INDEPENDENT_CODE=On \
    -DCMAKE_TOOLCHAIN_FILE=${SRC_DIR}/build/toolchains/clang.toolchain \
    -DCMAKE_BUILD_TYPE=Release \
    -DCATBOOST_COMPONENTS="PYTHON-PACKAGE" \
    ..

  make -j${CPU_COUNT} _catboost _hnsw
  popd
)

cd catboost/python-package/

export YARN_ENABLE_IMMUTABLE_INSTALLS=false  # the lock file is updated by the build
pushd catboost/widget/js/
  yarn install
popd

$PYTHON setup.py bdist_wheel --with-hnsw --prebuilt-extensions-build-root-dir=${SRC_DIR}/cmake_build -vv
$PYTHON -m pip install dist/catboost*.whl
