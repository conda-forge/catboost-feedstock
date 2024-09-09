#!/bin/bash

cmake ${CMAKE_ARGS} \
  -G Ninja \
  -DCMAKE_POSITION_INDEPENDENT_CODE=On \
  -DCMAKE_BUILD_TYPE=Release \
  -DCATBOOST_COMPONENTS="PYTHON-PACKAGE" \
  .

ninja -j${CPU_COUNT}
ninja install
