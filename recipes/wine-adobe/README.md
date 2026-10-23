# Wine 11.20 for Adobe apps (Lightroom Classic), as a private copy

This recipe builds the fork branch
[`adobe/wine-11.20`](https://github.com/oysteinkrog/wine/tree/adobe/wine-11.20) of
`oysteinkrog/wine` and installs it to `~/.local/share/adobe-wine/<build id>/`, with `current`
pointing at the one in use. It is meant for Adobe Lightroom Classic and Creative Cloud.

The system Wine must be the release the branch is based on (`BASE` in `recipe.sh`), because the
build copies it and replaces only the modules the branch changes.

## Commits on the branch

The first four are the commits of `taskslinger/wine-11.18` (recipe `wine-taskslinger`), picked
onto wine-11.20 without conflicts.

| Module | What it fixes |
|---|---|
| user32 | Adds `GetProcessUIContextInformation` (semi-stub, reports a desktop app) |
| kernelbase, kernel32 | Adds `GetApplicationUserModelId` (returns `APPMODEL_ERROR_NO_APPLICATION`) |
| win32u, winex11 | A window that draws its own title bar keeps its whole client area visible, and the window manager draws only a border. Lightroom Classic draws its own title bar, so this fixes its mouse offset under the KDE frame and the double title bar |
| win32u | Moves the maximize position and size an app returns from `WM_GETMINMAXINFO` to the monitor the window is on, as Windows does. Fixes maximize on any monitor other than the primary |
| d2d1 | `PushLayer` clips to the layer's geometric mask through a stencil buffer. Lightroom's histogram and thumbnail grid fills need it. Opt-in: set `D2D_LAYER_MASK=1` |

The window commits rely on `Decorated=Y` (window manager frame on).

wine-11.20 has its own fix for the same window problem (upstream `6cfa941df3`, "Display the full
client area if it extends into the window decorations"). That fix shows the whole window with no
frame at all. The local commit runs first and keeps the client area inside the visible rect, so
the upstream check no longer fires for these windows and the KDE border stays.

The d2d1 commit comes from `resources/patches/wine/d2d1-lightroom.patch` in
lightroom-classic-on-linux (written against wine-11.10) and replaces the drop-in
`d2d1-patched.dll`. That patch also registered `CLSID_D2D1ColorManagement` as a passthrough;
wine-11.20 has its own Color Management effect stub, so that part is left out.

To change it: commit on the branch in `~/src/wine`, `git push fork adobe/wine-11.20`,
`localbuild bump wine-adobe <commit>`, build, commit the recipe, install.
