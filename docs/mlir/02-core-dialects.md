# Core Dialects

Source: mlir.llvm.org/docs, dialect pages under `/docs/Dialects/`, plus
`/docs/Passes/`, `/docs/Bufferization/` and `/docs/TargetLLVMIR/`. Read on
2026-10-20. The site tracks MLIR's development branch, not a numbered release.

This chapter describes the "core" dialects that sit between a front end and
the `llvm` dialect: `func`, `arith`, `math`, `index`, `cf`, `scf`, `ub`,
`memref`, `tensor`, `bufferization`, `affine`, `vector`, `linalg` and
`complex`. For each operation it gives the textual form from the
documentation, the operand and result types, the meaning in a line, and the
LLVM IR that the operation ends up as.

Epitome reads LLVM IR. It does not need to run MLIR. But IR that came from
MLIR has a recognisable shape, and Epitome may one day accept MLIR's `llvm`
dialect, or a subset of these core dialects, directly. This chapter is the
map from each core operation to the LLVM IR that Epitome already models (see
the [instructions chapter](../llvm-ir/04-instructions.md) and the intrinsics
chapters).

Some words used throughout:

- **Op**: an MLIR operation, written `dialect.name`, for example `arith.addi`.
- **Custom form**: the readable syntax an op prints in. Every op also has a
  *generic form*, `"dialect.name"(operands) {attributes} : (types) -> types`.
- **Integer-like**: a signless integer `iN`, or a `vector` or `tensor` of
  them. **Float-like** is the same for floating-point types.
  **Bool-like** is `i1`, or a vector or tensor of `i1`.
- **Signless**: MLIR integers carry no sign. Each op says whether it reads its
  operands as signed or unsigned, exactly as LLVM IR does.
- **`index`**: an integer whose width is the target's pointer width. It
  becomes `i64` on 64-bit targets when lowered (see [the LLVM dialect chapter](03-llvm-dialect.md), section 8.2).
- **Region**: a list of blocks nested inside an op. A **terminator** ends each
  block, for example `scf.yield`.
- **Lowering**: rewriting ops of one dialect into ops of a lower one, by a
  conversion pass.

### How the LLVM IR column was found

The MLIR documentation does not publish an op-by-op table of what each
conversion pass emits. Where a page says what an op lowers to, the entry says
"documented". Everywhere else the LLVM IR shown is the LLVM instruction or
intrinsic with the same meaning in the LLVM Language Reference. We also ran the
upstream passes on our own small inputs (the PyTorch examples in
[examples/pytorch](examples/pytorch/)) and record what they printed; those
entries say "observed".

**Epitome note:** where the mapping is one to one, the LLVM IR that MLIR emits
is ordinary IR. Nothing in it is special to MLIR, except the shapes listed in
section 15 (memref descriptors, `_mlir_ciface_` wrappers, the `0xdeadbeef`
pointer for constant globals, and so on).

## 1. The `func` dialect

Source: https://mlir.llvm.org/docs/Dialects/Func/

The `func` dialect holds functions, calls and returns. A function is a symbol
with one region. Its arguments are the arguments of the region's first block.
A function body cannot use values defined outside it ("isolated from above").
A function with no body is a declaration.

| Op | Custom form | Meaning | LLVM IR |
| --- | --- | --- | --- |
| `func.func` | `func.func @f(%x: i64) -> (i64, i64) { ... }` | Define or declare a function. | `define` / `declare` (via `llvm.func`) |
| `func.call` | `%2 = func.call @my_add(%0, %1) : (f32, f32) -> f32` | Direct call to a symbol in the same symbol table. | `call` |
| `func.call_indirect` | `%r = func.call_indirect %f(%0, %1) : (tensor<16xf32>, tensor<16xf32>) -> tensor<16xf32>` | Call a value of function type. | `call` through a `ptr` |
| `func.constant` | `%f = func.constant @myfn : (tensor<16xf32>, f32) -> tensor<16xf32>` | A value naming a function. | the function's address (`llvm.mlir.addressof`) |
| `func.return` | `return %0, %1 : i32, f8` | Return any number of values. | `ret` |

Examples, copied from the page:

```
func.func private @abort()
func.func private @scribble(i32, i64, memref<? x 128 x f32, #layout_map0>) -> f64
func.func @count(%x: i64) -> (i64, i64)
  attributes {fruit = "banana"} {
  return %x, %x: i64, i64
}
func.func private @example_fn_arg(%x: i32 {swift.self = unit})
```

Attributes on `func.func`: `sym_name`, `function_type`, `sym_visibility`
(`private` in the custom form), `arg_attrs`, `res_attrs`, `no_inline`, and an
optional `dlti` data-layout attribute. `func.call` has `callee`, `arg_attrs`,
`res_attrs` and `no_inline`.

Lowering is by `-convert-func-to-llvm`. The rules are in the LLVM dialect
chapter ([03](03-llvm-dialect.md)), sections 8.4 and 9. In short:

- A function with several results returns one LLVM struct. The call site
  extracts the fields with `extractvalue`. (Documented.)
- A function with no results returns `void`. (Documented.)
- Each `memref` argument becomes several scalar arguments, one per descriptor
  field, unless the bare-pointer convention is chosen. (Documented.)
- `func.func` attributes spelt `llvm.<name>`, such as `llvm.target_cpu`, set
  the matching property on the `llvm.func`. The bare name without `llvm.` is
  dropped. Other attributes are copied through unchanged. `func.varargs`
  makes the function variadic. `llvm.readnone` sets the memory effects to
  "none". `llvm.emit_c_interface` asks for a `_mlir_ciface_` wrapper.
  (Documented.)

**Epitome note:** multiple results never reach LLVM IR as multiple values.
They arrive as a returned literal struct, built with a chain of `insertvalue`
starting from `poison` (observed; the published example starts from
`llvm.mlir.undef`, but the current passes print `llvm.mlir.poison`).

## 2. The `arith` dialect

Source: https://mlir.llvm.org/docs/Dialects/ArithOps/

`arith` holds integer and floating-point arithmetic, bitwise ops, shifts,
casts and comparisons. Every op works on scalars, on vectors and on tensors;
on vectors and tensors it works element by element. Integers are two's
complement bit vectors. Unless an op says otherwise, a poison operand makes a
poison result, element by element. The type `i0` is not allowed.

Floating-point ops may carry a rounding mode and fast-math flags. With no
rounding mode, MLIR folds constants with round-to-nearest-even, but what the
machine does at run time is left to the back end.

### 2.1 Flags and enums

| Attribute | Syntax | Values |
| --- | --- | --- |
| Integer overflow flags | `overflow<nsw, nuw>` | `none` = 0, `nsw` = 1, `nuw` = 2 |
| Fast-math flags | `fastmath<fast>` (`#arith.fastmath<...>`) | `none` 0, `reassoc` 1, `nnan` 2, `ninf` 4, `nsz` 8, `arcp` 16, `contract` 32, `afn` 64, `fast` 127 |
| Rounding mode | bare keyword after the operands | `to_nearest_even` 0, `downward` 1, `upward` 2, `toward_zero` 3, `to_nearest_away` 4 |
| `exact` | keyword `exact` | unit attribute on `divsi`, `divui`, `shrsi`, `shrui` |
| `nneg` | keyword `nneg` | unit attribute on `extui`, `index_castui`, `uitofp` |

The fast-math flag names and bit values match LLVM's own. `fast` is all seven
flags together.

### 2.2 Integer arithmetic

Custom form for the binary ops: `%r = arith.addi %a, %b overflow<nsw> : i64`.
Both operands and the result have the same type.

| Op | Meaning | Poison or UB | LLVM IR |
| --- | --- | --- | --- |
| `arith.addi` | Add, modulo 2^n. | Poison on signed/unsigned wrap if `nsw`/`nuw`. | `add [nuw] [nsw]` |
| `arith.subi` | Subtract, modulo 2^n. | As `addi`. | `sub [nuw] [nsw]` |
| `arith.muli` | Multiply, modulo 2^n. | As `addi`. | `mul [nuw] [nsw]` |
| `arith.divsi` | Signed divide, rounds towards zero. | UB on divide by zero or `MIN / -1`. Poison if `exact` and not a multiple. | `sdiv [exact]` |
| `arith.divui` | Unsigned divide. | UB on divide by zero. | `udiv [exact]` |
| `arith.ceildivsi` | Signed divide, rounds towards +infinity. | UB as `divsi`. | No single instruction; expanded by `-arith-expand` |
| `arith.ceildivui` | Unsigned divide, rounds up. | UB on divide by zero. | Expanded |
| `arith.floordivsi` | Signed divide, rounds towards -infinity. | UB as `divsi`. | Expanded |
| `arith.remsi` | Signed remainder, sign of dividend. | UB on divide by zero. | `srem` |
| `arith.remui` | Unsigned remainder. | UB on divide by zero. | `urem` |
| `arith.maxsi` / `arith.minsi` | Signed max / min. | | `llvm.smax` / `llvm.smin` (documented) |
| `arith.maxui` / `arith.minui` | Unsigned max / min. | | `llvm.umax` / `llvm.umin` (documented) |
| `arith.andi` | Bitwise AND. | | `and` |
| `arith.ori` | Bitwise OR. | | `or` |
| `arith.xori` | Bitwise XOR. | | `xor` |
| `arith.shli` | Shift left. | Poison if shift >= width; or on wrap with `nsw`/`nuw`. | `shl [nuw] [nsw]` |
| `arith.shrsi` | Arithmetic shift right. | Poison if shift >= width; or if `exact` and bits shifted out are non-zero. | `ashr [exact]` |
| `arith.shrui` | Logical shift right. | As `shrsi`. | `lshr [exact]` |

"Documented" for max and min: the `-arith-expand` pass page says these four
ops "have a direct arith-to-llvm lowering to the `llvm.intr.smax/umax/smin/umin`
intrinsics". Option `include-min-max-i` of `-arith-expand` instead turns them
into `cmpi` plus `select`.

Extended ops return two results:

| Op | Custom form | Meaning | LLVM IR |
| --- | --- | --- | --- |
| `arith.addui_extended` | `%sum, %overflow = arith.addui_extended %b, %c : i64, i1` | N-bit sum and an unsigned carry bit. | `llvm.uadd.with.overflow` + two `extractvalue` |
| `arith.subui_extended` | `%diff, %borrow = arith.subui_extended %b, %c : i64, i1` | N-bit difference and a borrow bit (`lhs < rhs` unsigned). | `llvm.usub.with.overflow` |
| `arith.mulsi_extended` | `%low, %high = arith.mulsi_extended %a, %b : i32` | Low and high halves of the 2N-bit signed product. | `sext` to 2N, `mul`, `trunc` and `lshr`+`trunc` |
| `arith.mului_extended` | `%low, %high = arith.mului_extended %a, %b : i32` | Same, unsigned. | `zext` to 2N, `mul`, `trunc`, `lshr`+`trunc` |

**Not documented:** which LLVM sequence the pass emits for the extended ops
and for `ceildivsi`, `ceildivui` and `floordivsi`.

### 2.3 Floating-point arithmetic

Custom form: `%r = arith.addf %a, %b [roundingmode] [fastmath<...>] : f32`.

| Op | Meaning | LLVM IR |
| --- | --- | --- |
| `arith.addf` | Add. | `fadd [fast-math flags]` |
| `arith.subf` | Subtract. | `fsub` |
| `arith.mulf` | Multiply. | `fmul` |
| `arith.divf` | Divide. | `fdiv` |
| `arith.remf` | Remainder with the sign of the dividend (C `fmod`). | `frem` |
| `arith.negf` | Negate. | `fneg` |
| `arith.maximumf` | Max; `-0.0 < +0.0`; NaN if either is NaN. | `llvm.maximum` (documented) |
| `arith.minimumf` | Min; same NaN and zero rules. | `llvm.minimum` (documented) |
| `arith.maxnumf` | Max; if one is NaN, return the other; zeros either way. | `llvm.maxnum` (documented) |
| `arith.minnumf` | Min, same rules. | `llvm.minnum` (documented) |
| `arith.maximumnumf` | IEEE 754-2019 `maximumNumber`. | `llvm.maximumnum` |
| `arith.minimumnumf` | IEEE 754-2019 `minimumNumber`. | `llvm.minimumnum` |
| `arith.flush_denormals` | Return zero (keeping sign) for a subnormal input, else the input. | Expanded by `-arith-expand` with `include-flush-denormals` |

The four "documented" entries come from the `include-min-max-f` option of
`-arith-expand`.

**Not documented:** what `arith.addf`, `subf`, `mulf` and `divf` lower to
when a rounding mode is given. `math.fma` with a rounding mode becomes
`llvm.experimental.constrained.fma` (section 3), so the constrained
intrinsics are the likely target here too.

### 2.4 Comparisons and select

`arith.cmpi` compares integer-like values and returns bool-like values of the
same shape:

```
%x = arith.cmpi slt, %lhs, %rhs : i32
%x = "arith.cmpi"(%lhs, %rhs) {predicate = 2 : i64} : (i32, i32) -> i1
```

| Predicate | Value | LLVM `icmp` |
| --- | --- | --- |
| `eq` | 0 | `eq` |
| `ne` | 1 | `ne` |
| `slt` | 2 | `slt` |
| `sle` | 3 | `sle` |
| `sgt` | 4 | `sgt` |
| `sge` | 5 | `sge` |
| `ult` | 6 | `ult` |
| `ule` | 7 | `ule` |
| `ugt` | 8 | `ugt` |
| `uge` | 9 | `uge` |

`arith.cmpf` compares float-like values. `u` means "unordered" (true if
either is NaN), not "unsigned".

```
%r1 = arith.cmpf oeq, %0, %1 : f32
%r2 = arith.cmpf ult, %0, %1 : tensor<42x42xf64>
```

| Predicate | Value | LLVM `fcmp` |
| --- | --- | --- |
| `false` | 0 | `false` |
| `oeq`, `ogt`, `oge`, `olt`, `ole`, `one`, `ord` | 1 to 7 | same name |
| `ueq`, `ugt`, `uge`, `ult`, `ule`, `une`, `uno` | 8 to 14 | same name |
| `true` | 15 | `true` |

`cmpf` accepts `fastmath<...>`, which maps to fast-math flags on `fcmp`.

`arith.select` chooses between two values:

```
%x = arith.select %cond, %true, %false : i32
%vx = arith.select %vcond, %vtrue, %vfalse : vector<42xi1>, vector<42xf32>
%vx = arith.select %cond, %vtrue, %vfalse : vector<42xf32>
```

If the condition is 1 the second operand is returned and the third is
ignored even if it is poison; and the other way round. A poison condition
gives poison. A vector condition picks element by element; an `i1` condition
picks the whole value. This matches LLVM `select` exactly.

**Epitome note:** the predicate numbers for `cmpi` are not LLVM's
`ICmpInst` numbers; only the names carry across. The `llvm` dialect prints
them as strings, `llvm.icmp "slt"` (observed).

### 2.5 Casts

Custom form: `%r = arith.extsi %x : i32 to i64`.

| Op | Meaning | LLVM IR |
| --- | --- | --- |
| `arith.extsi` | Sign-extend; result strictly wider. | `sext` |
| `arith.extui` | Zero-extend; with `nneg`, poison if the top bit is set. | `zext [nneg]` |
| `arith.trunci` | Truncate; result strictly narrower. `nuw`/`nsw` as in LLVM. | `trunc [nuw] [nsw]` |
| `arith.extf` | Widen a float; result strictly wider. | `fpext` |
| `arith.truncf` | Narrow a float; optional rounding mode. | `fptrunc` |
| `arith.convertf` | Same width, different format (for example `f16` to `bf16`). | **Not documented**; LLVM has no single instruction |
| `arith.fptosi` | Float to signed integer, round towards zero. | `fptosi` |
| `arith.fptoui` | Float to unsigned integer. | `fptoui` |
| `arith.sitofp` | Signed integer to float. | `sitofp` |
| `arith.uitofp` | Unsigned integer to float; optional `nneg`. | `uitofp [nneg]` |
| `arith.bitcast` | Same bit width, reinterpret. Also works on memrefs. | `bitcast` |
| `arith.index_cast` | `index` to or from an integer; sign-extend or truncate. | `sext` / `trunc` / nothing |
| `arith.index_castui` | Same, zero-extend; optional `nneg`. | `zext [nneg]` / `trunc` / nothing |
| `arith.scaling_extf` | OCP MX block-scaled widen: `extf(in) * extf(scale)`. | Expanded first |
| `arith.scaling_truncf` | OCP MX block-scaled narrow: `truncf(in / scale)`. | Expanded first |

Examples from the page:

```
%2 = arith.extsi %1 : i3 to i6    // 0b101 becomes 0b111101
%6 = arith.extui %3 nneg : i3 to i6
%5 = arith.trunci %a overflow<nsw, nuw> : i32 to i16
%1 = arith.index_castui %a nneg : i32 to index
%1 = arith.uitofp %a nneg : i32 to f64
```

**Epitome note:** after lowering, `index` is just `i64` on a 64-bit target,
so `arith.index_cast %x : i64 to index` becomes nothing at all, and the
`i32` case becomes one `sext` or `trunc`.

### 2.6 Constants

```
%1 = arith.constant 42 : i32
%1 = "arith.constant"() {value = 42 : i32} : () -> i32
```

The value is any typed attribute: integer, float, or a dense vector or tensor
constant. A scalar or vector constant becomes `llvm.mlir.constant` and then an
LLVM constant operand. A tensor constant cannot be lowered directly;
bufferization turns it into a `memref.global` plus `memref.get_global`
(observed in our PyTorch examples).

### 2.7 Atomic kinds

`arith` also defines the `AtomicRMWKind` enum used by `memref.atomic_rmw`:
`addf` 0, `addi` 1, `andi` 2, `assign` 3, `maximumf` 4, `maxnumf` 5, `maxs` 6,
`maxu` 7, `minimumf` 8, `minnumf` 9, `mins` 10, `minu` 11, `mulf` 12, `muli` 13,
`ori` 14, `xori` 15.

### 2.8 Passes

| Pass | What it does |
| --- | --- |
| `-convert-arith-to-llvm` | Arith to the `llvm` dialect. Option `index-bitwidth` (0 means machine word). |
| `-arith-expand` | Rewrites ops with no direct LLVM form (`ceildivsi`, small-float types, optionally min/max). Options `include-bf16`, `include-f8e8m0`, `include-f4e2m1`, `include-f8e5m2`, `include-f8e4m3fn`, `include-flush-denormals`, `include-min-max-f`, `include-min-max-i`. |
| `-arith-emulate-unsupported-floats` | Wraps ops on unsupported float types in `extf`/`truncf`. Options `source-types`, `target-type`. |
| `-arith-emulate-wide-int` | Splits 2N-bit integer ops into N-bit halves. Option `widest-int-supported`. |
| `-arith-int-range-narrowing`, `-arith-unsigned-when-equivalent`, `-int-range-optimizations` | Integer range analysis rewrites. |

## 3. The `math` dialect

Source: https://mlir.llvm.org/docs/Dialects/MathOps/

`math` holds maths beyond plain arithmetic. Every op works on scalars,
vectors and tensors, element by element. Float ops take the same
`fastmath<...>` flags as `arith`.

Custom form: `%a = math.sqrt %b fastmath<fast> : f32`. Two-operand ops:
`%a = math.powf %b, %c : f64`. `math.fpowi` has two types:
`%a = math.fpowi %base, %power : f64, i32`.

| Op | Meaning | LLVM IR |
| --- | --- | --- |
| `math.absf` | Float absolute value. | `llvm.fabs` |
| `math.absi` | Integer absolute value. | `llvm.abs` |
| `math.ceil` / `math.floor` / `math.trunc` | Round up / down / towards zero. | `llvm.ceil` / `llvm.floor` / `llvm.trunc` |
| `math.round` | Round to nearest, halves away from zero. | `llvm.round` |
| `math.roundeven` | Round to nearest, halves to even. | `llvm.roundeven` |
| `math.copysign` | Magnitude of first, sign of second. | `llvm.copysign` |
| `math.sqrt` | Square root. | `llvm.sqrt` |
| `math.rsqrt` | `1 / sqrt(x)`. | `llvm.sqrt` then `fdiv` |
| `math.cbrt` | Cube root. | No LLVM intrinsic; libm `cbrt` |
| `math.exp` / `math.exp2` | e^x / 2^x. | `llvm.exp` / `llvm.exp2` |
| `math.expm1` | e^x - 1. | No LLVM intrinsic |
| `math.log` / `math.log2` / `math.log10` | Logarithms. | `llvm.log` / `llvm.log2` / `llvm.log10` |
| `math.log1p` | log(1 + x). | No intrinsic; `-convert-math-to-llvm` has option `approximate-log1p` |
| `math.powf` | Float to float power. | `llvm.pow` |
| `math.fpowi` | Float to signed integer power. | `llvm.powi` |
| `math.ipowi` | Integer to integer power. | No intrinsic; `-convert-math-to-funcs` outlines it |
| `math.sin` / `math.cos` / `math.tan` | Trigonometry. | `llvm.sin` / `llvm.cos` / `llvm.tan` |
| `math.sincos` | Both sine and cosine; two results. | `llvm.sincos` |
| `math.asin` / `math.acos` / `math.atan` | Inverse trigonometry. | `llvm.asin` / `llvm.acos` / `llvm.atan` |
| `math.atan2` | Two-argument arc tangent. | `llvm.atan2` |
| `math.sinh` / `math.cosh` / `math.tanh` | Hyperbolic. | `llvm.sinh` / `llvm.cosh` / `llvm.tanh` |
| `math.asinh` / `math.acosh` / `math.atanh` | Inverse hyperbolic. | No intrinsic; `-math-expand-ops` or libm |
| `math.erf` / `math.erfc` | Error function and its complement. | No intrinsic; libm |
| `math.fma` | Fused `a*b + c`, optional rounding mode. | `llvm.fma`; with a rounding mode `llvm.experimental.constrained.fma` (documented) |
| `math.clampf` | `maxf(minf(value, max), min)`; poison if `min > max`. | `llvm.minnum` + `llvm.maxnum` (not documented which min/max) |
| `math.ctlz` / `math.cttz` / `math.ctpop` | Bit counts. | `llvm.ctlz` / `llvm.cttz` / `llvm.ctpop` |
| `math.isnan` / `math.isinf` / `math.isfinite` / `math.isnormal` | Classify; result is bool-like. | `llvm.is.fpclass` or `fcmp` |

Examples:

```
%sin, %cos = math.sincos %input : f64
%d = math.clampf %value to [%min, %max] : f64
%e = math.fma %a, %b, %c to_nearest_even : f64
%f = math.isfinite %a : f32
```

The only mapping the dialect page states outright is `math.fma`. The LLVM
dialect has an `llvm.intr.*` op for every intrinsic named in the table, which
supports the one-to-one reading.

**Not documented:** the `is_zero_poison` choice for `ctlz`/`cttz`, and the
`is_int_min_poison` choice for `absi`. The `math` page does not say what
`ctlz(0)` returns.

| Pass | What it does |
| --- | --- |
| `-convert-math-to-llvm` | Math to LLVM intrinsics. Option `approximate-log1p`. |
| `-convert-math-to-libm` | Math ops to calls to C library functions. |
| `-convert-math-to-funcs` | Outlines ops such as `ipowi` and `fpowi` as `linkonce_odr` functions. Options `min-width-of-fpowi-exponent`, `convert-ctlz`. |
| `-math-expand-ops` | Expands ops into simpler ones, for example hyperbolic functions into `exp`. Option `ops=sinh,acosh`. |
| `-math-extend-to-supported-types`, `-math-sincos-fusion`, `-math-uplift-to-fma` | Legalise small floats; fuse `sin`+`cos`; form `fma` from `mulf`+`addf`. |

**Epitome note:** `-convert-math-to-libm` leaves plain `call` instructions to
`sinf`, `erf` and so on. `-convert-math-to-funcs` leaves `linkonce_odr`
helper functions in the module. Both are ordinary IR.

## 4. The `index` dialect

Source: https://mlir.llvm.org/docs/Dialects/IndexOps/

`index` holds scalar operations on the `index` type only. The type is
signless, so signed and unsigned versions exist where it matters. Folding is
done in 64-bit arithmetic so that results do not depend on the eventual
pointer width.

Custom forms have no type, because every operand is `index`:

```
%c = index.add %a, %b
%0 = index.cmp slt(%a, %b)
%0 = index.constant 42
%0 = index.bool.constant true
%0 = index.casts %a : index to i32
%0 = index.sizeof
```

| Op | Meaning | LLVM IR (iN = pointer width) |
| --- | --- | --- |
| `index.add` / `sub` / `mul` | Wrapping arithmetic. | `add` / `sub` / `mul` |
| `index.divs` / `divu` | Divide towards zero; UB on zero (and `MIN / -1` for `divs`). | `sdiv` / `udiv` |
| `index.rems` / `remu` | Remainder. | `srem` / `urem` |
| `index.ceildivs` / `ceildivu` / `floordivs` | Rounding divisions. | Expanded into several ops (documented) |
| `index.maxs` / `maxu` / `mins` / `minu` | Max and min. | `llvm.smax` etc. |
| `index.and` / `or` / `xor` | Bitwise. | `and` / `or` / `xor` |
| `index.shl` / `shrs` / `shru` | Shifts; poison if the amount >= width. | `shl` / `ashr` / `lshr` |
| `index.cmp` | Compare with `eq`, `ne`, `slt`, `sle`, `sgt`, `sge`, `ult`, `ule`, `ugt`, `uge`. | `icmp` |
| `index.constant` | An `index` constant. | constant |
| `index.bool.constant` | An `i1` constant, from folding `cmp`. | constant |
| `index.casts` | To or from a fixed-width integer, sign-extending. | `sext` / `trunc` |
| `index.castu` | Same, zero-extending. | `zext` / `trunc` |
| `index.sizeof` | The width of `index` in bits, as an `index`. | constant 32 or 64 |

The pass `-convert-index-to-llvm` says the conversions are one to one except
the three rounding divisions. Its option `index-bitwidth` must be set to the
target's pointer width.

## 5. The `cf` dialect

Source: https://mlir.llvm.org/docs/Dialects/ControlFlowDialect/

`cf` is unstructured control flow: branches between blocks of a CFG. MLIR has
no `phi`. A branch passes values to the target block's arguments instead.

| Op | Custom form | LLVM IR |
| --- | --- | --- |
| `cf.br` | `cf.br ^bb3(%2 : tensor<*xf32>)` | `br label` (block arguments become `phi`) |
| `cf.cond_br` | `cf.cond_br %flag, ^bb1(%a : i32), ^bb1(%b : i32)` | `br i1` |
| `cf.switch` | see below | `switch` |
| `cf.assert` | `cf.assert %b, "Expected ... to be true"` | **Not documented** |

```
cf.switch %flag : i32, [
  default: ^bb1(%a : i32),
  42: ^bb1(%b : i32),
  43: ^bb3(%c : i32)
]
```

Rules:

- The condition of `cond_br` is `i1`. Both targets may be the same block with
  different operands, as in the example above.
- `cf.cond_br` may not target the entry block of a region.
- `cond_br` and `switch` may carry `weights(...)`, an `i32` array of branch
  weights.
- `cf.assert` aborts the program if its `i1` operand is false; the message is
  for a run-time library to show.

**Epitome note:** a `cond_br` whose two edges go to the same block with
different values has no direct LLVM form, because one LLVM `phi` cannot tell
the two edges apart. The translator must split one edge with an extra block.
The `llvm` dialect allows the same thing (LLVM dialect chapter, section 2).

**Not documented:** how `-convert-cf-to-llvm` lowers `cf.assert`. The pass
page only says ops it cannot convert make the pass fail. Its option is
`index-bitwidth`.

## 6. The `ub` dialect

Source: https://mlir.llvm.org/docs/Dialects/UBOps/

| Op | Custom form | Meaning | LLVM IR |
| --- | --- | --- | --- |
| `ub.poison` | `%0 = ub.poison : i32` | A poison constant of any type. An optional `<attr>` describes partly poisoned values. | `poison` (via `llvm.mlir.poison`) |
| `ub.unreachable` | `ub.unreachable` | Terminator; executing it is UB. | `unreachable` |

The pass is `-convert-ub-to-llvm` (option `index-bitwidth`). `-lift-cf-to-scf`
may create `ub.unreachable` for loops it can prove never exit.

## 7. The `scf` dialect

Source: https://mlir.llvm.org/docs/Dialects/SCFDialect/

`scf` is structured control flow: loops and conditionals as ops with regions.
It was first a common target for `affine` and `linalg`, and is normally
lowered to `cf` by `-convert-scf-to-cf`, then to LLVM.

### 7.1 `scf.for`

```
scf.for %iv = %lb to %ub step %step {
  ...
}
scf.for unsigned %iv_32 = %lb_32 to %ub_32 step %step_32 : i32 {
  ...
}
%sum = scf.for %iv = %lb to %ub step %step
    iter_args(%sum_iter = %sum_0) -> (f32) {
  %t = memref.load %buffer[%iv] : memref<1024xf32>
  %sum_next = arith.addf %sum_iter, %t : f32
  scf.yield %sum_next : f32
}
```

Meaning:

- Bounds and step are signed by default, unsigned with `unsigned`
  (`unsignedCmp`). The step must be strictly positive.
- The range is half-open: `lb` included, `ub` excluded. The trip count is
  `max(0, ceil((ub - lb) / step))` in exact arithmetic.
- `lb + n*step` must fit in the type of the induction variable. Otherwise the
  behaviour is undefined. This lets the loop lower to a simple
  increment-and-compare.
- Loop-carried values are block arguments after the induction variable. The
  body's `scf.yield` passes the next values. The op's results are the final
  values. With zero iterations the results are the initial values.

### 7.2 Other ops

| Op | Meaning |
| --- | --- |
| `scf.if` | If-then-else with regions. Results come from `scf.yield` in whichever region runs. The else region may be empty only when there are no results. |
| `scf.while` | A "before" region that ends in `scf.condition(%c) %args`, then an "after" region that ends in `scf.yield`. Payload in "before" makes a do-while; payload in "after" makes a while. |
| `scf.condition` | Terminator of the "before" region: continue to "after" if true, else exit with the forwarded values as results. |
| `scf.index_switch` | Switch on an `index` value with `case N { ... }` regions and a `default` region. |
| `scf.execute_region` | Runs its region once; lets a multi-block region live inside a single-block op. Optional `no_inline`. |
| `scf.parallel` | A multi-dimensional loop whose iterations may run in any order, with reductions through `scf.reduce`. |
| `scf.reduce` / `scf.reduce.return` | One region per reduction; each combines two values. Order is unspecified. |
| `scf.forall` / `scf.forall.in_parallel` | A parallel loop over tensors with `shared_outs`; each thread contributes a slice through `tensor.parallel_insert_slice`. |
| `scf.yield` | Terminator returning values to the parent op. |

```
%x, %y = scf.if %b -> (f32, f32) {
  scf.yield %x_true, %y_true : f32, f32
} else {
  scf.yield %x_false, %y_false : f32, f32
}

%res = scf.while (%arg1 = %init1) : (f32) -> f32 {
  %condition = call @evaluate_condition(%arg1) : (f32) -> i1
  scf.condition(%condition) %arg1 : f32
} do {
^bb0(%arg2: f32):
  %next = call @payload(%arg2) : (f32) -> f32
  scf.yield %next : f32
}
```

### 7.3 Lowering to `cf`, then LLVM

`-convert-scf-to-cf` turns each `scf.for` into a header block that compares
and branches, a body, and an exit. Observed on our matmul example, after the
full pipeline:

```
  llvm.br ^bb1(%12 : i64)
^bb1(%112: i64):  // 2 preds: ^bb0, ^bb5
  %113 = llvm.icmp "slt" %112, %11 : i64
  llvm.cond_br %113, ^bb2, ^bb6
```

which `mlir-translate` prints as:

```
28:                                               ; preds = %45, %7
  %29 = phi i64 [ %46, %45 ], [ 0, %7 ]
  %30 = icmp slt i64 %29, 4
  br i1 %30, label %31, label %47
```

The increment is a plain `add` with no flags (observed). The comparison is
`slt`, or `ult` for `unsigned` loops.

`scf.parallel` must first become `scf.for` nests (`-scf-parallel-for-to-nested-fors`
or `-scf-forall-to-for`) or OpenMP (`-convert-scf-to-openmp`). Other `scf`
passes: `-scf-for-loop-peeling`, `-scf-for-loop-specialization`,
`-scf-for-to-while`, `-scf-parallel-loop-tiling`, `-scf-parallel-loop-fusion`.

**Epitome note:** MLIR loops reach LLVM IR as unrotated, "top-tested"
loops: a header with a `phi`, an `icmp slt`, and a conditional branch. Loop
rotation in Epitome's middle end will see these just like clang's `-O0`
`for` loops after mem2reg.

## 8. The `memref` dialect

Source: https://mlir.llvm.org/docs/Dialects/MemRef/

A `memref<4x?xf32, layout, memspace>` is a reference to a buffer with a shape,
an element type, a layout (by default row-major, or `strided<[s0, s1],
offset: o>`) and a memory space. Dynamic sizes are `?`. `memref<*xf32>` is
unranked.

### 8.1 Allocation and globals

| Op | Custom form | Meaning | LLVM IR |
| --- | --- | --- | --- |
| `memref.alloc` | `%0 = memref.alloc(%d) : memref<8x?xf32, 1>` | Heap allocation; one operand per `?`; optional `alignment = N`. | `call @malloc` (or `aligned_alloc`) and pointer rounding |
| `memref.alloca` | `%0 = memref.alloca() : memref<8x64xf32>` | Stack allocation, freed when the nearest `AutomaticAllocationScope` (for example a function) exits. | `alloca` |
| `memref.alloca_scope` | `memref.alloca_scope { ... }` | Explicit scope for `alloca`s inside it. | `llvm.stacksave` / `llvm.stackrestore` |
| `memref.dealloc` | `memref.dealloc %0 : memref<8x64xf32>` | Free memory from `alloc`. Not for views. | `call @free` on the allocated pointer |
| `memref.realloc` | `%0 = memref.realloc %src : memref<64xf32> to memref<124xf32>` | Resize a 1-D buffer. | Expanded by `-expand-realloc` |
| `memref.global` | `memref.global "private" constant @c : memref<2xi32> = dense<[1, 4]>` | Static global buffer; `uninitialized` or no value for declarations. | global of array type |
| `memref.get_global` | `%x = memref.get_global @foo : memref<2xf32>` | A memref to a global. | `getelementptr` on the global |

Observed lowering of `memref.alloc() {alignment = 64} : memref<4x8xf32>`
(index is `i64`):

```
%90 = llvm.mlir.zero : !llvm.ptr
%91 = llvm.getelementptr %90[%89] : (!llvm.ptr, i64) -> !llvm.ptr, f32   // 32 elements
%92 = llvm.ptrtoint %91 : !llvm.ptr to i64                               // size in bytes
%94 = llvm.add %92, %93 : i64                                            // + alignment 64
%95 = llvm.call @malloc(%94) : (i64) -> !llvm.ptr
%96 = llvm.ptrtoint %95 : !llvm.ptr to i64
%98 = llvm.sub %93, %97 : i64
%99 = llvm.add %96, %98 : i64
%100 = llvm.urem %99, %93 : i64
%101 = llvm.sub %99, %100 : i64
%102 = llvm.inttoptr %101 : i64 to !llvm.ptr                             // aligned pointer
```

The size is computed with the "GEP from null" idiom. The malloc result goes in
descriptor field 0 (allocated pointer), the rounded value in field 1 (aligned
pointer).

Observed lowering of `memref.get_global` of a constant: field 1 is a
`getelementptr` to the global, and field 0 is `inttoptr 3735928559`
(`0xdeadbeef`), a marker that the buffer must never be freed.

### 8.2 Access

| Op | Custom form | Meaning | LLVM IR |
| --- | --- | --- | --- |
| `memref.load` | `%0 = memref.load %A[%a, %b] : memref<8x?xi32, #layout, memspace0>` | Read one element; indices must be in bounds. Optional `alignment(N)`, `nontemporal(true)`, `invariant(true)`. | address arithmetic + `getelementptr inbounds nuw` + `load` |
| `memref.store` | `memref.store %v, %A[%i, %j] : memref<4x4xf32>` | Write one element. | same + `store` |
| `memref.atomic_rmw` | `%x = memref.atomic_rmw "addf" %value, %I[%i] : (f32, memref<10xf32>) -> f32` | Atomic read-modify-write with an `AtomicRMWKind`. | `atomicrmw` |
| `memref.generic_atomic_rmw` | region with `memref.atomic_yield` | Atomic update by an arbitrary region. | `cmpxchg` loop (not documented) |
| `memref.prefetch` | `memref.prefetch %0[%i, %j], read, locality<3>, data : memref<400x400xi32>` | Prefetch hint. | `llvm.prefetch` |
| `memref.copy` | `memref.copy %arg0, %arg1 : memref<?xf32> to memref<?xf32>` | Copy all elements; same shape, any layouts. | see below |
| `memref.dma_start` / `dma_wait` | | Non-blocking DMA with a tag. | no general lowering |

The `memref.load` page documents the flags: `inbounds` is always set on the
`getelementptr`, and `nuw` only when every stride is statically
non-negative. Observed:

```
%118 = llvm.mul %114, %117 overflow<nsw, nuw> : i64
%119 = llvm.add %118, %112 overflow<nsw, nuw> : i64
%120 = llvm.getelementptr inbounds|nuw %116[%119] : (!llvm.ptr, i64) -> !llvm.ptr, f32
%121 = llvm.load %120 : !llvm.ptr -> f32
```

which becomes `getelementptr inbounds nuw float, ptr %p, i64 %idx` in LLVM IR.

`memref.copy` between non-contiguous layouts was observed to call a run-time
function, `declare void @memrefCopy(i64, ptr, ptr)`, with the element size in
bytes and pointers to two stack-allocated unranked descriptors.

### 8.3 Views and metadata

These change only the descriptor, never the data.

| Op | Custom form | Meaning |
| --- | --- | --- |
| `memref.subview` | `%r = memref.subview %a[1, 1][4, 4][2, 2] : memref<8x8xf32, strided<[8, 1], offset: 0>> to memref<4x4xf32, strided<[16, 2], offset: 9>>` | Offsets, sizes and strides of a sub-region. `stride' = stride * step`, `offset' = offset + dot(offsets, strides)`. |
| `memref.cast` | `%3 = memref.cast %1 : memref<4xf32> to memref<?xf32>` | Change static/dynamic information; a mismatch at run time is UB. |
| `memref.reinterpret_cast` | `memref.reinterpret_cast %base to offset: [%o], sizes: [..], strides: [..]` | Build any descriptor; no checks. |
| `memref.view` | `%1 = memref.view %0[%offset_1024][] : memref<2048xi8> to memref<64x4xf32>` | Typed view of an `i8` buffer at a byte shift. |
| `memref.collapse_shape` / `expand_shape` | `memref.collapse_shape %0 [[0, 1], [2]] : ... into ...` | Merge or split contiguous dimensions. |
| `memref.reshape` | `memref.reshape %src(%shape) : ...` | New shape from a shape operand; identity layout only. |
| `memref.transpose` | `memref.transpose %0 (i, j) -> (j, i) : ...` | Permute sizes and strides. |
| `memref.memory_space_cast` | `memref.memory_space_cast %1 : memref<?xf32, 5> to memref<?xf32>` | Change memory space. LLVM `addrspacecast`. |
| `memref.dim` / `memref.rank` | `%x = memref.dim %A, %c0 : memref<4 x ? x f32>` | Read a size / the rank. `extractvalue` of the size field, or a constant. |
| `memref.extract_strided_metadata` | `%base, %offset, %sizes:2, %strides:2 = memref.extract_strided_metadata %m : ...` | Split a memref into base, offset, sizes, strides. |
| `memref.extract_aligned_pointer_as_index` | `%0 = memref.extract_aligned_pointer_as_index %arg : memref<4x4xf32> -> index` | Field 1 as an integer (`ptrtoint`). |
| `memref.assume_alignment` | `memref.assume_alignment %m, 16 : memref<?xf32>` | Assume the buffer is aligned; poison if not. |
| `memref.distinct_objects` | `%1, %2 = memref.distinct_objects %a, %b : memref<?xf32>, memref<?xf32>` | Accesses through different results never alias. |

`-finalize-memref-to-llvm` does not handle the view ops itself.
`-expand-strided-metadata` must run first; it rewrites `subview`,
`collapse_shape`, `expand_shape`, `extract_aligned_pointer_as_index` and
`extract_strided_metadata` into `reinterpret_cast` and `affine.apply`
arithmetic. Then `-lower-affine` turns that into `arith`.

**Not documented:** what `assume_alignment` and `distinct_objects` become in
LLVM IR (perhaps `llvm.assume` with an `align` bundle, and `noalias`
metadata).

### 8.4 Memref passes

| Pass | What it does | Options |
| --- | --- | --- |
| `-finalize-memref-to-llvm` | Memref to the `llvm` dialect. | `use-aligned-alloc`, `index-bitwidth`, `use-generic-functions` |
| `-expand-strided-metadata` | View ops to explicit metadata arithmetic. | |
| `-memref-expand` | Legalise ops for LLVM conversion. | |
| `-expand-realloc` | `realloc` to alloc, copy, dealloc. | |
| `-normalize-memrefs` | Turn layout maps into identity layouts by rewriting indices. | |
| `-fold-memref-alias-ops`, `-flatten-memref` | Fold views into loads/stores; flatten to 1-D. | |

With `use-generic-functions`, calls go to `_mlir_memref_to_llvm_alloc`,
`_mlir_memref_to_llvm_aligned_alloc` and `_mlir_memref_to_llvm_free` instead
of `malloc`, `aligned_alloc` and `free`, with the same signatures.

## 9. The `tensor` dialect

Source: https://mlir.llvm.org/docs/Dialects/TensorOps/

A `tensor<4x?xf32>` is an immutable value, not memory. Tensor ops cannot be
lowered to LLVM directly. They must first be bufferized (section 10), which
turns them into `memref` ops.

| Op | Custom form | Meaning | Usual bufferized form |
| --- | --- | --- | --- |
| `tensor.empty` | `%t = tensor.empty(%d) : tensor<?x4xf32>` | A tensor of a shape with unspecified contents. | `memref.alloc` |
| `tensor.extract` | `%4 = tensor.extract %t[%1, %2] : tensor<4x4xi32>` | Read one element. | `memref.load` |
| `tensor.insert` | `%4 = tensor.insert %t into %dest[%1, %2] : tensor<4x4xi32>` | A copy of `dest` with one element changed. | `memref.store`, in place when safe |
| `tensor.extract_slice` | `%1 = tensor.extract_slice %0[0, 0, 0][1, 16, 4][1, 1, 1] : tensor<8x16x4xf32> to tensor<16x4xf32>` | A sub-tensor by offsets, sizes, strides; may drop unit dims. | `memref.subview` (documented) |
| `tensor.insert_slice` | `%1 = tensor.insert_slice %t into %0[0, 0, 0][1, 16, 4][1, 1, 1] : tensor<16x4xf32> into tensor<8x16x4xf32>` | A copy of `dest` with a slice replaced. | subview + copy, or nothing if in place (documented) |
| `tensor.from_elements` | `tensor.from_elements %a, %b, %c, %d, %e, %f : tensor<2x3xindex>` | Build from scalars, row-major. | alloc + stores |
| `tensor.generate` | `tensor.generate %m, %n { ^bb0(%i : index, ...): ... yield %elem : f32 } : tensor<?x3x?xf32>` | Build by a body run per index. | always a new allocation (documented) |
| `tensor.splat` | `%t = tensor.splat %s : tensor<8x16xf32>` | Every element the same. | alloc + fill |
| `tensor.pad` | `tensor.pad %src low[..] high[..] { ... tensor.yield %v } : ...` | Pad with a value from a region. | alloc + fill + copy |
| `tensor.concat` | `%0 = tensor.concat dim(0) %0, %1, %2 : (...) -> tensor<7x6xf32>` | Join along one dimension. | alloc + copies |
| `tensor.cast` | `%2 = tensor.cast %1 : tensor<*xf32> to tensor<?x?xf32>` | Change static/dynamic shape information. | `memref.cast` |
| `tensor.bitcast` | `%2 = tensor.bitcast %1 : tensor<4xui32> to tensor<4xi32>` | Same element width, new element type. | |
| `tensor.collapse_shape` / `expand_shape` | `%b = tensor.collapse_shape %a [[0, 1], [2]] : tensor<?x?x?xf32> into tensor<?x?xf32>` | Merge or split dimensions. | memref versions |
| `tensor.reshape` | `tensor.reshape %src(%shape) : ...` | New shape. | `memref.reshape` |
| `tensor.dim` / `tensor.rank` | `%x = tensor.dim %A, %c0 : tensor<4x?xf32>` | Size of a dimension / the rank. | `memref.dim` / `memref.rank` |
| `tensor.gather` / `tensor.scatter` | `tensor.gather %source[%indices] gather_dims([0, 1, 2]) : ...` | Index-driven gather and scatter. | |
| `tensor.parallel_insert_slice` | inside `scf.forall.in_parallel` | One thread's slice of a parallel result. | |
| `tensor.yield` | `tensor.yield %v : f32` | Terminator of `generate` and `pad`. | |

The "usual bufferized form" column is only a guide. The tensor page does not
give a table. Only `extract_slice`, `insert_slice` and `generate` are
described on the Bufferization page.

## 10. The `bufferization` dialect and One-Shot Bufferize

Source: https://mlir.llvm.org/docs/Bufferization/ and
https://mlir.llvm.org/docs/Dialects/BufferizationOps/ and `-one-shot-bufferize`
on https://mlir.llvm.org/docs/Passes/

### 10.1 Ops

| Op | Custom form | Meaning |
| --- | --- | --- |
| `bufferization.to_buffer` | `%m = bufferization.to_buffer %t : tensor<4x?xf32> to memref<4x?xf32, #layout, 0>` | The future buffer of a tensor. Optional `read_only`. |
| `bufferization.to_tensor` | `%t = bufferization.to_tensor %m : memref<4x?xf32, #layout, 0> to tensor<4x?xf32>` | A tensor view of a buffer. Optional `restrict`, `writable`. |
| `bufferization.materialize_in_destination` | `bufferization.materialize_in_destination %0 in restrict writable %C : (tensor<..>, memref<..>) -> ()` | The tensor's data must end up in `dest`. |
| `bufferization.alloc_tensor` | `%c = bufferization.alloc_tensor(%d1, %d2) : tensor<?x?xf32>` | Always a new buffer; optional `copy`. |
| `bufferization.clone` | `%arg1 = bufferization.clone %arg0 : memref<?xf32> to memref<?xf32>` | A copy, or an alias; mutating either afterwards is UB. |
| `bufferization.dealloc` | `bufferization.dealloc (%a0 : memref<2xf32>) if (%cond0) retain (%r0 : memref<?xf32>)` | Free each memref whose condition is set and which is not retained. |
| `bufferization.dealloc_tensor` | `bufferization.dealloc_tensor %tensor : tensor<1024x1024xf64, #CSR>` | Manual free in tensor form. |

`restrict` on `to_tensor` is like C `restrict`: no other `to_tensor` or
`materialize_in_destination` uses the same or an aliasing buffer.

### 10.2 One-Shot Bufferize in summary

- It rewrites every op that implements `BufferizableOpInterface` from tensors
  to memrefs, in one pass, a whole function at a time.
- It works in two phases: first an analysis decides, for each tensor operand,
  whether its buffer can be written in place; then the rewrite inserts an
  allocation and a copy for each operand that cannot.
- It is designed for **destination-passing style** (DPS). A DPS op has, for
  each tensor result, a tensor operand (the "destination", the `outs` of
  `linalg` ops) whose buffer the result may reuse. `tensor.insert %f into %t`
  either writes into `buffer(%t)` or into a fresh buffer; no other buffer is
  considered.
- Copies appear when the SSA use-def chain forks and a later op still reads
  the old value (a read-after-write conflict), or when the buffer is not
  writable (for example a `memref.global` from a constant).
- The analysis is greedy. Order is set by `analysis-heuristic`:
  `bottom-up` (default), `top-down`, `fuzzer`, `bottom-up-from-terminators`.
- It does not free anything. Run `-ownership-based-buffer-deallocation` (or
  the `buffer-deallocation-pipeline`) afterwards to insert deallocations, then
  `-bufferization-lower-deallocations` or `-convert-bufferization-to-memref`.
- Function boundaries are left alone unless `bufferize-function-boundaries` is
  set. Then tensor arguments and results become memrefs. Recursive calls,
  external functions returning tensors, and functions with several returns
  are not supported. Arguments are assumed writable unless annotated
  `bufferization.writable = false`.
- When a precise layout cannot be inferred, memrefs get fully dynamic layouts
  (`strided<[?, ?], offset: ?>`). `unknown-type-conversion` and
  `function-boundary-type-conversion` choose between `fully-dynamic-layout-map`,
  `identity-layout-map` and (for functions) `infer-layout-map`.
- Unknown ops make the pass fail unless `allow-unknown-ops` is set, in which
  case `to_buffer`/`to_tensor` are placed at the boundary.

Options: `allow-return-allocs-from-loops`, `allow-unknown-ops`,
`analysis-fuzzer-seed`, `analysis-heuristic`, `bufferize-function-boundaries`,
`may-have-parallel-regions`, `copy-before-write`, `dialect-filter`,
`dump-alias-sets`, `no-analysis-func-filter`, `function-boundary-type-conversion`,
`must-infer-memory-space`, `use-encoding-for-memory-space`, `test-analysis-only`,
`print-conflicts`, `unknown-type-conversion`, `buffer-alignment`.

Other bufferization passes: `-buffer-hoisting`, `-buffer-loop-hoisting`,
`-buffer-results-to-out-params` (memref results become out-parameters),
`-drop-equivalent-buffer-results`, `-eliminate-empty-tensors`,
`-empty-tensor-to-alloc-tensor`, `-promote-buffers-to-stack`,
`-optimize-allocation-liveness`, `-buffer-deallocation-simplification`,
`-static-memory-planner-analysis`.

**Epitome note:** in our observed pipeline
(`one-shot-bufferize{bufferize-function-boundaries function-boundary-type-conversion=identity-layout-map}`)
no deallocation pass ran, so the output IR calls `malloc` and never `free`.
That is a leak by design of the pipeline, not a lowering bug.

## 11. The `affine` dialect

Source: https://mlir.llvm.org/docs/Dialects/Affine/ and `-lower-affine` on
https://mlir.llvm.org/docs/Passes/

### 11.1 Affine maps and sets

- **Dimensions** `(d0, d1)` and **symbols** `[s0]` are `index` values.
  Symbols are fixed for a region (function arguments, constants, values
  defined at the top of an `AffineScope`); dimensions may also be loop
  induction variables.
- An **affine expression** uses `+`, `-`, multiplication by a constant, and
  `floordiv`, `ceildiv`, `mod` by a positive constant. Precedence: brackets,
  negation, then `*`/`floordiv`/`ceildiv`/`mod`, then `+`/`-`; all
  left-associative. `mod` results are never negative.
- An **affine map** is `affine_map<(d0, d1)[s0] -> (d0, d1 + s0, d1 - s0)>`.
  It may be named at the top of the file: `#map = affine_map<...>`.
- A **semi-affine map** also allows multiplying and dividing by symbols.
- An **integer set** is a conjunction of constraints:
  `affine_set<(d0, d1)[s0, s1] : (d0 >= 0, -d0 + s0 - 1 >= 0, d1 >= 0, -d1 + s1 - 1 >= 0)>`.

### 11.2 Ops

| Op | Custom form | Meaning |
| --- | --- | --- |
| `affine.apply` | `%2 = affine.apply affine_map<(i)[s0] -> (i + s0)> (%42)[%n]` | Evaluate a one-result map. |
| `affine.for` | `affine.for %i = 0 to %N step 2 { ... }` | Loop; bounds are maps, the step a positive constant. `max`/`min` for multi-result bounds. Optional `iter_args`. |
| `affine.if` | `affine.if #set(%i, %j)[%N] { ... } else { ... }` | Run a region if the point is in an integer set. |
| `affine.parallel` | `affine.parallel (%i, %j) = (0, 0) to (10, 10) { ... }` | Parallel band with optional reductions. |
| `affine.load` / `affine.store` | `%v = affine.load %A[%i + 3, %j] : memref<100x100xf32>` | Memory access with affine subscripts. |
| `affine.vector_load` / `affine.vector_store` | | Vector versions. |
| `affine.min` / `affine.max` | `%0 = affine.min affine_map<(d0)[s0] -> (1000, d0 + 512, s0)> (%arg0)[%arg1]` | Min/max over a multi-result map. |
| `affine.linearize_index` | `%l = affine.linearize_index [%i0, %i1, %i2] by (2, 3, 5) : index` | Multi-index to a linear index. |
| `affine.delinearize_index` | `%idx:3 = affine.delinearize_index %l into (%c16, %c224, %c224) : index, index, index` | Linear index to a multi-index. |
| `affine.prefetch`, `affine.dma_start`, `affine.dma_wait` | | Prefetch and DMA. |
| `affine.yield` | `affine.yield %v : f32` | Terminator. |

### 11.3 Lowering

`-lower-affine` turns `affine.for` into `scf.for`, `affine.if` into `scf.if`,
`affine.parallel` into `scf.parallel`, and `affine.apply` into `arith` on
`index`. The documented example:

```
%r = affine.apply affine_map<(d0, d1)[s0] -> (d0 + 2*d1 + s0)>(%d0, %d1)[%s0]
// becomes
%0 = arith.constant 2 : index
%1 = arith.muli %0, %d1
%2 = arith.addi %d0, %1
%r = arith.addi %2, %s0
```

`affine.load`/`store` become `memref.load`/`store` with the computed indices,
and `min`/`max` become comparisons and selects. The input must contain no
tensors.

**Not documented:** the exact `arith` sequence for `floordiv`, `ceildiv` and
`mod` (which must round towards minus infinity and give non-negative `mod`,
unlike `sdiv`/`srem`).

Analysis and transform passes in the dialect: `-affine-loop-fusion`,
`-affine-loop-tile`, `-affine-loop-unroll`, `-affine-loop-unroll-jam`,
`-affine-loop-invariant-code-motion`, `-affine-loop-normalize`,
`-affine-loop-coalescing`, `-affine-parallelize`, `-affine-scalrep`,
`-affine-super-vectorize`, `-affine-data-copy-generate`,
`-affine-pipeline-data-transfer`, `-affine-simplify-structures`,
`-affine-expand-index-ops`, and others.

## 12. The `vector` dialect (main ops)

Source: https://mlir.llvm.org/docs/Dialects/Vector/

MLIR vectors may have any rank: `vector<4x8x16xf32>`. A vector of rank 0 is
`vector<f32>`. A dimension in brackets is scalable: `vector<[4]xf32>` has
`4 * vscale` elements.

### 12.1 Type lowering

Documented: an n-D vector becomes nested LLVM arrays of 1-D vectors.
`vector<4x8x128xf32>` becomes `[4 x [8 x <128 x float>]]`, and
`vector<4x8x[128]xf32>` becomes `[4 x [8 x <vscale x 128 x float>]]`. Only the
trailing dimension may be scalable when lowering to LLVM.

The page explains the trade-off. With nested arrays, only the innermost
dimension can be indexed with a dynamic value (`extractelement`); outer
dimensions need `extractvalue` with constant indices. The other choice,
flattening to one long vector, was rejected because every access would need
index arithmetic.

### 12.2 Ops

| Op | Custom form | Meaning | LLVM IR (1-D case) |
| --- | --- | --- | --- |
| `vector.broadcast` | `%1 = vector.broadcast %0 : f32 to vector<16xf32>` | Splat a scalar or lower-rank vector. | `insertelement` + `shufflevector` zero mask |
| `vector.extract` | `%2 = vector.extract %0[2, 1, 3]: f32 from vector<4x8x16xf32>` | Read a sub-vector or element; out of bounds gives an undefined result. | `extractvalue` for outer dims, `extractelement` for the last |
| `vector.insert` | `%5 = vector.insert %3, %4[2, 1, 3] : f32 into vector<4x8x16xf32>` | Write a sub-vector or element. | `insertvalue` / `insertelement` |
| `vector.shuffle` | `%0 = vector.shuffle %a, %b[0, 3] : vector<2xf32>, vector<2xf32>` | Pick elements by a constant mask; `-1` is poison. | `shufflevector` |
| `vector.from_elements` | `%1 = vector.from_elements %f1, %f2 : vector<2xf32>` | Build from scalars. | chain of `insertelement` |
| `vector.to_elements` | | Split into scalars. | chain of `extractelement` |
| `vector.extract_strided_slice` / `insert_strided_slice` | | Strided sub-vectors. | shuffles |
| `vector.bitcast` | `%1 = vector.bitcast %0 : vector<5x1x4x3xf32> to vector<5x1x4x6xi16>` | Reinterpret the innermost dimension. | `bitcast` |
| `vector.shape_cast` | `%1 = vector.shape_cast %0 : vector<4x3xf32> to vector<3x2x2xf32>` | Same elements, new shape. | extract/insert or shuffles |
| `vector.transpose` | `%1 = vector.transpose %0, [1, 0] : vector<2x3xf32> to vector<3x2xf32>` | Permute dimensions. | shuffles (strategy is an option) |
| `vector.fma` | `%3 = vector.fma %0, %1, %2: vector<8x16xf32>` | Fused multiply-add. | `llvm.fma` (documented) |
| `vector.reduction` | `%1 = vector.reduction <add>, %0 : vector<16xf32> into f32` | Reduce a 1-D vector, optional accumulator. | `llvm.vector.reduce.*` |
| `vector.multi_reduction` | `%1 = vector.multi_reduction <add>, %0, %acc0 [1, 3] : vector<4x8x16x32xf32> to vector<4x16xf32>` | Reduce chosen dimensions. | lowered to `reduction` first |
| `vector.contract` | `%3 = vector.contract #trait %0, %1, %2 : vector<10xf32>, vector<10xf32> into f32` | Einsum-style contraction with `indexing_maps` and `iterator_types`. | lowered to `outerproduct`, `fma` or dot products |
| `vector.outerproduct` | `%2 = vector.outerproduct %0, %1: vector<4xf32>, vector<8xf32>` | Outer product, optional accumulator. | broadcasts + `fma` |
| `vector.load` | `%v = vector.load %base[%i, %j] : memref<100x100xf32>, vector<8xf32>` | Read contiguous elements. | `getelementptr` + vector `load` |
| `vector.store` | `vector.store %v, %base[%i, %j] : memref<100x100xf32>, vector<8xf32>` | Write contiguous elements. | `getelementptr` + `store` |
| `vector.maskedload` | `%0 = vector.maskedload %base[%i], %mask, %pass_thru : memref<?xf32>, vector<8xi1>, vector<8xf32> into vector<8xf32>` | Load lanes where the mask is set. | `llvm.masked.load` |
| `vector.maskedstore` | `vector.maskedstore %base[%i], %mask, %value : memref<?xf32>, vector<8xi1>, vector<8xf32>` | Store lanes where the mask is set. | `llvm.masked.store` |
| `vector.gather` / `vector.scatter` | `%0 = vector.gather %base[%c0][%v], %mask, %pass_thru : ... into vector<2x16xf32>` | Indexed load / store. | `llvm.masked.gather` / `scatter` |
| `vector.expandload` / `compressstore` | | Masked expand and compress. | `llvm.masked.expandload` / `compressstore` |
| `vector.create_mask` | `%1 = vector.create_mask %c3, %c2 : vector<4x3xi1>` | Mask true inside `[0, n)` per dimension. | step vector + `icmp` |
| `vector.constant_mask` | | Same with constants. | constant |
| `vector.step` | `%0 = vector.step : vector<4xindex>` | `[0, 1, ..., N-1]`, wrapping for narrow types. | constant, or `llvm.stepvector` for scalable |
| `vector.vscale` | | The run-time `vscale`. | `llvm.vscale` |
| `vector.transfer_read` / `transfer_write` | `%v = vector.transfer_read %A[%i, %j], %pad {permutation_map = ...} : memref<?x?xf32>, vector<32x256xf32>` | General read/write with permutation, padding and masking. | lowered to `load`/`maskedload` or loops (`-convert-vector-to-scf`) |
| `vector.mask` | `vector.mask %m { ... }` | Apply a mask to one maskable op. | `-lower-vector-mask` |
| `vector.print` | | Debug printing. | run-time calls |

Reduction kinds: `add`, `mul`, `minsi`, `minui`, `maxsi`, `maxui`, `and`, `or`,
`xor` for integers; `add`, `mul`, `minnumf`, `maxnumf`, `minimumf`, `maximumf`
for floats.

### 12.3 Passes

| Pass | Options |
| --- | --- |
| `-convert-vector-to-llvm` | `reassociate-fp-reductions`, `force-32bit-vector-indices`, `use-vector-alignment`, `enable-gep-inbounds-nuw`, `enable-arm-neon`, `enable-arm-sve`, `enable-arm-i8mm`, `enable-arm-bf16`, `enable-x86`, `vector-contract-lowering`, `vector-transpose-lowering` |
| `-convert-vector-to-scf` | `full-unroll`, `target-rank`, `lower-tensors`, `lower-scalable` |
| `-lower-vector-mask`, `-lower-vector-multi-reduction`, `-eliminate-vector-masks`, `-lower-vector-to-from-elements-to-shuffle-tree` | |

**Epitome note:** `reassociate-fp-reductions` decides whether a float
`vector.reduction` becomes `llvm.vector.reduce.fadd` with the `reassoc` flag
(unordered) or without it (strict in-order). `enable-gep-inbounds-nuw` is UB
if indices are out of range, exactly like the LLVM flags it sets.

**Not documented:** the op-by-op output of `-convert-vector-to-llvm`. The
"LLVM IR" column above is our reading of the semantics.

## 13. The `linalg` dialect

Source: https://mlir.llvm.org/docs/Dialects/Linalg/ and
`-convert-linalg-to-loops` on https://mlir.llvm.org/docs/Passes/

### 13.1 The structured op model

Every `linalg` op is a perfectly nested loop nest described by data, not by
loops. A `linalg.generic` carries:

- `ins(...)` and `outs(...)`: input and output operands, tensors or memrefs.
  On tensors, each `outs` operand is the "destination" and gives the shape of
  a result. On memrefs, the op writes the `outs` in place and has no results.
- `indexing_maps`: one affine map per operand. Each map takes the loop
  indices `(d0, ..., dn)` and gives that operand's subscript.
- `iterator_types`: one entry per loop, `parallel` or `reduction`.
- A region with one block. Its arguments are one scalar element per operand
  (inputs then outputs). It ends in `linalg.yield` with one value per output.
- Optional `library_call`, the name of an external function the op may become
  instead of loops; and optional `doc`.

The iteration space comes from the operand shapes: each loop's upper bound is
the size of an operand dimension that the loop index maps to. All accesses are
in bounds by construction, given that the operand sizes agree.

`linalg.index <dim>` reads the current value of loop `dim` inside the region.

Matmul as `linalg.generic` (from the dialect page):

```
#matmul_accesses = [
  affine_map<(m, n, k) -> (m, k)>,
  affine_map<(m, n, k) -> (k, n)>,
  affine_map<(m, n, k) -> (m, n)>
]
#matmul_trait = {
  doc = "C(m, n) += A(m, k) * B(k, n)",
  indexing_maps = #matmul_accesses,
  library_call = "linalg_matmul",
  iterator_types = ["parallel", "parallel", "reduction"]
}
linalg.generic #matmul_trait
  ins(%A, %B : memref<?x?xf32>, memref<?x?xf32>)
  outs(%C : memref<?x?xf32>) {
  ^bb0(%a: f32, %b: f32, %c: f32) :
    %d = arith.mulf %a, %b: f32
    %e = arith.addf %c, %d: f32
    linalg.yield %e : f32
}
```

On tensors, the same op takes `outs(%C : tensor<?x?xf32>)` and returns
`-> tensor<?x?xf32>`.

### 13.2 Named ops

Named ops are `linalg.generic` ops with fixed maps, iterator types and
bodies. They print in a short form with only `ins` and `outs`.

| Op | Computation | Notes |
| --- | --- | --- |
| `linalg.matmul` | `C(m,n) += A(m,k) * B(k,n)` | Optional `indexing_maps` to transpose or broadcast; optional `cast`. Operands are converted to the output type before the multiply. |
| `linalg.batch_matmul` | `C(b,m,n) += A(b,m,k) * B(b,k,n)` | |
| `linalg.batch_reduce_matmul` | `C(m,n) += sum over b of A(b,m,k) * B(b,k,n)` | |
| `linalg.matvec` / `vecmat` / `dot` | Matrix-vector, vector-matrix, dot product. | |
| `linalg.mmt4d` / `batch_mmt4d` | Tiled (4-D) matmul with transposed RHS. | |
| `linalg.contract` | General contraction `D[H] = sum A[I]*B[J] + C[H]` given by three `indexing_maps`. | Iterator types inferred. |
| `linalg.elementwise` | `linalg.elementwise <exp> ins(%x : ...) outs(%y : ...)` | Kind attribute; identity maps by default. |
| `linalg.map` | `%add = linalg.map { arith.addf } ins(%lhs, %rhs : ...) outs(%init: ...)` | Element-wise with a body. |
| `linalg.reduce` | `linalg.reduce { arith.addf } ins(...) outs(...) dimensions = [1]` | Reduce listed dimensions. |
| `linalg.transpose` | `linalg.transpose ins(...) outs(...) permutation = [1, 0]` | Moves data (unlike `memref.transpose`). |
| `linalg.broadcast` | | Static broadcast. |
| `linalg.fill` | `linalg.fill ins(%cst : f32) outs(%buf : memref<?x?xf32>)` | Every element set to a scalar. |
| `linalg.copy` | | Element-wise copy. |
| `linalg.conv_*` | for example `linalg.conv_2d_nhwc_hwcf` (input NHWC, kernel HWCF) | Attributes `strides` and `dilations` (`i64` elements, one per spatial dim). |
| `linalg.depthwise_conv_*`, `linalg.pooling_*` | Depthwise convolution; pooling with `max`, `min`, `sum` (and `_unsigned`). | Same attributes. |
| `linalg.softmax`, `linalg.pack`, `linalg.unpack`, `linalg.winograd_*` | Higher-level ops, decomposed by transforms. | |

Matmul with a transposed LHS:

```
linalg.matmul
    indexing_maps = [affine_map<(m, n, k) -> (k, m)>,
                     affine_map<(m, n, k) -> (k, n)>,
                     affine_map<(m, n, k) -> (m, n)>]
    ins(%arg0, %arg1 : memref<5x3xf32>, memref<5x7xf32>)
    outs(%arg2: memref<3x7xf32>)
```

Convolution sizes follow the usual rule: for output index `oh` and kernel
index `kh`, the input row is `oh * stride + kh * dilation`.

### 13.3 Lowering to loops

`-convert-linalg-to-loops` (or `-convert-linalg-to-affine-loops`,
`-convert-linalg-to-parallel-loops`) needs memref operands; tensors must be
bufferized first. It emits one `scf.for` per loop dimension, outermost `d0`,
each from 0 to the operand size, with step 1. In the innermost body it loads
one element of each operand through its indexing map, inlines the region, and
stores each yielded value to its output through the output's map. A
reduction loop reads and writes the same output element each iteration. The
documented form of the matmul above:

```
scf.for %m = %c0 to %M step %c1 {
  scf.for %n = %c0 to %N step %c1 {
    scf.for %k = %c0 to %K step %c1 {
      %a = memref.load %A[%m, %k] : memref<?x?xf32>
      %b = memref.load %B[%k, %n] : memref<?x?xf32>
      %c = memref.load %C[%m, %n] : memref<?x?xf32>
      %d = arith.mulf %a, %b: f32
      %e = arith.addf %c, %d: f32
      memref.store %e, %C[%m, %n] : memref<?x?xf32>
    }
  }
}
```

If `library_call` is set, the op may become `call @linalg_matmul(%A, %B, %C)`
with fully dynamic strided memrefs instead.

Other passes: `-linalg-generalize-named-ops` (named to `generic`),
`-linalg-specialize-generic-ops` (the reverse), `-linalg-fuse-elementwise-ops`,
`-linalg-fold-unit-extent-dims`, `-linalg-inline-scalar-operands`,
`-convert-elementwise-to-linalg`, `-linalg-block-pack-matmul`,
`-convert-tensor-to-linalg`.

**Epitome note:** after loop lowering, a `linalg.matmul` is three nested
top-tested loops with no `fma`: `fmul` then `fadd` with no fast-math flags
(observed). The `0.0` fill of the accumulator is a separate loop nest from
`linalg.fill`.

## 14. The `complex` dialect

Source: https://mlir.llvm.org/docs/Dialects/ComplexOps/ and
https://mlir.llvm.org/docs/TargetLLVMIR/

`complex<f32>` holds a real and an imaginary part. In LLVM it is the literal
struct `{ float, float }`, real first (documented).

| Op | Custom form | Meaning | LLVM IR |
| --- | --- | --- | --- |
| `complex.create` | `%a = complex.create %b, %c : complex<f32>` | From real and imaginary parts. | two `insertvalue` |
| `complex.constant` | `%a = complex.constant [0.1, -1.0] : complex<f64>` | Constant. | constant struct |
| `complex.re` / `complex.im` | `%a = complex.re %b : complex<f32>` | Read a part. | `extractvalue` 0 / 1 |
| `complex.add` / `sub` | `%a = complex.add %b, %c : complex<f32>` | Part-wise. | two `fadd` / `fsub` |
| `complex.mul` | `%a = complex.mul %b, %c : complex<f32>` | `(ac - bd) + (ad + bc)i`. | `fmul`, `fsub`, `fadd` |
| `complex.div` | `%a = complex.div %b, %c : complex<f32>` | Division; algorithm chosen by `complex-range`. | several float ops |
| `complex.neg` / `conj` | | Negate both / negate imaginary. | `fneg` |
| `complex.abs` | `%a = complex.abs %b : complex<f32>` | Modulus, a real. | `sqrt` of sum of squares, or scaled form |
| `complex.angle` | | Argument, a real. | `atan2` |
| `complex.eq` / `neq` | `%a = complex.eq %b, %c : complex<f32>` | Compare both parts; result `i1`. | two `fcmp` + `and`/`or` |
| `complex.exp`, `expm1`, `log`, `log1p`, `sqrt`, `rsqrt`, `sin`, `cos`, `tan`, `tanh`, `pow`, `powi`, `atan2`, `sign` | | Complex functions. | expanded by `-convert-complex-to-standard`, or libm calls |
| `complex.bitcast` | | Reinterpret as or from a same-size scalar. | `bitcast` |

All float ops take `fastmath<...>` (the `arith` flags).

`complex-range` (on `-convert-complex-to-llvm` and
`-convert-complex-to-standard`) controls division: `improved` (1), `basic`
(2), `none` (4). `-convert-complex-to-libm` turns supported ops into C library
calls.

**Not documented:** the formulas each range setting uses, and which libm
functions (`cexp`, `cabs` and so on) `-convert-complex-to-libm` calls. Passing a
`{ float, float }` struct by value is not the C ABI for `float _Complex` on
most targets, so libm calls need care.

## 15. The standard pipeline and what reaches LLVM IR

Source: https://mlir.llvm.org/docs/Passes/ and
https://mlir.llvm.org/docs/TargetLLVMIR/, plus observed output.

A typical pipeline from `linalg` on tensors to LLVM IR, as we ran it:

```
one-shot-bufferize{bufferize-function-boundaries function-boundary-type-conversion=identity-layout-map}
canonicalize
convert-linalg-to-loops
lower-affine
convert-scf-to-cf
expand-strided-metadata
finalize-memref-to-llvm
convert-arith-to-llvm
convert-math-to-llvm
convert-func-to-llvm
convert-cf-to-llvm
reconcile-unrealized-casts
```

then `mlir-translate --mlir-to-llvmir`. Order matters: `expand-strided-metadata`
creates `affine.apply`, so `lower-affine` must come after it if views are
present.

Shapes that mark LLVM IR as coming from MLIR:

| Shape | Cause |
| --- | --- |
| `; ModuleID = 'LLVMDialectModule'` and `source_filename = "LLVMDialectModule"` | The translator's module name (observed). |
| Arguments `(ptr, ptr, i64, i64..., i64...)` per memref | Unbundled memref descriptors (sections 8.3 and 9 of the LLVM dialect chapter). |
| Return type `{ ptr, ptr, i64, [N x i64], [N x i64] }` | Returned memref descriptor. |
| `define void @_mlir_ciface_f(ptr, ptr)` | C wrapper from `llvm.emit_c_interface`. |
| `inttoptr (i64 3735928559 ...)` | Allocated pointer of a constant global memref. |
| `malloc` size plus alignment, then `urem` rounding | `memref.alloc` with alignment. |
| `declare void @memrefCopy(i64, ptr, ptr)` | Non-contiguous `memref.copy`. |
| `getelementptr inbounds nuw float, ptr %p, i64 %i` with a `mul nuw nsw`/`add nuw nsw` index | Memref addressing. |
| `!llvm.module.flags = !{!0}`, `!0 = !{i32 2, !"Debug Info Version", i32 3}` | Always emitted by the translator (observed). |

**Epitome note:** none of these needs special support. They are useful to
recognise in test inputs, and the `_mlir_ciface_` wrapper is the entry point a
C harness calls.

## Still to read

| Gap | Document |
| --- | --- |
| Exact op-by-op output of `-convert-arith-to-llvm`, `-convert-math-to-llvm`, `-convert-vector-to-llvm` | No published table; run the passes on small inputs and record (observed behaviour) |
| `cf.assert` lowering | `-convert-cf-to-llvm` on a test input |
| Signed `floordiv`/`ceildiv`/`mod` expansion in `-lower-affine` and `-arith-expand` | Run the passes |
| Rationale for `index`, signless integers, `cmpi` design | https://mlir.llvm.org/docs/Rationale/Rationale/ |
| Builtin types and layouts (`strided<>`, affine layout maps) in full | https://mlir.llvm.org/docs/Dialects/Builtin/ (chapter 1) |
| Ownership-based buffer deallocation | https://mlir.llvm.org/docs/OwnershipBasedBufferDeallocation/ |
| Linalg OpDSL and the full list of named op bodies | https://mlir.llvm.org/docs/Dialects/Linalg/OpDSL/ |
| `vector.contract` and `vector.transfer_*` full semantics | https://mlir.llvm.org/docs/Dialects/Vector/ (long op entries not summarised here) |
| SCF to OpenMP, GPU | https://mlir.llvm.org/docs/Dialects/OpenMPDialect/, GPU pages |
| Complex division algorithms and libm names | Run `-convert-complex-to-standard` and `-convert-complex-to-libm` |
| Data layout and DLTI | https://mlir.llvm.org/docs/DataLayout/ |
