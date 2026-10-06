# FreeRDP 3.31.1 with encoder controls, as the pacman package freerdp-krdp-local.
# It installs into /opt/krdp-local, so only krdp-local loads it and the system
# freerdp (used by the clients and krfb) stays at the distro version.
#
# Changes live on the fork branch oystein/krdp-codecs (tag 3.31.1 plus local commits).

UPSTREAM=https://github.com/FreeRDP/FreeRDP.git
FORK=https://github.com/oysteinkrog/FreeRDP.git
MODE=fork
KIND=pkg
PIN=985a2dbff9ffa883340579b580c6f278b9a49204

lb_pkgver() {
    echo "$(git -C "$LB_WORK/src" describe --tags --abbrev=0 | sed 's/^v//').g${LB_COMMIT:0:10}"
}
