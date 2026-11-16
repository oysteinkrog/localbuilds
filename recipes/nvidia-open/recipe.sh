# NVIDIA open kernel modules 620.70.06 for the linux-cachyos kernel, with the
# CachyOS 7.3 patches and a local change that shortens RM API lock holds when GPU
# objects are freed (module parameter NVreg_RmLockRelief, 0 = stock behaviour).
# Built as the pacman package linux-cachyos-nvidia-open-local, which replaces
# linux-cachyos-nvidia-open. Installing it swaps the nvidia module: reboot after.
#
# Changes live on the fork branch oystein/620.70.06-rmlock-yield (off tag 620.70.06).
#
# To build for a kernel that is not installed yet (before a pacman -Syu), extract its
# linux-cachyos-headers package and set NVIDIA_KERNEL_BUILD to its .../build dir and
# NVIDIA_KERNEL_PKGVER / NVIDIA_UTILS_PKGVER to the target versions. lb_system_inputs
# then prints what pacman -Q will print after the upgrade, so the build ID matches and
# `localbuild install nvidia-open` finds the build once the upgrade is done.

UPSTREAM=https://github.com/NVIDIA/open-gpu-kernel-modules.git
FORK=https://github.com/oysteinkrog/open-gpu-kernel-modules.git
SRC=$HOME/src/open-gpu-kernel-modules
MODE=fork
KIND=pkg
PIN=f82504b15f125253977e872a6d5ea9836d40b18f

lb_pkgver() {
    echo "620.70.06.r$(git -C "$LB_WORK/src" rev-list --count 620.70.06..HEAD).g${LB_COMMIT:0:10}"
}

lb_check() {
    local nv
    nv=$(pacman -Q nvidia-utils 2>/dev/null | awk '{print $2}')
    case "$nv" in
        620.70.06-*|"") ;;
        *) warn "nvidia-open: nvidia-utils is $nv, not 620.70.06; rebase oystein/620.70.06-rmlock-yield onto the new tag before installing (see recipes/nvidia-open/README.md)" ;;
    esac
}

# The module is built against the installed linux-cachyos headers and must match
# the userspace driver, so a change in either needs a rebuild.
lb_system_inputs() {
    if [ -n "${NVIDIA_KERNEL_PKGVER:-}" ]; then
        printf 'linux-cachyos %s\nlinux-cachyos-headers %s\nnvidia-utils %s\n' \
            "$NVIDIA_KERNEL_PKGVER" "$NVIDIA_KERNEL_PKGVER" "${NVIDIA_UTILS_PKGVER:?set NVIDIA_UTILS_PKGVER too}"
        pacman -Q clang lld 2>&1 || true
    else
        pacman -Q linux-cachyos linux-cachyos-headers nvidia-utils clang lld 2>&1 || true
    fi
}
