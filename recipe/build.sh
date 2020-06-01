#!/bin/bash

pushd catboost/python-package/catboost

$PYTHON ../../../ya make -DPYTHON_CONFIG=$PREFIX/bin/python3-config -DUSE_ARCADIA_PYTHON=no -DOS_SDK=local -j${CPU_COUNT} --c-compiler=$CC --cxx-compiler=$CXX
