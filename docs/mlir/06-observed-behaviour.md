# Observed behaviour

Source: running MLIR, torch-mlir, firtool, arcilator and circt-verilog on
our own inputs, as the clean-room rules allow (see the
[design index](../design/README.md)). Every rule here was found by running
a tool and reading what it printed, not by reading its source.

The chapters mark each of these where it applies, with **Observed:**. This
chapter collects them in one place, so that the reader and the lowering
can be checked against them, and lists the gaps that still need a probe.

## 1. Tools

| Tool | Version | Used in |
| --- | --- | --- |
| torch | 2.16.0.dev20261020 (CPU, macOS arm64) | [from PyTorch](04-from-pytorch.md) |
| torch-mlir | 20261001 nightly wheel; `torch-mlir-opt` reports LLVM 24.0.0git | [from PyTorch](04-from-pytorch.md) |
| firtool, arcilator, circt-verilog | CIRCT `firtool-1.162.0` (LLVM 24.0.0git), release `circt-full-static-macos-arm64` | [hardware](05-hardware.md) |
| Chisel | 7.16.0, Scala 2.13.18, through scala-cli 1.18.0 | [hardware](05-hardware.md) |
| clang | Apple clang 21.0.0 | both |

The inputs and every output are in [`examples/`](examples). Each
chapter's worked-examples section says which command made which file.

## 2. Textual form

| Rule | How found | Where |
| --- | --- | --- |
| A `dialect_resources` blob, such as a weight tensor in `dense_resource`, starts with a 4-byte little-endian word (`04000000`), apparently its alignment, then the data in little-endian order. | Exported an `8x4xf32` weight and compared the blob with the tensor: 4 + 128 bytes. | [from PyTorch §9](04-from-pytorch.md) |
| The printer names a constant's result after its value: `%int1`, `%int-128`, `%false`, `%none`, `%float5.000000e-02`, with `_0`, `_1` for repeats. | torch-mlir output. | [from PyTorch §4](04-from-pytorch.md) |
| `hw.module` prints its ports as one list in port order, `in %name : T` and `out name : T`. The rationale page still shows the older `(%in: i4) -> (twoX: i4)` form. | firtool `--ir-hw`. | [hardware §4](05-hardware.md) |
| FIRRTL constants have `!firrtl.const.uint<8>` before the passes run, and plain `!firrtl.uint<8>` after. | firtool `--parse-only` against `--ir-fir`. | [hardware §3](05-hardware.md) |
| firtool writes the `bin` (two-state) flag on every `comb` operation. `circt-verilog` writes it on some only. | Both tools on our counters. | [hardware §5](05-hardware.md) |

## 3. Lowering to LLVM IR

| Rule | How found | Where |
| --- | --- | --- |
| `mlir-translate`'s output writes float constants as bit patterns, `float f0xBDEED1D0`, except where a short decimal is exact. Both forms appear in one array. Apple clang 21 rejects `f0x`; Epitome's reader accepts it. | The MLP and conv2d `.ll`. | [from PyTorch §8](04-from-pytorch.md) |
| The `.ll` has `; ModuleID = 'LLVMDialectModule'`, a `"Debug Info Version"` module flag, and no target triple or data layout unless the MLIR module had them. | All three PyTorch `.ll` files. | [from PyTorch §8](04-from-pytorch.md), [llvm dialect §11](03-llvm-dialect.md) |
| A function with memref arguments takes each descriptor as its fields, and returns a descriptor as a struct by value. Called from C as if it returned a C struct, it gives garbage. The `_mlir_ciface_` wrapper, with pointers to descriptors, is the C-callable entry. | `harness_matmul_bias.c`. | [from PyTorch §8](04-from-pytorch.md) |
| Descriptors are built with `insertvalue`, returned whole, and in conv2d stored whole. | The PyTorch `.ll` files; `epitome-llc` stops on each. | [design §5.5](../design/mlir.md) |
| `memref.alloc` with `alignment = 64` becomes `malloc` of size plus alignment, then the pointer rounded up. Nothing is freed. conv2d calls `memrefCopy` from MLIR's C runner library. | The PyTorch `.ll` files. | [core dialects §8](02-core-dialects.md) |
| Signed and unsigned integer types (`si8`, `ui8`) become plain `i8` once lowered to builtin tensors. | `dtypes.linalg.mlir`. | [from PyTorch §4](04-from-pytorch.md) |
| A padded convolution's loops use `affine.apply`, and translation fails unless `lower-affine` runs first: "LLVM Translation failed for operation: builtin.unrealized_conversion_cast". | `lower.py` on conv2d. | [from PyTorch §8](04-from-pytorch.md) |

## 4. Hardware semantics

| Rule | How found | Where |
| --- | --- | --- |
| `comb.shl` and `comb.shru` by the width or more give 0; `comb.shrs` gives all sign bits. | Every `comb` operation lowered by arcilator (`examples/comb/`). | [hardware §5](05-hardware.md) |
| Division and remainder by zero divide by 1 instead: `divu x, 0` is `x`, `modu x, 0` is 0. | The same. | [hardware §5](05-hardware.md) |
| `comb.icmp` `ceq`, `cne`, `weq`, `wne` lower to `icmp eq` and `ne`. | The same. | [hardware §5](05-hardware.md) |
| arcilator cannot lower `comb.truth_table`: "failed to legalize operation". | The same. | [hardware §5](05-hardware.md) |
| FIRRTL result widths match the specification's table for every primitive operation. `mux` with inputs of different widths pads the narrower. | `firrtl/primops/PrimOps.fir`, `--parse-only`. | [hardware §2](05-hardware.md) |
| A public module's ports must have known widths. Registers may be declared without one and are inferred. | firtool errors and the GCD example. | [hardware §2](05-hardware.md) |
| Chisel 7.16.0 writes `FIRRTL version 7.0.0`, newer than the last released specification (6.0.0). firtool 1.162.0 reads it. | The Chisel examples. | [hardware §2](05-hardware.md) |

## 5. Arcilator's model

| Rule | How found | Where |
| --- | --- | --- |
| The state is one byte buffer. Inputs, outputs, registers, the old clock and arcilator's time and next-wakeup slots are at fixed offsets, naturally aligned; `--state-file` writes them as JSON. GCD's is 41 bytes. | `--state-file` and the offsets in the lowered IR. | [hardware §9](05-hardware.md) |
| `<top>_eval(ptr)` computes one step: combinational logic, then registers on a rising clock. A driver sets inputs in the buffer, toggles the clock and calls `eval` twice per cycle. | `gcd_driver.c`, run against Epitome's and clang's builds. | [hardware §10](05-hardware.md) |
| Without `--target-triple`, the data layout is the host's (`e-m:o-...` on macOS). | arcilator `--emit-llvm`. | [hardware §9](05-hardware.md) |
| The 64-tap FIR's `eval` has 8 blocks and 690 instructions; the largest blocks have 354 and 191. Both grow linearly with the design. | `chisel/fir64/`. | [hardware §9](05-hardware.md) |

## 6. Tools and packaging

| Rule | How found |
| --- | --- |
| The torch-mlir nightly wheel has a Python 3.12 build, and no `torch_mlir.torchscript`: the TorchScript path is gone from it. | Installing it. |
| The wheel's `torch-mlir-opt` has only torch-mlir's own passes. Upstream's (`one-shot-bufferize`, `convert-linalg-to-loops`, `convert-*-to-llvm`) are reachable through its Python `PassManager`, and `.ll` through `torch_mlir.dialects.llvm.translate_module_to_llvmir`. | `--help`, then `lower.py`. |
| `export_and_import` defaults to `strict=False`. With `experimental_support_mutation=True` it fails. A `torch.qint8` tensor fails with `KeyError: torch.qint8`. | `inspect.signature` and our scripts. |
| Marking a dimension dynamic with an example size of 1 fails ("specialized it to be a constant (1)"); size 2 works. | `export_extra.py`. |
| A quantise–dequantise matmul stays float in the TOSA output, with no `tosa.rescale`. `torch._int_mm` becomes `tosa.matmul` from `i8` to `i32`. | `extra_qmatmul`, `extra_int8matmul`. |

## 7. Still to probe

These are marked **Not documented** in the chapters, and each needs a
small input run through a tool:

| Question | Probe |
| --- | --- |
| The spellings of every float type keyword (`f8E4M3FN` and the rest, `tf32`) | `mlir-opt` on a function using each |
| `dense<"0x...">` hex form, `#loc` aliases, string escapes | `mlir-opt --mlir-print-op-generic` and `--mlir-print-debuginfo` on our inputs |
| The text form of the `llvm` dialect's attributes listed only by C++ class: TBAA, alias scopes, access groups, loop annotations, linkage, CConv, `#llvm.di_*` | `mlir-translate --import-llvm` on clang `.ll` files that have each, then print |
| Custom forms of `llvm.switch`, `invoke`, `landingpad`, `alloca`, and the `fcmp` predicates `_false` and `_true` | The same |
| What `mlir-translate` does with a `cond_br` to one block twice with different arguments | A hand-written input |
| Lowering of `cf.assert`, `ctlz` and `abs` poison flags, signed `floordiv` and `mod`, complex division | `mlir-opt --convert-to-llvm` on one function per operation |
| The bytecode format's section ids, version numbers and builtin encodings | `mlir-opt --emit-bytecode` on small inputs, read back byte by byte |
| arcilator's runtime interface (`arcRuntimeIR_*`) and its generated header | `arcilator --emit-llvm` with the runtime options, and the header it writes |
