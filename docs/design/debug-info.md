# Debug info

Status: plan. Smaugian reads and prints debug info but does not understand
it.

## Where we are

`smaugian-ir` stores a debug-info node such as `!DISubprogram(...)` as a
generic `Metadata::Node`: a kind name plus a list of fields. Each field is a
name and a value, where the value is a reference, a string, a typed value, or
a word kept as written (`42`, `true`, `DW_TAG_member`,
`DIFlagPrototyped | DIFlagAllCallsDescribed`). Debug records keep their
arguments as a plain list of metadata references.

That is enough to read clang's output and print it back exactly, including
LLVM's numbering. The rules in
[observed behaviour](../llvm-ir/08-observed-behaviour.md) are implemented in
`ir/src/metadata.rs`. Nothing looks inside a node, though:

- An unknown field name, a missing required field, a repeated field, or a
  value of the wrong kind (`line: "x"`) is accepted.
- Fields print in the order they were written. LLVM prints them in a fixed
  order and always writes some defaults, so hand-written input does not
  come back the way LLVM would print it.
- Unknown `DW_OP_*`, `DW_TAG_*`, `DW_ATE_*`, `DW_LANG_*` and `DIFlag*` names
  are accepted.
- Nothing checks the rules the LangRef and the verifier impose, for example
  that a scope is a scope or that a compile unit is listed in
  `!llvm.dbg.cu`. Invalid debug info is kept, where LLVM drops it.
- Nothing can read debug info without parsing words: no line tables, no
  variable locations, no types. Debug info can't be emitted, and the C
  API's `LLVMDIBuilder*` functions have nothing to build on.

## Goal

A typed model of every debug-info node and debug record, with:

1. a parser that checks field names, value kinds, required fields and
   `distinct`;
2. a printer that writes fields in LLVM's order and with LLVM's defaults;
3. a debug-info verifier that, like LLVM, drops invalid debug info with a
   warning rather than rejecting the module;
4. an API good enough for DWARF emission, passes that update debug info, and
   the C API's DIBuilder.

## Sources

The clean-room rules apply. Everything comes from:

- the LangRef section "Specialized Metadata Nodes", already summarized in
  [metadata](../llvm-ir/03-metadata.md);
- [Source Level Debugging](https://llvm.org/docs/SourceLevelDebugging.html),
  for `DIExpression` operations, debug records and the meaning of each
  field. It is listed under "Still to read" and is the first step;
- the DWARF 5 standard, for the `DW_TAG`, `DW_ATE`, `DW_LANG`, `DW_OP` and
  `DW_MACINFO` values;
- the C API documentation for `llvm-c/DebugInfo.h` (declarations only,
  pending the C API decision);
- observed clang output, for anything the documents leave out: field order,
  printed defaults and which errors are fatal. Probes follow the method in
  [observed behaviour](../llvm-ir/08-observed-behaviour.md).

## Model

Debug-info nodes become their own case of `Metadata`:

```rust
pub enum Metadata {
    Tuple { distinct: bool, ops: Vec<Option<MdId>> },
    Di { distinct: bool, node: Box<DiNode> },
    String(Vec<u8>),
    Value(Value),
    Forward,
}

pub enum DiNode {
    CompileUnit(DiCompileUnit),
    File(DiFile),
    BasicType(DiBasicType),
    DerivedType(DiDerivedType),
    CompositeType(DiCompositeType),
    SubroutineType(DiSubroutineType),
    Subprogram(DiSubprogram),
    Location(DiLocation),
    LocalVariable(DiLocalVariable),
    Expression(DiExpression),
    ArgList(Vec<Value>),
    // ... one variant per kind the LangRef lists
}

pub struct DiLocation {
    pub line: u32,
    pub column: u16,
    pub scope: MdId,
    pub inlined_at: Option<MdId>,
    pub implicit_code: bool,
}
```

- **Fields.** Each field gets its real type:
  - references: `MdId` or `Option<MdId>`;
  - text: `Option<Vec<u8>>`;
  - numbers: `u32`/`u64`/`i64`;
  - DWARF constants: small enums (`DwTag`, `DwAte`, `DwLang`, `DwVirtuality`, `DwCc`) with a `Numbered(u32)` escape for values we don't name;
  - flags: bitsets (`DiFlags`, `DiSpFlags`) printed with LLVM's names;
  - enumerations such as `EmissionKind`, `NameTableKind` and `ChecksumKind`.
- **Expressions.** `DiExpression` holds `Vec<DwOp>`. Each op knows how many
  operands it takes, so `DW_OP_LLVM_fragment, 0, 32` is one op.
- **Records.** `DebugRecord` becomes an enum (`Value`, `Declare`, `Assign`,
  `Label`) with named fields: `location`, `variable`, `expression`, `dl` and,
  for assign, `assign_id`, `address` and `address_expression`.
- **Field tables.** One table per kind lists each field's name, type,
  whether it is required, its default, whether the default is printed, and
  its walk-order position. The parser, printer, uniquing and numbering all
  read these tables, so LLVM's per-kind rules live in one place.
  `walk_children` in `metadata.rs` moves into them.
- **Uniquing** hashes the typed node, which needs no change to the
  algorithm.

The generic `Node` case goes away. LLVM rejects unknown `!Name(...)` kinds,
and so will we.

## Steps

| # | Step | Done when |
| --- | --- | --- |
| 1 | Read Source Level Debugging. Add a debug-info chapter to `docs/llvm-ir/` covering every node, field, flag, `DW_OP` and record. | Every field of every kind is listed with its meaning, or marked **Not documented**. |
| 2 | Probe clang for each kind: field print order, which defaults are always printed, which fields are required, which errors are fatal and which are warnings. Record results in the observed-behaviour chapter. | A golden pair (input and clang output) for every kind in `ir/tests/metadata/`. |
| 3 | Typed model, parser and printer. | The corpus and golden tests still match clang exactly. Hand-written fields in any order print in LLVM's order. |
| 4 | DWARF constant and flag enums, `DW_OP` table with operand counts. | Unknown names are parse errors with positions. |
| 5 | Typed debug records. | `#dbg_assign` with the wrong argument kinds is an error. |
| 6 | Debug-info verifier, run after parsing, with LLVM's choice of fatal error or drop-and-warn for each rule. This includes dropping debug info when the `Debug Info Version` flag is missing. | The invalid cases in step 2's probes behave like clang. |
| 7 | Builder API, shaped after `LLVMDIBuilderCreate*` so the C API can wrap it directly. | A Rust test builds a CU, file, subprogram, local variable and location, and prints the same text clang does for the equivalent C. |

Steps 1 and 2 need no code and can run in parallel. Steps 3 to 5 are one
change to `smaugian-ir`. Step 6 belongs with the IR verifier. Step 7 waits
for the C API decisions (source of declarations, target LLVM version).

## Open questions

- **Old syntax.** How much old syntax should we accept? LLVM upgrades some old
  forms when reading, as with the `llvm.dbg.*` calls. Each one we find goes in
  the observed-behaviour chapter and gets a test.
- **Unnamed DWARF values.** For tags and languages with no `DW_*` name, LLVM
  prints a number. We need to confirm by probing which fields allow that.
- **Typed or generic.** The typed model could stay behind the generic one,
  for example with `DiNode` computed on demand. Making it the only form is
  simpler and catches errors at parse time, so that is the plan unless the C
  API's needs say otherwise.
