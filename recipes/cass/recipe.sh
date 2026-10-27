# cass (coding_agent_session_search), built as the pacman package cass-local.
#
# Pinned to the fork branch local/v0.10.0-stream: local/v0.10.0-cuda plus streamed ingest
# of big Claude Code transcripts, built with --features cuda. See README. See
# ~/.dotfiles/docs/cass-setup.md before moving the pin.

UPSTREAM=https://github.com/Dicklesworthstone/coding_agent_session_search.git
FORK=https://github.com/oysteinkrog/coding_agent_session_search.git
MODE=fork
KIND=pkg
SRC=$HOME/work/cass-gpu
PIN=11ed976da15430871e3e025aec9988eaa6227cdb

lb_pkgver() {
    local ver
    ver=$(sed -n 's/^version = "\(.*\)"/\1/p' "$LB_WORK/src/Cargo.toml" | head -1)
    echo "${ver:-0}.g${LB_COMMIT:0:10}"
}

lb_check() {
    command -v nvcc >/dev/null || [ -x /opt/cuda/bin/nvcc ] || warn "cass: nvcc not found (pacman -S cuda)"
}
