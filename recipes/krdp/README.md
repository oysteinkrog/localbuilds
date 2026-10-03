KRDP master with audio and microphone redirection (MR 239) and local fixes, as krdp-local.

It replaces the distro krdp package and links against the private KPipeWire in
/opt/krdp-local (see the kpipewire recipe). It runs in `--monitor` mode, streaming one
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

## Install

`localbuild install krdp` cannot replace the distro krdp, because pacman's `--noconfirm`
answers no to removing a conflicting package. Install the built package with
`sudo pacman -U --ask=4 <package>` instead.

## Go back to the distro krdp

`sudo pacman -S krdp` removes krdp-local and installs the repo package. Remove the
`Environment=KRDP_OUTPUT_RESIZE_HOOK` line from the unit drop-in too, although the stock
server ignores it.
