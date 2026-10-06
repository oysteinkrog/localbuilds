FreeRDP 3.31.1 server libraries with encoder controls, installed in /opt/krdp-local for krdp-local only.

KRDP gets its RemoteFX and AVC444 encoders from FreeRDP, and upstream FreeRDP hard-codes
how they work: RemoteFX always uses the MS default quality, which makes text soft, and
the H.264 encoder is either VAAPI (which NVIDIA cannot do) or libx264 at the slow
"medium" preset. This copy adds the controls KRDP needs. It is server only (no clients,
no shadow server, no proxy) and lives in its own prefix, so the system `freerdp` used by
the clients and krfb stays at the distro version. Its libraries carry an rpath to
`/opt/krdp-local/lib`, and so does krdp-local.

| Fork branch | Commit | Why |
|---|---|---|
| `oystein/krdp-codecs` | upstream tag 3.31.1 | matches the distro FreeRDP |
| `oystein/krdp-codecs` | codec: let the caller set the RemoteFX quantization values | the fixed default quantization blurs text; KRDP makes it a setting |
| `oystein/krdp-codecs` | codec/h264: let the caller pick the FFmpeg encoder and its speed | NVENC on NVIDIA, and libx264 presets fast enough for 1440p at 60 fps and AVC444 |
| `oystein/krdp-codecs` | codec/h264: set the x264 "zerolatency" tune only for x264 | NVENC rejected it and FFmpeg logged a warning on every connect |
| `oystein/krdp-codecs` | codec/yuv: give each threaded encode work item only its own strip | each strip converted from its top to the bottom of the frame, about 45 times the work; KRDP used about 9 cores |
| `oystein/krdp-codecs` | codec/h264: compare the 64x64 tiles on the thread pool | change detection took 5 to 9 ms per frame on one thread, now about 2 ms |
| `oystein/krdp-codecs` | codec/h264: fix two bugs in the change detection for U, V and AVC444v2 chroma | colour-only changes could be missed, and AVC444v2 chroma rects pointed at the wrong screen areas |

## Keeping it in step with the distro

The libraries have the same sonames as the distro ones (`libfreerdp3.so.3` and so on).
When the distro moves to a new FreeRDP 3 release, rebase the branch on the new tag,
`localbuild bump freerdp <commit>`, and rebuild this recipe and then krdp.
