# KRDP from master with the audio MR merged, as the pacman package krdp-local.
# It replaces the distro krdp package and links against the private KPipeWire 6.8
# from the kpipewire recipe (/opt/krdp-local).
#
# Changes live on the fork branch oystein/main (master plus MR 239 and the local fixes).

UPSTREAM=https://invent.kde.org/plasma/krdp.git
FORK=https://github.com/oysteinkrog/krdp.git
MODE=fork
KIND=pkg
PIN=d650f9d8a19f459134e712ff036716063b8e891a

lb_pkgver() {
    local ver
    ver=$(sed -n 's/^set(PROJECT_VERSION "\(.*\)")/\1/p' "$LB_WORK/src/CMakeLists.txt")
    echo "${ver:-0}.g${LB_COMMIT:0:10}"
}

# Links KDE Frameworks and Plasma libraries: an upgrade of those must give a new
# build ID, or localbuild reuses the old build (added for the Plasma 6.8.3 upgrade).
lb_system_inputs() {
    pacman -Q qt6-base kcoreaddons kconfig ki18n kcmutils kcrash kguiaddons kstatusnotifieritem kwindowsystem 2>&1 || true
}
