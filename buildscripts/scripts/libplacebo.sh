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

# Android provides Vulkan, but no pkg-config file
mkdir -p "$prefix_dir"/lib/pkgconfig
cat >"$prefix_dir"/lib/pkgconfig/vulkan.pc <<"END"
Name: Vulkan
Description:
Version: 1.1
Libs: -lvulkan
Cflags:
END

#####

# create meson cross file
mkdir -p _build$ndk_suffix
crossfile=_build$ndk_suffix/crossfile.txt
# c_link_args + c_args are needed for shaderc
cat >$crossfile <<AAA
[binaries]
c = '$CC'
cpp = '$CXX'
ar = '$ndk_triple-ar'
strip = '$ndk_triple-strip'
[properties]
c_link_args = ['-L$prefix_dir/lib']
c_args = ['-I$prefix_dir/include']
sys_root = '$prefix_dir'
[host_machine]
system = 'linux'
cpu_family = '${ndk_triple%%-*}'
cpu = '${CC%%-*}'
endian = 'little'
[paths]
prefix = '$prefix_dir'
AAA

unset CC CXX
meson _build$ndk_suffix \
	--buildtype release --cross-file $crossfile \
	--default-library static

ninja -C _build$ndk_suffix -j$cores
ninja -C _build$ndk_suffix install
