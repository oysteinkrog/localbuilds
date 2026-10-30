# Plasma Login Manager 6.8.2 with a setting to turn off the wallpaper blur on the login
# screen, as the pacman package plasma-login-manager-local. It replaces the distro package.
#
# Changes live on the fork branch oystein/no-wallpaper-blur-6.8.2 (off v6.8.2). See README.md for
# how to move to a new Plasma release.

UPSTREAM=https://invent.kde.org/plasma/plasma-login-manager.git
FORK=https://github.com/oysteinkrog/plasma-login-manager.git
MODE=fork
KIND=pkg
PIN=607dcfcc0aa0da608eb50f8691e482da707edae9

lb_pkgver() {
    local base
    base=$(git -C "$LB_WORK/src" describe --tags --abbrev=0 | sed 's/^v//')
    echo "$base.r$(git -C "$LB_WORK/src" rev-list --count "v$base..HEAD").g${LB_COMMIT:0:10}"
}

lb_check() {
    case "$(pacman -Si plasma-login-manager 2>/dev/null | awk '/^Version/{print $3; exit}')" in
        6.8.2-*|"") ;;
        *) warn "plasma-login-manager: the repos moved past 6.8.2; rebase oystein/no-wallpaper-blur-6.8.2 (see recipes/plasma-login-manager/README.md)" ;;
    esac
}
