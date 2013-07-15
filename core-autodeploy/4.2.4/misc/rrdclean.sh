#! /usr/bin/env bash

if [ -z "$BUILD_DIR" ]
then
   BUILD_DIR=`pwd`/build
fi

[ ! -d "$BUILD_DIR" ] && exit
cd "$BUILD_DIR"

echo "Cleaning rrdtool dependencies..."

rm -rf cairo-*
rm -rf libiconv-*
rm -rf fontconfig-*
rm -rf freetype-*
rm -rf gettext-*
rm -rf glib-*
rm -rf libpng-*
rm -rf libxml2-*
rm -rf pango-*
rm -rf pixman-*
rm -rf pkg-*
rm -rf zlib-*

