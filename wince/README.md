# LK8000 WinCE port

This directory contains the WinCE compatibility layer for building current LK8000 on legacy Pocket PC / Windows CE devices, initially targeting the HP iPAQ hx4700 (PXA270/XScale, Windows Mobile 2003 SE / CE 4.21).

## Design goals

1. Keep the delta from upstream LK8000 small and easy to rebase.
2. Do not downgrade upstream C++20 code. A modern Clang frontend should compile the same sources used by the other targets.
3. Keep WinCE-specific runtime, toolchain and platform glue under `wince/` wherever possible.
4. Reuse the `_WIN32_WCE` paths that still exist in upstream LK8000 instead of restoring the historical PPC2003/PNA code wholesale.
5. CI must separately verify:
   - that we can produce real ARM WinCE PE binaries;
   - that the modern C++20 frontend can generate XScale/ARM code;
   - eventually, that the resulting program actually starts under a Windows CE runtime/emulator.

## Current milestones

- [x] Branch `wince` starts directly from current upstream LK8000 master.
- [x] Add a reproducible CeGCC WinCE build probe in GitHub Actions.
- [x] Add a Clang C++20/XScale compiler probe.
- [ ] Link a Clang-produced object into a WinCE executable.
- [ ] Produce a Clang-built WinCE hello-world that runs on WM2003SE.
- [ ] Restore the minimal LK8000 WinCE platform glue on current master.
- [ ] Build current LK8000 for the hx4700.
- [ ] Run automated smoke tests in a WinCE emulator.
- [ ] Verify on physical hx4700 hardware.

## CI / emulation

Linux containers can build WinCE binaries, but WinCE itself is not a Linux container workload. The first CI stage uses the public ENLYZE CeGCC 9.3 ARM WinCE image as a known-good reference toolchain.

For runtime testing we are evaluating two routes:

- Microsoft Device Emulator with a WM2003SE ARM image on a Windows runner/self-hosted runner. This is closest to the historical Pocket PC runtime but depends on legacy Microsoft components and ROM/image licensing.
- A modern clean-room emulator/HLE such as CE Runtime Foundation or PocketHLE when it becomes suitable for unattended CI.

The physical hx4700 remains the final compatibility test because an emulator cannot reproduce every PXA270/driver quirk.

## Upstream maintenance

The WinCE branch should remain a short patch stack on top of `LK8000/LK8000:master`. Platform-neutral fixes belong upstream whenever possible. WinCE-specific changes should be isolated here and selected by the build system rather than spread through algorithmic code.
