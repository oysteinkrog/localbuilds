Powerdevil 6.8.1 with two local brightness fixes, as powerdevil-local.

It replaces the distro powerdevil package (`provides=(powerdevil=6.8.1)`, `conflicts=(powerdevil)`).
The build steps and dependencies are copied from the Arch powerdevil 6.8.1 PKGBUILD.
It goes together with `ddcutil-local` (recipes/ddcutil), which fixes the libddcutil side.

All changes are on the fork branch `oystein/powerdevil-6.8.1-local`, off `v6.8.1`:

| Commits | Why | Upstream-Status |
|---|---|---|
| 1 brightness commit | a display object that is added or replaced (monitor found again, powerdevil restart) never sent a dimming value to KWin, so an idle-dim ratio of 0.3 could stay on the output: the monitor looked much darker than the slider said and the slider seemed dead | local-only |
| 2 ddcutil commits | a DDC/CI monitor that lost brightness control (sleep, remote session, failed writes) only came back on a later libddcutil event, which often never came, or came while the monitor was still waking. Now powerdevil redetects after 2 s, 5 s, 15 s, 30 s, 60 s, 120 s, then every 5 minutes, until each lost monitor is back | local-only |

Symptoms without the fixes: `kscreen-doctor -o` shows "Brightness control: unsupported" for a
DDC/CI monitor that still answers `ddcutil --bus N getvcp 10`, or "dimming to 30%" with no idle
dimming active. The fixed build logs `Lost DDC/CI brightness control for display ...` and
`Display ... is back` in the powerdevil journal.

## Go back to the distro powerdevil

`sudo pacman -S powerdevil` removes powerdevil-local, then `systemctl --user restart plasma-powerdevil`.

## When the repos move past 6.8.1

`localbuild check` warns. Cherry-pick the commits onto the new tag, push as
`oystein/powerdevil-<new>-local`, update the PKGBUILD from the Arch one,
`localbuild bump powerdevil <commit>`, build and install.
