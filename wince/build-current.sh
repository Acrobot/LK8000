#!/bin/sh
set -eu

# Build current upstream LK8000 sources for the hx4700 without modifying the
# upstream Makefile. All target-specific values are command-line overrides,
# which have higher precedence than ordinary Makefile assignments.
#
# During bring-up this can also build a single object, e.g.:
#   ./wince/build-current.sh Bin/WINCE/xcs/Screen/GDI/Init.o V=2

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

CPPFLAGS_WINCE="\
-ICommon/Header/mingw32compat \
-ICommon/Header/mingw32compat/zlib \
-ICommon/Header/mingw32compat/WinCE \
-ICommon/Header \
-ICommon/Source \
-ICommon/Source/Library \
-ICommon/Source/xcs \
-Ilib/doctest \
-Ilib/json/include \
-DUSE_GDI \
-DUNICODE -D_UNICODE -DWIN32 \
-D_WIN32_WCE=0x0420 -D_WIN32_IE=0x0420 \
-DWIN32_PLATFORM_PSPC=400 -DMSOFT \
-DWIN32_RESOURCE \
-DPOCO_NO_UNWINDOWS -DPOCO_STATIC \
-DLK_TARGET_WINCE=1 \
-DNDEBUG \
-fsigned-char"

exec make \
  TARGET=WINCE \
  CONFIG_WIN32=y \
  CONFIG_PC=n \
  CONFIG_WINE=n \
  CONFIG_LINUX=n \
  TCPATH=arm-mingw32ce- \
  CE_MAJOR=4 \
  CE_MINOR=20 \
  CE_PLATFORM=400 \
  MCPU=-mcpu=xscale \
  PKG_CONFIG="$ROOT/wince/pkg-config-empty.sh" \
  WIN32_RESOURCE=y \
  CPPFLAGS="$CPPFLAGS_WINCE" \
  CXXFLAGS="-std=gnu++20 -O2 -g0" \
  CFLAGS="-O2 -g0" \
  TARGET_ARCH="-mwin32 -mcpu=xscale" \
  LDFLAGS="-Wl,--major-subsystem-version=4 -Wl,--minor-subsystem-version=20" \
  LDLIBS="-Wl,-Bstatic -lstdc++ -latomic -Wl,-Bdynamic -lcommctrl -lole32 -loleaut32 -luuid -lws2 -laygshell -limgdecmp" \
  "$@"
