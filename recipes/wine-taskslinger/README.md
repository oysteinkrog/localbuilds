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

To change it: commit on the branch in `~/src/wine`, `git push fork taskslinger/wine-11.18`,
`localbuild bump wine-taskslinger <commit>`, build, commit the recipe, install.

## Known issues

- GPU and disk graphs stay at 0, and the process list shows only Wine processes. Wine does not
  report Linux GPU or disk counters.
- Window frame, maximize and mouse offset: being worked on in a Wine change to how undecorated
  windows with a custom title bar are handled.

## Related

The Wine, DXVK and nvenc changes that Swing Catalyst needs are on `swing-catalyst/*` branches of
`InitialForce/wine`, `InitialForce/dxvk` and `InitialForce/nvenc`, built by the company monorepo.
