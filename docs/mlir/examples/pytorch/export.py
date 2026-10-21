"""Export three tiny PyTorch models to MLIR with torch-mlir's FX importer.

Usage: python -I export.py OUTDIR

Writes, for each model NAME:
  NAME.exported.txt  the torch.export ExportedProgram (graph and signature)
  NAME.raw.mlir      torch dialect straight from the importer (output_type="raw")
  NAME.torch.mlir    torch dialect after the backend-contract passes
  NAME.linalg.mlir   linalg-on-tensors
  NAME.tosa.mlir     TOSA
  NAME.stablehlo.mlir StableHLO
"""
import os
import sys

import torch
from torch_mlir import fx


class MLP(torch.nn.Module):
    def __init__(self):
        super().__init__()
        self.fc1 = torch.nn.Linear(4, 8)
        self.relu = torch.nn.ReLU()
        self.fc2 = torch.nn.Linear(8, 2)

    def forward(self, x):
        return self.fc2(self.relu(self.fc1(x)))


class MatmulBias(torch.nn.Module):
    def forward(self, a, b, bias):
        return torch.matmul(a, b) + bias


class Conv(torch.nn.Module):
    def __init__(self):
        super().__init__()
        self.conv = torch.nn.Conv2d(1, 2, kernel_size=3, padding=1)

    def forward(self, x):
        return self.conv(x)


def models():
    torch.manual_seed(0)
    yield "mlp", MLP().eval(), (torch.randn(1, 4),)
    yield "matmul_bias", MatmulBias().eval(), (
        torch.randn(2, 3), torch.randn(3, 4), torch.randn(4))
    yield "conv2d", Conv().eval(), (torch.randn(1, 1, 5, 5),)


def main(outdir):
    os.makedirs(outdir, exist_ok=True)
    for name, model, args in models():
        ep = torch.export.export(model, args)
        with open(os.path.join(outdir, f"{name}.exported.txt"), "w") as f:
            f.write(str(ep))
        for kind in ["raw", "torch", "linalg-on-tensors", "tosa", "stablehlo"]:
            suffix = {"linalg-on-tensors": "linalg"}.get(kind, kind)
            path = os.path.join(outdir, f"{name}.{suffix}.mlir")
            try:
                m = fx.export_and_import(model, *args, output_type=kind,
                                         func_name=name)
                text = str(m)
            except Exception as e:  # record failures in the file
                text = f"// FAILED: {type(e).__name__}: {e}\n"
            with open(path, "w") as f:
                f.write(text)
            print(name, kind, "->", path, len(text.splitlines()), "lines")


if __name__ == "__main__":
    main(sys.argv[1])
