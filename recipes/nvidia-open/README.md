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
| | 2 local commits (3e65278, 4167285) | KWin froze for 200 ms to 1.4 s while background GPU jobs (Wine MotionCatalyst, dotnet test hosts) freed their GPU objects under the global RM API write lock. See below. |

Upstream-Status: local-only.

## The change (NVreg_RmLockRelief, default 0x2)

- Bit 0 (opt-in): when an fd closes, its RM clients are freed through the existing deferred client
  free (as `RMClientListDeferredFree=1`), and that free may release the API lock after a 4 ms
  slice when another thread waits for it. Only clients that are already disabled are sliced.
- Bit 1 (default on): uncached and write-combined system memory is returned to the kernel
  from a worker thread (`nv_free_q`) after RM releases it, so `set_pages_array_wb` (a TLB
  flush on every CPU) runs outside the RM locks. At most 4096 frees wait; the queue is drained
  before suspend and at module unload.

Explicit user frees of a live Device are not sliced; they are still one hold, now without the
page-attribute work. The serial GSP FREE RPCs (about 0.3 to 0.7 ms each, 220 per MotionCatalyst
exit) stay inside the hold: shortening that safely needs a teardown reservation protocol in
resserv, which this change does not attempt. Measurements and the test plan: `/var/tmp/claude/rmprof/` on the office
desktop (2026-11-11).

Check it is active: `grep RmLockRelief /proc/driver/nvidia/params`.
Turn it off without a rebuild: see "Go back to the stock module".

## Test plan

Needs a reboot, which ends the desktop session: only with Oystein's yes.

1. Baseline (stock module, already recorded 2026-11-11): count KWin waits on the RM API lock
   over 60 min with background jobs running. `/var/tmp/claude/rmlock/rmhold.bt` prints a
   `KWINWAIT` line for every KWin main-thread read wait of 200 ms or more; set the KWin pid in
   the script first (`pgrep -x kwin_wayland`). Stock: 13 per hour, 183 to 1400 ms.
2. Install: `localbuild install nvidia-open`. pacman takes a snapper pre/post snapshot, removes
   linux-cachyos-nvidia-open and rebuilds the initramfs (the nvidia modules are in it, see
   `/etc/mkinitcpio.conf.d/10-chwd.conf`). Check `pacman -Q linux-cachyos-nvidia-open-local`.
3. Reboot. Then check:
   - `modinfo -F version nvidia` is 615.78.08 and `grep RmLockRelief /proc/driver/nvidia/params`
     shows `2`.
   - `journalctl -k -b | grep -iE 'NVRM|Xid|nvidia'` has no new errors compared with the last
     stock boot (`journalctl -k -b -1`), in particular no `NVRM: ... assert`, Xid, RPC timeout
     or `Not allowed: nv_kthread_q_schedule_q_item`.
   - `pgrep -a nv_free_q` shows the worker thread.
4. Run the usual background load (headless MotionCatalyst jobs and Wine dotnet test runs) for
   60 min with `rmhold.bt` running. Pass: KWin waits of 200 ms or more drop clearly below 13 per
   hour and the MotionCatalyst exit holds (229 to 290 ms stock) shrink by about 45 to 70 ms.
   Expect remaining waits: the serial GSP RPCs are untouched.
5. Soak for a day: suspend and resume once, start and quit MotionCatalyst, a CUDA job, a game or
   video. Watch `free -g` and `/proc/meminfo` for memory that is not returned (the worker
   should keep up), and dmesg as in step 3.
6. Optional second stage, bit 0: `options nvidia NVreg_RmLockRelief=3` in
   `/etc/modprobe.d/nvidia-rmlock.conf`, rebuild the initramfs (`sudo mkinitcpio -P`), reboot,
   repeat steps 3 to 5. Look for exit-path holds (`rm_cleanup_file_private`) in `rmhold.bt`
   output; they should stop exceeding a few slices of 4 ms.

Risks: this is a kernel module. A bug can hang or crash the whole machine, corrupt memory or
leave the GPU unusable until reboot. Bit 1 changes when pages return to the kernel, not whether;
the allocation is already unreferenced. Bit 0 turns on NVIDIA's deferred client free, which NVIDIA
ships off by default. The modules are unsigned (fine on this kernel). Kernel and driver
upgrades are blocked by the exact-version depends until this is rebuilt or removed.

## Go back to the stock module

Without a rebuild: `options nvidia NVreg_RmLockRelief=0` in `/etc/modprobe.d/`, `sudo mkinitcpio -P`,
reboot. This gives stock behaviour from the patched binary.

Stock binary: `sudo pacman -U /var/cache/pacman/pkg/linux-cachyos-nvidia-open-7.3.0-4-x86_64_v3.pkg.tar.zst`
(or `sudo pacman -S linux-cachyos-nvidia-open`). It removes this package and rebuilds the
initramfs; then reboot.

If the desktop does not come back: pick the pre-install snapper snapshot in the Limine boot menu
(limine-snapper-sync lists them), boot it, then `sudo pacman -U` the stock package as above
from that system, or roll back with `snapper` from a TTY.

## When linux-cachyos or nvidia-utils moves

`localbuild check` warns. For a new kernel only, rebuild. For a new driver, cherry-pick the local
commit onto the new tag with the matching CachyOS patches, push a new branch,
`localbuild bump nvidia-open <commit>`, build, then install.
