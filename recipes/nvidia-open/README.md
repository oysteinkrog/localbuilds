NVIDIA open kernel modules 615.78.08 for linux-cachyos, with RM API lock relief, as linux-cachyos-nvidia-open-local.

It replaces linux-cachyos-nvidia-open (`provides=(NVIDIA-MODULE linux-cachyos-nvidia-open=<kernel>)`,
`conflicts=(linux-cachyos-nvidia-open ...)`). It depends on the exact linux-cachyos and
nvidia-utils versions it was built for, so pacman refuses a kernel or driver upgrade until the
recipe is rebuilt (or the stock package is put back). The build flags are copied from the
CachyOS linux-cachyos 7.3.0-4 PKGBUILD: clang, ld.lld, LLVM=1, modules compressed with zstd -19.
The modules are not signed; this kernel does not enforce module signatures.

| Fork branch | Commits | Why |
|---|---|---|
| `oystein/615.78.08-rmlock-yield` | 3 CachyOS patches from `CachyOS/kernel-patches` 7.3/misc/nvidia at 89bb22d (0001 DSC RC tables, 0002 Bigscreen Beyond WAR, 0004 sysfs config on 7.3), the same set the stock package applies | keep parity with linux-cachyos-nvidia-open 7.3.0-4 |
| | 1 local commit (3e65278) | KWin froze for 200 ms to 1.4 s while background GPU jobs (Wine MotionCatalyst, dotnet test hosts) freed their GPU objects under the global RM API write lock. See below. |

Upstream-Status: local-only.

## The change (NVreg_RmLockRelief, default 0x3)

- Bit 0: when an fd closes, its RM clients are freed through the existing deferred client
  free (as `RMClientListDeferredFree=1`), and that free may release the API lock after a 4 ms
  slice when another thread waits for it. Only clients that are already disabled are sliced.
- Bit 1: uncached and write-combined system memory is returned to the kernel from a worker
  thread after RM releases it, so `set_pages_array_wb` (a TLB flush on every CPU) runs outside
  the RM locks.

Explicit user frees of a live Device are not sliced; they are still one hold, now without the
page-attribute work. Measurements and the test plan: `/var/tmp/claude/rmprof/` on the office
desktop (2026-11-11).

Check it is active: `grep RmLockRelief /proc/driver/nvidia/params`.
Turn it off without a rebuild: `options nvidia NVreg_RmLockRelief=0` in `/etc/modprobe.d/`,
then reboot.

## Go back to the stock module

`sudo pacman -U /var/cache/pacman/pkg/linux-cachyos-nvidia-open-7.3.0-4-x86_64_v3.pkg.tar.zst`
(or `sudo pacman -S linux-cachyos-nvidia-open`), which removes this package, then reboot.

## When linux-cachyos or nvidia-utils moves

`localbuild check` warns. For a new kernel only, rebuild. For a new driver, cherry-pick the local
commit onto the new tag with the matching CachyOS patches, push a new branch,
`localbuild bump nvidia-open <commit>`, build, then install.
