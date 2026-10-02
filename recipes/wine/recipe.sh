# Wine with local fixes, installed as a private copy per consumer app.
#
# Wine loads its builtin DLLs from its own library directory before WINEDLLPATH or the
# prefix, so a patched builtin only works in a Wine install of its own. The build copies
# the system Wine (it must be the same release as PIN) and replaces the DLLs the series
# touches. Variant <v> installs to ~/.local/share/<v>-wine/<build id>, with `current`
# pointing at the one in use. Run it as ~/.local/share/<v>-wine/current/bin/wine.

UPSTREAM=https://gitlab.winehq.org/wine/wine.git
MODE=patches
KIND=tree
PIN=wine-11.18
VARIANTS="taskslinger"

lb_install_root() { echo "$HOME/.local/share/$LB_VARIANT-wine"; }

_wine_system_version() { /usr/bin/wine --version 2>/dev/null; }

# Modules the series changes, from the paths in the patches (dlls/<module>/...).
_wine_modules() {
    local p
    for p in "${LB_PATCHES[@]}"; do grep -oE '^diff --git a/dlls/[^/]+/' "$p"; done \
        | sed -E 's|^diff --git a/dlls/||; s|/$||' | sort -u
}

lb_build() {
    local sysver; sysver=$(_wine_system_version)
    [ "$sysver" = "$PIN" ] || { echo "system Wine is $sysver, recipe pins $PIN; bump the pin and rebase"; return 1; }

    mkdir -p build
    if [ ! -f build/Makefile ]; then
        (cd build && ../src/configure --enable-archs=x86_64 --disable-tests \
            --without-x --without-freetype --without-wayland --without-vulkan --without-opengl)
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
    if [ "$sysver" != "$PIN" ]; then
        echo "wine@$LB_VARIANT: system Wine is now $sysver but the recipe pins $PIN."
        echo "  The installed copy still works. To move: localbuild bump wine $sysver, then build."
    fi
}
