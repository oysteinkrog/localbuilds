KWin 6.7.5 with "Resizable Virtual Monitors" backported from 6.8, as kwin-local.

It replaces the distro kwin package (`provides=(kwin=6.7.5)`, `conflicts=(kwin)`).
The build steps and dependencies are copied from the Arch kwin 6.7.5 PKGBUILD.

| Fork branch | Commit | Why |
|---|---|---|
| `oystein/resizable-virtual-monitors` | cherry-pick of KWin MR 7932 onto v6.7.5 | lets KRDP resize its virtual monitor to the RDP client window |

Upstream-Status: merged 6.8 (https://invent.kde.org/plasma/kwin/-/merge_requests/7932)

## Go back to the distro kwin

`sudo pacman -S kwin` removes kwin-local and installs the repo package. Log out and in.

## Remove after Plasma 6.8

When the repos ship kwin 6.8, `pacman -Syu` will stop on the conflict with kwin-local.
Run `sudo pacman -S kwin` as part of that upgrade, then delete this recipe.
`localbuild check` warns once the repos have moved past 6.7.
