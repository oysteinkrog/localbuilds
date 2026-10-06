# cass agent session search, my fork, as the pacman package cass-local

Upstream is `Dicklesworthstone/coding_agent_session_search`; my fork is
`oysteinkrog/coding_agent_session_search`. The clone lives at `~/work/cass-gpu` (older
scripts and docs use that path). The package installs `/usr/bin/cass`; `~/.local/bin/cass`
and `~/.local/bin/cass-gpu` are symlinks to it for scripts that use the old path.

## Fork branches

| Branch | What it is |
|---|---|
| `main-latest` | upstream 4773d03e, the base of the build, no local changes |
| `local/ledger-folder-pinned` | what is built: `main-latest` plus the two commits below |
| `ledger-parent-dir-no-sidecars` | the ledger fix alone on `main-latest`, without the pin |
| `pr/ledger-folder-dependency` | the ledger fix on upstream master, for an upstream report |
| `gpu-embedding` | old fastembed/ONNX DirectML and CUDA work, based on a May commit; superseded |
| `gpu-cuda-native` | candle CUDA embedding for the current pure-Rust embedder; built by the `cass-gpu` recipe |

## Local commits

1. **Ledger folder dependency.** The source ingest ledger recorded each source's parent
   folder as a dependency, so a new file in a folder re-parsed every unchanged file in it
   (thousands of Claude Code subagent transcripts each night). The Claude Code and Codex
   connectors read no sidecars, so the folder is no longer a dependency for them. Other
   connectors keep it. Upstream-Status: report drafted, not yet filed.
2. **Contract pin.** `build.rs` emits the contract of the 4773d03e build
   (`c01f9a85...`) instead of the hash of `src/`, so this build reuses the existing
   ledger instead of re-parsing the whole corpus. Parsers are unchanged, so that is safe
   here. Drop this commit when the base moves to a newer upstream commit or any parser
   changes. Local only.

Check after a build: `strings <binary> | grep -o 'c01f9a85[0-9a-f]*'` prints the full
contract.

## Notes

- `cass upgrade` must not replace this build. With `~/.local/bin/cass` a symlink into
  `/usr/bin`, an upgrade that writes there fails instead of overwriting it.
- Setup and recovery: `~/.dotfiles/docs/cass-setup.md`.
