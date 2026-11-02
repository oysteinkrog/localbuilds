# obs-backgroundremoval 1.4.1 built against onnxruntime-cuda with the CUDA execution
# provider turned on, as the pacman package obs-backgroundremoval-cuda-local.
# The AUR package builds without GPU support: upstream CMake never defines
# HAVE_ONNXRUNTIME_CUDA_EP for a system onnxruntime, so "GPU - CUDA" is missing
# from the filter's Inference Device list. No source changes; the series is empty.

UPSTREAM=https://github.com/royshil/obs-backgroundremoval.git
MODE=patches
KIND=pkg
PIN=1.4.1

lb_pkgver() {
    echo "1.4.1"
}

lb_system_inputs() {
    pacman -Q onnxruntime-cuda obs-studio opencv 2>/dev/null
}
