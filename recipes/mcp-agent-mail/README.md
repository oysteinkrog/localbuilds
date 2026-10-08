# MCP Agent Mail server and am CLI, upstream release, as the pacman package mcp-agent-mail-local

Upstream is `Dicklesworthstone/mcp_agent_mail_rust`; the fork is
`oysteinkrog/mcp_agent_mail_rust`. The clone lives at `~/src/mcp-agent-mail`.

The package installs `/usr/bin/am` and `/usr/bin/mcp-agent-mail`. `~/.local/bin/am` and
`~/.local/bin/mcp-agent-mail` are symlinks to them, because the systemd user unit and older
scripts use the `~/.local/bin` path. The other names upstream's installer creates
(`agent-mail`, `agentmail`, `mcp_agent_mail`, `mcpagentmail`) link to `mcp-agent-mail`.

## Fork branches

| Branch | What it is |
|---|---|
| `local/v0.3.38` | upstream tag v0.3.38 (`f9c68b4e`), no local changes. This is what is built. |

## Before moving the pin

Read the upstream release notes for every version in between. Some releases migrate the
mailbox database on the first server start (v0.3.37 adds schema v30 and v31). Stop the
server, back up `storage.sqlite3` with the C `sqlite3` tool (`.backup`), then install and
start. The server and the CLI must be the same version: an older `am` must not open a
migrated mailbox.
