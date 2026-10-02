KRDP master with audio and microphone redirection (MR 239), as krdp-local.

It replaces the distro krdp package and links against the private KPipeWire in
/opt/krdp-local (see the kpipewire recipe). Live resizing of the virtual monitor also
needs the kwin recipe until Plasma 6.8.

| Fork branch | Commit | Why |
|---|---|---|
| `oystein/audio-and-resize` | upstream master | dynamic virtual monitor resizing (MR 113) and RemoteAccess mode (MR 230), both in 6.8 |
| `oystein/audio-and-resize` | merge of MR 239 | rdpsnd (desktop sound to the client) and audin (client microphone as a PipeWire source) |

Upstream-Status: submitted https://invent.kde.org/plasma/krdp/-/merge_requests/239

## Go back to the distro krdp

`sudo pacman -S krdp` removes krdp-local and installs the repo package.

## Remove after MR 239 is released

Once a Plasma release contains MR 239, install the distro krdp and delete this recipe.
