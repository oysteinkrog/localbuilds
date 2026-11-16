# Plasma Desktop 6.8.3 with a setting to turn off the lock screen wallpaper blur, as the
# pacman package plasma-desktop-local. It replaces the distro package.
#
# Changes live on the fork branch oystein/no-lockscreen-blur-6.8.3 (off v6.8.3). See
# README.md for how to move to a new Plasma release.

UPSTREAM=https://invent.kde.org/plasma/plasma-desktop.git
FORK=https://github.com/oysteinkrog/plasma-desktop.git
MODE=fork
KIND=pkg
PIN=9e92fd2298e761e44b95193f2e689592977085a9

lb_pkgver() {
    local base
    base=$(git -C "$LB_WORK/src" describe --tags --abbrev=0 | sed 's/^v//')
    echo "$base.r$(git -C "$LB_WORK/src" rev-list --count "v$base..HEAD").g${LB_COMMIT:0:10}"
}

lb_check() {
    case "$(pacman -Si plasma-desktop 2>/dev/null | awk '/^Version/{print $3; exit}')" in
        6.8.3-*|"") ;;
        *) warn "plasma-desktop: the repos moved past 6.8.3; rebase oystein/no-lockscreen-blur-6.8.3 (see recipes/plasma-desktop/README.md)" ;;
    esac
}

# Links KDE Frameworks and Plasma libraries: an upgrade of those must give a new
# build ID, or localbuild reuses the old build (added for the Plasma 6.8.3 upgrade).
lb_system_inputs() {
    pacman -Q qt6-base kcoreaddons kconfig ki18n kio kwindowsystem libplasma plasma-activities plasma-workspace libksysguard baloo 2>&1 || true
}
