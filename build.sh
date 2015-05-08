#!/bin/bash

export CC="clang"

if clang >/dev/null 2>&1 ; then
	echo "clang is not installed, switching to gcc"
	export CC="gcc"
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR
mkdir -p ./lib

echo "using $CC"
if [[ `uname` == 'Darwin' ]]; then
	$CC -std=c99 -march=native -dynamiclib ./csrc/learn1.c -O3 -lm -o ./lib/superlib.dylib
elif [[ `uname` == 'Linux' ]]; then
	$CC -std=c99 -march=native -shared ./csrc/learn.c -O3 -lm -fPIC -o ./lib/superlib.so
fi
