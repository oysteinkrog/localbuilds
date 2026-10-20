# Shader Wallpaper v4 (C++ rewrite), as the pacman package plasma-wallpaper-shader-local.
# The KDE Store only has 3.0.3, whose settings page cannot save speed or shader choice.
# One local fix in the series, see README.md.

UPSTREAM=https://github.com/y4my4my4m/kde-shader-wallpaper.git
MODE=patches
KIND=pkg
PIN=v4.1.1

lb_pkgver() {
    echo "${PIN#v}"
}
