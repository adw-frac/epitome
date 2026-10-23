"""Extra observations: core ATen decomposition, dynamic shapes, buffers,
mutation, and quantised (QDQ) matmul.

Usage: python -I export_extra.py OUTDIR
"""
import os
import sys

import torch
from torch.export import Dim
from torch_mlir import fx

# Registers torch.ops.quantized_decomposed.*.
import torch.ao.quantization.fx._decomposed  # noqa: F401


class MLP(torch.nn.Module):
    def __init__(self):
        super().__init__()
        self.fc1 = torch.nn.Linear(4, 8)
        self.fc2 = torch.nn.Linear(8, 2)

    def forward(self, x):
        return self.fc2(torch.relu(self.fc1(x)))


class Counter(torch.nn.Module):
    """A buffer that forward() mutates in place."""
    def __init__(self):
        super().__init__()
        self.register_buffer("count", torch.zeros(1))

    def forward(self, x):
        self.count.add_(1)
        return x * self.count


class QMatmul(torch.nn.Module):
    """Quantise-dequantise around a float matmul (the PT2E QDQ pattern)."""
    def forward(self, a, b):
        qd = torch.ops.quantized_decomposed
        qa = qd.quantize_per_tensor(a, 0.05, 3, -128, 127, torch.int8)
        qb = qd.quantize_per_tensor(b, 0.1, 0, -128, 127, torch.int8)
        da = qd.dequantize_per_tensor(qa, 0.05, 3, -128, 127, torch.int8)
        db = qd.dequantize_per_tensor(qb, 0.1, 0, -128, 127, torch.int8)
        return torch.mm(da, db)


class Int8Matmul(torch.nn.Module):
    """int8 x int8 -> int32 matrix multiply."""
    def forward(self, a, b):
        return torch._int_mm(a, b)


def save(outdir, name, text):
    with open(os.path.join(outdir, name), "w") as f:
        f.write(text)
    print("wrote", name, len(text.splitlines()), "lines")


def attempt(outdir, name, fn):
    try:
        text = fn()
    except Exception as e:
        text = f"// FAILED: {type(e).__name__}: {str(e)[:2000]}\n"
    save(outdir, name, text)


def main(outdir):
    os.makedirs(outdir, exist_ok=True)
    torch.manual_seed(0)
    mlp = MLP().eval()
    x = torch.randn(1, 4)

    # 1. torch.export output, before and after decomposition to core ATen.
    ep = torch.export.export(mlp, (x,))
    save(outdir, "extra_mlp.core_aten.txt", str(ep.run_decompositions()))

    # 2. Dynamic batch dimension. The example batch must not be 1, or
    #    torch.export specialises it.
    batch = Dim("batch")
    x = torch.randn(2, 4)
    attempt(outdir, "extra_mlp_dynamic.torch.mlir", lambda: str(
        fx.export_and_import(mlp, x, output_type="torch",
                             dynamic_shapes={"x": {0: batch}},
                             import_symbolic_shape_expressions=True,
                             func_name="mlp_dyn")))
    attempt(outdir, "extra_mlp_dynamic.linalg.mlir", lambda: str(
        fx.export_and_import(mlp, x, output_type="linalg-on-tensors",
                             dynamic_shapes={"x": {0: batch}},
                             func_name="mlp_dyn")))

    # 3. Mutated buffer, with and without mutation support.
    for mut in (False, True):
        attempt(outdir, f"extra_counter_mut{int(mut)}.raw.mlir", lambda: str(
            fx.export_and_import(Counter(), torch.randn(3), output_type="raw",
                                 experimental_support_mutation=mut,
                                 func_name="counter")))
    save(outdir, "extra_counter.exported.txt",
         str(torch.export.export(Counter(), (torch.randn(3),))))

    # 4. QDQ matmul and plain integer matmul.
    a, b = torch.randn(2, 3), torch.randn(3, 4)
    for kind in ("torch", "tosa", "linalg-on-tensors"):
        suffix = {"linalg-on-tensors": "linalg"}.get(kind, kind)
        attempt(outdir, f"extra_qmatmul.{suffix}.mlir", lambda: str(
            fx.export_and_import(QMatmul(), a, b, output_type=kind,
                                 func_name="qmatmul")))
    # _int_mm wants sizes that are multiples of 8 (and >16 rows).
    ai = torch.randint(-128, 127, (32, 8), dtype=torch.int8)
    bi = torch.randint(-128, 127, (8, 8), dtype=torch.int8)
    for kind in ("torch", "tosa", "linalg-on-tensors"):
        suffix = {"linalg-on-tensors": "linalg"}.get(kind, kind)
        attempt(outdir, f"extra_int8matmul.{suffix}.mlir", lambda: str(
            fx.export_and_import(Int8Matmul(), ai, bi, output_type=kind,
                                 func_name="int8matmul")))


if __name__ == "__main__":
    main(sys.argv[1])
