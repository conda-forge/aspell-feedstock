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


for lang in en de es fr af am ar ast az be bg bn br ca cs csb cy da de el eo et fa fi fo fy ga gd gl grc gu gv he hi hil hr hsb hu hus hy ia id it kn ku ky la lt lv mg mi mk ml mn mr ms mt nds nl nn ny or pa pl pt_BR pt_PT qu ro ru rw sc sk sl sr sv sw ta te tet tk tl tn tr uk uz vi wa yi zu; do
	cd $lang
	./configure --vars ASPELL=$PREFIX/bin/aspell PREZIP=$PREFIX/bin/prezip
    make install
	cd ..
done
