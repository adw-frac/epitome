# Observed behaviour

Source: the output of LLVM's tools for small hand-written inputs, not the
documentation. Each rule here was found by running

```
clang -S -emit-llvm -x ir input.ll -o -
```

and reading what LLVM printed back, or what it rejected. LLVM's parser,
verifier and printer all run on the way through, so the output shows what
LLVM keeps, changes and drops. The tool was Apple clang 21.0.0
(clang-2100.3.34.2), observed on 2026-10-13.

Observed rules can change between LLVM versions. Each rule is covered by a
test in `ir/tests/metadata.rs`, so a change shows up when the expected
files are regenerated with a newer clang.

## Metadata identity

- **Uniquing.** Two nodes that are not `distinct` and have the same kind
  and operands are the same node. An inline `!DILocation(line: 4, column: 7,
  scope: !10)` and an identical numbered one print as the same `!N`. A node
  that refers to itself, such as `!0 = !{!0}`, is not merged with another
  such node.
- **`distinct` is required** for `!DICompileUnit`, `!DIAssignID`, and a
  `!DISubprogram` that is a definition (`spFlags: DISPFlagDefinition`). The
  parser rejects these without it: `missing 'distinct', required for
  !DIAssignID()`.
- **A `!DISubprogram` with no `spFlags` is a definition.** The flag defaults
  to set, so a declaration must say `spFlags: 0` (or other flags without
  `DISPFlagDefinition`).

## Numbering

LLVM does not keep the numbers in the input. It renumbers every node from
`!0` when printing:

- **Unused nodes are dropped.** A node that nothing refers to is not printed.
- **Inline nodes.** `!DIExpression(...)` and `!DIArgList(...)` are always
  written where they are used, never as `!N`, even if the input numbered
  them. Strings (`!"..."`) and typed values (`i32 7`) are also always inline.
  Every other node gets a number, including tuples written inline, such as
  `!annotation !{!"x"}`.
- **Order.** Numbers are given in the order nodes are first reached by this
  walk:
  1. the attachments of each global variable, in module order;
  2. the operands of each named metadata, in source order;
  3. each function in module order, declarations included: first the
     function's attachments, then for each instruction its debug records
     (arguments in order), its metadata call arguments, then its
     attachments.

  A node is numbered as soon as it is reached, then its operands are walked,
  depth first (pre-order). Inline nodes get no number, but their operands are
  still walked.
- **Operand order.** Operands are walked in printed field order, with these
  exceptions:

  | Kind | Walk order |
  | --- | --- |
  | `DIDerivedType`, `DICompositeType`, `DILexicalBlock`, `DILexicalBlockFile`, `DIModule` | `file`, then `scope`, then the rest in print order |
  | `DISubprogram` | `file`, `scope`, `type`, `unit`, `declaration`, `retainedNodes`, then the rest in print order (`containingType`, `templateParams`, `thrownTypes`, `annotations`) |

  These kinds walk in print order: `DICompileUnit`, `DISubroutineType`,
  `DISubrange`, `DIGenericSubrange`, `DITemplateTypeParameter`,
  `DITemplateValueParameter`, `DINamespace`, `DIGlobalVariable`,
  `DIGlobalVariableExpression`, `DILocation`, `DILocalVariable`, `DILabel`,
  `DIObjCProperty`, `DIImportedEntity`, `DIMacroFile`, `DICommonBlock`,
  `DIStringType`.

  Method: give every reference field of one node its own valid target node
  and read off the numbers LLVM assigns them.

## Attachment order

Attachments are printed sorted by kind, whatever order the input used. On
functions they are space-separated, on instructions comma-separated, and the
rule is the same for both. Built-in kinds come first, in this order:

`dbg`, `tbaa`, `prof`, `fpmath`, `range`, `tbaa.struct`, `invariant.load`,
`alias.scope`, `noalias`, `nontemporal`, `llvm.mem.parallel_loop_access`,
`nonnull`, `dereferenceable`, `dereferenceable_or_null`, `make.implicit`,
`unpredictable`, `invariant.group`, `align`, `llvm.loop`, `type`,
`section_prefix`, `absolute_symbol`, `associated`, `callees`, `irr_loop`,
`llvm.access.group`, `callback`, `vcall_visibility`, `noundef`, `annotation`,
`nosanitize`, `func_sanitize`, `exclude`, `memprof`, `callsite`, `kcfi_type`,
`pcsections`, `DIAssignID`, `coro.outside.frame`, `mmra`, `noalias.addrspace`.

Any other kind follows, in the order the module first uses it. That includes
kinds documented in the LangRef but not built in, such as `srcloc`,
`heapallocsite`, `loop`, `explicit` and `preserve.access.index`.

Method: put many kinds on one instruction in reverse order with one invalid
value, so the verifier's error message prints the instruction. The message
lists the attachments in sorted order. A kind that comes after a custom kind
such as `!zz` is not built in.

## Debug intrinsics

Calls to the old debug intrinsics become debug records, and the intrinsic
declarations are removed:

```
call void @llvm.dbg.value(metadata i32 %a, metadata !5, metadata !DIExpression()), !dbg !6
```

becomes

```
  #dbg_value(i32 %a, !5, !DIExpression(), !6)
```

The arguments move across unchanged, and the call's `!dbg` location becomes
the last argument. `llvm.dbg.declare`, `llvm.dbg.assign` and
`llvm.dbg.label` become `#dbg_declare`, `#dbg_assign` and `#dbg_label` the
same way. The record is attached to the instruction after the call.

## Dropping debug info

- **No debug-info version.** Without the module flag `!{i32 2, !"Debug Info
  Version", i32 3}`, debug-info attachments such as `!DIAssignID` and
  `!heapallocsite` are dropped silently.
- **Invalid debug info.** It is dropped with `warning: ignoring invalid debug
  info in <file>`, not rejected. Examples seen: a `#dbg_value` whose variable
  is not a `!DILocalVariable`, a scope of the wrong kind, a
  `!DICompileUnit` missing from `!llvm.dbg.cu`. The input still loads.

## Other rules seen

- **Named metadata operands** must be numbered references such as `!0`. An
  inline `!{...}` is rejected: `expected integer`.
- **Metadata arguments** are allowed only in calls to intrinsics: `Function
  has metadata parameter but isn't an intrinsic`. `@llvm.foo` is accepted
  and printed with a `; Unknown intrinsic` comment.
- **Debug-info fields are printed in a fixed order**, with some defaults
  always written. `!DICompileUnit` always shows `isOptimized:` and
  `runtimeVersion:`. Draconian keeps fields as written; see
  `docs/design/debug-info.md`.
- **`zeroinitializer` for target types.** It is rejected for
  `target("spirv.Image", void, 1)`: `invalid type for null constant`. Draconian
  accepts it today.

## The assembler

Found by assembling Draconian's own AArch64 assembly with
`clang --target=aarch64-linux-gnu -c` and reading the object file (Apple
clang 21.0.0, 2026-10-19). Draconian's object writer does the same, and
`codegen/tests/programs.rs` and `codegen/tests/sqlite.rs` check it does.

- **Calls to local functions in the same section are resolved** in place,
  with no relocation. Calls to global functions keep `R_AARCH64_CALL26`,
  even when defined in the same file.
- **References to local symbols are made against the section**: a section
  symbol, with the local symbol's offset as the addend (`.data+0x1b8`).
  `:got:` references stay against the symbol.
- **Relocated fields are zero**, the addend being in the RELA record.
- **Mapping symbols**: `$x` at the start of `.text`, and `$d` at the start
  of each data section that has contents or size, `.bss` included. Section
  symbols are emitted only for sections that relocations refer to.
- **`mov` with an immediate** is encoded as `movz` when the value is one
  16-bit piece at any shift, before trying `movn`: `mov w0, #-65536` is
  `movz w0, #0xffff, lsl #16`.
