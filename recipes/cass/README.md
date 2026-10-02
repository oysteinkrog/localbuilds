# cass agent session search, my fork, as the pacman package cass-local

Upstream is `Dicklesworthstone/coding_agent_session_search`; my fork is
`oysteinkrog/coding_agent_session_search`. The clone lives at `~/work/cass-gpu` (older
scripts and docs use that path). The package installs `/usr/bin/cass`; `~/.local/bin/cass`
and `~/.local/bin/cass-gpu` are symlinks to it for scripts that use the old path.

## Fork branches

| Branch | What it is |
|---|---|
| `main-latest` | the pinned upstream commit, no local changes |
| `gpu-embedding` | DirectML and CUDA embedding work, not built |

## Notes

- `cass upgrade` must not replace this build. With `~/.local/bin/cass` a symlink into
  `/usr/bin`, an upgrade that writes there fails instead of overwriting it.
- Setup and recovery: `~/.dotfiles/docs/cass-setup.md`.
