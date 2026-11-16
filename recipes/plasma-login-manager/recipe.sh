# Plasma Login Manager 6.8.3 with a setting to turn off the wallpaper blur on the login
# screen, as the pacman package plasma-login-manager-local. It replaces the distro package.
#
# Changes live on the fork branch oystein/no-wallpaper-blur-6.8.3 (off v6.8.3). See README.md for
# how to move to a new Plasma release.

UPSTREAM=https://invent.kde.org/plasma/plasma-login-manager.git
FORK=https://github.com/oysteinkrog/plasma-login-manager.git
MODE=fork
KIND=pkg
PIN=70e8d31e623421fba459f4ba1558ec7784e155e4

lb_pkgver() {
    local base
    base=$(git -C "$LB_WORK/src" describe --tags --abbrev=0 | sed 's/^v//')
    echo "$base.r$(git -C "$LB_WORK/src" rev-list --count "v$base..HEAD").g${LB_COMMIT:0:10}"
}

lb_check() {
    case "$(pacman -Si plasma-login-manager 2>/dev/null | awk '/^Version/{print $3; exit}')" in
        6.8.3-*|"") ;;
        *) warn "plasma-login-manager: the repos moved past 6.8.3; rebase oystein/no-wallpaper-blur-6.8.3 (see recipes/plasma-login-manager/README.md)" ;;
    esac
}

# Links KDE Frameworks and Plasma libraries: an upgrade of those must give a new
# build ID, or localbuild reuses the old build (added for the Plasma 6.8.3 upgrade).
lb_system_inputs() {
    pacman -Q qt6-base kcoreaddons kconfig ki18n kio kwindowsystem layer-shell-qt libkscreen libplasma plasma-workspace 2>&1 || true
}
