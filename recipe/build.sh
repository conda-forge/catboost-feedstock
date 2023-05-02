#!/bin/bash

# install using pip from the whl files on PyPI

if [ `uname` == Darwin ]; then
    if [ "$PY_VER" == "3.7" ]; then
        WHL_FILE=https://pypi.org/packages/cp37/c/catboost/catboost-${PKG_VERSION}-cp37-cp37m-macosx_11_0_universal2.whl
    elif [ "$PY_VER" == "3.8" ]; then
        WHL_FILE=https://pypi.org/packages/cp38/c/catboost/catboost-${PKG_VERSION}-cp38-cp38-macosx_11_0_universal2.whl
    elif [ "$PY_VER" == "3.9" ]; then
        WHL_FILE=https://pypi.org/packages/cp39/c/catboost/catboost-${PKG_VERSION}-cp39-cp39-macosx_11_0_universal2.whl
    elif [ "$PY_VER" == "3.10" ]; then
        WHL_FILE=https://pypi.org/packages/cp310/c/catboost/catboost-${PKG_VERSION}-cp310-cp310-macosx_11_0_universal2.whl
    elif [ "$PY_VER" == "3.11" ]; then
        WHL_FILE=https://pypi.org/packages/cp311/c/catboost/catboost-${PKG_VERSION}-cp311-cp311-macosx_11_0_universal2.whl
    fi
fi

if [ `uname` == Linux ]; then
    if [ "$PLATFORM" == "linux-aarch64" ]; then
        TARGET_ARCH=aarch64
    elif [ "$PLATFORM" == "linux-x86_64" ]; then
        TARGET_ARCH=x86_64
    fi

    if [ "$PY_VER" == "3.7" ]; then
        WHL_FILE=https://pypi.org/packages/cp37/c/catboost/catboost-${PKG_VERSION}-cp37-cp37m-manylinux2014_${TARGET_ARCH}.whl
    elif [ "$PY_VER" == "3.8" ]; then
        WHL_FILE=https://pypi.org/packages/cp38/c/catboost/catboost-${PKG_VERSION}-cp38-cp38-manylinux2014_${TARGET_ARCH}.whl
    elif [ "$PY_VER" == "3.9" ]; then
        WHL_FILE=https://pypi.org/packages/cp39/c/catboost/catboost-${PKG_VERSION}-cp39-cp39-manylinux2014_${TARGET_ARCH}.whl
    elif [ "$PY_VER" == "3.10" ]; then
        WHL_FILE=https://pypi.org/packages/cp310/c/catboost/catboost-${PKG_VERSION}-cp310-cp310-manylinux2014_${TARGET_ARCH}.whl
    elif [ "$PY_VER" == "3.11" ]; then
        WHL_FILE=https://pypi.org/packages/cp311/c/catboost/catboost-${PKG_VERSION}-cp311-cp311-manylinux2014_${TARGET_ARCH}.whl
    fi
fi

$PYTHON -m pip install --no-deps $WHL_FILE
