#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

for patch in wince/patches/*.patch; do
  [ -f "$patch" ] || continue

  if git apply --reverse --check "$patch" >/dev/null 2>&1; then
    echo "already applied: $patch"
    continue
  fi

  echo "applying: $patch"
  if ! git apply --check "$patch"; then
    echo "WinCE patch no longer applies cleanly to the current upstream tree: $patch" >&2
    echo "This is intentional: refresh the small compatibility patch instead of silently carrying a stale fork." >&2
    exit 1
  fi
  git apply "$patch"
done
