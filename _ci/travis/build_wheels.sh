#!/bin/bash
set -e -x

export CFLAGS='-std=c99'

# install build dependencies in container
yum install -y hdf5-devel

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    "${PYBIN}/pip" install -r /io/python/dev_requirements.txt
    "${PYBIN}/pip" wheel -w wheelhouse/ /io/build/python/dist/*
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair "$whl" -w /io/wheelhouse/
done

# Install packages and test
for PYBIN in /opt/python/*/bin/; do
    "${PYBIN}/pip" install digital_rf --no-index -f /io/wheelhouse
    # (cd "$HOME"; "${PYBIN}/nosetests" digital_rf)
done