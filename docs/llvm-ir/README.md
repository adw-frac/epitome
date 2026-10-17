# LLVM IR reference

This is Smaugian's own description of LLVM IR. It is written only from LLVM's
published documentation, never from LLVM source code. See the clean-room
rules in the [design index](../design/README.md).

The documentation was read on 2026-10-13 from llvm.org/docs. That site tracks
LLVM's development branch, not a numbered release.

## Chapters

| Chapter | Covers |
| --- | --- |
| [Module structure](01-module-structure.md) | Syntax, identifiers, globals, functions, linkage, calling conventions, attributes, data layout, target triple, memory model, fast-math flags |
| [Types and constants](02-types-and-constants.md) | Every type, constants and constant expressions, `undef` and `poison`, inline assembly |
| [Metadata](03-metadata.md) | Metadata nodes, debug info nodes, metadata kinds on instructions, module flags, ThinLTO summaries, special globals |
| [Instructions](04-instructions.md) | Every instruction, with syntax, type rules and semantics |
| [Intrinsics, part 1](05-intrinsics-a.md) | Intrinsic naming rules, varargs, GC, codegen, C library, bit manipulation, overflow and saturating arithmetic, vector and matrix intrinsics |
| [Intrinsics, part 2](06-intrinsics-b.md) | Vector predication, masked memory, constrained floating point, general intrinsics, stack maps, element-wise atomics, Objective-C ARC |
| [Bitcode format](07-bitcode.md) | The bitstream container and how IR is encoded in it |
| [Observed behaviour](08-observed-behaviour.md) | Rules the documents leave out, found from clang's output: metadata numbering and merging, attachment order, debug intrinsic upgrade |

## Sources

| Document | URL |
| --- | --- |
| LLVM Language Reference Manual | https://llvm.org/docs/LangRef.html |
| LLVM Bitcode File Format | https://llvm.org/docs/BitCodeFormat.html |
| Output of `clang -S -emit-llvm -x ir` for hand-written inputs | Chapter 8 only |

## Still to read

LangRef sends readers to these documents for details it leaves out. They are
public documentation, so they can fill the gaps marked in the chapters.

| Gap | Document |
| --- | --- |
| Full `DIExpression` operations, debug-info fields and flags, `llvm.dbg.*`, debug records | [Source Level Debugging](https://llvm.org/docs/SourceLevelDebugging.html) |
| `llvm.eh.*`, landing pads and funclets | [Exception Handling](https://llvm.org/docs/ExceptionHandling.html) |
| Convergence intrinsics and tokens | [Convergent Operation Semantics](https://llvm.org/docs/ConvergentOperations.html) |
| `llvm.ptrauth.*` | [Pointer Authentication](https://llvm.org/docs/PointerAuth.html) |
| `llvm.experimental.stackmap` and `patchpoint` | [Stack Maps](https://llvm.org/docs/StackMaps.html) |
| `!prof` branch weights and entry counts | [Branch Weight Metadata](https://llvm.org/docs/BranchWeightMetadata.html) |
| `!type` and type tests | [Type Metadata](https://llvm.org/docs/TypeMetadata.html) |
| GC statepoints and `gc.*` | [Garbage Collection Safepoints](https://llvm.org/docs/Statepoints.html) |

The bitcode document has no record layouts for constants, function bodies,
the value symbol table or metadata. No public document covers these, so
Smaugian will have to work them out from bitcode files that LLVM writes.

## Conventions

- **Smaugian note:** something the documentation implies for our
  implementation.
- **Not documented:** a question the documentation does not answer. Smaugian
  decides these for itself, and records the decision in the design docs.
- **Deprecated** and **Experimental** mark features the documentation labels
  that way.

Exact names, keywords and numbers are copied from the documentation because
Smaugian must read and write them. Explanations are in our own words.
