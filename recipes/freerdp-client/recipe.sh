# FreeRDP 3.32.2 clients with GPU H.264 decode and Opus audio, as the pacman package
# freerdp-client-local. It installs into /opt/freerdp-client, so the system freerdp
# (Remmina, KRDC, krfb) stays at the distro version.
#
# No source changes: the fork branch oystein/client-hw is upstream tag 3.32.2. Only the
# build options differ from the distro package.

UPSTREAM=https://github.com/FreeRDP/FreeRDP.git
FORK=https://github.com/oysteinkrog/FreeRDP.git
MODE=fork
KIND=pkg
PIN=97eff6ddfbbfaa8e42a126d362686bd001ff8bdc
SRC=$HOME/src/freerdp   # share the freerdp recipe's clone

lb_pkgver() {
    echo "$(git -C "$LB_WORK/src" describe --tags --abbrev=0 | sed 's/^v//').g${LB_COMMIT:0:10}"
}
