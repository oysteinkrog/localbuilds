# EideticEngine (ee), Jeffrey Emanuel's structured memory CLI for agents, from the upstream
# x86_64 glibc release tarball, packaged as ee-bin-local. Used as the memory layer of the
# scheduled agent sessions (life repo, agents/README.md).
#
# Move it with `localbuild bump ee-bin <version>`: lb_pin_hash downloads the release file and
# prints its SHA512 after checking the upstream SHA256.

UPSTREAM=https://github.com/Dicklesworthstone/eidetic_engine_cli
MODE=binary
KIND=pkg
PIN=0.19.0
SHA512=cfba2c562da2272ef793441b55df981c462c6721c544dda293788f1e1a2a798edd3771ac43316a6598366483289e624694f506eb2f016171f62f5b3d172ba1c9

lb_pin_hash() {
    local d f=ee-x86_64-unknown-linux-gnu.tar.xz
    d=$(mktemp -d -p /var/tmp) || return 1
    (cd "$d" && gh release download "v$1" -R Dicklesworthstone/eidetic_engine_cli -p "$f" -p "$f.sha256" >/dev/null &&
        sha256sum -c --quiet "$f.sha256" && sha512sum "$f" | cut -d' ' -f1)
    rm -r -- "$d"
}

lb_check() {
    pacman -Q ee-bin-local >/dev/null 2>&1 || warn "ee-bin: ee-bin-local is not installed"
}
