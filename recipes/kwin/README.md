KWin 6.8.1 with two local fixes, as kwin-local.

It replaces the distro kwin package (`provides=(kwin=6.8.1)`, `conflicts=(kwin)`).
The build steps and dependencies are copied from the Arch kwin 6.8.1 PKGBUILD.

All changes are on the fork branch `oystein/kwin-6.8.1-local`, off `v6.8.1`:

| Commits | Why | Upstream-Status |
|---|---|---|
| 3 placementtracker and xdgshellwindow commits | maximized windows keep the right size when monitors are turned on or off or change mode (remote mode switches) | local-only; KWin master still had both bugs on 2026-10-18 |
| 1 workspace commit | a DDC/CI brightness device still finds its output when the output's EDID is overridden (edid-add-mode on the RDP monitor): falls back to vendor, product code and serial when no exact EDID match exists | local-only; 6.8 still matches with `startsWith` on the raw EDID |

Without the workspace commit the monitor with the EDID override gets no brightness slider.

The 6.7.5 branches (`oystein/resizable-virtual-monitors`, `oystein/maximized-output-change`,
`oystein/brightness-edid-fallback`) are history. The resizable virtual monitors backport
(KWin MR 7932) is part of 6.8.

## When the repos move past 6.8.1

kwin-local must match the installed Plasma. A Plasma upgrade with an old kwin-local can
leave the next login without a working desktop, and the old version no longer builds
(on 2026-10-23 the 6.7.5 tree failed on a missing `kglobalaccel_interface.h`).
`localbuild check` warns when the repos ship a different kwin. Then:

1. Add a worktree at the new tag, cherry-pick the commits from `oystein/kwin-<old>-local`,
   push as `oystein/kwin-<new>-local`.
2. Update `PKGBUILD` from the Arch kwin PKGBUILD (depends, `provides`), and `recipe.sh`.
3. `localbuild bump kwin <commit>`, build, install, then log out and in.

## Go back to the distro kwin

`sudo pacman -S kwin` removes kwin-local and installs the repo package. Log out and in.
This loses both fixes.
