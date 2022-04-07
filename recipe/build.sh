#!/bin/bash

# install using pip from the whl files on PyPI

if [ `uname` == Darwin ]; then
    if [ "$PY_VER" == "2.7" ]; then
        WHL_FILE=https://pypi.org/packages/cp27/c/catboost/catboost-${PKG_VERSION}-cp27-none-macosx_10_6_universal2.whl
    elif [ "$PY_VER" == "3.5" ]; then
        WHL_FILE=https://pypi.org/packages/cp35/c/catboost/catboost-${PKG_VERSION}-cp35-none-macosx_10_6_universal2.whl
    elif [ "$PY_VER" == "3.6" ]; then
        WHL_FILE=https://pypi.org/packages/cp36/c/catboost/catboost-${PKG_VERSION}-cp36-none-macosx_10_6_universal2.whl
    elif [ "$PY_VER" == "3.7" ]; then
        WHL_FILE=https://pypi.org/packages/cp37/c/catboost/catboost-${PKG_VERSION}-cp37-none-macosx_10_6_universal2.whl
    elif [ "$PY_VER" == "3.8" ]; then
        WHL_FILE=https://pypi.org/packages/cp38/c/catboost/catboost-${PKG_VERSION}-cp38-none-macosx_10_6_universal2.whl
    elif [ "$PY_VER" == "3.9" ]; then
        WHL_FILE=https://pypi.org/packages/cp39/c/catboost/catboost-${PKG_VERSION}-cp39-none-macosx_10_6_universal2.whl
    elif [ "$PY_VER" == "3.10" ]; then
        WHL_FILE=https://pypi.org/packages/cp310/c/catboost/catboost-${PKG_VERSION}-cp310-none-macosx_10_6_universal2.whl
    fi
fi

if [ `uname` == Linux ]; then
    if [ "$PY_VER" == "2.7" ]; then
        WHL_FILE=https://pypi.org/packages/cp27/c/catboost/catboost-${PKG_VERSION}-cp27-none-manylinux1_x86_64.whl
    elif [ "$PY_VER" == "3.5" ]; then
        WHL_FILE=https://pypi.org/packages/cp35/c/catboost/catboost-${PKG_VERSION}-cp35-none-manylinux1_x86_64.whl
    elif [ "$PY_VER" == "3.6" ]; then
        WHL_FILE=https://pypi.org/packages/cp36/c/catboost/catboost-${PKG_VERSION}-cp36-none-manylinux1_x86_64.whl
    elif [ "$PY_VER" == "3.7" ]; then
        WHL_FILE=https://pypi.org/packages/cp37/c/catboost/catboost-${PKG_VERSION}-cp37-none-manylinux1_x86_64.whl
    elif [ "$PY_VER" == "3.8" ]; then
        WHL_FILE=https://pypi.org/packages/cp38/c/catboost/catboost-${PKG_VERSION}-cp38-none-manylinux1_x86_64.whl
    elif [ "$PY_VER" == "3.9" ]; then
        WHL_FILE=https://pypi.org/packages/cp39/c/catboost/catboost-${PKG_VERSION}-cp39-none-manylinux1_x86_64.whl
    elif [ "$PY_VER" == "3.10" ]; then
        WHL_FILE=https://pypi.org/packages/cp310/c/catboost/catboost-${PKG_VERSION}-cp310-none-manylinux1_x86_64.whl
    fi
fi

pip install --no-deps $WHL_FILE
