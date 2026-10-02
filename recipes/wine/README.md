# Wine 11.18 with fixes, as a private copy per app

Each variant installs to `~/.local/share/<variant>-wine/<build id>/`, with `current` pointing
at the one in use. Run apps with `~/.local/share/<variant>-wine/current/bin/wine`. The system
Wine must be the same release as the pin, because the build copies it and replaces only the
modules the patches touch.

## Variants

| Variant | For | Series |
|---|---|---|
| `taskslinger` | TaskSlinger 0.9.2, a Windows task manager | base series plus 0004 and 0005 |

## Patches

| Patch | Module | What it fixes |
|---|---|---|
| 0001 | quartz, qcap | DirectShow capture samples get a start time, so webcam capture shows frames |
| 0002 | ws2_32 | Accepts the socket options MsQuic sets when it starts a listener |
| 0003 | crypt32 | Exports the private key of a certificate loaded from a PFX |
| 0004 | user32 | Adds `GetProcessUIContextInformation` (semi-stub, reports a desktop app) |
| 0005 | kernelbase, kernel32 | Adds `GetApplicationUserModelId` (returns `APPMODEL_ERROR_NO_APPLICATION`) |

All five are `Upstream-Status: local-only`.

## Known issues

- TaskSlinger: GPU and disk graphs stay at 0, and the process list shows only Wine processes.
  Wine does not report Linux GPU or disk counters.
- TaskSlinger: with window manager decorations on, hover and clicks land above the pointer.
  Turn decorations off in the prefix:
  `wine reg add 'HKCU\Software\Wine\X11 Driver' /v Decorated /t REG_SZ /d N /f`.
