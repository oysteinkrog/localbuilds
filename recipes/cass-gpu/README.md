# cass with CUDA embedding, my fork, as the pacman package cass-gpu-local

This is the same program as the `cass` recipe, built from the fork branch
`gpu-cuda-native` with `--features cuda`. The semantic embedder (all-MiniLM-L6-v2) then runs
large batches on the NVIDIA GPU through candle. Lexical indexing and search are unchanged.

The package conflicts with `cass-local`, since both install `/usr/bin/cass`. Install one or
the other.

## Fork branches

| Branch | What it is |
|---|---|
| `gpu-cuda-native` | `main-latest` plus the `cuda` feature: `src/search/cuda_embedder.rs`, `src/search/cuda_minibert.rs` |

## What changes in a cuda build

- The MiniLM embedder uses the F32 model variant on the CPU instead of the int8 one. The
  CPU F32 variant embeds search queries and is the fallback.
- Batches of 8 or more texts go to the GPU. At start, cass compares the GPU output for 9
  fixed texts with the CPU F32 output and uses the GPU only if no value differs by more
  than 1e-4.
- The vectors get their own vector-space revision, so an index built by a default build
  is not reused. Switching builds means a full semantic re-embed.
- Default embed batches are 1,024 rows (default build: 128).

Environment: `CASS_EMBED_DEVICE=cpu` turns the GPU off. `CASS_CUDA_MIN_BATCH` (default 8)
and `CASS_CUDA_TOKEN_BUDGET` (default 32768 padded tokens per GPU pass) tune batching.

## Build needs

- `cuda` (nvcc, cuBLAS, cuRAND). The binary links `libcuda`, `libcublas` and `libcurand`
  and does not start without them.
- `CUDA_COMPUTE_CAP` defaults to 120 (RTX 50 series) in the PKGBUILD. Set it for other
  cards.

## Notes

- Same clone as the `cass` recipe: `~/work/cass-gpu`.
- `cass upgrade` must not replace this build, as for `cass`.
- Setup and recovery: `~/.dotfiles/docs/cass-setup.md`.
