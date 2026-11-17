# NVIDIA open kernel modules 615.78.08 for the linux-cachyos kernel, with the
# CachyOS 7.3 patches and the same local changes as the nvidia-open recipe (RM API
# lock relief, NVreg_RmLockRelief; 4 KiB pages for the client shadow fault buffer).
# Built as the same pacman package name, linux-cachyos-nvidia-open-local, so it
# replaces whichever nvidia-open build is installed. It exists to go back to the 615
# driver, which had no "nv_flip == NULL" flip timeouts (620.70.06 had 21 in 4 days).
#
# Changes live on the fork branch oystein/615.78.08-rmlock-yield-v2 (off tag 615.78.08).
# Install it only together with nvidia-utils 615.78.08 and the matching userspace
# packages (see README.md); `localbuild install` alone would leave the userspace at 620.

UPSTREAM=https://github.com/NVIDIA/open-gpu-kernel-modules.git
FORK=https://github.com/oysteinkrog/open-gpu-kernel-modules.git
SRC=$HOME/src/open-gpu-kernel-modules
MODE=fork
KIND=pkg
PIN=17468131d629e4e9c78ff81b6d37ca685da8b385

lb_pkgver() {
    echo "615.78.08.r$(git -C "$LB_WORK/src" rev-list --count 615.78.08..HEAD).g${LB_COMMIT:0:10}"
}

lb_check() {
    local nv
    nv=$(pacman -Q nvidia-utils 2>/dev/null | awk '{print $2}')
    case "$nv" in
        615.78.08-*|"") ;;
        *) warn "nvidia-open-615: nvidia-utils is $nv, not 615.78.08; install the 615.78.08 userspace in the same pacman transaction (see recipes/nvidia-open-615/README.md)" ;;
    esac
}

# The module is built against the installed linux-cachyos headers. The userspace
# version is fixed at 615.78.08 (the target), not read from pacman, so the build ID
# stays the same before and after the userspace is moved back.
lb_system_inputs() {
    if [ -n "${NVIDIA_KERNEL_PKGVER:-}" ]; then
        printf 'linux-cachyos %s\nlinux-cachyos-headers %s\n' "$NVIDIA_KERNEL_PKGVER" "$NVIDIA_KERNEL_PKGVER"
    else
        pacman -Q linux-cachyos linux-cachyos-headers 2>&1 || true
    fi
    printf 'nvidia-utils 615.78.08\n'
    pacman -Q clang lld 2>&1 || true
}
