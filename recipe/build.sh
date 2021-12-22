#!/bin/bash

set -ex

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

export LDFLAGS="$LDFLAGS -lintl"

./configure --prefix=$PREFIX

make -j${CPU_COUNT}

make install
