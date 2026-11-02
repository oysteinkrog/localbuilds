OBS background removal plugin (royshil/obs-backgroundremoval) with GPU inference through the ONNX Runtime CUDA provider.

The AUR package `obs-backgroundremoval` links the system ONNX Runtime but never defines
`HAVE_ONNXRUNTIME_CUDA_EP`, so the filter only offers CPU inference. This recipe builds the
same release with that define and depends on `onnxruntime-cuda` instead of `onnxruntime-cpu`.

After install, pick "GPU - CUDA" under the filter's Advanced settings > Inference Device.
The OBS log line `Inference Device: cuda` confirms it.

Drop the recipe if the AUR package starts shipping a CUDA build.
