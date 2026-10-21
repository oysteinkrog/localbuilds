Shader Wallpaper v4 for Plasma 6 (plugin id `online.knowmad.shaderwallpaper`), installed system-wide as a pacman package.

Upstream ships v4 only as source. The KDE Store copy is 3.0.3, the old QML version: from
System Settings its config page has no `wallpaper` object, so speed, play/pause and shader
choice are never saved (upstream issues #78 and #79, fixed in v4).

The package installs under `/usr`. A copy in `~/.local/share/plasma/wallpapers/` takes
precedence, so remove the KDE Store install. Restart plasmashell after installing.

Fork branch `oystein/local` in https://github.com/oysteinkrog/kde-shader-wallpaper is
upstream tag v4.1.1 with these commits on top:

| Commit | Why |
|---|---|
| plugin: keep C++ ownership of the shared QML singletons | the shared shader library object was deleted when one QML engine went away, so later wallpapers fell back to the default shader (seen as `toRelativeShaderPath is not a function`) |
| tweaks: keep vec3 values as strings in the ListModel | the Shader Tweaks panel lost vec3 and colour values in its ListModel and wrote `vec3(0.0, 0.0, 0.0)`, which turned colour-graded shaders black |

To move to a new upstream release, rebase `oystein/local` onto the new tag, push it, then
`localbuild bump shader-wallpaper <commit>`.
