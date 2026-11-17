NVIDIA open kernel modules 615.78.08 for linux-cachyos, with RM API lock relief, as linux-cachyos-nvidia-open-local.

This is the `nvidia-open` recipe moved back to driver 615.78.08. It builds the same package name,
`linux-cachyos-nvidia-open-local`, with version `615.78.08.r7.g<commit>`, so installing it replaces
the 620.70.06 build. Why: on 615.78.08 this desktop had no `nv_flip == NULL` flip timeouts in 6 days;
on 620.70.06 it had 21 (9 s desktop freezes). NVIDIA forum report of the same bug:
https://forums.developer.nvidia.com/t/bug-open-driver-version-620-70-06-rtx-4070-ti-kwin-wayland-6-8-3-crash-with-kernel-7-3-4-in-two-monitor-setup/389242

| Fork branch | Commits | Why |
|---|---|---|
| `oystein/615.78.08-rmlock-yield-v2` | 3 CachyOS patches (4772c84, 0cf9904, 689e986), the set the stock 615.78.08 package applied on 7.3 | parity with stock linux-cachyos-nvidia-open 7.3.0-4 |
| | 3e65278, 4167285, 565523d: NVreg_RmLockRelief | see `recipes/nvidia-open/README.md` |
| | 1746813: cherry-pick of f82504b (4 KiB pages for the client shadow fault buffer); the same patch id, applied cleanly | see `recipes/nvidia-open/README.md` |

The six commits up to 565523d are the old `oystein/615.78.08-rmlock-yield` branch, which is the
source the 620 port was cherry-picked from. `git range-diff` shows the 620 series differs only in one
context line in `nv-linux.h`, so the 615 and 620 builds carry the same change.

Upstream-Status: local-only.

## Install

The package depends on `nvidia-utils=615.78.08`, so the userspace must move back in the same pacman
transaction. `localbuild install nvidia-open-615` alone fails that dependency. The steps, the package
files and the rollback are in the install plan kept outside this repo. In short: one
`sudo pacman -U` with this package plus nvidia-utils, lib32-nvidia-utils, opencl-nvidia,
lib32-opencl-nvidia, nvidia-settings and libxnvctrl 615.78.08 from the pacman cache, and
linux-cachyos-lts-nvidia-open must be removed or moved back too, since it pins nvidia-utils.
Then reboot.

Do not run a pacman `-Syu` while this is installed: it would move the userspace back to 620.
Add the NVIDIA packages to `IgnorePkg` first.
