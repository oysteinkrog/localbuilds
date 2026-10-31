# Plasma Desktop 6.8.2 with a setting to turn off the lock screen wallpaper blur, as the
# pacman package plasma-desktop-local. It replaces the distro package.
#
# Changes live on the fork branch oystein/no-lockscreen-blur-6.8.2 (off v6.8.2). See
# README.md for how to move to a new Plasma release.

UPSTREAM=https://invent.kde.org/plasma/plasma-desktop.git
FORK=https://github.com/oysteinkrog/plasma-desktop.git
MODE=fork
KIND=pkg
PIN=5151a9d84d43b497dcade88b8d8d04d082e6c51c

lb_pkgver() {
    local base
    base=$(git -C "$LB_WORK/src" describe --tags --abbrev=0 | sed 's/^v//')
    echo "$base.r$(git -C "$LB_WORK/src" rev-list --count "v$base..HEAD").g${LB_COMMIT:0:10}"
}

lb_check() {
    case "$(pacman -Si plasma-desktop 2>/dev/null | awk '/^Version/{print $3; exit}')" in
        6.8.2-*|"") ;;
        *) warn "plasma-desktop: the repos moved past 6.8.2; rebase oystein/no-lockscreen-blur-6.8.2 (see recipes/plasma-desktop/README.md)" ;;
    esac
}
