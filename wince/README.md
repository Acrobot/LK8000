# LK8000 WinCE port

This directory contains the WinCE compatibility layer for building current LK8000 on legacy Pocket PC / Windows CE devices, initially targeting the HP iPAQ hx4700 (PXA270/XScale, Windows Mobile 2003 SE / CE 4.21).

## Design goals

1. Keep the delta from upstream LK8000 small and easy to rebase.
2. Do not downgrade upstream C++20 code. Current LK8000 sources should remain source-compatible with upstream.
3. Keep WinCE-specific runtime, toolchain and platform glue under `wince/` wherever possible.
4. Reuse the `_WIN32_WCE` paths that still exist in upstream LK8000 instead of restoring the historical PPC2003/PNA code wholesale.
5. Prefer command-line/build overlays over edits to algorithmic upstream source files.
6. CI must separately verify compile-time, PE/runtime and physical-device compatibility.

## Toolchain

The primary toolchain is the modern CeGCC fork published by Salman Javed / ENLYZE. Its ARM Docker image contains GCC 14.2.0 and binutils 2.43.1 targeting `arm-mingw32ce`.

This has already built and linked a real XScale WinCE PE executable using C++20 `std::vector`, `std::wstring`, `std::span` and concepts. `objdump` identifies the output as `pei-arm-wince-little` with imports from `COREDLL.dll`.

Clang is retained as a fallback/compiler-backend experiment, but a custom Clang linker/runtime is no longer the primary plan unless CeGCC exposes a blocker.

## Current milestones

- [x] Branch `wince` starts directly from current upstream LK8000 master.
- [x] Reproducible CeGCC 14.2 ARM WinCE build in GitHub Actions.
- [x] C++20 + XScale WinCE executable links successfully.
- [x] PE format/import validation in CI.
- [x] Add a headless C++20 runtime binary suitable for unattended emulation.
- [x] Add PocketHLE/Unicorn runtime smoke-test job.
- [x] Add a zero-delta wrapper for compiling current upstream objects as WinCE.
- [ ] Get the representative current-master object probe fully green.
- [ ] Build current LK8000 for the hx4700.
- [ ] Execute the full LK8000 binary in an emulator.
- [ ] Verify on physical hx4700 hardware.

## Building current upstream source

`build-current.sh` deliberately does not edit the upstream Makefile. It supplies the WinCE target configuration as GNU Make command-line overrides:

```sh
sh wince/build-current.sh Bin/WINCE/xcs/Screen/GDI/Init.o V=2
```

During bring-up, CI compiles representative GDI, event, OS, POCO and serial-port objects. Once those are clean the same wrapper will be expanded toward the complete executable.

The small `pkg-config-empty.sh` shim is temporary. Current upstream probes several desktop/Linux libraries unconditionally; the shim lets the WinCE compile probe get past those host dependency checks so the actual target-specific incompatibilities are visible. Any dependency that current LK8000 genuinely needs at runtime must eventually be built for WinCE or replaced by a WinCE-compatible implementation.

## CI / emulation

Linux containers can cross-compile WinCE binaries, but WinCE itself is not a Linux container workload.

The current CI tiers are:

1. CeGCC 14.2 builds real ARM/XScale WinCE PE binaries and validates their headers/imports.
2. PocketHLE uses Unicorn to execute a headless WinCE ARM C++20 smoke binary on a Linux GitHub runner.
3. A fuller Windows Mobile 2003 SE emulator may later be used for OS-level integration tests where licensing and automation permit it.
4. The physical hx4700 remains the final compatibility test because an HLE/emulator cannot reproduce every PXA270, display, CF, serial and driver quirk.

PocketHLE is intentionally only a smoke test: it is a clean-room high-level implementation of WinCE APIs, not the actual Microsoft CE 4.21 kernel.

## Upstream maintenance

The `wince` branch should remain a short overlay on top of `LK8000/LK8000:master`. Platform-neutral fixes belong upstream whenever possible. WinCE-specific changes should be isolated under `wince/` or in very small build-selection patches rather than spread through navigation, task or rendering algorithms.
