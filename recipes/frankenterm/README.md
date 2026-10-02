# FrankenTerm terminal, my fork, as the pacman package frankenterm-local

Upstream is `Dicklesworthstone/frankenterm`; my fork is `oysteinkrog/frankenterm`. The
package installs `/usr/bin/frankenterm-gui` and `/usr/bin/frankenterm-mux-server`. The
`frankenterm` launcher and the `frankenterm-mux.service` user unit live in the dotfiles.

## Fork branches

`oystein/main` is the integration branch. It holds exactly what is installed: the pin is
always a commit on `oystein/main`. Work happens on topic branches, which are merged into
`oystein/main` before a build. The fork's `main` and `master` only mirror upstream, so
syncing upstream stays a fast-forward.

| Branch | What it adds |
|---|---|
| `oystein/main` | Integration branch: every topic branch below, merged. The installed build |
| `oystein/linux-setup` | Wayland build fix, vertical tab bar with bell colours, move tab to window, `cli spawn` and `cli list`, tab close and spawn fixes, mux window guard deadlock fixes, explicit palette fix |
| `oystein/tab-reorder-sync` | GUI tab moves committed on the mux server, and `cli move-tab` |
| `pr/*` | One upstream PR each, rebased onto upstream `main`. Not built here |

To ship a change: commit it on a topic branch, merge that into `oystein/main`, push both,
then `localbuild bump frankenterm <oystein/main commit>`, build, commit the recipe, install.

## Notes

- The build uses the toolchain in the repo's `rust-toolchain.toml` through rustup.
- Cargo output goes to `~/.cache/build/frankenterm/target`, shared between builds, so a
  build of a nearby commit takes a few minutes, not a full rebuild.
- Installing a new package does not restart the running mux server. The new binaries start
  the next time the unit starts.
