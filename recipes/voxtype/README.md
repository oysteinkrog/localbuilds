voxtype push-to-talk dictation with CUDA ONNX engines, engine_isolation and a live preview overlay, as the pacman package voxtype-cuda-local.

## Why

- The AUR package `voxtype-bin` ships a CUDA build, but `voxtype setup gpu` refuses to
  enable it on CPUs without AVX-512. The binary itself runs fine on AVX2; the check is the
  only blocker.
- Upstream unloads ONNX models after each transcription (`on_demand_loading`), but the
  daemon keeps the CUDA context, cuDNN, cuBLAS and ONNX Runtime arenas: about 825 MB of
  RSS after one Cohere run, against 25 MB before. The fork adds `engine_isolation = true`,
  which runs ONNX engines in a `transcribe-worker` process that exits after each
  transcription, as `[whisper] gpu_isolation` already does for Whisper.
- Live preview, modelled on Claude Code's dictation: `live_preview_model` makes that
  worker stream a Parakeet transcript to the OSD while you speak, and the engine model
  (Cohere) types the final text once on release.

## Layout

- Binaries: `/usr/lib/voxtype-local/{voxtype,voxtype-osd,voxtype-osd-gtk4}`. The daemon
  starts the `voxtype-osd` next to its own executable, so the patched overlay ships here.
  Beside them are symlinks to the ONNX Runtime CUDA 13
  libraries that `voxtype-bin` installs in `/usr/lib/voxtype/cuda-13/`.
- The systemd user unit runs this binary directly, so `voxtype setup` resetting
  `/usr/bin/voxtype` does not change the daemon.

## CPU target

The package is built for x86-64-v3 (AVX2, FMA, BMI2), not for the build host's CPU:
the PKGBUILD sets `RUSTFLAGS` itself, because a `makepkg.conf.d/rust.conf` with
`target-cpu=native` would tie the binary to the machine that built it. One build then
installs on every machine with an x86-64-v3 CPU (Intel Haswell and newer, AMD Zen and
newer). Check with `objdump -d /usr/lib/voxtype-local/voxtype | grep -c zmm`, which
should print 0. ONNX Runtime is a separate library and picks its own CPU code at run
time.

## Live preview model

The preview runs `parakeet-unified-en-0.6b` on the CPU. The fp32 download is 2.4 GB and
pushed a recording's worker RSS to 4.2 GB, so the config points at an int8 copy (881 MB,
peak RSS 2.7 GB, about 2.0 GB held while recording). Make it once per machine after
`voxtype setup --download --model parakeet-unified-en-0.6b`:

```sh
M=~/.local/share/voxtype/models
heavy-build uv run --no-project --with onnxruntime --with onnx python -I \
    quantize-parakeet-unified.py $M/parakeet-unified-en-0.6b $M/parakeet-unified-en-0.6b-int8
```

It takes about 20 s and peaks at 5.6 GB RSS.

## Fork branch

`voxtype-onnx-isolation` on oysteinkrog/voxtype: upstream tag v1.1.1 plus three commits.

| Commit | What |
|---|---|
| Add engine_isolation | Run ONNX engines in a short-lived transcribe-worker subprocess |
| Live preview | Stream Parakeet text to the OSD, type the engine model's final on release |
| Live preview: join chunk text | Fix the running text and the streaming context sizes |

When moving to a new upstream tag, rebase the commits and check that the ORT version in
`voxtype-bin` still matches the symlinks in the PKGBUILD.
