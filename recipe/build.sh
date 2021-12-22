#!/bin/bash

set -ex

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

if [[ $target_platform == "osx-arm64" ]]; then
	export LDFLAGS="$LDFLAGS -lintl"
fi

./configure --prefix=$PREFIX

make -j${CPU_COUNT}

make install
