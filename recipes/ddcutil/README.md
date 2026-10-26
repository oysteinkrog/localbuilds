ddcutil 3.0.2 with a fix for monitors stuck as disconnected, as ddcutil-local.

It replaces the distro ddcutil package (`provides=(ddcutil=3.0.2)`, `conflicts=(ddcutil)`).
KDE powerdevil uses libddcutil for DDC/CI brightness, so this is what fixes the slider.
The build steps and dependencies are copied from the Arch ddcutil 3.0.2 PKGBUILD.

| Fork branch | Commit | Why |
|---|---|---|
| `oystein/no-sticky-disconnect` | 1 commit on v3.0.2 | after an I/O error, libddcutil checks the bus with two EDID reads 100 ms apart and, when both fail, marked the display disconnected for good. A monitor entering or leaving DPMS sleep can fail both (nvidia, seen 2026-10-23 on one of three Dell U2412M). No udev event follows, so powerdevil lost brightness control for that monitor until it restarted. The fix returns the error for that call only. |

Upstream-Status: local-only. Upstream master (checked 2026-10-23) still marks the display.

Symptom without the fix: the powerdevil journal shows
`Checking EDID failed after 2 tries (B)` and then `disconnected set for Display_Ref[Disconnected: ...]`
with `ddca_open_display2 -3020` on every brightness change.

## Go back to the distro ddcutil

`sudo pacman -S ddcutil` removes ddcutil-local, then `systemctl --user restart plasma-powerdevil`.

## When the repos move past 3.0.2

`localbuild check` warns. Cherry-pick the commit onto the new tag, push it as a new branch,
`localbuild bump ddcutil <commit>`, build and install. Drop the recipe if upstream fixes it.
