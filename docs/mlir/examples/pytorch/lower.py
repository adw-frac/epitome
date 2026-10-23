"""Lower a linalg-on-tensors module to the llvm dialect and to LLVM IR.

Uses the upstream MLIR passes bundled in the torch-mlir wheel's Python
bindings (torch-mlir-opt does not register them).

Usage: python -I lower.py NAME.linalg.mlir OUTPREFIX

Every func.func gets the llvm.emit_c_interface attribute, so the output
also has a C-callable _mlir_ciface_NAME wrapper.

Writes OUTPREFIX.bufferized.mlir, OUTPREFIX.loops.mlir,
OUTPREFIX.llvm.mlir and OUTPREFIX.ll.
"""
import sys

from torch_mlir import ir, passmanager
from torch_mlir.dialects import llvm

STAGES = [
    ("bufferized", [
        # Tensors become memrefs. Function arguments and results too.
        "one-shot-bufferize{bufferize-function-boundaries "
        "function-boundary-type-conversion=identity-layout-map}",
        "canonicalize",
    ]),
    ("loops", [
        # linalg ops become scf.for nests of memref.load / memref.store.
        "convert-linalg-to-loops",
    ]),
    ("llvm", [
        "lower-affine",
        "convert-scf-to-cf",
        "expand-strided-metadata",
        "finalize-memref-to-llvm",
        "convert-arith-to-llvm",
        "convert-math-to-llvm",
        "convert-func-to-llvm",
        "convert-cf-to-llvm",
        "reconcile-unrealized-casts",
    ]),
]


def main(src_path, prefix):
    with ir.Context():
        module = ir.Module.parse(open(src_path).read())
        # Ask convert-func-to-llvm for a C-callable wrapper,
        # _mlir_ciface_NAME, that takes memref descriptors by pointer.
        for op in module.body.operations:
            if op.operation.name == "func.func":
                op.operation.attributes["llvm.emit_c_interface"] = ir.UnitAttr.get()
        for stage, passes in STAGES:
            pipeline = "builtin.module(" + ",".join(passes) + ")"
            passmanager.PassManager.parse(pipeline).run(module.operation)
            with open(f"{prefix}.{stage}.mlir", "w") as f:
                f.write(str(module))
        with open(f"{prefix}.ll", "w") as f:
            f.write(str(llvm.translate_module_to_llvmir(module.operation)))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
