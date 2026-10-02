# KPipeWire from Plasma 6.8 beta 2, as the pacman package kpipewire-krdp-local.
# It installs into /opt/krdp-local, so only krdp-local loads it and the system
# kpipewire stays at the distro version.
#
# Fork branch oystein/krdp-private points at the upstream tag v6.7.91.
# Drop this recipe once Plasma 6.8 is installed: see README.md.

UPSTREAM=https://invent.kde.org/plasma/kpipewire.git
FORK=https://github.com/oysteinkrog/kpipewire.git
MODE=fork
KIND=pkg
PIN=319637f9bd5d93ce57bbcdb1b46482d128561847

lb_pkgver() {
    echo "$(git -C "$LB_WORK/src" describe --tags --abbrev=0 | sed 's/^v//').g${LB_COMMIT:0:10}"
}
