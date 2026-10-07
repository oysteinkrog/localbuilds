KRDP master with audio and microphone redirection (MR 239) and local fixes, as krdp-local.

It replaces the distro krdp package and links against the private KPipeWire and FreeRDP
in /opt/krdp-local (see the kpipewire and freerdp recipes). It runs in `--monitor` mode, streaming one
real monitor; no virtual monitor and no RemoteAccess mode.

| Fork branch commit | Why |
|---|---|
| upstream master | dynamic virtual monitor resizing (MR 113), RemoteAccess mode (MR 230) and the other 6.8 changes |
| merge of MR 239 | rdpsnd (desktop sound to the client) and audin (client microphone as a PipeWire source) |
| VideoStream: resume a paused encoder when frames are dropped after a GFX reset | the encoder stayed paused for good when queued frames were dropped |
| VideoStream: on a GFX caps re-advertisement, forget surfaces without deleting them | mstsc stopped acknowledging frames after deletes for surfaces it had already dropped |
| VideoStream: restart the H.264 encoder after a GFX caps re-advertisement | without a new key frame the client stayed black on every connection after the first |
| VideoStreamSurface: give each H.264 encoder its own copy of the PipeWire fd | KPipeWire closes the fd when an encoder stops, so a restarted encoder got nothing |
| AudinStream: make the Remote Desktop microphone the default source while connected | apps record from the default source, so the client microphone went unused |
| SessionController: run a hook with the client size when streaming a real monitor | `KRDP_OUTPUT_RESIZE_HOOK` gets the client's width and height |
| Run the output resize hook with the client's desktop size at connect | fits the monitor at logon, not only when the client window is resized |
| AudinStream: reopen the microphone channel when the client doesn't answer | mstsc rejects AUDIO_INPUT when it is opened within about 100 ms of connect, which left the microphone off for the session |
| VideoStreamSurface: don't warn about cursor-only frames | KWin sends image-less buffers when only the cursor moves; KRDP logged a warning for each |
| Video: add AVC444 and AVC420 through FreeRDP, codec settings, RemoteFX quality | full color resolution over H.264, NVENC, and sharp text in RemoteFX; needs the freerdp recipe |
| VideoStream: start a fresh H.264 encoder for every new surface | a reused encoder only sent changed blocks, so a new (black) surface showed black squares |
| VideoStreamSurface: keep the raw source stream when the mode is set again | recreating it on mstsc's second caps advertisement closed the shared PipeWire fd, so the session failed and krdpserver aborted |
| VideoStream: send nothing for 500 ms after the first CapsConfirm | added while chasing protocol error 0xd06 on reconnect; the real cause was the encode race fixed below, so this may no longer be needed |
| Hold back wrong-size frames while the resize hook fits the monitor | added for the same 0xd06 hunt; may also be unneeded now |
| VideoStream: let KRDP_FIRST_FRAME_DELAY_MS override the first-frame delay | for testing the delay without a rebuild |
| Video: debug log of the first AVC frames and of ResetGraphics | compares a working and a failing connection; debug level only |
| Video: don't send a frame to a surface the client reset during encoding | the real cause of 0xd06 on reconnect: mstsc re-advertised its caps while the first NVENC frame (about 400 ms) was encoding, and that frame then went to a surface the client had dropped |
| Video: log encode time and frame acknowledgement time | debug log every 5 s, to find where video latency goes |
| Audio: AudioCodec and AudioIdleTimeout settings | the codec and the silence pause were fixed in code |
| Audio: AAC by default again, AudioBitrate setting, log the latency guard | with mstsc, PCM gave about 300 ms of client latency and dropouts; AAC gives about 135 to 160 ms and plays clean |
| VideoStreamSurface: read the frame before KWin reuses it, and skip a slow conversion | the queued handler could read a buffer KWin was already drawing into again; the RGBA to RGB32 conversion took Qt's slow generic path |
| Video: convert AVC444 frames on the GPU; encode them with NVENC straight from GPU memory; GpuEncode setting | A GL compute shader makes both AVC444 pictures and marks changed tiles; NVENC reads them through CUDA-GL interop. Encode time per frame at 2560x1440 went from 26 to 53 ms to 4 to 6 ms, CPU from 50 to 120% to about 15% |
| GpuAvc444Converter: offline test | `tools/gpuavc444test.cpp` checks the GPU pictures byte for byte against FreeRDP's conversion and decodes the NVENC stream with FreeRDP |
| Video: log frame sizes and acknowledgement time by frame size | debug log every 5 s; `KRDP_FRAME_TRACE=1` logs every frame. It showed that mstsc's software H.264 decode, not the network, made large frames slow to acknowledge |
| Video: force an IDR picture on reset instead of reopening NVENC, and open it early | mstsc resets its graphics channel on every connect; reopening NVENC cost 90 to 120 ms each time |
| Video: KRDP_MAX_IN_FLIGHT fixes the frame window | for experiments; the window normally comes from the round-trip time |
| Video: confirm the newest GFX caps version we know, not the newest offered | msrdc offers RDPGFX 11.1 to 11.5, which FreeRDP does not know; confirming one turned AVC444 off |
| Video: send a full-screen key frame every 10 s on the GPU path; handle suspended frame acknowledgements | after a few hours with msrdc the picture became smeared blocks until a reconnect: KRDP sent one key frame per connection, so a client decoder that got out of step never recovered |
| Video: capture the GPU AVC444 stream on request; never mix encoders | `touch $XDG_RUNTIME_DIR/krdp-dump-now` writes the next 10 s to `/var/tmp/krdp-dump/`, and `tools/avc444dumpdecode` decodes it like a client, to tell a client bug from a KRDP bug. A frame without a DMA-BUF went to FreeRDP's CPU encoder, a second encoder feeding the client's one decoder |

Upstream-Status: MR 239 submitted https://invent.kde.org/plasma/krdp/-/merge_requests/239;
the fixes on top are local-only.

## How this host uses it

- `~/bin/krdp-remote-mode` (dotfiles) is both the watcher service and the resize hook. On
  connect the hook saves the monitor layout, turns the other monitors off and sets the
  streamed monitor to the client's size. On disconnect the watcher restores the layout.
- A size the monitor's EDID lacks (2560x1440 on a 1920x1200 monitor) needs the EDID
  override from `edid-add-mode` (dotfiles `bin/`, unit `edid-add-mode@.service`). The
  physical monitor shows "out of range" in that mode while nobody sits at it.
- The KRDP unit drop-in from `setup/steps/70-services.sh` sets `KRDP_OUTPUT_RESIZE_HOOK`.

## Video and audio settings

Set in `~/.config/krdpserverrc`, group `[General]`, read when the server starts:

| Key | Values | Default |
|---|---|---|
| `VideoCodec` | `KPipeWire`, `Auto`, `AVC444`, `AVC420`, `RemoteFX` | `KPipeWire` |
| `VideoEncoder` | `Auto` (NVENC, else libx264), `NVENC`, `libx264` | `Auto` |
| `EncoderSpeed` | `Default`, `Fast`, `Fastest` | `Fast` |
| `RemoteFXQuality` | 0 to 100 (100 keeps every detail, 50 is the Windows default) | `100` |
| `GpuEncode` | AVC444 on the GPU (compute shader and NVENC from CUDA memory) when CUDA is available; ignored with `libx264` | `true` |
| `KeyFrameInterval` | seconds between full-screen key frames on the GPU path, so a broken picture recovers; 0 turns them off | `10` |
| `AudioCodec` | `Auto` (AAC, else Opus, else PCM), `AAC`, `Opus`, `PCM` | `Auto` |
| `AudioBitrate` | AAC and Opus bit rate, 32 to 320 kbit/s | `192` |
| `AudioIdleTimeout` | seconds of silence before the client's audio stream closes; 0 keeps it open | `60` |

`Auto` and `AVC444` fall back to AVC420 when the client cannot do AVC444, and to RemoteFX
when it cannot do H.264. The `Quality` key still sets the H.264 quality (as a constant QP).
`KRDP_DISABLE_H264=1` in the environment still forces RemoteFX.

## Which Windows client

Use msrdc (the Remote Desktop app, or the Windows App), not mstsc. Measured on 2026-10-06 at
2560x1440 over Tailscale (16.6 ms RTT), AVC444 with GPU encode:

| | mstsc | msrdc |
|---|---|---|
| H.264 decode on the client | software | GPU |
| Acknowledgement, frames below 64 kB | 27 to 39 ms | 18 to 21 ms |
| Acknowledgement, frames of 256 kB and more | 81 to 134 ms | 21 to 24 ms |
| Audio latency the client reports | about 110 ms | about 110 ms |

msrdc has no connect dialog: save the connection from mstsc as an `.rdp` file and open that
file with `msrdc.exe`.

## Install

`localbuild install krdp` cannot replace the distro krdp, because pacman's `--noconfirm`
answers no to removing a conflicting package. Install the built package with
`sudo pacman -U --ask=4 <package>` instead.

## Go back to the distro krdp

`sudo pacman -S krdp` removes krdp-local and installs the repo package. Remove the
`Environment=KRDP_OUTPUT_RESIZE_HOOK` line from the unit drop-in too, although the stock
server ignores it.
