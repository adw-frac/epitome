# MLIR reference

This is Epitome's own description of MLIR, of the dialects that lead from
PyTorch and from Chisel to LLVM IR, and of the tools that produce them. It
is written only from published documentation and from running the tools on
our own inputs, never from source code. See the clean-room rules in the
[design index](../design/README.md) and in [the MLIR design](../design/mlir.md),
section 9.

The documentation was read on 2026-10-20 from mlir.llvm.org/docs,
circt.llvm.org/docs, the torch-mlir `docs/` pages, pytorch.org and the
FIRRTL specification. The MLIR and CIRCT sites track their development
branches, not numbered releases.

## Chapters

| Chapter | Covers |
| --- | --- |
| [The language](01-language.md) | Operations, regions, blocks and dialects; the lexical rules and the generic form's grammar; custom formats; dominance, graph regions and symbols; every builtin type, attribute and operation; affine maps and integer sets; the bytecode container; verification |
| [Core dialects](02-core-dialects.md) | `func`, `arith`, `math`, `index`, `cf`, `ub`, `scf`, `memref`, `tensor`, `bufferization`, `affine`, `vector`, `linalg` and `complex`, each operation with the LLVM IR it becomes |
| [The `llvm` dialect](03-llvm-dialect.md) | Its types, operations and attributes against LLVM IR; intrinsics; memref descriptors and calling conventions; the conversion passes; translation to `.ll` |
| [From PyTorch](04-from-pytorch.md) | `torch.export`, torch-mlir's FX importer, the `torch` dialect, the linalg-on-tensors, TOSA and StableHLO back ends, and the path down to LLVM IR, with worked examples |
| [Hardware](05-hardware.md) | Chisel, FIRRTL and its dialect, `hw`, `comb`, `seq`, `sv`, `emit`, the `moore` front end, and the `arc` dialect and arcilator, with worked examples |
| [Observed behaviour](06-observed-behaviour.md) | Rules the documents leave out, found by running the tools, and the probes still to run |

## Examples

[`examples/`](examples) holds real inputs and outputs, made by the tools
listed in [observed behaviour](06-observed-behaviour.md):

| Directory | What |
| --- | --- |
| `pytorch/` | An MLP, a matmul with bias and a conv2d, at every stage from `torch.export` to `.ll`; also an int8 matmul, a quantised matmul, a dynamic batch, a mutated buffer and dtype spellings. The scripts that made them, and a C harness. |
| `chisel/counter/`, `chisel/gcd/`, `chisel/fir/`, `chisel/fir64/`, `chisel/mem/` | Chisel source, FIRRTL, firtool's stages (`firrtl`, `hw`, `sv`), SystemVerilog, arcilator's stages, the `llvm` dialect and `.ll`. `gcd/` has a C driver and Epitome's assembly. |
| `firrtl/primops/` | Every FIRRTL primitive operation, through firtool |
| `comb/` | Every `comb` operation, lowered to LLVM IR by arcilator |
| `verilog/counter/` | A SystemVerilog counter through `circt-verilog`: `moore`, `llhd`, `hw` |

## Sources

| Document | URL |
| --- | --- |
| MLIR Language Reference | https://mlir.llvm.org/docs/LangRef/ |
| MLIR dialect pages | https://mlir.llvm.org/docs/Dialects/ |
| MLIR passes | https://mlir.llvm.org/docs/Passes/ |
| LLVM IR target | https://mlir.llvm.org/docs/TargetLLVMIR/ |
| Bufferization | https://mlir.llvm.org/docs/Bufferization/ |
| Bytecode format | https://mlir.llvm.org/docs/BytecodeFormat/ |
| CIRCT dialects and rationale | https://circt.llvm.org/docs/ |
| FIRRTL specification | https://github.com/chipsalliance/firrtl-spec |
| Chisel | https://www.chisel-lang.org/docs |
| torch-mlir documentation | https://github.com/llvm/torch-mlir/tree/main/docs |
| PyTorch export and IR | https://docs.pytorch.org/docs/stable/export.html |
| TOSA specification | https://www.mlplatform.org/tosa/tosa_spec.html |
| StableHLO specification | https://openxla.org/stablehlo/spec |
| Lattner et al., "MLIR: Scaling Compiler Infrastructure for Domain Specific Computation", CGO 2021 | https://arxiv.org/abs/2002.11054 |

Each chapter has a `Source:` line per section and a "Still to read" table
of the gaps it found.

## Conventions

As in [`docs/llvm-ir`](../llvm-ir/README.md):

- **Epitome note:** something the documentation implies for our
  implementation.
- **Not documented:** a question the documentation does not answer.
- **Observed:** a rule found by running a tool on our own inputs.

Exact names, keywords and syntax are copied from the documentation because
Epitome must read and write them. Explanations are in our own words.
