# sheepdog fork (kccarlos/herdr-sheepdog), the voice orchestrator for herdr-core agents,
# with my changes on branch oystein/main of the fork.
#
# To ship a change: commit and push it in ~/projects/herdr-sheepdog, then
# `localbuild bump sheepdog <commit>`, `localbuild build sheepdog`, commit the recipe,
# `localbuild install sheepdog`, and `sheepdog-use local` (dotfiles) to point
# sheepdog.service at it. For quick tries skip all that: `make build` in the checkout and
# `sheepdog-use dev`.
#
# KIND=tree: a single static Go binary, installed side by side next to the upstream
# release (which its own installer keeps in ~/.local/share/sheepdog/bin), so switching
# back is one command.

UPSTREAM=https://github.com/kccarlos/herdr-sheepdog.git
FORK=https://github.com/oysteinkrog/herdr-sheepdog.git
MODE=fork
KIND=tree
PIN=ca10ea85b38802d289e25b455a6c958f56f50ad8
SRC=$HOME/projects/herdr-sheepdog   # my forks live in ~/projects

lb_install_root() { echo "$HOME/.local/share/sheepdog-local"; }

lb_build() {
    local ver
    ver=$(git -C src describe --tags --match 'v*' --always 2>/dev/null || echo dev)
    mkdir -p out
    (cd src && go build -trimpath \
        -ldflags "-X 'main.version=${ver}-oystein' -X 'main.commit=${LB_COMMIT:0:8}' -X 'main.date=$(date -u +%Y-%m-%dT%H:%M:%SZ)'" \
        -o ../out/sheepdog ./cmd/sheepdog)
}
