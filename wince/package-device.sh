#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
EXE=${1:-"$ROOT/LK8000-WINCE.exe"}
OUT=${2:-"$ROOT/out/hx4700-device-test"}

if [ ! -s "$EXE" ]; then
  echo "WinCE executable not found: $EXE" >&2
  exit 2
fi

rm -rf "$OUT"
mkdir -p "$OUT"

# Start from the upstream runtime distribution tree. -L deliberately
# dereferences repository symlinks because FAT/WinCE media cannot use them.
cp -RL "$ROOT/Common/Distribution/LK8000" "$OUT/LK8000"

# Upstream's install packaging also materialises current language assets.
mkdir -p "$OUT/LK8000/_Language"
cp "$ROOT/Common/Data/Language/language.json" "$OUT/LK8000/_Language/"
cp "$ROOT/Common/Data/Language/Translations/"*.json "$OUT/LK8000/_Language/"
cp "$ROOT/Common/Data/Language/DEFAULT_MENU.TXT" "$OUT/LK8000/_System/DEFAULT_MENU.TXT"

# Use the historical executable name expected by Pocket PC users while keeping
# this build identifiable in BUILD-WINCE.txt.
cp "$EXE" "$OUT/LK8000/LK8000-PPC2003.exe"

COMMIT=$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo unknown)
UPSTREAM=$(git -C "$ROOT" rev-parse HEAD^ 2>/dev/null || echo unknown)
EXE_SHA=$(sha256sum "$OUT/LK8000/LK8000-PPC2003.exe" | awk '{print $1}')

cat > "$OUT/BUILD-WINCE.txt" <<EOF
LK8000 WinCE / hx4700 experimental device-test build

Repository: Acrobot/LK8000
Branch: wince
Commit: $COMMIT
Parent/upstream base at build time: $UPSTREAM
Target: Windows CE 4.20 / Pocket PC 2003 / ARM XScale
Compiler: arm-mingw32ce GCC 14.2 toolchain
Executable: LK8000/LK8000-PPC2003.exe
Executable SHA256: $EXE_SHA

This package is generated from current LK8000 source plus the WinCE overlay.
It is an experimental compatibility build, not an official LK8000 release.
EOF

cat > "$OUT/TEST-HX4700.txt" <<'EOF'
LK8000 current-master WinCE — HP iPAQ hx4700 test checklist
============================================================

IMPORTANT
---------
This is an experimental port intended for bench testing. Do NOT use this build
as the only navigation source in flight and do not rely on the bundled DEMO
airspace/map/waypoints for real flying.

Use a separate SD card for this test. Do not overwrite the inherited WinPilot
card or reset/flash the iPAQ for this test.

INSTALL
-------
1. Extract/copy the entire LK8000 directory to the root of a clean SD card.
   The resulting path should look like:
       <SD card>\LK8000\LK8000-PPC2003.exe
2. Put the SD card in the iPAQ's SD slot. Leave the CompactFlash slot free.
3. On the iPAQ, open File Explorer and run LK8000-PPC2003.exe from the LK8000
   directory.

PHASE 1 — SAFE STARTUP / SIM
----------------------------
Do this without the CF GPS inserted.

[ ] LK8000 starts without a system error dialog.
[ ] Main screen renders correctly at 480x640.
[ ] Touch input works across the screen, including corners.
[ ] Menus/dialogs open and text is readable.
[ ] Orientation/rotation, if changed, does not crash the program.
[ ] DEMO map/terrain can be selected and rendered.
[ ] SIM mode runs for at least 10 minutes without a crash.
[ ] Memory does not obviously leak until the device becomes unresponsive.
[ ] Exit LK8000 normally.
[ ] Start it again and verify configuration can be saved/read.

PHASE 2 — DEVICE BEHAVIOUR
--------------------------
[ ] Backlight remains usable while LK8000 is active.
[ ] Suspend/resume once and verify LK8000 recovers.
[ ] Suspend/resume several times and verify it remains stable.
[ ] Hardware buttons do not cause a crash.
[ ] Sound failure, if any, does not prevent navigation/UI operation.

PHASE 3 — CF GPS / NMEA
-----------------------
Only after Phase 1 and 2 work.

1. Exit LK8000.
2. Insert the CoPilot D157N CompactFlash GPS receiver.
3. Start LK8000 outdoors with a clear view of the sky.
4. Configure a serial device manually. The WinCE port opens ports as COMn:.
5. Try the port/baud values from the old WinPilot/CoPilot configuration first.
   If those are unavailable, 4800 baud is a reasonable first test but is not
   confirmed for the D157N.

[ ] Serial port opens.
[ ] NMEA sentences are received.
[ ] GPS fix is obtained outdoors.
[ ] Position/altitude/speed update continuously.
[ ] Leave it running for 20–30 minutes.
[ ] Suspend/resume with GPS attached and verify recovery.

IF SOMETHING FAILS
------------------
Record:
- exact step,
- exact on-screen error text,
- whether the device hangs or LK8000 exits,
- whether it happens before or after inserting the CF GPS,
- COM port and baud if relevant,
- a photo of the screen if rendering/UI is wrong.

Do not factory-reset or flash the iPAQ as part of troubleshooting this package.
EOF

printf '%s\n' "Device test package created at: $OUT"
find "$OUT" -maxdepth 2 -type f | sort | head -80
