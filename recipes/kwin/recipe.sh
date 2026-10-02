# KWin 6.7.5 with resizable virtual monitors backported from 6.8, as the pacman
# package kwin-local. It replaces the distro kwin package.
#
# Changes live on the fork branch oystein/resizable-virtual-monitors (off v6.7.5).
# Drop this recipe once Plasma 6.8 is installed: see README.md.

UPSTREAM=https://invent.kde.org/plasma/kwin.git
FORK=https://github.com/oysteinkrog/kwin.git
MODE=fork
KIND=pkg
PIN=250efe954de41b22ed36adfb5de5f3c1ce729532

lb_pkgver() {
    local base
    base=$(git -C "$LB_WORK/src" describe --tags --abbrev=0 | sed 's/^v//')
    echo "$base.r$(git -C "$LB_WORK/src" rev-list --count "v$base..HEAD").g${LB_COMMIT:0:10}"
}

lb_check() {
    local have; have=$(pacman -Q kwin-local 2>/dev/null | awk '{print $2}')
    case "$(pacman -Si kwin 2>/dev/null | awk '/^Version/{print $3; exit}')" in
        6.7.*|"") ;;
        *) warn "kwin: the repos now ship kwin 6.8 or newer; uninstall kwin-local (see recipes/kwin/README.md)" ;;
    esac
}
