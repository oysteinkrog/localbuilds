# Shader Wallpaper v4 (C++ rewrite), as the pacman package plasma-wallpaper-shader-local.
# The KDE Store only has 3.0.3, whose settings page cannot save speed or shader choice.
#
# Fork branch oystein/local is upstream tag v4.1.1 plus the fixes in README.md.

UPSTREAM=https://github.com/y4my4my4m/kde-shader-wallpaper.git
FORK=https://github.com/oysteinkrog/kde-shader-wallpaper.git
MODE=fork
KIND=pkg
PIN=f5c5585e0a63f74d15768f9329ed5f1cb9d233a7

lb_pkgver() {
    echo "$(git -C "$LB_WORK/src" describe --tags --abbrev=0 | sed 's/^v//').g${LB_COMMIT:0:10}"
}
