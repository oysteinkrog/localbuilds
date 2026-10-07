# KRDP from master with the audio MR merged, as the pacman package krdp-local.
# It replaces the distro krdp package and links against the private KPipeWire 6.8
# from the kpipewire recipe (/opt/krdp-local).
#
# Changes live on the fork branch oystein/main (master plus MR 239 and the local fixes).

UPSTREAM=https://invent.kde.org/plasma/krdp.git
FORK=https://github.com/oysteinkrog/krdp.git
MODE=fork
KIND=pkg
PIN=aa388dff885837328bc81fcf063c58a68a24a2d5

lb_pkgver() {
    local ver
    ver=$(sed -n 's/^set(PROJECT_VERSION "\(.*\)")/\1/p' "$LB_WORK/src/CMakeLists.txt")
    echo "${ver:-0}.g${LB_COMMIT:0:10}"
}
