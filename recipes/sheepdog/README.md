sheepdog, the voice orchestrator for herdr-core agents, built from my fork with local fixes and voice page changes.

Fork: https://github.com/oysteinkrog/herdr-sheepdog, branch `oystein/main`, based on
upstream tag v0.1.30. Working checkout: `~/projects/herdr-sheepdog`. Installed tree:
`~/.local/share/sheepdog-local/current/sheepdog`. The dotfiles command `sheepdog-use`
picks which build `sheepdog.service` runs (`upstream`, `local` or `dev`).

| Change | Why | Upstream |
|---|---|---|
| herdrcore: ReadANSI from `hc attach --observe` | Without a coloured read, Claude Code's dim prompt suggestion counted as typed text and every voice prompt to that pane failed with "terminal has unsent input" | issue #679 |
