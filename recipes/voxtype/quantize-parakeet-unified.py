"""Make an int8 copy of voxtype's parakeet-unified-en-0.6b model.

Dynamic int8 quantization of the encoder MatMuls (weights only). The small
decoder_joint graph and the tokenizer files are copied unchanged.
Usage: quantize_parakeet_unified.py <src-model-dir> <dst-model-dir>
"""

import shutil
import sys
from pathlib import Path

from onnxruntime.quantization import QuantType, quantize_dynamic

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(parents=True, exist_ok=True)
for name in ("decoder_joint.onnx", "tokenizer.model", "vocab.txt"):
    shutil.copy2(src / name, dst / name)

quantize_dynamic(
    model_input=src / "encoder.onnx",
    model_output=dst / "encoder.onnx",
    weight_type=QuantType.QInt8,
    op_types_to_quantize=["MatMul"],
    use_external_data_format=False,
)
for f in sorted(dst.iterdir()):
    print(f.name, f.stat().st_size)
