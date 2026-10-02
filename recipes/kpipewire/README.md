KPipeWire 6.8 beta 2 (v6.7.91), installed in /opt/krdp-local for krdp-local only.

KRDP master calls `PipeWireEncodedStream::setRequestedSize`, which first shipped in
KPipeWire 6.8. Replacing the system kpipewire would also change Spectacle, the screen
sharing portal and Plasma, so this copy lives in its own prefix. Its libraries carry an
rpath to `/opt/krdp-local/lib`, and so does krdp-local.

| Fork branch | Commit | Why |
|---|---|---|
| `oystein/krdp-private` | upstream tag v6.7.91, no local changes | API that KRDP master needs |

## Remove after Plasma 6.8

Once the distro ships kpipewire 6.8, build the krdp recipe against the system copy
(drop `CMAKE_PREFIX_PATH` and `CMAKE_INSTALL_RPATH` from its PKGBUILD), then
`sudo pacman -R kpipewire-krdp-local` and delete this recipe.
