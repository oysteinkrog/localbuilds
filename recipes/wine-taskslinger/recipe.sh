# Wine 11.18 with the fixes TaskSlinger needs, installed as a private copy.
#
# Wine loads its builtin DLLs from its own library directory before WINEDLLPATH or the
# prefix, so a patched builtin only works in a Wine install of its own. The build copies
# the system Wine (it must be the release in BASE) and replaces the modules the fork
# branch changes. Installs to ~/.local/share/taskslinger-wine/<build id>, with `current`
# pointing at the one in use.
#
# The changes are commits on branch taskslinger/wine-11.18 of oysteinkrog/wine.

UPSTREAM=https://gitlab.winehq.org/wine/wine.git
FORK=https://github.com/oysteinkrog/wine.git
MODE=fork
KIND=tree
SRC=$HOME/src/wine
BASE=wine-11.18
PIN=cb0713657deaee31933e851fddc68c4d3bf28314

lb_install_root() { echo "$HOME/.local/share/taskslinger-wine"; }

_wine_system_version() { /usr/bin/wine --version 2>/dev/null; }

# Modules the fork changes on top of BASE, from the paths dlls/<module>/...
_wine_modules() {
    git -C "$LB_WORK/src" diff --name-only "$BASE" HEAD -- dlls \
        | cut -d/ -f2 | sort -u
}

lb_build() {
    local sysver; sysver=$(_wine_system_version)
    [ "$sysver" = "$BASE" ] || { echo "system Wine is $sysver, recipe is based on $BASE; rebase the branch"; return 1; }

    mkdir -p build
    if [ ! -f build/Makefile ]; then
        # X11, FreeType, Vulkan and OpenGL stay on: win32u and winex11 built without them
        # lose fonts and Direct3D, and winex11.so is not built at all without X.
        (cd build && ../src/configure --enable-archs=x86_64 --disable-tests --without-wayland)
    fi
    local mods=() m
    mapfile -t mods < <(_wine_modules)
    echo "modules: ${mods[*]}"
    local targets=(); for m in "${mods[@]}"; do targets+=("dlls/$m/all"); done
    make -C build -j"$(nproc)" "${targets[@]}"

    # Stage a full copy of the system Wine, then lay the rebuilt modules over it.
    rm -rf out/bin out/lib out/share
    mkdir -p out/bin out/lib out/share
    cp -a --reflink=auto /usr/lib/wine out/lib/
    cp -a --reflink=auto /usr/share/wine out/share/
    local tool
    for tool in wine wineserver wineboot winecfg wineconsole winepath winedbg msiexec regedit; do
        [ -e "/usr/bin/$tool" ] && cp -a "/usr/bin/$tool" out/bin/
    done
    local f
    for m in "${mods[@]}"; do
        for f in build/dlls/"$m"/x86_64-windows/*.{dll,exe,drv,sys}; do
            [ -f "$f" ] && cp "$f" out/lib/wine/x86_64-windows/
        done
        for f in build/dlls/"$m"/*.so; do
            [ -f "$f" ] && cp "$f" out/lib/wine/x86_64-unix/
        done
    done
    return 0
}

lb_check() {
    local sysver; sysver=$(_wine_system_version)
    if [ "$sysver" != "$BASE" ]; then
        echo "wine-taskslinger: system Wine is now $sysver but the branch is based on $BASE."
        echo "  The installed copy still works. To move: rebase the branch onto $sysver, then bump."
    fi
}
