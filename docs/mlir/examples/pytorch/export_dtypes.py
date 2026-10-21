"""How torch-mlir spells dtypes, before and after the backend lowering.

Usage: python -I export_dtypes.py OUTDIR
"""
import os
import sys

import torch
from torch_mlir import fx


class F(torch.nn.Module):
    def forward(self, a, b, c, d, e, f):
        return a.sum(), b + 1, c, d * 2, e, f


ARGS = (torch.ones(2, dtype=torch.bool), torch.ones(2, dtype=torch.int64),
        torch.ones(2, dtype=torch.uint8), torch.ones(2, dtype=torch.float16),
        torch.ones(2, dtype=torch.bfloat16), torch.ones((), dtype=torch.float64))

if __name__ == "__main__":
    out = sys.argv[1]
    for kind, suffix in (("raw", "raw"), ("linalg-on-tensors", "linalg")):
        m = fx.export_and_import(F(), *ARGS, output_type=kind, func_name="dtypes")
        with open(os.path.join(out, f"dtypes.{suffix}.mlir"), "w") as f:
            f.write(str(m))
