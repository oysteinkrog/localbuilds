# voxtype push-to-talk dictation with CUDA ONNX engines, my fork, as the pacman package
# voxtype-cuda-local. Installs beside the AUR package voxtype-bin and reuses its bundled
# ONNX Runtime 1.24.4 CUDA 13 libraries.
#
# Pinned to the fork branch voxtype-onnx-isolation: upstream tag v1.1.1 plus the
# engine_isolation option (ONNX engines in a short-lived worker process) and the live
# preview overlay. See README.

UPSTREAM=https://github.com/peteonrails/voxtype.git
FORK=https://github.com/oysteinkrog/voxtype.git
MODE=fork
SRC=$HOME/projects/voxtype   # my forks live in ~/projects; ~/work until the office move
[ -d "$SRC" ] || SRC=$HOME/work/voxtype
KIND=pkg
PIN=3d4d46a78eccf0360c9fb23615c8e219198e0038

lb_pkgver() {
    local ver
    ver=$(sed -n '/^\[package\]/,/^\[/s/^version = "\(.*\)"/\1/p' "$LB_WORK/src/Cargo.toml" | head -1)
    echo "${ver:-0}.g${LB_COMMIT:0:10}"
}
