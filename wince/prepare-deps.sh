#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
DEPS="$ROOT/out/wince-deps"

mkdir -p "$DEPS/src" "$DEPS/include/GeographicLib" "$DEPS/include/zzip"

if [ ! -d "$DEPS/src/zlib/.git" ]; then
  rm -rf "$DEPS/src/zlib"
  git clone --depth 1 --branch v1.3.1 \
    https://github.com/madler/zlib.git \
    "$DEPS/src/zlib"
fi

if [ ! -d "$DEPS/src/geographiclib/.git" ]; then
  rm -rf "$DEPS/src/geographiclib"
  git clone --depth 1 --branch v2.5.1 \
    https://github.com/geographiclib/geographiclib.git \
    "$DEPS/src/geographiclib"
fi

if [ ! -d "$DEPS/src/zziplib/.git" ]; then
  rm -rf "$DEPS/src/zziplib"
  git clone --depth 1 --branch v0.13.81 \
    https://github.com/brunotl/zziplib.git \
    "$DEPS/src/zziplib"
fi

# GeographicLib generates Config.h during its normal configure/CMake build.
# The current object-level bring-up only needs the public headers, so provide
# the exact release version/configuration here. The full static WinCE library
# will be built by build-deps.sh for the link milestone.
cat > "$DEPS/include/GeographicLib/Config.h" <<'EOF'
#pragma once
#define GEOGRAPHICLIB_VERSION_STRING "2.5.1"
#define GEOGRAPHICLIB_VERSION_MAJOR 2
#define GEOGRAPHICLIB_VERSION_MINOR 5
#define GEOGRAPHICLIB_VERSION_PATCH 1
#define GEOGRAPHICLIB_DATA "\\Application Data\\GeographicLib"
#define GEOGRAPHICLIB_HAVE_LONG_DOUBLE 1
#define GEOGRAPHICLIB_WORDS_BIGENDIAN 0
#define GEOGRAPHICLIB_PRECISION 2
#ifndef GEOGRAPHICLIB_SHARED_LIB
#define GEOGRAPHICLIB_SHARED_LIB 0
#endif
EOF

# zziplib's source headers include a generated zzip/_config.h. Start from the
# checked-in Windows configuration, then tailor it to cegcc/Pocket PC 2003.
# cegcc's <direct.h> is only a forwarding shim and Pocket PC 2003 does not
# provide the desktop CRT behind it. Its string.h does provide strcasecmp(),
# so tell zzip to use that declaration instead of its older non-const fallback.
# LK8000 supplies its own file I/O plugin to zzip, while the memory-disk path
# does not need Win32 mmap support.
cp "$DEPS/src/zziplib/zzip/_msvc.h" "$DEPS/include/zzip/_config.h"
cat >> "$DEPS/include/zzip/_config.h" <<'EOF'

/* Pocket PC 2003 / cegcc target overrides. */
#undef ZZIP_HAVE_DIRECT_H
#undef ZZIP_HAVE_WINBASE_H
#ifndef ZZIP_HAVE_STRCASECMP
#define ZZIP_HAVE_STRCASECMP 1
#endif
EOF

printf '%s\n' "$DEPS"
