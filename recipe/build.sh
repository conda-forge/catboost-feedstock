#!/bin/bash

mkdir bin
ln -sf ${BUILD_PREFIX}/bin/{swig,ragel,yasm} bin/

if [[ "$target_platform" != "$build_platform" ]]; then
  (
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

    # Unset them as we're ok with builds that are either slow or non-portable
    unset CFLAGS
    unset CPPFLAGS
    unset CXXFLAGS

    cmake \
     -DCMAKE_POSITION_INDEPENDENT_CODE=On \
     -DCMAKE_BUILD_TYPE=Release \
     -DCATBOOST_COMPONENTS="PYTHON-PACKAGE" \
    ..

    make -j${CPU_COUNT} _catboost _hnsw
    popd
  )
  export CMAKE_ARGS="${CMAKE_ARGS} -DTOOLS_ROOT=$SRC_DIR/native-build"
fi

cmake ${CMAKE_ARGS} \
  -DCMAKE_POSITION_INDEPENDENT_CODE=On \
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
