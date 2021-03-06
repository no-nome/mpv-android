#!/bin/bash -e

. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf _build$ndk_suffix
	exit 0
else
	exit 255
fi

[ -f waf ] || ./bootstrap.py

extrald=
[[ "$ndk_triple" == "aarch64"* ]] && extrald="-fuse-ld=gold"

# paths are added manually here for shaderc (has no .pc)
LDFLAGS="$extrald -L$prefix_dir/lib" \
CFLAGS="-I$prefix_dir/include" \
./waf configure \
	--disable-iconv --lua=52 \
	--enable-libmpv-shared \
	--disable-manpage-build \
	-o "`pwd`/_build$ndk_suffix"

./waf build -j$cores
./waf install --destdir="$prefix_dir"
