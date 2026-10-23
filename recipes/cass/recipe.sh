# cass (coding_agent_session_search), built as the pacman package cass-local.
#
# Pinned to the fork branch local/v0.10.0-cuda: upstream release v0.10.0 plus two ledger
# fixes and the CUDA embedding commits, built with --features cuda. See README. See
# ~/.dotfiles/docs/cass-setup.md before moving the pin.

UPSTREAM=https://github.com/Dicklesworthstone/coding_agent_session_search.git
FORK=https://github.com/oysteinkrog/coding_agent_session_search.git
MODE=fork
KIND=pkg
SRC=$HOME/work/cass-gpu
PIN=54ed6b4f9a43ca12a80381b032659d12c83f1852

lb_pkgver() {
    local ver
    ver=$(sed -n 's/^version = "\(.*\)"/\1/p' "$LB_WORK/src/Cargo.toml" | head -1)
    echo "${ver:-0}.g${LB_COMMIT:0:10}"
}

lb_check() {
    command -v nvcc >/dev/null || [ -x /opt/cuda/bin/nvcc ] || warn "cass: nvcc not found (pacman -S cuda)"
}
