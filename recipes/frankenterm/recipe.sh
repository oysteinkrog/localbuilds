# FrankenTerm fork, built as the pacman package frankenterm-local.
#
# Changes live as commits on the fork (branch oystein/linux-setup and topic branches off
# it). To ship a change: commit and push it in ~/src/frankenterm, then
# `localbuild bump frankenterm <commit>`, build, commit the recipe, install.

UPSTREAM=https://github.com/Dicklesworthstone/frankenterm.git
FORK=https://github.com/oysteinkrog/frankenterm.git
MODE=fork
KIND=pkg
PIN=4b2010cc24ecf3fff6d70deeb7dc887aa999a1aa

lb_pkgver() {
    local ver
    ver=$(sed -n '/^\[workspace.package\]/,/^\[/s/^version = "\(.*\)"/\1/p' "$LB_WORK/src/Cargo.toml" | head -1)
    echo "${ver:-0}.g${LB_COMMIT:0:10}"
}
