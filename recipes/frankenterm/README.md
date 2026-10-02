# FrankenTerm terminal, my fork, as the pacman package frankenterm-local

Upstream is `Dicklesworthstone/frankenterm`; my fork is `oysteinkrog/frankenterm`. The
package installs `/usr/bin/frankenterm-gui` and `/usr/bin/frankenterm-mux-server`. The
`frankenterm` launcher and the `frankenterm-mux.service` user unit live in the dotfiles.

## Fork branches

| Branch | What it adds |
|---|---|
| `oystein/linux-setup` | Wayland build fix, vertical tab bar with bell colours, move tab to window, `cli spawn` and `cli list`, tab close and spawn fixes |
| `oystein/tab-reorder-sync` | Tab order kept in sync with the mux server (in progress, branched from `oystein/linux-setup`) |

The pin is the commit the installed package is built from. Move it with
`localbuild bump frankenterm <commit>` once that commit is pushed.

## Notes

- The build uses the toolchain in the repo's `rust-toolchain.toml` through rustup.
- Cargo output goes to `~/.cache/build/frankenterm/target`, shared between builds, so a
  build of a nearby commit takes a few minutes, not a full rebuild.
- Installing a new package does not restart the running mux server. The new binaries start
  the next time the unit starts.
