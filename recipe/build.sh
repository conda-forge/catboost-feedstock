#!/bin/bash

mkdir bin
ln -sf ${BUILD_PREFIX}/bin/{swig,ragel,yasm} bin/

cmake ${CMAKE_ARGS} \
  -DCMAKE_POSITION_INDEPENDENT_CODE=On \
  -DCMAKE_BUILD_TYPE=Release \
  -DCATBOOST_COMPONENTS="PYTHON-PACKAGE" \
  .

make -j${CPU_COUNT} _catboost _hnsw

cd catboost/python-package/

pushd catboost/widget/js/
  yarn install
popd

$PYTHON setup.py bdist_wheel --with-hnsw --prebuilt-extensions-build-root-dir=${SRC_DIR} -vv
$PYTHON -m pip install dist/catboost*.whl
