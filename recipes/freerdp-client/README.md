FreeRDP 3.32.2 clients with GPU H.264 decode (VA-API) and Opus audio, installed in /opt/freerdp-client.

The distro FreeRDP is built without `WITH_FFMPEG_HWACCEL` and without `WITH_OPUS`, so its
clients decode H.264 and AVC444 on the CPU and cannot take Opus audio from the server. This
copy turns both on, plus `WITH_SOXR` for better audio resampling. It is client only
(`xfreerdp3`, `sdl-freerdp3` and the client channels) and lives in its own prefix with an
rpath to `/opt/freerdp-client/lib`, so Remmina, KRDC and krfb keep the distro libraries.

| Fork branch | Commit | Why |
|---|---|---|
| `oystein/client-hw` | upstream tag 3.32.2 | matches the distro FreeRDP |
| `oystein/client-hw` | dsp/ffmpeg: open the Opus encoder in low-delay mode with 10 ms frames | libopus defaults to 20 ms frames in "audio" mode (about 26.5 ms extra delay); this sets `application=lowdelay` and `frame_duration=10` for the microphone. `FREERDP_OPUS_APPLICATION` and `FREERDP_OPUS_FRAME_MS` override them |

## Hardware decode

With `WITH_FFMPEG_HWACCEL` the FFmpeg H.264 decoder uses VA-API on `/dev/dri/renderD128`
by default. On NVIDIA this needs `libva-nvidia-driver` (NVDEC behind VA-API); `vainfo`
must list `VAProfileH264High : VAEntrypointVLD`. Overrides, read at connect:
`FREERDP_HWCTX_TYPE` (an FFmpeg hwdevice type such as `vaapi` or `cuda`) and
`FREERDP_HWCTX_DEVICE`. Upstream marks the option experimental.

## Keeping it in step with the distro

When the distro moves to a new FreeRDP 3 release, push the new tag commit to
`oystein/client-hw`, `localbuild bump freerdp-client <commit>` and rebuild.
