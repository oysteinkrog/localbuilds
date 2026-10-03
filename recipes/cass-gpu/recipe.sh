# cass with CUDA batch embedding, built as the pacman package cass-gpu-local.
#
# Same clone and fork as the cass recipe, but pinned to the fork branch gpu-cuda-native and
# built with --features cuda. It conflicts with cass-local: install one or the other. See
# README.md before installing; a cuda build needs a full semantic re-embed.

UPSTREAM=https://github.com/Dicklesworthstone/coding_agent_session_search.git
FORK=https://github.com/oysteinkrog/coding_agent_session_search.git
MODE=fork
KIND=pkg
SRC=$HOME/work/cass-gpu
PIN=b6cada65439b68021cf3b6505abfe07025bd854c

lb_pkgver() {
    local ver
    ver=$(sed -n 's/^version = "\(.*\)"/\1/p' "$LB_WORK/src/Cargo.toml" | head -1)
    echo "${ver:-0}.g${LB_COMMIT:0:10}"
}

lb_check() {
    command -v nvcc >/dev/null || [ -x /opt/cuda/bin/nvcc ] || warn "cass-gpu: nvcc not found (pacman -S cuda)"
}
