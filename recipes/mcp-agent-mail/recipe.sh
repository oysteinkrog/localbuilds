# mcp_agent_mail_rust (the agent-mail server and the am CLI), built as the pacman package
# mcp-agent-mail-local.
#
# Pinned to the fork branch local/v0.3.38, which is upstream tag v0.3.38 with no local
# changes. See README before moving the pin: some releases migrate the mailbox database.

UPSTREAM=https://github.com/Dicklesworthstone/mcp_agent_mail_rust.git
FORK=https://github.com/oysteinkrog/mcp_agent_mail_rust.git
MODE=fork
KIND=pkg
PIN=f9c68b4e642e60ea07818ab9d1b32a02b2777997

lb_pkgver() {
    local ver
    ver=$(sed -n '/^\[workspace.package\]/,/^\[/s/^version = "\(.*\)"/\1/p' "$LB_WORK/src/Cargo.toml" | head -1)
    echo "${ver:-0}.g${LB_COMMIT:0:10}"
}
