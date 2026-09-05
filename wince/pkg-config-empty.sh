#!/bin/sh
# The current upstream Makefile probes desktop/Linux pkg-config dependencies
# unconditionally. WinCE historically supplied its own compatibility/runtime
# implementations instead. This shim lets the overlay build reach the real
# compiler errors without modifying the upstream Makefile just to bypass those
# host-library probes.

case "$1" in
  --exists)
    exit 0
    ;;
  --cflags|--libs)
    exit 0
    ;;
  --modversion)
    echo 0
    exit 0
    ;;
  --print-provides)
    shift
    echo "${1:-wince-stub} = 0"
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
