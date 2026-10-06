# KRDP from master with the audio MR merged, as the pacman package krdp-local.
# It replaces the distro krdp package and links against the private KPipeWire 6.8
# from the kpipewire recipe (/opt/krdp-local).
#
# Changes live on the fork branch oystein/audio-and-resize (master plus MR 239).

UPSTREAM=https://invent.kde.org/plasma/krdp.git
FORK=https://github.com/oysteinkrog/krdp.git
MODE=fork
KIND=pkg
PIN=b584554cfb512716deaedea42763c014cb12748d

lb_pkgver() {
    local ver
    ver=$(sed -n 's/^set(PROJECT_VERSION "\(.*\)")/\1/p' "$LB_WORK/src/CMakeLists.txt")
    echo "${ver:-0}.g${LB_COMMIT:0:10}"
}
