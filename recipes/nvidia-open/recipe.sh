# NVIDIA open kernel modules 615.78.08 for the running linux-cachyos kernel, with the
# CachyOS 7.3 patches and a local change that shortens RM API lock holds when GPU
# objects are freed (module parameter NVreg_RmLockRelief, 0 = stock behaviour).
# Built as the pacman package linux-cachyos-nvidia-open-local, which replaces
# linux-cachyos-nvidia-open. Installing it swaps the nvidia module: reboot after.
#
# Changes live on the fork branch oystein/615.78.08-rmlock-yield (off tag 615.78.08).

UPSTREAM=https://github.com/NVIDIA/open-gpu-kernel-modules.git
FORK=https://github.com/oysteinkrog/open-gpu-kernel-modules.git
SRC=$HOME/src/open-gpu-kernel-modules
MODE=fork
KIND=pkg
PIN=3e65278fc628f837200e0a9513536e8d1e886354

lb_pkgver() {
    echo "615.78.08.r$(git -C "$LB_WORK/src" rev-list --count 615.78.08..HEAD).g${LB_COMMIT:0:10}"
}

lb_check() {
    local nv
    nv=$(pacman -Q nvidia-utils 2>/dev/null | awk '{print $2}')
    case "$nv" in
        615.78.08-*|"") ;;
        *) warn "nvidia-open: nvidia-utils is $nv, not 615.78.08; rebase oystein/615.78.08-rmlock-yield onto the new tag before installing (see recipes/nvidia-open/README.md)" ;;
    esac
}

# The module is built against the installed linux-cachyos headers and must match
# the userspace driver, so a change in either needs a rebuild.
lb_system_inputs() {
    pacman -Q linux-cachyos linux-cachyos-headers nvidia-utils clang lld 2>&1 || true
}
