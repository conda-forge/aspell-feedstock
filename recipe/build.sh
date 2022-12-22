#!/bin/bash

set -ex

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .


if [[ $target_platform == "osx-arm64" ]]; then
    # For the dictionaries, it is necessary to build aspell for the build platform
    # when cross-compiling.

    # Start a subshell to not disturb the variables below
    (
    export CC=$CC_FOR_BUILD
    export CXX=$CXX_FOR_BUILD
    export AR=($CC_FOR_BUILD -print-prog-name=ar)
    export LD=($CC_FOR_BUILD -print-prog-name=ld)
    export NM=($CC_FOR_BUILD -print-prog-name=nm)
    export LDFLAGS="-L$BUILD_PREFIX/lib -Wl,-rpath,$BUILD_PREFIX/lib -lintl"
    export host_alias=$build_alias
    export CFLAGS=""
    export CXXFLAGS=""
    export CPPFLAGS=""

    ./configure --prefix=$PREFIX --host="$BUILD" || { cat config.log; exit 1; }

    make -j${CPU_COUNT}

    make install
    )
else
    ./configure --prefix=$PREFIX

    make -j${CPU_COUNT}

    make install
fi


# Install dictionaries
for lang in en de es fr af am ar ast az be bg bn br ca cs csb cy da de el eo et fa fi fo fy ga gd gl grc gu gv he hi hil hr hsb hu hus hy ia id it kn ku ky la lt lv mg mi mk ml mn mr ms mt nds nl nn ny or pa pl pt_BR pt_PT qu ro ru rw sc sk sl sr sv sw ta te tet tk tl tn tr uk uz vi wa yi zu; do
    cd $lang
    ./configure --vars ASPELL=$PREFIX/bin/aspell PREZIP=$PREFIX/bin/prezip
    make install
    cd ..
done


if [[ $target_platform == "osx-arm64" ]]; then
    # Build the actual cross-compiled aspell
    export LDFLAGS="$LDFLAGS -lintl"

    make clean

    ./configure --prefix=$PREFIX
    make -j${CPU_COUNT}

    make install

fi
