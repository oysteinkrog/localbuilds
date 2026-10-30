# Shared code for bin/localbuild. Sourced, not run.
#
# A recipe is recipes/<name>/recipe.sh. It sets:
#   UPSTREAM  git URL of the upstream project
#   MODE      patches  apply the files listed in `series` on top of PIN
#             fork     build PIN as it is; PIN must be a commit pushed to FORK
#             binary   package a prebuilt upstream release; PIN is its version, KIND must be pkg
#   KIND      tree     install a directory under lb_install_root, switched with a `current` link
#             pkg      build a pacman package from the recipe's PKGBUILD and install it with pacman
#   PIN       upstream tag or commit (patches), or fork commit (fork)
#   FORK      git URL of the fork (fork mode only)
#   VARIANTS  optional, space separated; variant v uses series.v instead of series
#   SHA512    checksum of the release file (binary mode only); the PKGBUILD gets it as $LB_SHA512
# and may define the functions lb_build (required for tree), lb_install_root (tree),
# lb_pkgver (pkg), lb_check, lb_pin_hash (binary: print the SHA512 for the version in $1,
# so `localbuild bump` can update SHA512 too) and lb_system_inputs (print the installed
# versions of system packages the build links against; a change gives a new build ID).

LB_CACHE=${LB_CACHE:-$HOME/.cache/build}
LB_STATE=${LB_STATE:-$HOME/.local/state/localbuild}
LB_GIT_ID=(-c user.name=localbuild -c user.email=localbuild@localhost)

say()  { printf '%s\n' "$*"; }
warn() { printf 'localbuild: %s\n' "$*" >&2; }
die()  { warn "$*"; exit 1; }

# lb_load <name>[@variant]: read the recipe and work out the build identity.
lb_load() {
    local spec=$1
    LB_NAME=${spec%%@*}
    LB_VARIANT=""
    if [[ $spec == *@* ]]; then LB_VARIANT=${spec#*@}; fi
    LB_RECIPE_DIR=$LB_ROOT/recipes/$LB_NAME
    [ -f "$LB_RECIPE_DIR/recipe.sh" ] || die "no recipe: recipes/$LB_NAME/recipe.sh"

    UPSTREAM="" MODE="" KIND="" PIN="" FORK="" VARIANTS="" SHA512=""
    unset -f lb_build lb_install_root lb_pkgver lb_check lb_pin_hash lb_system_inputs 2>/dev/null || true
    SRC=$HOME/src/$LB_NAME
    . "$LB_RECIPE_DIR/recipe.sh"
    [ -n "$UPSTREAM" ] && [ -n "$PIN" ] || die "$LB_NAME: recipe must set UPSTREAM and PIN"
    case "$MODE" in patches|fork|binary) ;; *) die "$LB_NAME: MODE must be patches, fork or binary" ;; esac
    case "$KIND" in tree|pkg) ;; *) die "$LB_NAME: KIND must be tree or pkg" ;; esac
    if [ "$MODE" = binary ]; then
        [ "$KIND" = pkg ] || die "$LB_NAME: binary recipes must use KIND=pkg"
        [[ $SHA512 =~ ^[0-9a-f]{128}$ ]] || die "$LB_NAME: binary recipe must set SHA512"
    fi

    if [ -n "$VARIANTS" ] && [ -z "$LB_VARIANT" ]; then
        die "$LB_NAME has variants ($VARIANTS); use $LB_NAME@<variant>"
    fi
    if [ -n "$LB_VARIANT" ] && [[ " $VARIANTS " != *" $LB_VARIANT "* ]]; then
        die "$LB_NAME: unknown variant $LB_VARIANT (known: ${VARIANTS:-none})"
    fi
    LB_SERIES_FILE=$LB_RECIPE_DIR/series${LB_VARIANT:+.$LB_VARIANT}
    LB_FULL=$LB_NAME${LB_VARIANT:+@$LB_VARIANT}
    lb_series_list
    lb_identity
}

# Patch files in apply order. A line "@include <file>" pulls in another series file.
lb_series_list() {
    LB_PATCHES=()
    [ "$MODE" = patches ] || return 0
    [ -f "$LB_SERIES_FILE" ] || return 0
    local line
    _lb_read_series() {
        while IFS= read -r line || [ -n "$line" ]; do
            line=${line%%#*}; line=${line//[[:space:]]/}
            [ -z "$line" ] && continue
            if [[ $line == @include* ]]; then
                _lb_read_series "$LB_RECIPE_DIR/${line#@include}"
            else
                [ -f "$LB_RECIPE_DIR/patches/$line" ] || die "$LB_FULL: series lists missing patch $line"
                LB_PATCHES+=("$LB_RECIPE_DIR/patches/$line")
            fi
        done < "$1"
    }
    _lb_read_series "$LB_SERIES_FILE"
}

# The build ID changes whenever any input changes: pin, recipe, series, patch bytes, PKGBUILD,
# and the system package versions from lb_system_inputs.
lb_identity() {
    local hash
    hash=$({
        printf '%s\n' "$PIN" "$MODE" "$KIND" "$LB_VARIANT"
        cat "$LB_RECIPE_DIR/recipe.sh"
        if [ -f "$LB_SERIES_FILE" ]; then cat "$LB_SERIES_FILE"; fi
        local p; for p in "${LB_PATCHES[@]}"; do basename "$p"; cat "$p"; done
        if [ -f "$LB_RECIPE_DIR/PKGBUILD" ]; then cat "$LB_RECIPE_DIR/PKGBUILD"; fi
        if declare -F lb_system_inputs >/dev/null; then lb_system_inputs; fi
    } | sha256sum | cut -c1-10)
    local pin=$PIN
    if [[ $pin =~ ^[0-9a-f]{40}$ ]]; then pin=${pin:0:10}; fi
    LB_HASH=$hash
    LB_ID=${LB_VARIANT:+$LB_VARIANT-}${pin//\//_}-$hash
    LB_WORK=$LB_CACHE/$LB_NAME/$LB_ID
    LB_LATEST=$LB_CACHE/$LB_NAME/latest${LB_VARIANT:+-$LB_VARIANT}
}

# Clone upstream into ~/src/<name> if needed and make sure PIN is present.
lb_source() {
    # Binary recipes have no clone: makepkg downloads the release and checks SHA512.
    if [ "$MODE" = binary ]; then LB_COMMIT=$PIN; return 0; fi
    if [ ! -d "$SRC/.git" ]; then
        say "cloning $UPSTREAM into $SRC"
        git clone --filter=blob:none --no-checkout "$UPSTREAM" "$SRC"  # noqa: grove-worktree
    fi
    if [ "$MODE" = fork ] && [ -n "$FORK" ]; then
        local url
        url=$(git -C "$SRC" remote get-url fork 2>/dev/null || true)
        [ -n "$url" ] || git -C "$SRC" remote add fork "$FORK"
    fi
    if ! git -C "$SRC" rev-parse -q --verify "$PIN^{commit}" >/dev/null; then
        git -C "$SRC" fetch --tags origin
        if [ "$MODE" = fork ]; then git -C "$SRC" fetch fork; fi
    fi
    LB_COMMIT=$(git -C "$SRC" rev-parse "$PIN^{commit}") || die "$LB_FULL: cannot find $PIN in $SRC"
}

# True when the fork commit is on a branch of the fork remote.
lb_pin_pushed() {
    [ "$MODE" = fork ] || return 0
    git -C "$SRC" fetch -q fork 2>/dev/null || true
    [ -n "$(git -C "$SRC" branch -r --contains "$LB_COMMIT" --list 'fork/*' 2>/dev/null)" ]
}

# Fresh detached worktree at the pin, with the series applied as commits.
lb_fresh_worktree() {
    if [ -d "$LB_WORK/src" ]; then
        git -C "$SRC" worktree remove --force "$LB_WORK/src" 2>/dev/null || rm -rf "$LB_WORK/src"
        git -C "$SRC" worktree prune
    fi
    rm -rf "$LB_WORK"
    mkdir -p "$LB_WORK"
    [ "$MODE" = binary ] && return 0
    git -C "$SRC" worktree add -q --detach "$LB_WORK/src" "$LB_COMMIT"  # noqa: grove-worktree
    local p
    for p in "${LB_PATCHES[@]}"; do
        git "${LB_GIT_ID[@]}" -C "$LB_WORK/src" am -q --keep-cr "$p" \
            || die "$LB_FULL: $(basename "$p") does not apply on $PIN; rebase it"
    done
    git -C "$LB_WORK/src" rev-parse HEAD > "$LB_WORK/series-head"
}

lb_worktree_dirty() {
    local dir=$1
    [ "$MODE" = binary ] && return 1
    [ -n "$(git -C "$dir/src" status --porcelain --untracked-files=normal 2>/dev/null)" ] && return 0
    [ "$(git -C "$dir/src" rev-parse HEAD)" != "$(cat "$dir/series-head")" ]
}

lb_recipe_clean() {
    [ -z "$(git -C "$LB_ROOT" status --porcelain -- "recipes/$LB_NAME" lib bin 2>/dev/null)" ]
}

lb_cmd_build() {
    local spec="" dev=""
    for a in "$@"; do case "$a" in --dev) dev=1 ;; *) spec=$a ;; esac; done
    [ -n "$spec" ] || die "usage: localbuild build <name>[@variant] [--dev]"
    lb_load "$spec"
    lb_source

    if [ -n "$dev" ]; then
        [ -L "$LB_LATEST" ] || die "$LB_FULL: no build yet; run localbuild build $LB_FULL first"
        LB_WORK=$(readlink -f "$LB_LATEST")
        LB_ID=$(basename "$LB_WORK")
    fi
    mkdir -p "$(dirname "$LB_WORK")"
    exec 9>"$LB_WORK.lock"
    flock -n 9 || die "$LB_FULL: another build of $LB_ID is running"

    if [ -n "$dev" ]; then
        say "dev build in $LB_WORK/src (edits kept; this build cannot be installed)"
    else
        if [ -f "$LB_WORK/DONE" ] && ! lb_worktree_dirty "$LB_WORK"; then
            ln -sfn "$LB_ID" "$LB_LATEST"
            say "$LB_FULL $LB_ID already built: $LB_WORK"
            return 0
        fi
        lb_fresh_worktree
    fi
    rm -f "$LB_WORK/DONE"
    mkdir -p "$LB_WORK/out"
    say "building $LB_FULL $LB_ID (log: $LB_WORK/build.log)"
    (
        cd "$LB_WORK"
        export LB_WORK LB_ID LB_NAME LB_VARIANT LB_COMMIT LB_RECIPE_DIR
        # libtool's configure runs `mt -?` to look for the Windows manifest tool; a
        # different `mt` on PATH that never exits hangs every autotools build
        export MANIFEST_TOOL=:
        if [ "$KIND" = pkg ]; then lb_build_pkg; else lb_build; fi
    ) >> "$LB_WORK/build.log" 2>&1 || { tail -20 "$LB_WORK/build.log" >&2; die "$LB_FULL: build failed"; }
    lb_buildinfo > "$LB_WORK/out/BUILDINFO"
    if [ -n "$dev" ] || lb_worktree_dirty "$LB_WORK"; then touch "$LB_WORK/DIRTY"; else rm -f "$LB_WORK/DIRTY"; fi
    touch "$LB_WORK/DONE"
    ln -sfn "$LB_ID" "$LB_LATEST"
    say "built $LB_FULL $LB_ID"
}

lb_buildinfo() {
    printf 'name=%s\nvariant=%s\nid=%s\nupstream=%s\nmode=%s\nkind=%s\npin=%s\ncommit=%s\n' \
        "$LB_NAME" "$LB_VARIANT" "$LB_ID" "$UPSTREAM" "$MODE" "$KIND" "$PIN" "$LB_COMMIT"
    printf 'recipe_commit=%s\nbuilt=%s\n' "$(git -C "$LB_ROOT" rev-parse --short HEAD 2>/dev/null)" "$(date -Iseconds)"
    local p; for p in "${LB_PATCHES[@]}"; do printf 'patch=%s\n' "$(basename "$p")"; done
    [ -f "$LB_WORK/DIRTY" ] && printf 'dirty=1\n'
    return 0
}

# Default pkg build: makepkg with the recipe's PKGBUILD, building from the patched worktree.
lb_build_pkg() {
    local pkgdir=$LB_WORK/makepkg
    rm -rf "$pkgdir"; mkdir -p "$pkgdir"
    cp "$LB_RECIPE_DIR/PKGBUILD" "$pkgdir/"
    if [ "$MODE" = binary ]; then
        # Downloads are kept per recipe, so rebuilding the same release does not fetch it again.
        local srcdest=$LB_CACHE/$LB_NAME/sources
        mkdir -p "$srcdest"
        (cd "$pkgdir" && SRCDEST=$srcdest LB_PKGVER=$PIN LB_PKGREL=1 LB_SHA512=$SHA512 \
            PKGDEST=$LB_WORK/out makepkg -f --noconfirm --nodeps)
        return
    fi
    local ver
    ver=$(declare -F lb_pkgver >/dev/null && lb_pkgver || echo "r$(git -C "$LB_WORK/src" rev-list --count HEAD).${LB_COMMIT:0:10}")
    (cd "$pkgdir" && LB_SRCDIR=$LB_WORK/src LB_PKGVER=$ver LB_PKGREL=1 PKGDEST=$LB_WORK/out \
        makepkg -f --noconfirm --nodeps --noextract)
}

lb_cmd_install() {
    [ $# -ge 1 ] || die "usage: localbuild install <name>[@variant]"
    lb_load "$1"
    lb_recipe_clean || die "$LB_FULL: recipes/$LB_NAME has uncommitted changes; commit them first"
    lb_source
    lb_pin_pushed || die "$LB_FULL: fork commit $LB_COMMIT is not pushed to $FORK"
    [ -f "$LB_WORK/DONE" ] || die "$LB_FULL: $LB_ID is not built; run localbuild build $LB_FULL"
    [ -f "$LB_WORK/DIRTY" ] && die "$LB_FULL: $LB_ID has unsaved edits; run localbuild patch-save, then build again"
    mkdir -p "$LB_STATE"
    local state=$LB_STATE/$LB_FULL
    if [ "$KIND" = pkg ]; then
        local pkg
        pkg=$(ls "$LB_WORK"/out/*.pkg.tar.* | grep -v '\.sig$' | head -1)
        [ -f "$state.installed" ] && cp "$state.installed" "$state.previous"
        # --noconfirm alone answers no to "remove the distro package it conflicts with?";
        # --ask 4 (ALPM_QUESTION_CONFLICT_PKG) answers yes to that question only
        sudo pacman -U --noconfirm --ask 4 "$pkg"
        printf '%s\n%s\n' "$LB_ID" "$pkg" > "$state.installed"
    else
        local root; root=$(lb_install_root)
        mkdir -p "$root"
        exec 8>"$root/.localbuild.lock"
        flock 8
        if [ ! -d "$root/$LB_ID" ]; then
            rm -rf "$root/.$LB_ID.tmp"
            cp -a --reflink=auto "$LB_WORK/out" "$root/.$LB_ID.tmp"
            mv "$root/.$LB_ID.tmp" "$root/$LB_ID"
        fi
        local prev; prev=$(readlink "$root/current" 2>/dev/null || true)
        [ -n "$prev" ] && [ "$prev" != "$LB_ID" ] && printf '%s\n' "$prev" > "$root/.previous"
        ln -sfn "$LB_ID" "$root/.current.new" && mv -T "$root/.current.new" "$root/current"
        printf '%s\n%s\n' "$LB_ID" "$root" > "$state.installed"
    fi
    say "installed $LB_FULL $LB_ID"
}

# Copy a finished build of the recipe as committed from another machine over ssh, so
# `localbuild install` can install it here without building. The peer must have built
# the same build ID (same pin, recipe and PKGBUILD) under the same path below $HOME.
lb_cmd_fetch() {
    local spec="" peer=""
    while [ $# -gt 0 ]; do
        case "$1" in --from) peer=${2:-}; shift 2 ;; *) spec=$1; shift ;; esac
    done
    [ -n "$spec" ] && [ -n "$peer" ] || die "usage: localbuild fetch <name>[@variant] --from <ssh host>"
    lb_load "$spec"
    [ "$KIND" = pkg ] || die "$LB_FULL: fetch only handles pkg recipes"
    lb_recipe_clean || die "$LB_FULL: recipes/$LB_NAME has uncommitted changes; commit them first"
    lb_source
    if [ -f "$LB_WORK/DONE" ] && [ ! -f "$LB_WORK/DIRTY" ]; then
        ln -sfn "$LB_ID" "$LB_LATEST"
        say "$LB_FULL $LB_ID already here: $LB_WORK"
        return 0
    fi
    # A local build of this ID that is unfinished or has edits stays as it is.
    [ ! -e "$LB_WORK/src" ] || die "$LB_FULL: $LB_WORK has a local build; finish it with localbuild build"
    case "$LB_WORK" in "$HOME"/*) ;; *) die "LB_CACHE must be under \$HOME to fetch" ;; esac
    local rel=${LB_WORK#"$HOME"/}
    # shellcheck disable=SC2029  # rel is meant to expand here
    ssh -o BatchMode=yes "$peer" "test -f '$rel/DONE' && test ! -f '$rel/DIRTY'" \
        || die "$LB_FULL: $peer has no finished clean build $LB_ID"
    mkdir -p "$LB_WORK"
    exec 9>"$LB_WORK.lock"
    flock -n 9 || die "$LB_FULL: another build or fetch of $LB_ID is running"
    rsync -a --delete "$peer:$rel/out/" "$LB_WORK/out.part/" || die "$LB_FULL: copy from $peer failed"
    local info=$LB_WORK/out.part/BUILDINFO want
    [ -f "$info" ] || die "$LB_FULL: $peer's build has no BUILDINFO"
    for want in "id=$LB_ID" "pin=$PIN" "commit=$LB_COMMIT" "variant=$LB_VARIANT"; do
        grep -qxF "$want" "$info" || die "$LB_FULL: $peer's BUILDINFO does not have $want"
    done
    ! grep -qx 'dirty=1' "$info" || die "$LB_FULL: $peer's build has unsaved edits"
    ls "$LB_WORK"/out.part/*.pkg.tar.* >/dev/null 2>&1 || die "$LB_FULL: $peer's build has no package"
    [ ! -e "$LB_WORK/out" ] || mv "$LB_WORK/out" "$LB_WORK/out.old.$$"
    mv "$LB_WORK/out.part" "$LB_WORK/out"
    printf '%s\n' "$peer" > "$LB_WORK/FETCHED"
    touch "$LB_WORK/DONE"
    ln -sfn "$LB_ID" "$LB_LATEST"
    say "fetched $LB_FULL $LB_ID from $peer"
}

lb_cmd_rollback() {
    [ $# -ge 1 ] || die "usage: localbuild rollback <name>[@variant]"
    lb_load "$1"
    if [ "$KIND" = pkg ]; then
        local state=$LB_STATE/$LB_FULL
        [ -f "$state.previous" ] || die "$LB_FULL: no previous package recorded"
        sudo pacman -U --noconfirm "$(sed -n 2p "$state.previous")"
        mv "$state.previous" "$state.installed"
    else
        local root; root=$(lb_install_root)
        [ -f "$root/.previous" ] || die "$LB_FULL: no previous build recorded in $root"
        local prev; prev=$(cat "$root/.previous")
        [ -d "$root/$prev" ] || die "$LB_FULL: $root/$prev is gone"
        readlink "$root/current" > "$root/.previous"
        ln -sfn "$prev" "$root/.current.new" && mv -T "$root/.current.new" "$root/current"
        printf '%s\n%s\n' "$prev" "$root" > "$LB_STATE/$LB_FULL.installed"
    fi
    say "rolled back $LB_FULL"
}

lb_cmd_shell() {
    [ $# -ge 1 ] || die "usage: localbuild shell <name>[@variant]"
    lb_load "$1"
    [ -L "$LB_LATEST" ] || die "$LB_FULL: no build yet"
    say "$(readlink -f "$LB_LATEST")/src"
}

lb_cmd_patch_save() {
    local spec="" slug="" msg=""
    while [ $# -gt 0 ]; do
        case "$1" in -m) msg=$2; shift 2 ;; *) if [ -z "$spec" ]; then spec=$1; else slug=$1; fi; shift ;; esac
    done
    [ -n "$spec" ] && [ -n "$slug" ] || die "usage: localbuild patch-save <name>[@variant] <slug> -m <message>"
    lb_load "$spec"
    [ "$MODE" = patches ] || die "$LB_FULL is a fork recipe: commit and push in $SRC, then localbuild bump"
    [ -L "$LB_LATEST" ] || die "$LB_FULL: no build worktree"
    local work; work=$(readlink -f "$LB_LATEST")
    local wt=$work/src
    if [ -n "$(git -C "$wt" status --porcelain)" ]; then
        [ -n "$msg" ] || die "uncommitted edits in $wt: pass -m '<subject>' to commit them"
        git -C "$wt" add -A
        git "${LB_GIT_ID[@]}" -C "$wt" commit -q -m "$msg"
    fi
    local base; base=$(cat "$work/series-head")
    [ "$(git -C "$wt" rev-parse HEAD)" != "$base" ] || die "$LB_FULL: nothing to save"
    mkdir -p "$LB_RECIPE_DIR/patches"
    local n
    n=$(ls "$LB_RECIPE_DIR/patches" 2>/dev/null | grep -oE '^[0-9]{4}' | sort -n | tail -1 || true)
    n=$((10#${n:-0}))
    local c count=0
    for c in $(git -C "$wt" rev-list --reverse "$base..HEAD"); do
        n=$((n + 1)); count=$((count + 1))
        local name; name=$(printf '%04d-%s' "$n" "$slug")
        [ "$count" -gt 1 ] && name+="-$count"
        git -C "$wt" format-patch -q -1 "$c" --stdout > "$LB_RECIPE_DIR/patches/$name.patch"
        printf '%s.patch\n' "$name" >> "$LB_SERIES_FILE"
        say "saved patches/$name.patch and added it to $(basename "$LB_SERIES_FILE")"
    done
    say "next: add a line for it in recipes/$LB_NAME/README.md, commit, then localbuild build $LB_FULL"
}

lb_cmd_bump() {
    [ $# -eq 2 ] || die "usage: localbuild bump <name> <pin>"
    local f=$LB_ROOT/recipes/$1/recipe.sh
    [ -f "$f" ] || die "no recipe $1"
    sed -i "s|^PIN=.*|PIN=$2|" "$f"
    if grep -q '^MODE=binary' "$f"; then
        local hash
        hash=$(. "$f"; declare -F lb_pin_hash >/dev/null && lb_pin_hash "$2" || true)
        [[ $hash =~ ^[0-9a-f]{128}$ ]] || die "recipes/$1: no SHA512 for $2; set it by hand"
        sed -i "s|^SHA512=.*|SHA512=$hash|" "$f"
    fi
    say "recipes/$1: PIN=$2. Build, test, then commit the recipe."
}

lb_each() {
    local d name v
    for d in "$LB_ROOT"/recipes/*/; do
        name=$(basename "$d")
        v=$(sed -n 's/^VARIANTS=["'\'']\{0,1\}\([^"'\'']*\).*/\1/p' "$d/recipe.sh")
        if [ -n "$v" ]; then for x in $v; do "$@" "$name@$x"; done; else "$@" "$name"; fi
    done
}

_lb_status_one() {
    ( lb_load "$1"
      local installed="-" note=()
      local state=$LB_STATE/$LB_FULL.installed
      [ -f "$state" ] && installed=$(head -1 "$state")
      [ "$installed" = "-" ] && note+=("not installed by localbuild")
      [ "$installed" != "-" ] && [ "$installed" != "$LB_ID" ] && note+=("recipe changed since install (want $LB_ID)")
      [ "$MODE" = binary ] || [ -d "$SRC/.git" ] || note+=("no source clone")
      if [ -L "$LB_LATEST" ] && [ -f "$(readlink -f "$LB_LATEST")/DIRTY" ]; then
          note+=("unsaved edits in $(readlink -f "$LB_LATEST")/src")
      fi
      if [ "$MODE" = fork ] && [ -d "$SRC/.git" ] && git -C "$SRC" rev-parse -q --verify "$PIN^{commit}" >/dev/null; then
          LB_COMMIT=$(git -C "$SRC" rev-parse "$PIN^{commit}")
          [ -n "$(git -C "$SRC" branch -r --contains "$LB_COMMIT" --list 'fork/*' 2>/dev/null)" ] || note+=("pin not pushed")
      fi
      printf '%-24s %-7s %-4s %-14s %-32s %s\n' "$LB_FULL" "$MODE" "$KIND" "${PIN:0:14}" "$installed" "${note[*]:-ok}" )
}

lb_status() {
    printf '%-24s %-7s %-4s %-14s %-32s %s\n' RECIPE MODE KIND PIN INSTALLED NOTES
    lb_each _lb_status_one
}

_lb_check_one() {
    ( lb_load "$1"; declare -F lb_check >/dev/null && lb_check || true )
}

lb_cmd_check() { lb_each _lb_check_one; }

_lb_index_row() {
    ( lb_load "$1"
      local about; about=$(sed -n '1s/^# //p' "$LB_RECIPE_DIR/README.md" 2>/dev/null)
      printf '| [%s](recipes/%s/) | %s | %s | %s | `%s` | %s | %s |\n' \
          "$LB_FULL" "$LB_NAME" "$about" "$MODE" "$KIND" "$PIN" "${#LB_PATCHES[@]}" "$UPSTREAM" )
}

lb_cmd_index() {
    {
        echo "# Recipe Index"
        echo
        echo "Generated by \`localbuild index\`. Do not edit by hand."
        echo
        echo "| Recipe | What | Mode | Kind | Pin | Patches | Upstream |"
        echo "|---|---|---|---|---|---|---|"
        lb_each _lb_index_row
    } > "$LB_ROOT/INDEX.md"
    say "wrote INDEX.md"
}
