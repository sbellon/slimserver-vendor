#!/usr/bin/env bash
#
# $Id $

OS=`uname`

# Build dir
BUILD=$PWD/build

# Wavpack version
VERSION="5.3.0"

FLAGS=""
CONFIG_FLAGS=""
# Mac-specific flags (must be built on Leopard)
if [ $OS = "Darwin" ]; then
    FLAGS="-arch arm64 -mmacosx-version-min=11.0"
    CONFIG_FLAGS="--disable-asm"
elif [ $OS = "FreeBSD" ]; then
    # needed to find iconv
    FLAGS="-I/usr/local/include -L/usr/local/lib"
fi

# FreeBSD's make sucks
if [ $OS = "FreeBSD" ]; then
    if [ !-x /usr/local/bin/gmake ]; then
        echo "ERROR: Please install GNU make (gmake)"
        exit
    fi
    export GNUMAKE=/usr/local/bin/gmake
    export MAKE=/usr/local/bin/gmake
else
    export MAKE=/usr/bin/make
fi

# Clean up
# XXX command-line flag to skip cleanup
rm -rf $BUILD

mkdir $BUILD

# Build wavpack
tar jxvf wavpack-$VERSION.tar.bz2
cd wavpack-$VERSION
. ../../CPAN/update-config.sh
CFLAGS="$FLAGS" \
LDFLAGS="$FLAGS" \
    ./configure --prefix=$BUILD \
    --disable-dependency-tracking \
    --disable-shared \
    $CONFIG_FLAGS
make
if [ $? != 0 ]; then
    echo "make failed"
    exit $?
fi
make install
cd ..
rm -rf wavpack-$VERSION

cp $BUILD/bin/wvunpack .
rm -rf $BUILD

if [ $OS = 'Darwin' ]; then
    strip -S wvunpack
elif [ $OS = 'Linux' -o $OS = "FreeBSD" ]; then
    strip wvunpack
fi
