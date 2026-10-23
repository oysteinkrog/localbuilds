# cass agent session search, my fork with CUDA embedding, as the pacman package cass-local

Upstream is `Dicklesworthstone/coding_agent_session_search`; my fork is
`oysteinkrog/coding_agent_session_search`. The clone lives at `~/work/cass-gpu` (older
scripts and docs use that path). The package installs `/usr/bin/cass`; `~/.local/bin/cass`
and `~/.local/bin/cass-gpu` are symlinks to it for scripts that use the old path.

## Fork branches

| Branch | What it is |
|---|---|
| `local/v0.10.0-cuda` | what is built: upstream tag v0.10.0 plus the six commits below |
| `local/v0.10.0` | v0.10.0 plus the two ledger fixes only, without CUDA |
| `local/ledger-folder-pinned` | the old build: upstream 4773d03e plus the ledger fixes and the contract pin |
| `main-latest` | upstream 4773d03e, the old base |
| `pr/ledger-folder-dependency` | the folder fix on upstream master, for upstream issue #512 |
| `gpu-cuda-native` | the CUDA commits on the old base; the `cass-gpu` recipe built it |
| `gpu-embedding` | old fastembed/ONNX DirectML work, based on a May commit; superseded |

Track release tags, not upstream `main`. For a new release, rebase the local commits onto
the tag on a new `local/<tag>-cuda` branch, push it to the fork and run
`localbuild bump cass <commit>`.

## Local commits

1. **Ledger folder dependency.** The source ingest ledger recorded each source's parent
   folder as a dependency, so a new file in a folder re-parsed every unchanged file in it
   (thousands of Claude Code subagent transcripts each night). The Claude Code and Codex
   connectors read no sidecars, so the folder is no longer a dependency for them. Other
   connectors keep it. Upstream-Status: fixed upstream after v0.10.0 (#512, commits
   8dbf2ffb and 997e4630). Drop this commit at the next release.
2. **Ledger ignores the device number.** The ledger compared each source's device
   number, and btrfs gives a subvolume mount a new one at some boots, so after a
   reboot every unchanged source looked changed and was parsed again. The device is
   no longer recorded, and a saved entry's device is ignored when matching. Size,
   mtime, inode and ctime still catch a real change. Upstream-Status: reported as #536.
3. **CUDA embedding (four commits).** With `--features cuda` the MiniLM embedder
   (all-MiniLM-L6-v2) runs large batches on the NVIDIA GPU through candle. Lexical
   indexing and search are unchanged. Upstream-Status: local only; upstream will not take
   CUDA in the binary (#481).

The contract pin of the old build (`build.rs` emitting the 4773d03e contract) is
dropped. The first `cass index` on v0.10.0 rebuilds the lexical index once anyway.

## What changes in a cuda build

- The MiniLM embedder uses the F32 model variant on the CPU instead of the int8 one. The
  CPU F32 variant embeds search queries and is the fallback.
- Batches of 8 or more texts go to the GPU. At start, cass compares the GPU output for 9
  fixed texts with the CPU F32 output and uses the GPU only if no value differs by more
  than 1e-4. Any CUDA failure falls back to the CPU.
- The vectors get their own vector-space revision, so an index built by a CPU-only build
  is not reused, and a CPU-only build rejects this one rather than mix them.
- Default embed batches are 1,024 rows (CPU-only build: 128).

Environment: `CASS_EMBED_DEVICE=cpu` turns the GPU off. `CASS_CUDA_MIN_BATCH` (default 8)
and `CASS_CUDA_TOKEN_BUDGET` (default 32768 padded tokens per GPU pass) tune batching.

## Build needs

- `cuda` (nvcc, cuBLAS, cuRAND). The binary links `libcuda`, `libcublas` and `libcurand`
  and does not start without them.
- `CUDA_COMPUTE_CAP` defaults to 120 (RTX 50 series) in the PKGBUILD. Set it for other
  cards.

## Notes

- `cass upgrade` must not replace this build. With `~/.local/bin/cass` a symlink into
  `/usr/bin`, an upgrade that writes there fails instead of overwriting it.
- Setup and recovery: `~/.dotfiles/docs/cass-setup.md`.
