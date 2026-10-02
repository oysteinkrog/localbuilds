# cass (coding_agent_session_search), built as the pacman package cass-local.
#
# Pinned to an upstream commit pushed to my fork as branch main-latest; there are no local
# changes on it yet. The GPU embedding work is on the fork's gpu-embedding branch and is not
# built. See ~/.dotfiles/docs/cass-setup.md before moving the pin.

UPSTREAM=https://github.com/Dicklesworthstone/coding_agent_session_search.git
FORK=https://github.com/oysteinkrog/coding_agent_session_search.git
MODE=fork
KIND=pkg
SRC=$HOME/work/cass-gpu
PIN=4773d03ec30605c1c87522b581050b6748d65a2c

lb_pkgver() {
    local ver
    ver=$(sed -n 's/^version = "\(.*\)"/\1/p' "$LB_WORK/src/Cargo.toml" | head -1)
    echo "${ver:-0}.g${LB_COMMIT:0:10}"
}
