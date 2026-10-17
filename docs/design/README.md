# Smaugian design documents

These documents describe what Smaugian has to do to work like LLVM. They are
split into two halves:

- [IR and middle end](ir.md): the intermediate representation, the pass
  manager, and the analysis and transform passes that run on IR.
- [Code generation](codegen.md): lowering IR to machine code, from
  instruction selection to object file emission.
- [Debug info](debug-info.md): the plan for a typed debug-info model,
  parser, printer and verifier.

## Clean-room rules

Everything here comes from LLVM's published documentation only. No LLVM
source code was read to write these documents, and none may be read when
implementing them.

When the documentation leaves something out, the gap is marked **Open** and
Smaugian decides for itself. We do not fill a gap by looking at LLVM's source.

We may also run LLVM's tools, such as `clang -S -emit-llvm -x ir`, on our
own inputs and record what they print. Rules found this way are listed with
how they were found in
[observed behaviour](../llvm-ir/08-observed-behaviour.md).

### Sources

| Document | Used for |
| --- | --- |
| [LLVM's Analysis and Transform Passes](https://llvm.org/docs/Passes.html) | Every IR pass listed in `ir.md` |
| [Using the New Pass Manager](https://llvm.org/docs/NewPassManager.html) | Pass manager design and pipeline syntax |
| [The LLVM Target-Independent Code Generator](https://llvm.org/docs/CodeGenerator.html) | Codegen phases, data structures, SelectionDAG, register allocation, MC layer |
| [Global Instruction Selection](https://llvm.org/docs/GlobalISel/index.html) and [Core Pipeline](https://llvm.org/docs/GlobalISel/Pipeline.html) | GlobalISel passes and generic MIR |
| [Writing an LLVM Backend](https://llvm.org/docs/WritingAnLLVMBackend.html) | Backend components and pass hooks |
| [LLVM Language Reference](https://llvm.org/docs/LangRef.html) | IR semantics, to be cited per feature as it is built |

The pass list on the Passes page says it may be incomplete. Where we learn
about a pass from another public document, we add that source to the entry.

## Status labels

Each pass or component has one of these labels:

- **Planned**: in scope, not started.
- **Later**: in scope, but after the core works end to end.
- **Skip**: not needed for a functional clone, such as GraphViz viewers.
- **Done**: implemented and tested.
