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

## Keeping it in step with the distro

The libraries have the same sonames as the distro ones (`libfreerdp3.so.3` and so on).
When the distro moves to a new FreeRDP 3 release, rebase the branch on the new tag,
`localbuild bump freerdp <commit>`, and rebuild this recipe and then krdp.
