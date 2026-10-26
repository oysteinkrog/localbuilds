# Powerdevil 6.8.1 with local fixes (DDC/CI monitors that lose brightness control are
# found again, dimming is applied to newly added displays), as the pacman package
# powerdevil-local. It replaces the distro powerdevil package.
#
# Changes live on the fork branch oystein/powerdevil-6.8.1-local (off v6.8.1).

UPSTREAM=https://invent.kde.org/plasma/powerdevil.git
FORK=https://github.com/oysteinkrog/powerdevil.git
MODE=fork
KIND=pkg
PIN=06ae14d4a214b4d1ed575f060a9ffd5543415bcf

lb_pkgver() {
    local base
    base=$(git -C "$LB_WORK/src" describe --tags --abbrev=0 | sed 's/^v//')
    echo "$base.r$(git -C "$LB_WORK/src" rev-list --count "v$base..HEAD").g${LB_COMMIT:0:10}"
}

lb_check() {
    case "$(pacman -Si powerdevil 2>/dev/null | awk '/^Version/{print $3; exit}')" in
        6.8.1-*|"") ;;
        *) warn "powerdevil: the repos moved past powerdevil 6.8.1; rebase oystein/powerdevil-6.8.1-local (see recipes/powerdevil/README.md)" ;;
    esac
}
