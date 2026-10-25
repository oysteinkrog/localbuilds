Plasma Login Manager 6.8.1 with a setting to turn off the login screen wallpaper blur, as plasma-login-manager-local.

It replaces the distro plasma-login-manager package (`provides=(plasma-login-manager=6.8.1)`,
`conflicts=(plasma-login-manager)`). The build steps and dependencies are copied from the Arch
plasma-login-manager 6.8.1 PKGBUILD.

| Fork branch | Commit | Why |
|---|---|---|
| `oystein/no-wallpaper-blur` | 1 commit on v6.8.1 | adds `BlurWallpaper` in `[Greeter]` of `/etc/plasmalogin.conf`. The greeter blurs, dims and recolours the wallpaper behind the login form, which hides the shader wallpaper. `BlurWallpaper=false` keeps it sharp. The default is true, so upstream behaviour is unchanged |

Upstream-Status: local-only, not sent upstream.

The dotfiles bootstrap (`bin/shader-wallpaper-greeter-setup`) writes `BlurWallpaper=false`.
With the distro package the key does nothing, so it is safe either way.

## New Plasma release

When the repos ship a newer plasma-login-manager, `pacman -Syu` keeps this package and
`localbuild check` warns. Rebase the branch onto the new tag, push it to the fork, then
`localbuild bump plasma-login-manager <commit>`, update the version in `PKGBUILD` and
`lb_check`, build and install.

## Go back to the distro package

`sudo pacman -S plasma-login-manager` removes plasma-login-manager-local. The blur comes back
at the next login screen.
