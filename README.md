# localbuilds

Recipes for the open source software I patch or build from source on my Arch (CachyOS)
desktop, and `localbuild`, the script that builds and installs them. Each recipe pins an
upstream version and lists the local changes on top of it, so any build can be repeated
and every change has a written reason.

[INDEX.md](INDEX.md) lists every recipe. `localbuild status` shows what is installed.

## Layout

| Path | What it holds |
|---|---|
| `recipes/<name>/recipe.sh` | upstream URL, pin, mode, kind and build steps |
| `recipes/<name>/series[.<variant>]` | patch files to apply, in order |
| `recipes/<name>/patches/` | `git format-patch` files, each with a commit message |
| `recipes/<name>/PKGBUILD` | packaging, for recipes built as pacman packages |
| `recipes/<name>/README.md` | what the recipe is for and one line per patch |
| `bin/localbuild` | the command |
| `hooks/pre-commit` | blocks commits that contain private details |

Outside the repo:

| Path | What it holds |
|---|---|
| `~/src/<name>/` | upstream clone; only fetched, never built in |
| `~/.cache/build/<name>/<id>/` | one worktree and build output per build; safe to delete |
| `~/.local/state/localbuild/` | which build of each recipe is installed |
| install location | set by the recipe: a pacman package, or a directory with a `current` link |

## Recipes

A recipe has one **mode**:

- `patches`: apply the patch files in `series` on top of an upstream tag or commit. Use it
  for a few small fixes.
- `fork`: build a commit of my fork as it is. Use it when the changes are large or still
  growing. The commit must be pushed to the fork before it can be installed.

and one **kind**:

- `pkg`: build a pacman package with `makepkg` and install it with `pacman -U`. Use it for
  normal tools, so pacman tracks the files.
- `tree`: copy the build output into a versioned directory and point `current` at it. Use it
  for software that needs side-by-side copies, such as a private Wine per app.

A recipe can have **variants**. `wine@taskslinger` uses `series.taskslinger`, which includes
the base `series` and adds two patches.

The build ID is a hash of everything that goes into a build: pin, recipe, series, patch
contents and PKGBUILD. Two variants on the same Wine release get different IDs.

## Commands

```
localbuild status
localbuild build <name>[@variant] [--dev]
localbuild install <name>[@variant]
localbuild rollback <name>[@variant]
localbuild shell <name>[@variant]
localbuild patch-save <name>[@variant] <slug> -m "<subject>"
localbuild bump <name> <pin>
localbuild check
localbuild index
```

## Changing a patched project

1. `localbuild build wine@taskslinger` makes a fresh worktree with the series applied.
2. `localbuild shell wine@taskslinger` prints that worktree. Edit there.
3. `localbuild build wine@taskslinger --dev` rebuilds with your edits. A dev build cannot be
   installed.
4. `localbuild patch-save wine@taskslinger <slug> -m "<module>: <what it fixes>"` writes the
   edits as the next numbered patch and adds it to the series.
5. Add the patch to the recipe README, run `localbuild index`, commit.
6. `localbuild build wine@taskslinger`, then `localbuild install wine@taskslinger`.

`install` refuses when the recipe has uncommitted changes, when the build has unsaved edits,
or when a fork commit is not pushed.

For a fork recipe, work in `~/src/<name>` on a branch, commit, push to the fork, then
`localbuild bump <name> <commit>`.

## Rules

- No hostnames, IP addresses, serial numbers, account names or company product names in this
  repo. The pre-commit hook checks for common cases. Enable it once per clone with
  `git config core.hooksPath hooks`.
- Each patch carries `Upstream-Status:` in its message: `local-only`, `submitted <link>` or
  `merged <version>`. Drop a patch from the series when upstream has it.
- `localbuild check` warns when the system has moved under a recipe, for example a Wine
  upgrade past the pinned release. It never rebuilds on its own.
