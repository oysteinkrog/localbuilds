# KWin 6.8.2 with local fixes (maximized layout on output changes, brightness
# device match for overridden EDIDs), as the pacman package kwin-local. It
# replaces the distro kwin package.
#
# Changes live on the fork branch oystein/kwin-6.8.2-local (off v6.8.2).

UPSTREAM=https://invent.kde.org/plasma/kwin.git
FORK=https://github.com/oysteinkrog/kwin.git
MODE=fork
KIND=pkg
PIN=64db21467bdcd8f27d768d2b07443ec966f0245b

lb_pkgver() {
    local base
    base=$(git -C "$LB_WORK/src" describe --tags --abbrev=0 | sed 's/^v//')
    echo "$base.r$(git -C "$LB_WORK/src" rev-list --count "v$base..HEAD").g${LB_COMMIT:0:10}"
}

lb_check() {
    local have; have=$(pacman -Q kwin-local 2>/dev/null | awk '{print $2}')
    case "$(pacman -Si kwin 2>/dev/null | awk '/^Version/{print $3; exit}')" in
        6.8.2-*|"") ;;
        *) warn "kwin: the repos moved past kwin 6.8.2; rebase oystein/kwin-6.8.2-local and rebuild kwin-local before the next login (see recipes/kwin/README.md)" ;;
    esac
}

# kwin links Qt private API and Plasma libraries, so any change there needs a rebuild
# even with the same pin (a qt6-base update on 2026-10-11 left no desktop at the next login).
lb_system_inputs() {
    pacman -Q qt6-base qt6-declarative kconfig kcoreaddons kwindowsystem \
        kdecoration kglobalacceld kscreenlocker kwayland libplasma plasma-activities \
        plasma-workspace 2>&1 || true
}
