# cass (coding_agent_session_search), built as the pacman package cass-local.
#
# Pinned to the fork branch local/ledger-folder-pinned: upstream 4773d03e (branch
# main-latest) plus a source-ledger fix and a local pin of the ingest contract. See README. The GPU embedding work is on the fork's gpu-embedding branch and is not
# built. See ~/.dotfiles/docs/cass-setup.md before moving the pin.

UPSTREAM=https://github.com/Dicklesworthstone/coding_agent_session_search.git
FORK=https://github.com/oysteinkrog/coding_agent_session_search.git
MODE=fork
KIND=pkg
SRC=$HOME/work/cass-gpu
PIN=2031aaa770f7d4948e8987bbdc0aed2e89062138

lb_pkgver() {
    local ver
    ver=$(sed -n 's/^version = "\(.*\)"/\1/p' "$LB_WORK/src/Cargo.toml" | head -1)
    echo "${ver:-0}.g${LB_COMMIT:0:10}"
}
