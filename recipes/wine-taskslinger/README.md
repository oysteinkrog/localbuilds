# Wine 11.18 for TaskSlinger, as a private copy

TaskSlinger 0.9.2 is a Windows task manager. This recipe builds the fork branch
[`taskslinger/wine-11.18`](https://github.com/oysteinkrog/wine/tree/taskslinger/wine-11.18) of
`oysteinkrog/wine` and installs it to `~/.local/share/taskslinger-wine/<build id>/`, with
`current` pointing at the one in use. The launcher `~/.local/bin/taskslinger` (dotfiles) runs it
with the prefix `~/.local/share/wineprefixes/taskslinger`.

The system Wine must be the release the branch is based on (`BASE` in `recipe.sh`), because the
build copies it and replaces only the modules the branch changes.

## Commits on the branch

| Module | What it fixes |
|---|---|
| user32 | Adds `GetProcessUIContextInformation` (semi-stub, reports a desktop app) |
| kernelbase, kernel32 | Adds `GetApplicationUserModelId` (returns `APPMODEL_ERROR_NO_APPLICATION`) |
| win32u, winex11 | A window that draws its own title bar keeps its whole client area visible, and the window manager draws only a border. Fixes the mouse offset under the KDE frame and the double title bar |
| win32u | Moves the maximize position and size an app returns from `WM_GETMINMAXINFO` to the monitor the window is on, as Windows does. Fixes maximize on any monitor other than the primary |

The launcher sets `Decorated=Y` (window manager frame on), which these two commits rely on.

To change it: commit on the branch in `~/src/wine`, `git push fork taskslinger/wine-11.18`,
`localbuild bump wine-taskslinger <commit>`, build, commit the recipe, install.

## Known issues

- GPU and disk graphs stay at 0, and the process list shows only Wine processes. Wine does not
  report Linux GPU or disk counters.

## Related

The Wine, DXVK and nvenc changes that Swing Catalyst needs are on `swing-catalyst/*` branches of
`InitialForce/wine`, `InitialForce/dxvk` and `InitialForce/nvenc`, built by the company monorepo.
