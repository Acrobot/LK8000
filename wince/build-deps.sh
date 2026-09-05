#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
DEPS="$ROOT/out/wince-deps"
SRC="$DEPS/src"
LIB="$DEPS/lib"
OBJ="$DEPS/obj"

if [ ! -d "$SRC/zlib" ] || [ ! -d "$SRC/zziplib" ] || [ ! -d "$SRC/geographiclib" ]; then
  sh "$ROOT/wince/prepare-deps.sh" >/dev/null
fi

CC=${CC:-arm-mingw32ce-gcc}
CXX=${CXX:-arm-mingw32ce-g++}
AR=${AR:-arm-mingw32ce-ar}

COMMON="-O2 -g0 -mcpu=xscale -D_WIN32_WCE=0x0420 -D_WIN32_IE=0x0420 -DWIN32_PLATFORM_PSPC=400 -DWIN32 -UUNDER_CE -DUNDER_CE=420"

rm -rf "$OBJ"
mkdir -p "$LIB" "$OBJ/zlib" "$OBJ/zzip" "$OBJ/zzipmmapped" "$OBJ/geographiclib"

# zlib: build the standard static library directly. This avoids running a
# host-oriented configure script while keeping the exact upstream sources.
ZLIB_SRCS="adler32.c compress.c crc32.c deflate.c gzclose.c gzlib.c gzread.c gzwrite.c infback.c inffast.c inflate.c inftrees.c trees.c uncompr.c zutil.c"
for file in $ZLIB_SRCS; do
  obj="$OBJ/zlib/${file%.c}.o"
  "$CC" $COMMON -I"$SRC/zlib" -c "$SRC/zlib/$file" -o "$obj"
done
"$AR" rcs "$LIB/libz.a" "$OBJ"/zlib/*.o

# zziplib: use the Windows configuration prepared by prepare-deps.sh. Both
# archives are linked by current LK8000; they deliberately get separate fetch.o
# objects because that source belongs to both upstream targets.
ZZIP_FLAGS="$COMMON -DHAVE_CONFIG_H -I$DEPS/include -I$SRC/zlib -I$SRC/zziplib"
ZZIP_SRCS="dir.c err.c file.c info.c plugin.c stat.c write.c zip.c fetch.c"
for file in $ZZIP_SRCS; do
  obj="$OBJ/zzip/${file%.c}.o"
  "$CC" $ZZIP_FLAGS -c "$SRC/zziplib/zzip/$file" -o "$obj"
done
"$AR" rcs "$LIB/libzzip.a" "$OBJ"/zzip/*.o

ZZIPMMAPPED_SRCS="mmapped.c memdisk.c fetch.c"
for file in $ZZIPMMAPPED_SRCS; do
  obj="$OBJ/zzipmmapped/${file%.c}.o"
  "$CC" $ZZIP_FLAGS -c "$SRC/zziplib/zzip/$file" -o "$obj"
done
"$AR" rcs "$LIB/libzzipmmapped.a" "$OBJ"/zzipmmapped/*.o

# GeographicLib: LK8000 uses the normal static C++ library. Compile the exact
# source set declared by GeographicLib 2.5.1's src/CMakeLists.txt, but skip the
# host CMake feature probes; prepare-deps.sh supplies the WinCE Config.h.
GEO_FLAGS="$COMMON -std=gnu++20 -DGEOGRAPHICLIB_SHARED_LIB=0 -I$DEPS/include -I$SRC/geographiclib/include"
GEO_SRCS="Accumulator.cpp AlbersEqualArea.cpp AuxAngle.cpp AuxLatitude.cpp AzimuthalEquidistant.cpp CassiniSoldner.cpp CircularEngine.cpp DAuxLatitude.cpp DMS.cpp DST.cpp Ellipsoid.cpp EllipticFunction.cpp GARS.cpp GeoCoords.cpp Geocentric.cpp Geodesic.cpp GeodesicExact.cpp GeodesicLine.cpp GeodesicLineExact.cpp Geohash.cpp Geoid.cpp Georef.cpp Gnomonic.cpp GravityCircle.cpp GravityModel.cpp Intersect.cpp LambertConformalConic.cpp LocalCartesian.cpp MGRS.cpp MagneticCircle.cpp MagneticModel.cpp Math.cpp NormalGravity.cpp OSGB.cpp PolarStereographic.cpp PolygonArea.cpp Rhumb.cpp SphericalEngine.cpp TransverseMercator.cpp TransverseMercatorExact.cpp UTMUPS.cpp Utility.cpp"
for file in $GEO_SRCS; do
  obj="$OBJ/geographiclib/${file%.cpp}.o"
  "$CXX" $GEO_FLAGS -c "$SRC/geographiclib/src/$file" -o "$obj"
done
"$AR" rcs "$LIB/libGeographicLib.a" "$OBJ"/geographiclib/*.o

printf '%s\n' "$LIB/libz.a" "$LIB/libzzip.a" "$LIB/libzzipmmapped.a" "$LIB/libGeographicLib.a"
