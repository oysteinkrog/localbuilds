Shader Wallpaper v4 for Plasma 6 (plugin id `online.knowmad.shaderwallpaper`), installed system-wide as a pacman package.

Upstream ships v4 only as source. The KDE Store copy is 3.0.3, the old QML version: from
System Settings its config page has no `wallpaper` object, so speed, play/pause and shader
choice are never saved (upstream issues #78 and #79, fixed in v4).

The package installs under `/usr`. A copy in `~/.local/share/plasma/wallpapers/` takes
precedence, so remove the KDE Store install. Restart plasmashell after installing.

No local patches.
