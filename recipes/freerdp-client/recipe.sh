# FreeRDP 3.32.2 clients with GPU H.264 decode and Opus audio, as the pacman package
# freerdp-client-local. It installs into /opt/freerdp-client, so the system freerdp
# (Remmina, KRDC, krfb) stays at the distro version.
#
# The fork branch oystein/client-hw is upstream tag 3.32.2 plus the commits listed in
# README.md. Its build options also differ from the distro package.

UPSTREAM=https://github.com/FreeRDP/FreeRDP.git
FORK=https://github.com/oysteinkrog/FreeRDP.git
MODE=fork
KIND=pkg
PIN=c4ba6f47b64ade4d0c1f4a080d90b7b2568b05c6
SRC=$HOME/src/freerdp   # share the freerdp recipe's clone

lb_pkgver() {
    echo "$(git -C "$LB_WORK/src" describe --tags --abbrev=0 | sed 's/^v//').g${LB_COMMIT:0:10}"
}
