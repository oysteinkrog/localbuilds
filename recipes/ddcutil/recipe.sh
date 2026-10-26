# ddcutil 3.0.2 (command line tool and libddcutil) with a fix that keeps a monitor
# usable after a failed I2C alive check, as the pacman package ddcutil-local.
# It replaces the distro ddcutil package; KDE powerdevil loads libddcutil from it.
#
# Changes live on the fork branch oystein/no-sticky-disconnect (off v3.0.2).

UPSTREAM=https://github.com/rockowitz/ddcutil.git
FORK=https://github.com/oysteinkrog/ddcutil.git
MODE=fork
KIND=pkg
PIN=7295d600581aab757eaca9308d76c7b9dc2a94cd

lb_pkgver() {
    local base
    base=$(git -C "$LB_WORK/src" describe --tags --abbrev=0 | sed 's/^v//')
    echo "$base.r$(git -C "$LB_WORK/src" rev-list --count "v$base..HEAD").g${LB_COMMIT:0:10}"
}

lb_check() {
    case "$(pacman -Si ddcutil 2>/dev/null | awk '/^Version/{print $3; exit}')" in
        3.0.2-*|"") ;;
        *) warn "ddcutil: the repos moved past 3.0.2; rebase oystein/no-sticky-disconnect (see recipes/ddcutil/README.md)" ;;
    esac
}
