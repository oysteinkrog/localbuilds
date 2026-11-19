sheepdog, the voice orchestrator for herdr-core agents, built from my fork with local fixes and voice page changes.

Fork: https://github.com/oysteinkrog/herdr-sheepdog, branch `oystein/main`, based on
upstream tag v0.1.30. Working checkout: `~/projects/herdr-sheepdog`. Installed tree:
`~/.local/share/sheepdog-local/current/sheepdog`. The dotfiles command `sheepdog-use`
picks which build `sheepdog.service` runs (`upstream`, `local` or `dev`).

| Change | Why | Upstream |
|---|---|---|
| herdrcore: ReadANSI from `hc attach --observe` | Without a coloured read, Claude Code's dim prompt suggestion counted as typed text and every voice prompt to that pane failed with "terminal has unsent input" | issue #679 |
| voice page: transcript lines no longer end in "undefined" | the closing fragment of a line has no text field | local |
| voice page: controls on top, stats folded, mic only, GPT-Live model and voice picker, cost line (`/api/voice/openai`, `/api/spend`) | Oystein's layout and cost asks, 2026-11-19 | local |
