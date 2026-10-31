Plasma Desktop 6.8.2 with a setting to turn off the lock screen wallpaper blur, as plasma-desktop-local.

It replaces the distro plasma-desktop package (`provides=(plasma-desktop=6.8.2)`,
`conflicts=(plasma-desktop)`). The build steps and dependencies are copied from the Arch
plasma-desktop 6.8.2 PKGBUILD.

| Fork branch | Commit | Why |
|---|---|---|
| `oystein/no-lockscreen-blur-6.8.2` | 1 commit on v6.8.2 | adds `blurWallpaper` to the lock screen config. The lock screen blurs, dims and recolours the wallpaper while the unlock prompt is shown, which hides the shader wallpaper. `blurWallpaper=false` in `[Greeter][LnF][General]` of `~/.config/kscreenlockerrc` keeps it sharp. The default is true, so upstream behaviour is unchanged |

Upstream-Status: local-only, not sent upstream.

The login screen has its own blur, turned off by the `plasma-login-manager` recipe. With
autologin the login screen rarely shows, so the lock screen is the one you see.

## New Plasma release

When the repos ship a newer plasma-desktop, `pacman -Syu` keeps this package and
`localbuild check` warns. Put the commit on the new tag, push it to the fork as a new
branch, then `localbuild bump plasma-desktop <commit>`, update the version in `PKGBUILD`,
`recipe.sh` and this file, build and install.

## Go back to the distro package

`sudo pacman -S plasma-desktop` removes plasma-desktop-local. The blur comes back the
next time the screen locks.
