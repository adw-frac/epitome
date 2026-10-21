# The LLVM Dialect and Translation to LLVM IR

Source: https://mlir.llvm.org/docs/Dialects/LLVM/,
https://mlir.llvm.org/docs/TargetLLVMIR/, https://mlir.llvm.org/docs/Passes/,
https://mlir.llvm.org/docs/DataLayout/ and
https://mlir.llvm.org/docs/Tutorials/Toy/Ch-6/. Read on 2026-10-20.

The `llvm` dialect is MLIR's copy of LLVM IR. Each op is one LLVM instruction,
intrinsic or module-level construct, so translating the dialect to a `.ll`
file is close to a one-to-one walk. This chapter covers the dialect's types,
ops and attributes; how the core dialects of the [previous
chapter](02-core-dialects.md) are converted into it; the memref descriptor and
calling conventions; and the translation to LLVM IR.

**Epitome note:** this dialect is the most likely way for Epitome to accept
MLIR directly. A reader for it needs no MLIR semantics beyond block arguments,
regions on globals, and `llvm.mlir.*` constant ops. Everything else is LLVM IR
that Epitome already models (see the [instructions
chapter](../llvm-ir/04-instructions.md)).

## 1. Overview

Producing LLVM IR from MLIR has two stages:

1. **Conversion.** Passes rewrite other dialects into the `llvm` dialect (or
   target dialects such as `nvvm` that also translate to LLVM IR). All real
   changes to the program happen here.
2. **Translation.** `mlir-translate --mlir-to-llvmir` (or the C++ function
   `translateModuleToLLVMIR`) walks the `llvm` dialect and builds an LLVM
   module. This step is meant to be simple and mechanical.

The dialect page states the rule: the semantics of each `llvm` op must be
those of the matching LLVM IR instruction, and any difference is a bug. Ops
that exist only to fit LLVM IR into MLIR's structure are named `llvm.mlir.*`,
for example `llvm.mlir.constant`.

**Not documented:** the exact command-line name of the export flag. The docs
show `mlir-translate -import-llvm` for the reverse direction, and the Toy
tutorial calls `translateModuleToLLVMIR`. `--mlir-to-llvmir` is the name in
common use and in our scripts (which call the Python binding
`translate_module_to_llvmir`).

## 2. Module structure

Source: https://mlir.llvm.org/docs/Dialects/LLVM/, sections "Module Structure"
to "Attribute Pass-Through".

### 2.1 Module, data layout and triple

An LLVM module is a builtin `module`. It may be named and nested, and may hold
any ops. The data layout and target triple are string attributes on the
module, in LLVM IR syntax, and are checked:

```
module attributes {llvm.data_layout = "e",
                   llvm.target_triple = "aarch64-linux-android"} {
  // module contents
}
```

They become `target datalayout = "e"` and `target triple = "aarch64-linux-android"`.

**Not documented:** the dialect page text names the triple attribute
`llvm.triple`, but its own example uses `llvm.target_triple`. We take the
example as correct. Separately, MLIR has its own data layout model (`dlti`,
section 8.2); `-set-llvm-module-datalayout` writes `llvm.data_layout` from a
string option `data-layout`, and `-llvm-target-to-data-layout` derives a DLTI
layout from an `llvm.target` attribute.

### 2.2 Block arguments instead of `phi`

MLIR has no `phi`. A terminator passes values to its successor's block
arguments. The translator creates one `phi` per block argument, then fills in
the incoming values once the whole function is translated.

```
^bb1:
  %0 = llvm.add %arg0, %cst : i32
  llvm.br ^bb2(%0 : i32)
^bb2(%arg1: i32):
```

is LLVM IR `%arg1 = phi i32 [ %0, %bb1 ], ...`.

A terminator may branch to the same block twice with different values:

```
^bb1:
  llvm.cond_br %cond, ^bb2(%0 : i32), ^bb2(%1 : i32)
^bb2(%arg0: i32):
```

**Epitome note:** LLVM IR cannot express this with one `phi`, since both
edges come from the same block. A reader must insert a block on one edge.
**Not documented:** what the translator does here.

### 2.3 Constants are ops

LLVM IR uses constants directly as operands. MLIR has no such values (for
thread safety), so constants are produced by ops:

| Op | Example | LLVM IR |
| --- | --- | --- |
| `llvm.mlir.constant` | `%3 = llvm.mlir.constant(42 : i32) : i32` | `i32 42` |
| `llvm.mlir.undef` | `%0 = llvm.mlir.undef : !llvm.struct<(i32, f32)>` | `undef` |
| `llvm.mlir.poison` | `%0 = llvm.mlir.poison : i32` | `poison` |
| `llvm.mlir.zero` | `%1 = llvm.mlir.zero : !llvm.ptr` | `null` / `zeroinitializer` |
| `llvm.mlir.none` | `%0 = llvm.mlir.none : !token` | `none` token |
| `llvm.mlir.addressof` | `%0 = llvm.mlir.addressof @const : !llvm.ptr` | `@const` |

`llvm.mlir.constant` takes a scalar integer or float attribute (the type may
be left out for `i64` and `f64`), a dense, array or sparse attribute for a
vector, a string for an `[N x i8]` array, an array attribute for a struct, or
nested arrays (with zero or undef leaves) for an array of structs.

```
%1 = llvm.mlir.constant(42) : i64
%2 = llvm.mlir.constant(42.0 : f32) : f32
%3 = llvm.mlir.constant(dense<1.0> : vector<4xf32>) : vector<4xf32>
```

The type appears twice: once on the attribute (a builtin type) and once on the
result (an LLVM type). They must agree.

**Epitome note:** the translator folds these ops back into constant operands.
A constant op used in many places becomes the same LLVM constant each time.
Observed output from `index` constants prints as
`llvm.mlir.constant(2 : index) : i64`.

### 2.4 Globals and linkage

Globals are `llvm.mlir.global` ops at module level. Functions are `llvm.func`.
Both may have a linkage keyword between the op name and the symbol; with no
keyword the linkage is `external`. Linkage is separate from MLIR symbol
visibility (`private` in MLIR only limits who may refer to the symbol inside
MLIR).

The linkage keywords are LLVM's own: `private`, `internal`, `available_externally`,
`linkonce`, `weak`, `common`, `appending`, `extern_weak`, `linkonce_odr`,
`weak_odr`, `external`. **Not documented:** the dialect page does not list
them; it says only "the same keyword as in LLVM IR".

### 2.5 Attribute pass-through

`passthrough` on `llvm.func` forwards function attributes by name. It is meant
for prototyping only.

```
llvm.func @func() attributes {
  passthrough = ["readonly",           // no value
                 ["alignstack", "4"],  // with a value, as a string
                 ["other", "attr"]]    // unknown to LLVM: becomes "other"="attr"
} {
  llvm.return
}
```

## 3. Types

Source: https://mlir.llvm.org/docs/Dialects/LLVM/, section "Types".

The dialect uses builtin types where they exist, and adds `!llvm.*` types for
the rest. Every LLVM IR type has exactly one MLIR spelling. Inside angle
brackets the `!llvm.` prefix may be dropped: `!llvm.struct<(ptr, f32)>` is the
canonical form of `!llvm.struct<(!llvm.ptr, f32)>`. There are no named type
declarations at module level; types are written out in full, or with MLIR
type aliases.

| MLIR type | LLVM IR type | Notes |
| --- | --- | --- |
| `i1`, `i8`, ..., `iN` | `iN` | Signless only; `si32`/`ui32` are not allowed. |
| `bf16`, `f16`, `f32`, `f64`, `f80`, `f128` | `bfloat`, `half`, `float`, `double`, `x86_fp80`, `fp128` | |
| `!llvm.ppc_fp128` | `ppc_fp128` | |
| `vector<4xi32>` | `<4 x i32>` | 1-D only. Elements may be integers, floats or `!llvm.ptr`. |
| `vector<[4]xi32>` | `<vscale x 4 x i32>` | Scalable. |
| `!llvm.ptr` | `ptr` | Opaque pointer. |
| `!llvm.ptr<3>` | `ptr addrspace(3)` | Address space as an integer. |
| `!llvm.array<4 x i32>` | `[4 x i32]` | Nest for more dimensions. |
| `!llvm.struct<(i32, f32)>` | `{ i32, float }` | Literal struct. |
| `!llvm.struct<packed (i8, i32)>` | `<{ i8, i32 }>` | Packed literal struct. |
| `!llvm.struct<"a", (i32, ptr)>` | `%a = type { i32, ptr }` | Identified struct. |
| `!llvm.struct<"a", opaque>` | `%a = type opaque` | |
| `!llvm.struct<"a">` | reference to `%a` | Only inside another struct, for recursion. |
| `!llvm.func<i32 (f32, i32)>` | `i32 (float, i32)` | Exactly one result, `void` allowed. `, ...` for varargs. |
| `!llvm.void` | `void` | Only as a function result. |
| `!llvm.metadata` | `metadata` | Only when the metadata cannot be an attribute. |
| `!token` | `token` | Builtin token type. |
| (none) | `label` | Blocks are not values in MLIR. |

Struct details:

- `!llvm.struct<>` is not allowed; the empty literal struct is
  `!llvm.struct<()>`, and the empty identified struct `!llvm.struct<"a", ()>`.
- Identified structs are unique by name within the context, not per module.
  MLIR does not rename them on a clash. Once a body is set it cannot change.
- An identified struct may be created without a body and filled in later,
  which is how recursive types are built.

Functions are not first-class values: there is no value of `!llvm.func` type.
Take the address with `llvm.mlir.addressof` and call through the pointer.

**Not documented:** the type section does not mention LLVM's target
extension types (`target("...")`), `x86_amx`, or the byte type. Whether the
dialect can express them is unknown from the docs.

## 4. Operations

Source: https://mlir.llvm.org/docs/Dialects/LLVM/, section "Operations".

Every op's name is the LLVM IR opcode prefixed with `llvm.`. The tables give
the custom form and the LLVM instruction. Flags in square brackets are
optional and print in the positions shown.

### 4.1 Integer and float arithmetic

| Op | Custom form | LLVM IR |
| --- | --- | --- |
| `llvm.add` | `%r = llvm.add %a, %b overflow<nsw, nuw> : i64` | `add nuw nsw` |
| `llvm.sub` | `%r = llvm.sub %a, %b [overflow<...>] : i64` | `sub` |
| `llvm.mul` | `%r = llvm.mul %a, %b [overflow<...>] : i64` | `mul` |
| `llvm.shl` | `%r = llvm.shl %a, %b [overflow<...>] : i64` | `shl` |
| `llvm.udiv` / `llvm.sdiv` | `%r = llvm.sdiv exact %a, %b : i32` | `udiv` / `sdiv [exact]` |
| `llvm.urem` / `llvm.srem` | `%r = llvm.urem %a, %b : i64` | `urem` / `srem` |
| `llvm.lshr` / `llvm.ashr` | `%r = llvm.lshr exact %a, %b : i32` | `lshr` / `ashr [exact]` |
| `llvm.and` / `llvm.xor` | `%r = llvm.and %a, %b : i32` | `and` / `xor` |
| `llvm.or` | `%r = llvm.or disjoint %a, %b : i32` | `or [disjoint]` |
| `llvm.fadd` / `fsub` / `fmul` / `fdiv` / `frem` | `%r = llvm.fadd %a, %b fastmath<fast> : f32` | `fadd` etc. with fast-math flags |
| `llvm.fneg` | `%r = llvm.fneg %a : f32` | `fneg` |

Note that `exact` and `disjoint` come before the operands, but
`overflow<...>` and `fastmath<...>` come after them. All forms come from the
syntax lines on the dialect page; the `overflow<nsw, nuw>` and `exact`
positions are also observed.

### 4.2 Conversions

All have the form `%r = llvm.<op> %x : <from> to <to>`.

| Op | Extra syntax | LLVM IR |
| --- | --- | --- |
| `llvm.trunc` | `[overflow<nsw, nuw>]` after the operand | `trunc [nuw] [nsw]` |
| `llvm.zext` | `nneg` before the operand | `zext [nneg]` |
| `llvm.sext` | | `sext` |
| `llvm.fptrunc` / `llvm.fpext` | `[fastmath<...>]` | `fptrunc` / `fpext` |
| `llvm.fptoui` / `llvm.fptosi` | | `fptoui` / `fptosi` |
| `llvm.uitofp` | `nneg` before the operand | `uitofp [nneg]` |
| `llvm.sitofp` | | `sitofp` |
| `llvm.ptrtoint` | | `ptrtoint` |
| `llvm.ptrtoaddr` | | `ptrtoaddr` |
| `llvm.inttoptr` | `[dereferenceable<...>]` | `inttoptr` with `!dereferenceable` metadata |
| `llvm.bitcast` | | `bitcast` |
| `llvm.addrspacecast` | | `addrspacecast` |

### 4.3 Comparison, select, freeze

| Op | Custom form | LLVM IR |
| --- | --- | --- |
| `llvm.icmp` | `%r = llvm.icmp "slt" %a, %b : i64` | `icmp slt` |
| `llvm.fcmp` | `%r = llvm.fcmp "ugt" %a, %b [fastmath<...>] : f32` | `fcmp ugt` |
| `llvm.select` | `%r = llvm.select %c, %a, %b [fastmath<...>] : i1, f32` | `select` |
| `llvm.freeze` | `%r = llvm.freeze %x : i32` | `freeze` |

The predicate prints as a quoted string (observed: `llvm.icmp "slt"`,
`llvm.fcmp "ugt"`). `icmp` accepts integers, pointers and vectors of them.
The predicate names are LLVM's: `eq ne slt sle sgt sge ult ule ugt uge` and
`_false oeq ogt oge olt ole one ord ueq ugt uge ult ule une uno _true`.

**Not documented:** the dialect page does not list the predicate enums; the
names above are LLVM's, and `_false`/`_true` for the constant `fcmp`
predicates is our assumption from the generic enum style.

### 4.4 Memory

| Op | Custom form | LLVM IR |
| --- | --- | --- |
| `llvm.alloca` | `%9 = llvm.alloca %8 x !llvm.struct<(...)> : (i64) -> !llvm.ptr` | `alloca` |
| `llvm.load` | `%0 = llvm.load %ptr : !llvm.ptr -> f32` | `load` |
| `llvm.store` | `llvm.store %val, %ptr : f32, !llvm.ptr` | `store` |
| `llvm.getelementptr` | `%0 = llvm.getelementptr inbounds %1[3] : (!llvm.ptr) -> !llvm.ptr, f32` | `getelementptr` |
| `llvm.fence` | `llvm.fence [syncscope("agent")] acquire` | `fence` |
| `llvm.atomicrmw` | `%r = llvm.atomicrmw add %ptr, %v monotonic : !llvm.ptr, i32` | `atomicrmw` |
| `llvm.cmpxchg` | `%r = llvm.cmpxchg %ptr, %cmp, %new acq_rel monotonic : !llvm.ptr, i32` | `cmpxchg` (result `{ i32, i1 }`) |
| `llvm.va_arg` | `%r = llvm.va_arg %list : (!llvm.ptr) -> i32` | `va_arg` |

`llvm.alloca` has attributes `alignment`, `elem_type` and `inalloca`.

`llvm.load` and `llvm.store` options, from the syntax and examples:

```
%0 = llvm.load volatile %ptr : !llvm.ptr -> f32
%0 = llvm.load %ptr <nontemporal> : !llvm.ptr -> f32           // as printed in the docs
%0 = llvm.load %ptr noundef : !llvm.ptr -> i32
%0 = llvm.load %ptr range<i32, 0, 10> : !llvm.ptr -> i32
%0 = llvm.load %ptr atomic monotonic <alignment = 8> : !llvm.ptr -> i64
llvm.store %val, %ptr atomic monotonic <alignment = 8> : i64, !llvm.ptr
```

The keywords `invariant`, `invariant_group`, `dereferenceable<...>`, `noundef`
and `range<...>` map to the LLVM metadata `!invariant.load`,
`!invariant.group`, `!dereferenceable`/`!dereferenceable_or_null`, `!noundef`
and `!range`. An atomic load or store needs an explicit alignment.

`llvm.getelementptr`:

- Indices may be constants written inline or SSA values. Indices into a
  struct must be constants.
- The source element type is written last, after the function type:
  `: (!llvm.ptr, i64) -> !llvm.ptr, f32` is `getelementptr float, ptr %p, i64 %i`.
- No-wrap flags `inbounds`, `nusw`, `nuw`, combined with `|`. `inbounds`
  implies `nusw`. Observed: `llvm.getelementptr inbounds|nuw`.
- `inrange <i64, -16, 8>` models `inrange(-16, 8)`; LLVM allows it only on
  constant expressions.

### 4.5 Aggregates and vectors

| Op | Custom form | LLVM IR |
| --- | --- | --- |
| `llvm.extractvalue` | `%1 = llvm.extractvalue %0[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1xi64>, array<1xi64>)>` | `extractvalue ..., 3, 0` |
| `llvm.insertvalue` | `%1 = llvm.insertvalue %v, %0[0] : !llvm.struct<(i32, i64)>` | `insertvalue` |
| `llvm.extractelement` | `%r = llvm.extractelement %v[%i : i32] : vector<4xf32>` | `extractelement` |
| `llvm.insertelement` | `%r = llvm.insertelement %x, %v[%i : i32] : vector<4xf32>` | `insertelement` |
| `llvm.shufflevector` | `%r = llvm.shufflevector %a, %b [0, 1, 4, 5] : vector<4xf32>` | `shufflevector` |

The mask of `shufflevector` is a constant integer array; the docs give no
example of how `poison` lanes are written. **Not documented:** we expect `-1`.

### 4.6 Control flow

| Op | Custom form | LLVM IR |
| --- | --- | --- |
| `llvm.br` | `llvm.br ^bb1(%17 : i64)` | `br label` |
| `llvm.cond_br` | `llvm.cond_br %c weights([90, 10]), ^bb2, ^bb6` | `br i1` with `!prof` |
| `llvm.switch` | `llvm.switch %v : i32, ^def [ 1: ^bb1, 2: ^bb2 ]` | `switch` |
| `llvm.indirectbr` | `llvm.indirectbr %addr : !llvm.ptr, [^bb1, ^bb2]` | `indirectbr` |
| `llvm.return` | `llvm.return %v : i32` | `ret` |
| `llvm.unreachable` | `llvm.unreachable` | `unreachable` |
| `llvm.resume` | `llvm.resume %v : !llvm.struct<(ptr, i32)>` | `resume` |
| `llvm.invoke` | `llvm.invoke @f(%a) to ^ok unwind ^bad : (i32) -> i32` | `invoke` |
| `llvm.landingpad` | `%lp = llvm.landingpad cleanup : !llvm.struct<(ptr, i32)>` | `landingpad` |

`br` and `cond_br` may carry `loop_annotation = #llvm.loop_annotation<...>`,
which becomes `!llvm.loop` metadata. `cond_br`, `switch` and `invoke` take
`branch_weights` (`!prof`).

`llvm.blocktag <id = 1>` marks a block, and
`llvm.blockaddress <function = @f, tag = <id = 1>> : !llvm.ptr` takes its
address (LLVM `blockaddress(@f, %bb)`).

**Not documented:** the custom forms of `llvm.switch`, `llvm.indirectbr`,
`llvm.invoke` and `llvm.landingpad`; the forms above are reconstructed from
their syntax lines and operand lists. The funclet EH instructions
(`catchswitch`, `catchpad`, `cleanuppad`, `catchret`, `cleanupret`) and
`callbr` have no ops in the dialect.

### 4.7 Calls and inline assembly

```
%0 = llvm.call @foo() : () -> (f32)
llvm.call @bar(%0) : (f32) -> ()
%1 = llvm.mlir.addressof @foo : !llvm.ptr
llvm.call %1(%0) : !llvm.ptr, (f32) -> ()
llvm.call @printf(%0, %1) vararg(!llvm.func<i32 (ptr, ...)>) : (!llvm.ptr, i32) -> i32
```

- A direct call names a symbol (`callee`); an indirect call's first operand
  is an `!llvm.ptr`.
- A call to a variadic function must give the LLVM function type in
  `vararg(...)` (`var_callee_type`).
- Calls return 0 or 1 values. The trailing MLIR type uses `()` for no result,
  not `void`.
- Attributes: `CConv`, `TailCallKind`, `fastmathFlags`, `memory_effects`,
  `convergent`, `no_unwind`, `will_return`, `noreturn`, `returns_twice`,
  `hot`, `cold`, `noduplicate`, `no_inline`, `always_inline`, `inline_hint`,
  `nobuiltin`/`builtin`, `allocsize`, `optsize`, `minsize`,
  operand bundles (`op_bundle_sizes`, `op_bundle_tags`), `arg_attrs`,
  `res_attrs`, and the memory metadata `access_groups`, `alias_scopes`,
  `noalias_scopes`, `tbaa`.

`llvm.call_intrinsic` calls an intrinsic by name (`intrin`), using the op's
MLIR function type to pick the overload. It is the escape hatch for
intrinsics that have no dedicated op.

`llvm.inline_asm`:

```
operation ::= `llvm.inline_asm` (`has_side_effects`)? (`is_align_stack`)?
              (`tail_call_kind` `=` $tail_call_kind)? (`convergent`)?
              (`asm_dialect` `=` $asm_dialect)? (`operand_attrs` `=` $operand_attrs)?
              attr-dict $asm_string `,` $constraints operands `:` functional-type(operands, results)
```

`asm_dialect` is ATT (0) or Intel (1). Unlike LLVM IR, the asm string may not
name any symbol or global; doing so is undefined behaviour in MLIR. `musttail`
is not allowed.

### 4.8 Module-level ops

| Op | Example | LLVM IR |
| --- | --- | --- |
| `llvm.func` | `llvm.func internal @f(%arg0: i64) -> i64 { llvm.return %arg0 : i64 }` | `define` / `declare` |
| `llvm.mlir.global` | `llvm.mlir.global internal constant @cst(42 : i32) : i32` | global variable |
| `llvm.mlir.alias` | `llvm.mlir.alias external @foo_alias {addr_space = 0 : i32} : !llvm.ptr { ... }` | `alias` |
| `llvm.mlir.ifunc` | `llvm.mlir.ifunc @f : !llvm.func<void ()>, !llvm.ptr @resolver` | `ifunc` |
| `llvm.comdat` / `llvm.comdat_selector` | see 4.9 | `$name = comdat any` |
| `llvm.mlir.global_ctors` | `llvm.mlir.global_ctors ctors = [@ctor], priorities = [0], data = [#llvm.zero]` | `@llvm.global_ctors` |
| `llvm.mlir.global_dtors` | same with `dtors` | `@llvm.global_dtors` |
| `llvm.module_flags` | `llvm.module_flags [#llvm.mlir.module_flag<error, "wchar_size", 4>]` | `!llvm.module.flags` |
| `llvm.named_metadata` | | named metadata `!name = !{...}` |
| `llvm.linker_options` | `llvm.linker_options ["/DEFAULTLIB:", "libcmt"]` | `!llvm.linker.options` |
| `llvm.dso_local_equivalent` | `%r = llvm.dso_local_equivalent @f : !llvm.ptr` | `dso_local_equivalent @f` |
| `llvm.mlir.metadata_as_value` | `%nr = llvm.mlir.metadata_as_value #llvm.md_node<#llvm.md_string<"sp">> : !llvm.metadata` | `metadata !{!"sp"}` operand |

`llvm.func`:

```
llvm.func @bar(%arg0: i64) -> i64 {     // i64 (i64)
  llvm.return %arg0 : i64
}
llvm.func @foo(%arg0: i64) {            // void (i64); !llvm.void is not written
  llvm.return
}
llvm.func internal @internal_func() {
  llvm.return
}
llvm.func @malloc(i64) -> !llvm.ptr     // declaration
llvm.func @printf(!llvm.ptr, ...) -> i32
```

Its attribute list is long. The ones with direct LLVM equivalents are:
`linkage`, `dso_local`, `CConv`, `comdat`, `personality`, `garbageCollector`
(`gc`), `section`, `unnamed_addr`, `visibility_`, `alignment`, `arg_attrs`,
`res_attrs`, `memory_effects`, `function_entry_count` (`!prof`),
`vscale_range`, `frame_pointer`, `target_cpu`, `tune_cpu`, `target_features`,
`prefer_vector_width`, `reciprocal_estimates`, `denormal_fpenv`,
`no_signed_zeros_fp_math`, `fp_contract`, `instrument_function_entry`/`exit`,
`no_inline`, `always_inline`, `inline_hint`, `no_unwind`, `will_return`,
`noreturn`, `optimize_none`, `returns_twice`, `hot`, `cold`, `noduplicate`,
`convergent`, `nobuiltins`, `allocsize`, `optsize`, `minsize`,
`zero_call_used_regs`, `uwtable_kind`, `use_sample_profile`,
`disable_tail_calls`, the `arm_*` streaming and ZA attributes, the OpenCL
work-group attributes, and `passthrough` for anything else.

`llvm.mlir.global`:

```
llvm.mlir.global @variable(32.0 : f32) : f32
llvm.mlir.global @string("abc") : !llvm.array<3 x i8>         // no implicit \00
llvm.mlir.global constant @no_trailing_type("foo bar")
llvm.mlir.global private constant @y(dense<1.0> : tensor<8xf32>) { alignment = 32 : i64 } : !llvm.array<8 x f32>
llvm.mlir.global constant @int_gep() : !llvm.ptr {               // initialiser region
  %0 = llvm.mlir.addressof @g2 : !llvm.ptr
  %1 = llvm.mlir.constant(2 : i32) : i32
  %2 = llvm.getelementptr %0[%1] : (!llvm.ptr, i32) -> !llvm.ptr, i32
  llvm.return %2 : !llvm.ptr
}
```

- Either an initial-value attribute or an initialiser region, not both. The
  region computes a constant expression and ends in `llvm.return`.
- Order: linkage, then `constant`, then the name.
- Other attributes: `dso_local`, `tls_mode`, `externally_initialized`,
  `addr_space`, `unnamed_addr`, `section`, `comdat`, `visibility_`,
  `associated` (`!associated`), `absolute_symbol` (`!absolute_symbol`, pairs
  of `[lower, upper)`; `[-1, -1]` is the full set), `dbg_exprs`, and
  `target_specific_attrs` (attribute pass-through for globals).
- A dense tensor initialiser fills an array type, row-major. Observed:
  `dense_resource<...> : tensor<8x4xf32>` with type
  `!llvm.array<8 x array<4 x f32>>`.

**Epitome note:** an initialiser region is the MLIR way to write a constant
expression. The translator must fold the region into one LLVM constant, so
only ops that can form a constant expression may appear in it.

### 4.9 Comdats

```
llvm.comdat @__llvm_comdat {
  llvm.comdat_selector @any any
}
llvm.mlir.global internal constant @has_any_comdat(1 : i64) comdat(@__llvm_comdat::@any) : i64
```

A comdat op is a symbol table; each selector inside it is one LLVM comdat with
a selection kind (`any`, `exactmatch`, `largest`, `nodeduplicate`,
`samesize`). The pass `-llvm-add-comdats` gives every `linkonce` and
`linkonce_odr` function an `any` comdat.

## 5. Attributes

Source: the attribute columns of each op on https://mlir.llvm.org/docs/Dialects/LLVM/.

The dialect page lists attributes by their C++ class and a one-line
description. It does not give the textual syntax of most of them.

| Attribute | Class | Used on | LLVM IR |
| --- | --- | --- | --- |
| Linkage | `LinkageAttr` | `func`, `mlir.global`, `mlir.alias`, `mlir.ifunc` | linkage keyword |
| Fast-math | `FastmathFlagsAttr`, printed `fastmath<...>` | float ops, `fcmp`, `select`, `call`, float intrinsics | `nnan ninf nsz arcp contract afn reassoc` / `fast` |
| Overflow flags | printed `overflow<nsw, nuw>` | `add`, `sub`, `mul`, `shl`, `trunc` | `nsw` / `nuw` |
| `exact`, `disjoint`, `nneg` | unit attributes | `udiv sdiv lshr ashr`; `or`; `zext uitofp` | same keywords |
| GEP no-wrap | `inbounds`, `nusw`, `nuw` | `getelementptr` | same keywords |
| Calling convention | `CConvAttr` | `func`, `call`, `invoke` | `fastcc`, `ccc`, ... |
| Tail call kind | `TailCallKindAttr` | `call`, `inline_asm` | `tail`, `musttail`, `notail` |
| Comdat | `comdat::ComdatAttr` | selectors | comdat kind |
| Atomic ordering | `AtomicOrderingAttr` | `load`, `store`, `fence`, `atomicrmw`, `cmpxchg` | `unordered` ... `seq_cst` |
| Sync scope | string, `syncscope("...")` | atomics, `fence` | `syncscope("...")` |
| RMW operation | `AtomicBinOpAttr` | `atomicrmw` | `xchg add sub and nand or xor max min umax umin fadd fsub fmax fmin` ... |
| Visibility | `VisibilityAttr` | globals, functions | `default`, `hidden`, `protected` |
| Unnamed addr | `UnnamedAddrAttr` | globals, functions | `unnamed_addr`, `local_unnamed_addr` |
| TLS mode | `ThreadLocalModeAttr` | globals | `thread_local(...)` |
| TBAA | array of TBAA tags | memory ops, `call`, mem intrinsics | `!tbaa` |
| Alias scopes | `alias_scopes`, `noalias_scopes` arrays of `AliasScopeAttr` | memory ops | `!alias.scope`, `!noalias` |
| Access groups | `access_groups` array | memory ops | `!llvm.access.group` |
| Loop annotation | `LoopAnnotationAttr` | `br`, `cond_br` | `!llvm.loop` |
| Branch weights | `i32` dense array | `cond_br`, `switch`, `invoke` | `!prof !{"branch_weights", ...}` |
| Memory effects | `MemoryEffectsAttr` | `func`, `call` | `memory(...)` |
| Dereferenceable | `DereferenceableAttr` (`bytes`, `mayBeNull`) | `load` of a pointer, `inttoptr` | `!dereferenceable`, `!dereferenceable_or_null` |
| Constant range | `ConstantRangeAttr`, `<i32 lower, upper>` | `load` `range`, GEP `inrange` | `!range`, `inrange(...)` |
| Function entry count | `FunctionEntryCountAttr` | `func` | `!prof !{"function_entry_count", ...}` (or synthetic) |
| Target features | `TargetFeaturesAttr`, `#llvm.target_features<["+sme", "+sve"]>` | `func` | `"target-features"` |
| Frame pointer, UW table, vscale range, denormal mode | `FramePointerKindAttr`, `UWTableKindAttr`, `VScaleRangeAttr`, `DenormalFPEnvAttr` | `func` | `"frame-pointer"`, `uwtable`, `vscale_range`, `denormal_fpenv` |
| Rounding mode, exception behaviour | `RoundingModeAttr`, `FPExceptionBehaviorAttr` | constrained intrinsics | metadata strings like `"round.tonearest"` |
| Metadata values | `#llvm.md_string<"...">`, `#llvm.md_const<0 : i32>`, `#llvm.md_node<...>`, `#llvm.md_global_value<@g>`, md_null, md_addrspacecast | `mlir.metadata_as_value`, named metadata | metadata nodes |
| Module flag | `#llvm.mlir.module_flag<behaviour, "key", value>` | `module_flags` | `!{i32 1, !"key", ...}` |

**Not documented:** the textual syntax of TBAA tags, alias scopes, access
groups, loop annotations, linkage and calling-convention attributes. The
`Dialects/LLVM` page lists only their C++ class names. The RFC discussions
that introduced them are forum posts, not reference docs. We must find the
syntax by printing our own inputs with the tools.

**Epitome note:** every attribute in the table above maps to a construct the
[module structure](../llvm-ir/01-module-structure.md) and
[metadata](../llvm-ir/03-metadata.md) chapters already describe. MLIR keeps
metadata as structured attributes, not as numbered nodes, so the translator
numbers them on output.

## 6. Intrinsic ops

Source: https://mlir.llvm.org/docs/Dialects/LLVM/, section "Operations for LLVM
IR Intrinsics".

General LLVM intrinsics are ops named `llvm.intr.<name>`, where `<name>` is the
intrinsic name without `llvm.` and without type suffixes. Target intrinsics
live in separate dialects (`nvvm`, `rocdl`, `x86vector`, `arm_neon`, and so
on). Most use the form

```
%r = llvm.intr.fma(%a, %b, %c) fastmath<fast> : (f32, f32, f32) -> f32
%m = llvm.intr.smax(%a, %b) : (i32, i32) -> i32
```

where the function type picks the overload, so `llvm.intr.fma` with `f32`
becomes `@llvm.fma.f32`. Some have bespoke forms, for example
`llvm.intr.lifetime.start %ptr : !llvm.ptr`,
`llvm.intr.assume %cond : i1` (with optional operand bundles), and
`%0 = llvm.intr.stacksave : !llvm.ptr` (observed). Flags that LLVM passes as
`i1` immediate arguments become attributes: `is_zero_poison` on `ctlz`/`cttz`,
`is_int_min_poison` on `abs`, `isVolatile` on `memcpy`/`memmove`/`memset`.

The dialect has these intrinsic ops (239 in all):

| Group | Ops (`llvm.intr.` omitted) |
| --- | --- |
| Float maths | `fabs` `sqrt` `sin` `cos` `tan` `asin` `acos` `atan` `atan2` `sinh` `cosh` `tanh` `sincos` `exp` `exp2` `exp10` `log` `log2` `log10` `pow` `powi` `fma` `fmuladd` `copysign` `floor` `ceil` `trunc` `round` `roundeven` `rint` `nearbyint` `lrint` `llrint` `lround` `llround` `ldexp` `frexp` `modf` `is.fpclass` `arithmetic.fence` |
| Min/max | `minnum` `maxnum` `minimum` `maximum` `minimumnum` `maximumnum` `smin` `smax` `umin` `umax` `scmp` `ucmp` |
| Integer | `abs` `ctlz` `cttz` `ctpop` `bitreverse` `bswap` `fshl` `fshr` `clmul` `pdep` `pext` `smulh` `umulh` |
| Overflow | `sadd.with.overflow` `uadd.with.overflow` `ssub.with.overflow` `usub.with.overflow` `smul.with.overflow` `umul.with.overflow` |
| Saturating | `sadd.sat` `uadd.sat` `ssub.sat` `usub.sat` `sshl.sat` `ushl.sat` |
| Memory | `memcpy` `memcpy.inline` `memmove` `memset` `memset.inline` `lifetime.start` `lifetime.end` `invariant.start` `invariant.end` `launder.invariant.group` `prefetch` `ptrmask` `threadlocal.address` `stacksave` `stackrestore` |
| Masked and VP | `masked.load` `masked.store` `masked.gather` `masked.scatter` `masked.expandload` `masked.compressstore` `vp.load` `vp.store` `vp.merge` `vp.sdiv` `vp.udiv` `vp.srem` `vp.urem` `vp.reduce.*` `experimental.vp.strided.load` `experimental.vp.strided.store` |
| Vector | `vector.reduce.add` `mul` `and` `or` `xor` `smax` `smin` `umax` `umin` `fadd` `fmul` `fmax` `fmin` `fmaximum` `fminimum` `fmaximumnum` `fminimumnum`; `vector.insert` `vector.extract` `vector.interleave2` `vector.deinterleave2` `stepvector` `vscale` `get.active.lane.mask` |
| Matrix | `matrix.multiply` `matrix.transpose` `matrix.column.major.load` `matrix.column.major.store` |
| Constrained FP | `experimental.constrained.*` for `fadd` `fsub` `fmul` `fdiv` `frem` `fma` `fmuladd` `fptrunc` `fpext` `fptosi` `fptoui` `sitofp` `uitofp` `fcmp` `fcmps` and the maths functions |
| Hints | `assume` `expect` `expect.with.probability` `is.constant` `experimental.noalias.scope.decl` `ssa.copy` `fake.use` |
| Annotations | `annotation` `ptr.annotation` `var.annotation` |
| Varargs | `vastart` `vacopy` `vaend` |
| Traps | `trap` `debugtrap` `ubsantrap` |
| Coroutines | `coro.id` `coro.begin` `coro.size` `coro.align` `coro.save` `coro.suspend` `coro.end` `coro.free` `coro.resume` `coro.destroy` `coro.done` `coro.promise` `coro.frame` `coro.alloc` `coro.noop` `coro.dead` `coro.is_in_ramp` `coro.await.suspend.*` |
| EH | `eh.typeid.for` |
| Debug | `dbg.declare` `dbg.value` `dbg.label` |

**Epitome note:** any intrinsic missing from this list can still be reached
with `llvm.call_intrinsic "llvm.foo.bar"`. A reader of the dialect only needs
the generic rule (strip `llvm.intr.`, add `llvm.`, mangle the overload types
from the function type) plus the few bespoke forms.

## 7. Debug information

Source: https://mlir.llvm.org/docs/Dialects/LLVM/, section "Debug Info".

Debug information uses MLIR locations plus attributes that mirror LLVM's
`DINode`s (`DISubprogramAttr`, `DILocalVariableAttr`, `DIExpressionAttr`,
`DILabelAttr`, and so on). A function's subprogram is attached as a fused
location (`FusedLoc`) whose metadata is a `DISubprogramAttr`. An op's scope is
attached the same way with a `DIScopeAttr`. Variables use the intrinsic ops:

```
llvm.intr.dbg.value #var = %v : f32
llvm.intr.dbg.declare #var #expr = %addr : !llvm.ptr
```

The pass `-ensure-debug-info-scope-on-llvm-func` adds a subprogram to every
function so that file-line-column locations become a line table (option
`emission-kind`).

**Not documented:** the syntax of the `#llvm.di_*` attributes and how
locations without a subprogram are dropped. The translator also always emits
`!{i32 2, !"Debug Info Version", i32 3}` in `!llvm.module.flags`, even with no
debug info (observed).

## 8. Converting other dialects to the `llvm` dialect

Source: https://mlir.llvm.org/docs/TargetLLVMIR/, section "Conversion to the
LLVM Dialect".

### 8.1 Progressive conversion

Most passes convert one dialect and leave the rest. For example
`-finalize-memref-to-llvm` converts only `memref` ops, even if other ops use
memref values. Where a converted op meets an unconverted one, the type
converter inserts `builtin.unrealized_conversion_cast`:

```
%1 = builtin.unrealized_conversion_cast %0 : memref<4xf32> to !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
```

When all dialects are converted, these casts form chains that convert a value
back to its own type. `-reconcile-unrealized-casts` removes such chains. Any
cast left after it is an error for translation.

All passes must use the same type converter (`LLVMTypeConverter`) or the casts
will not cancel. The docs recommend using the pattern sets together (as
`-convert-to-llvm` does) rather than many separate passes, because `cf`
branches fail if their operand types do not match their target blocks.

### 8.2 Type conversion

| Builtin type | LLVM dialect type |
| --- | --- |
| LLVM-compatible types (`iN`, floats, 1-D vectors, `!llvm.*`) | unchanged |
| `index` | `iN`, N from the module data layout (`i64` on x86-64); a pass option `index-bitwidth` can override it |
| `complex<T>` | `!llvm.struct<(T, T)>`, real then imaginary |
| `vector<4x8xf32>` (n-D) | `!llvm.array<4 x vector<8xf32>>`; one array level per leading dimension |
| `memref<...>` ranked | descriptor struct (8.3) |
| `memref<*x...>` unranked | `!llvm.struct<(i64, ptr)>` |
| function type | `!llvm.func<...>` (8.4) |
| `tensor<...>` | not convertible; bufferize first |
| `!llvm.struct<(index)>` and other containers of non-LLVM types | converted element by element; identified structs get a new name prefixed `_Converted.` |

The `index` width comes from DLTI when present:

```
module attributes { dlti.dl_spec = #dlti.dl_spec<
  #dlti.dl_entry<index, 32>
>} { ... }
```

Without this entry `index` is 64 bits (from the DataLayout page).

### 8.3 The memref descriptor

A ranked memref of rank N becomes a literal struct:

| Field | Type | Meaning |
| --- | --- | --- |
| 0 | `ptr` | **Allocated pointer**, as returned by the allocator. Used only to free. |
| 1 | `ptr` | **Aligned pointer**, the base that all accesses use. |
| 2 | index (`i64`) | **Offset** from the aligned pointer to the first element, in elements. |
| 3 | `[N x i64]` | **Sizes**, in elements, per dimension. |
| 4 | `[N x i64]` | **Strides**, in elements, per dimension. |

```
memref<f32>              -> !llvm.struct<(ptr, ptr, i64)>        // rank 0: no arrays
memref<1 x f32>          -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
memref<? x f32>          -> same as above
memref<10x?x42x?x123xf32>-> !llvm.struct<(ptr, ptr, i64, array<5 x i64>, array<5 x i64>)>
memref<1x?xvector<4xf32>>-> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
```

Static sizes are still stored in the descriptor, as constants; this is part of
the ABI for calling external functions. Only memrefs in strided form can be
converted; other layouts must first be rewritten into strided form (for
example by `-normalize-memrefs` or by materialising the layout as
`affine.apply`).

An **unranked** memref is `{ i64 rank, ptr }`, where the pointer points to a
ranked descriptor in memory. That memory is by convention on the stack and
lives until the function returns, so making unranked descriptors in a loop can
overflow the stack. A function returning an unranked memref copies the ranked
descriptor to the heap just before returning; the caller must free it. The
default lowering of `func.call` copies it back to the caller's stack.

**Address computation.** An access `memref.load %m[%i, %j, %k, %l]` computes
`offset + i*stride0 + j*stride1 + k*stride2 + l*stride3` in `i64`, then
`getelementptr` from the aligned pointer and `load`. Static strides and
offsets become constants; a unit stride is not multiplied; a zero offset is
not added. The conversion does no common-subexpression elimination of its own.

```
%stride1 = llvm.extractvalue %d[4, 0] : !llvm.struct<(ptr, ptr, i64, array<4xi64>, array<4xi64>)>
%addr1 = arith.muli %stride1, %1 : i64
...
%offset = llvm.extractvalue %d[2] : ...
%addr7 = arith.addi %addr6, %offset : i64
%aligned = llvm.extractvalue %d[1] : ...
%ptr = llvm.getelementptr %aligned[%addr7] : (!llvm.ptr, i64) -> !llvm.ptr, f32
%0 = llvm.load %ptr : !llvm.ptr -> f32
```

(The published example uses `arith` ops for the arithmetic; current passes
emit `llvm.mul ... overflow<nsw, nuw>` and `llvm.add ... overflow<nsw, nuw>`
and `getelementptr inbounds|nuw`, observed.)

### 8.4 Function types and signatures

| MLIR | LLVM dialect |
| --- | --- |
| `() -> ()` | `!llvm.func<void ()>` |
| `(i32) -> (i64)` | `!llvm.func<i64 (i32)>` |
| `(i32, f32) -> (i64, f64)` | `!llvm.func<struct<(i64, f64)> (i32, f32)>` |
| `(() -> ()) -> (() -> ())` | `!llvm.func<ptr (ptr)>` |
| `(memref<f32>) -> ()` | `!llvm.func<void (ptr, ptr, i64)>` |
| `(memref<f32>, f32) -> ()` | `!llvm.func<void (ptr, ptr, i64, f32)>` |
| `(memref<?x?xf32>) -> ()` | `!llvm.func<void (ptr, ptr, i64, i64, i64, i64, i64)>` |
| `(memref<*xf32>) -> ()` | `!llvm.func<void (i64, ptr)>` |
| `() -> (memref<?xf32>)` | `!llvm.func<struct<(ptr, ptr, i64, array<1xi64>, array<1xi64>)> ()>` |
| `() -> (memref<f32>, memref<f64>)` | `!llvm.func<struct<(struct<(ptr, ptr, i64)>, struct<(ptr, ptr, i64)>)> ()>` |
| `(i32) -> ()` with `func.varargs = true` | `!llvm.func<void (i32, ...)>` |

Memref **arguments** are unbundled into one argument per scalar field (2N+3
for rank N), so that attributes such as `noalias` and `align` can go on the
individual pointers. Memref **results** are not unbundled. Several results are
packed into one struct.

## 9. Calling conventions

Source: https://mlir.llvm.org/docs/TargetLLVMIR/, sections "Calling
Conventions" to "C-compatible wrapper emission".

### 9.1 Result packing

```
func.func @foo(%arg0: i32, %arg1: i64) -> (i32, i64) {
  return %arg0, %arg1 : i32, i64
}
// becomes
llvm.func @foo(%arg0: i32, %arg1: i64) -> !llvm.struct<(i32, i64)> {
  %0 = llvm.mlir.undef : !llvm.struct<(i32, i64)>
  %1 = llvm.insertvalue %arg0, %0[0] : !llvm.struct<(i32, i64)>
  %2 = llvm.insertvalue %arg1, %1[1] : !llvm.struct<(i32, i64)>
  llvm.return %2 : !llvm.struct<(i32, i64)>
}
```

The caller does `llvm.extractvalue %r[0]` and `[1]`.

### 9.2 Default convention for ranked memrefs

The callee rebuilds the descriptor from its scalar arguments; the caller takes
it apart before the call:

```
llvm.func @foo(%arg0: !llvm.ptr,   // allocated pointer
               %arg1: !llvm.ptr,   // aligned pointer
               %arg2: i64,         // offset
               %arg3: i64,         // size, dim 0
               %arg4: i64) {       // stride, dim 0
  %0 = llvm.mlir.undef : !llvm.memref_1d
  %1 = llvm.insertvalue %arg0, %0[0] : !llvm.memref_1d
  %2 = llvm.insertvalue %arg1, %1[1] : !llvm.memref_1d
  %3 = llvm.insertvalue %arg2, %2[2] : !llvm.memref_1d
  %4 = llvm.insertvalue %arg3, %3[3, 0] : !llvm.memref_1d
  %5 = llvm.insertvalue %arg4, %4[4, 0] : !llvm.memref_1d
  ...
}
```

The argument order for rank N is: allocated, aligned, offset, size 0 ... size
N-1, stride 0 ... stride N-1 (sizes first, then strides; observed in
`@mlp(ptr, ptr, i64, i64, i64, i64, i64)` where `%3`, `%4` are sizes and `%5`,
`%6` strides).

### 9.3 Unranked memrefs

Two arguments: `i64` rank and `ptr` to the ranked descriptor. Casting a ranked
memref to unranked needs the descriptor in memory, so the caller stores it in
an `alloca`; the caller owns that memory. Observed: the lowering brackets
such stores with `llvm.intr.stacksave` / `llvm.intr.stackrestore`.

### 9.4 Bare-pointer convention

With `-convert-func-to-llvm{use-bare-ptr-memref-call-conv}`, each memref
argument is a single pointer to the aligned data. It applies only to
signatures; inside the function the full descriptor is rebuilt, with both
pointers set to the argument, offset 0, and the static sizes and strides as
constants. Restrictions:

- default (identity) layout only;
- all dimensions static;
- the allocated and aligned pointers must be equal, or the same function must
  allocate and free.

Unranked memrefs are not supported.

```
func.func @callee(memref<2x4xf32>)
// becomes
llvm.func @callee(!llvm.ptr)
```

**Epitome note:** bare-pointer signatures look exactly like C: `void f(float *)`.
The default convention's `(ptr, ptr, i64, ...)` signatures do not match any C
prototype, which is why the C wrappers exist.

### 9.5 Allocation functions

`memref.alloc` calls `malloc` (or `aligned_alloc` with `use-aligned-alloc`) and
`memref.dealloc` calls `free`. With `use-generic-functions` the names are
`_mlir_memref_to_llvm_alloc`, `_mlir_memref_to_llvm_aligned_alloc` and
`_mlir_memref_to_llvm_free`, with the same signatures, so a run-time library
can supply its own.

### 9.6 C-compatible wrappers (`_mlir_ciface_`)

The unit attribute `llvm.emit_c_interface` on a `func.func` (or the pass
`-llvm-request-c-wrappers` for all functions) asks for a wrapper. In the
wrapper each memref argument is a pointer to a descriptor struct that matches
this C++ type:

```
template<typename T, size_t N>
struct MemRefDescriptor {
  T *allocated;
  T *aligned;
  intptr_t offset;
  intptr_t sizes[N];
  intptr_t strides[N];
};
```

A struct result (a memref, or several results) becomes an extra **first**
argument, a pointer to where the result is stored.

For a function **defined** in the module, a new function
`_mlir_ciface_<name>` loads each descriptor from its pointer, unpacks it,
calls the original, and stores any struct result:

```
llvm.func @_mlir_ciface_foo(%arg0: !llvm.ptr, %arg1: !llvm.ptr) {
  %0 = llvm.load %arg1 : !llvm.ptr -> !llvm.memref_2d
  %1 = llvm.extractvalue %0[0] : !llvm.memref_2d
  ...
  %8 = llvm.call @foo(%1, %2, %3, %4, %5, %6, %7) : (...) -> !llvm.memref_2d
  llvm.store %8, %arg0 : !llvm.memref_2d, !llvm.ptr
  llvm.return
}
```

which in C is `void _mlir_ciface_foo(MemRefDescriptor<float, 2> *output,
MemRefDescriptor<float, 2> *input);`. Observed in LLVM IR:

```
define void @_mlir_ciface_mlp(ptr %0, ptr %1) {
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %1, align 8
  %4 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 0
  ...
  %11 = call { ptr, ptr, i64, [2 x i64], [2 x i64] } @mlp(ptr %4, ptr %5, i64 %6, i64 %7, i64 %8, i64 %9, i64 %10)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %11, ptr %0, align 8
  ret void
}
```

For an **external** function (declaration only), the roles swap: the
original gets a body that builds descriptors on the stack and calls a
declared `_mlir_ciface_<name>`, which C code must provide.

Wrappers cannot be made for variadic functions, because C cannot forward
`...`. The docs give two reasons for wrappers over changing the convention:
calls between MLIR functions stay cheap (no descriptor on the stack in a hot
loop, no concurrent access to one stack slot), and on GPUs the descriptors
need not be copied to device memory.

## 10. Conversion passes

Source: https://mlir.llvm.org/docs/Passes/, "Conversion Passes" and the
`llvm` dialect pass sections.

| Pass | Converts | Options |
| --- | --- | --- |
| `-convert-to-llvm` | Every dialect that implements `ConvertToLLVMPatternInterface`, in one pass. | `filter-dialects`, `dynamic` (configure from `ConvertToLLVMAttrInterface` attributes and DLTI), `allow-pattern-rollback` |
| `-convert-func-to-llvm` | `func` | `use-bare-ptr-memref-call-conv`, `index-bitwidth` |
| `-convert-arith-to-llvm` | `arith` | `index-bitwidth` |
| `-convert-cf-to-llvm` | `cf` | `index-bitwidth` |
| `-convert-math-to-llvm` | `math` | `approximate-log1p` |
| `-convert-index-to-llvm` | `index` | `index-bitwidth` |
| `-convert-ub-to-llvm` | `ub` | `index-bitwidth` |
| `-finalize-memref-to-llvm` | `memref` (after `-expand-strided-metadata`) | `use-aligned-alloc`, `index-bitwidth`, `use-generic-functions` |
| `-convert-vector-to-llvm` | `vector` | see chapter 2, section 12.3 |
| `-convert-complex-to-llvm` | `complex` | `complex-range` |
| `-convert-scf-to-cf` | `scf` to `cf` (not to LLVM directly) | `allow-pattern-rollback` |
| `-lower-affine` | `affine` to `scf` + `arith` | |
| `-convert-math-to-libm` / `-convert-complex-to-libm` | maths to C library calls | |
| `-convert-math-to-funcs` | maths to outlined `linkonce_odr` functions | `min-width-of-fpowi-exponent`, `convert-ctlz` |
| `-convert-openmp-to-llvm`, `-convert-async-to-llvm`, `-gpu-to-llvm`, `-convert-nvvm-to-llvm`, `-convert-spirv-to-llvm` | other dialects | |
| `-reconcile-unrealized-casts` | removes cast chains that cancel | |
| `-set-llvm-module-datalayout` | sets `llvm.data_layout` | `data-layout` |
| `-llvm-request-c-wrappers` | adds `llvm.emit_c_interface` to every function | |
| `-llvm-add-comdats` | `any` comdat on every `linkonce`/`linkonce_odr` function | |
| `-llvm-legalize-for-export` | makes the dialect translatable | |
| `-llvm-use-default-visibility` | sets default visibility, like `-fvisibility` | `visibility` |
| `-ensure-debug-info-scope-on-llvm-func` | adds subprograms | `emission-kind` |
| `-llvm-target-to-data-layout` / `-llvm-target-to-target-features` | derive DLTI from `#llvm.target` | `initialize-llvm-targets` |

`-convert-func-to-llvm` documents its input requirements: no tensors, all
vectors 1-D, and every block reachable from the entry block. An LLVM data
layout string on the module, if present, is used during conversion.

`index-bitwidth = 0` (the default) means "use the machine word size from the
data layout".

**Not documented:** which dialects `-convert-to-llvm` covers by default. It
covers whichever loaded dialects register the interface.

A full pipeline, as we ran it:

```
builtin.module(lower-affine, convert-scf-to-cf, expand-strided-metadata,
               finalize-memref-to-llvm, convert-arith-to-llvm,
               convert-math-to-llvm, convert-func-to-llvm, convert-cf-to-llvm,
               reconcile-unrealized-casts)
```

## 11. Translation to LLVM IR

Source: https://mlir.llvm.org/docs/TargetLLVMIR/, section "Translation to LLVM
IR", and https://mlir.llvm.org/docs/Tutorials/Toy/Ch-6/.

A module of `llvm.func`, `llvm.mlir.global` and metadata ops translates by
this scheme:

1. Module-level globals become LLVM global values.
2. Module-level metadata becomes LLVM metadata (ops may add more later).
3. Every function is declared first, so that any function can refer to any
   other.
4. Each function is translated on its own, with access to the maps of globals,
   metadata and functions.
5. Blocks are visited in topological order. Each becomes an LLVM basic block,
   with one empty `phi` per block argument.
6. Ops in a block are translated in order. Ops with regions translate their
   own regions.
7. After the whole function, each `phi` gets its incoming values.

Dialects outside `llvm` can take part through `LLVMTranslationDialectInterface`
with two hooks: `convertOperation` (translate an op of that dialect) and
`amendOperation` (act on a dialect attribute, for example to add
instruction metadata). The hooks are meant for intrinsics and metadata only;
they cannot change how types or blocks translate, and cannot add module-level
constructs.

The Toy tutorial shows the result. Dialect form:

```
%166 = llvm.getelementptr inbounds|nuw %162[%165] : (!llvm.ptr, i64) -> !llvm.ptr, f64
%167 = llvm.load %166 : !llvm.ptr -> f64
%168 = llvm.call @printf(%148, %167) vararg(!llvm.func<i32 (ptr, ...)>) : (!llvm.ptr, f64) -> i32
%169 = llvm.add %160, %159 : i64
llvm.br ^bb15(%169 : i64)
```

LLVM IR:

```
%91 = getelementptr inbounds nuw double, ptr %88, i64 %90
%92 = load double, ptr %91, align 8
%93 = call i32 (ptr, ...) @printf(ptr @frmt_spec, double %92)
%94 = add i64 %85, 1
br label %84
```

Points to notice:

- Constant ops vanish: `%148` (an `addressof`) became `ptr @frmt_spec` and
  `%159` became `1`.
- `load` got `align 8` although the op had no alignment. The output always
  carries an explicit alignment, presumably the ABI alignment from the data
  layout. **Not documented:** where it comes from.
- `llvm.mlir.global internal constant @nl("\0A\00")` became
  `@nl = internal constant [2 x i8] c"\0A\00"`.
- `llvm.func @free(!llvm.ptr)` became `declare void @free(ptr)`.

Our own runs add these observations:

| Observation | Detail |
| --- | --- |
| Module header | `; ModuleID = 'LLVMDialectModule'`, `source_filename = "LLVMDialectModule"` |
| No triple or data layout lines | unless the module has `llvm.target_triple` / `llvm.data_layout` |
| Module flags | `!llvm.module.flags = !{!0}` with `!0 = !{i32 2, !"Debug Info Version", i32 3}` always |
| Value names | all numbered (`%0`, `%1`, ...); block arguments become numbered `phi`s |
| Float constants | printed in hex form, for example `float f0x3E89545E` (this LLVM version's syntax) |
| Globals | `private constant [8 x [4 x float]] [...], align 64` from `alignment = 64` |

**Epitome note:** the translated IR passes LLVM's verifier and is ordinary
textual IR. Epitome reads it with no MLIR-specific code. The only thing to
watch is the hex float syntax `f0x...`, which belongs to the LLVM version that
produced the file and must be in our lexer (see the [types and constants
chapter](../llvm-ir/02-types-and-constants.md)).

### 11.1 Import

`mlir-translate -import-llvm file.ll` reads LLVM IR into the `llvm` dialect.
The docs call it experimental and say it handles "a substantially limited
subset" of LLVM IR.

## Still to read

| Gap | Document |
| --- | --- |
| Textual syntax of linkage, `CConv`, TBAA, alias scope, access group, loop annotation and `#llvm.di_*` attributes | Not on the dialect page; print our own inputs with `mlir-opt` and record (observed behaviour) |
| Custom forms of `llvm.switch`, `llvm.invoke`, `llvm.landingpad`, `llvm.alloca` with alignment, `llvm.atomicrmw` | Same: print test inputs |
| `icmp`/`fcmp` predicate enum spellings, especially the constant `fcmp` predicates | Same |
| What the translator does with a `cond_br` to one block twice | Translate a test input |
| `mlir-translate` command-line options | No tools page (`/docs/Tools/mlir-translate/` is 404); use `mlir-translate --help` |
| Data layout and DLTI attribute syntax in full | https://mlir.llvm.org/docs/DataLayout/ and https://mlir.llvm.org/docs/Dialects/DLTIDialect/ |
| SPIR-V to LLVM conversion | https://mlir.llvm.org/docs/SPIRVToLLVMDialectConversion/ |
| Target dialects that also translate to LLVM IR | https://mlir.llvm.org/docs/Dialects/NVVMDialect/, ROCDL, ArmNeon, ArmSVE, X86Vector |
| Dialect conversion framework (type converter, materialisations) | https://mlir.llvm.org/docs/DialectConversion/ |
| Exact `-convert-to-llvm` dialect coverage | Run the pass on mixed input |
| LLVM IR import limits | https://mlir.llvm.org/docs/TargetLLVMIR/ only says "limited subset" |
