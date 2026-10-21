"""The expected outputs for `mlir/tests/torch.rs`, computed by PyTorch.

Each model is the one `docs/mlir/examples/pytorch/export.py` exported, with
its weights read back from the exported `.torch.mlir` file, run on the
inputs the test's C driver makes: element i of input k is
((7i + 3k) mod 11 - 5) / 4 for floats, and (7i + 3k) mod 11 - 5 for
integers. Run with torch-mlir's Python environment (see
docs/mlir/04-from-pytorch.md):

    python reference.py ../../../docs/mlir/examples/pytorch .
"""

import os
import re
import sys

import numpy as np
import torch
import torch.ao.quantization.fx._decomposed  # noqa: F401, registers quantized_decomposed
import torch.nn.functional as F


def blobs(path):
    """The dialect_resources blobs of a file, as float32 arrays."""
    text = open(path).read()
    out = {}
    for key, hexdata in re.findall(r'(\w[\w.]*): "0x([0-9A-Fa-f]+)"', text):
        data = bytes.fromhex(hexdata)[4:]  # The first word is the alignment.
        out[key] = torch.from_numpy(np.frombuffer(data, dtype=np.float32).copy())
    return out


def inputs(shapes, dtype):
    xs = []
    for k, shape in enumerate(shapes):
        n = int(np.prod(shape))
        v = [((7 * i + 3 * k) % 11) - 5 for i in range(n)]
        t = torch.tensor(v, dtype=torch.float64).reshape(shape)
        xs.append((t / 4).to(torch.float32) if dtype == "float" else t.to(dtype))
    return xs


def main(examples, out):
    results = {}

    a, b, bias = inputs([(2, 3), (3, 4), (4,)], "float")
    results["matmul_bias"] = [torch.matmul(a, b) + bias]

    w = blobs(os.path.join(examples, "mlp.torch.mlir"))
    (x,) = inputs([(1, 4)], "float")
    h = F.relu(F.linear(x, w["torch_tensor_8_4_torch.float32"].reshape(8, 4), w["torch_tensor_8_torch.float32"]))
    results["mlp"] = [F.linear(h, w["torch_tensor_2_8_torch.float32"].reshape(2, 8), w["torch_tensor_2_torch.float32"])]

    w = blobs(os.path.join(examples, "conv2d.torch.mlir"))
    (x,) = inputs([(1, 1, 5, 5)], "float")
    weight = w["torch_tensor_2_1_3_3_torch.float32"].reshape(2, 1, 3, 3)
    results["conv2d"] = [F.conv2d(x, weight, w["torch_tensor_2_torch.float32"], padding=1)]

    a, b = inputs([(32, 8), (8, 8)], torch.int8)
    results["extra_int8matmul"] = [a.to(torch.int32) @ b.to(torch.int32)]

    # Quantise and dequantise around a float matmul (export_extra.py).
    qd = torch.ops.quantized_decomposed
    a, b = inputs([(2, 3), (3, 4)], "float")
    da = qd.dequantize_per_tensor(qd.quantize_per_tensor(a, 0.05, 3, -128, 127, torch.int8), 0.05, 3, -128, 127, torch.int8)
    db = qd.dequantize_per_tensor(qd.quantize_per_tensor(b, 0.1, 0, -128, 127, torch.int8), 0.1, 0, -128, 127, torch.int8)
    results["extra_qmatmul"] = [torch.mm(da, db)]

    for name, outs in results.items():
        with open(os.path.join(out, name + ".expected"), "w") as f:
            for t in outs:
                for v in t.flatten().tolist():
                    f.write(f"{v:.9g}\n" if isinstance(v, float) else f"{v}\n")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
