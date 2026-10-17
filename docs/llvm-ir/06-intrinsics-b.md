# Intrinsic functions, part 2

Source: LLVM Language Reference, sections "Vector Predication Intrinsics" to "Preserving Debug Information Intrinsics".

This chapter is a checklist. Every intrinsic the source describes in this
range has a row in a table. Overload suffixes are written as `.*`, or with
explicit placeholders such as `.<vty>.<pty>`, where the source uses them.

Placeholder conventions used below:

- `<W x T>` is a fixed or scalable vector (`<vscale x W x T>`). For scalable
  vectors, W is the runtime element count.
- `M` is a mask vector `<W x i1>` with the same element count as the data.
- `evl` is an `i32` explicit vector length.
- `rm` is a rounding-mode metadata string, `eb` an exception-behaviour
  metadata string (both defined in the constrained FP section).

---

## Vector predication (`llvm.vp.*`)

### Shared operand rules

Most VP intrinsics take a mask and an explicit vector length (EVL) as their
last two operands:

```
<W x T> llvm.vp.<op>.*(<W x T> %x, <W x T> %y, <W x i1> %mask, i32 %evl)
```

- **Mask.** Always a vector of `i1` with the same element count as the data
  vector.
- **EVL.** Always `i32`, read as unsigned. It must satisfy
  `0 <= evl <= W`. If `evl > W` the behaviour is undefined.
- **Effective mask.** EVL builds a mask that is true for lanes `i < evl` and
  false for lanes `evl <= i < W`. The effective mask is
  `M = mask AND evl_mask`.
- **Enabled lanes** are those where `M[i]` is true. Elementwise operations
  compute the normal result on enabled lanes.
- **Disabled lanes.** The general introduction says disabled lanes are
  `undef`. Every individual entry in this range instead says the result on
  disabled lanes is `poison`. **Smaugian note:** use poison for disabled
  lanes. It matches every per-intrinsic definition.
- **Reductions** treat disabled lanes as holding the operation's neutral
  value. They also fold in a scalar `start_value`. If no lanes are enabled
  (including `evl == 0`), the result is `start_value`. To ignore the start
  value, pass the neutral value.
- **Memory VP ops** (`vp.load`, `vp.store`, `vp.gather`, `vp.scatter`,
  strided forms) take alignment from an `align` parameter attribute on the
  pointer operand. Without it, alignment is the ABI alignment of the data
  type from the datalayout.
- **Optimisation hint.** Some targets (AVX512 is the example) have no
  hardware EVL. Using a non-trivial EVL there is discouraged. A target hook
  reports whether EVL is native.

**Not documented:** this version of the source lists only the VP members in
the table below. It has no entries for elementwise VP arithmetic such as
`llvm.vp.add`, `llvm.vp.fadd`, `llvm.vp.select`, casts or compares. Whether
those still exist is not stated in this range.

### VP elementwise and data movement

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.vp.merge.*` | `(<W x i1> cond, <W x T> on_true, <W x T> on_false, i32 pivot)` | Lane `i` comes from `on_true` if `cond[i]` is true and `i < pivot`. Otherwise it comes from `on_false`. There is no mask/EVL pair: `pivot` takes the EVL role. May carry fast-math flags when T is floating point. |
| `llvm.vp.sdiv.*` | `(<W x iN> a, <W x iN> b, M, evl)` | Signed `sdiv` on enabled lanes. Disabled lanes are poison. |
| `llvm.vp.udiv.*` | `(a, b, M, evl)` | Unsigned `udiv` on enabled lanes. Disabled lanes are poison. |
| `llvm.vp.srem.*` | `(a, b, M, evl)` | Signed `srem` on enabled lanes. Disabled lanes are poison. |
| `llvm.vp.urem.*` | `(a, b, M, evl)` | Unsigned `urem` on enabled lanes. Disabled lanes are poison. |
| `llvm.experimental.vp.splice.*` | `(<W x T> vec1, <W x T> vec2, i32 imm, M, i32 evl1, i32 evl2)` | **Experimental.** VP form of `llvm.vector.splice`. Joins `vec1[0..evl1)` and `vec2[0..evl2)`, then takes `evl2` elements starting at `imm` (or `evl1 + imm` when `imm` is negative). Lanes at or past `evl2` are undef. Masked-off lanes are poison. UB unless `-evl1 <= imm < evl1`, `0 <= evl1 <= VL` and `0 <= evl2 <= VL`. |
| `llvm.experimental.vp.reverse.*` | `(<W x T> vec, M, evl)` | **Experimental.** VP form of `llvm.vector.reverse`. Reverses the first `evl` elements. Masked-off lanes and lanes at or past `evl` are poison. |
| `llvm.vp.cttz.elts.<rty>.<vty>` | `(<W x iN> op, i1 is_zero_poison, M, evl)` | Counts trailing (lowest-index) zero elements among enabled lanes. Poison if the return type cannot hold W. Poison if all of `op` is zero and `is_zero_poison` is true; otherwise an all-zero input returns `evl`. `is_zero_poison` must be a constant. |

Splice examples from the source: `splice(<A,B,C,D>, <E,F,G,H>, 1, evl1=2, evl2=3)`
gives `<B, E, F, poison>`; `splice(..., -2, evl1=3, evl2=2)` gives
`<B, C, poison, poison>`.

**Not documented:** the `vp.cttz.elts` text says "otherwise, it returns the
explicit vector length". Read literally this is wrong for inputs that do
contain a non-zero element. The sensible reading is that `evl` is returned
only when no enabled lane is non-zero.

### VP reductions

All have the shape `T llvm.vp.reduce.<op>.<vty>(T start, <W x T> val, M, evl)`.
The element type of `val` equals the scalar type `T`.

| Intrinsic | Element type | Neutral value for disabled lanes | Meaning |
| --- | --- | --- | --- |
| `llvm.vp.reduce.add.*` | integer | `0` | `start + sum(enabled lanes)`. |
| `llvm.vp.reduce.mul.*` | integer | `1` | `start * product(enabled lanes)`. |
| `llvm.vp.reduce.and.*` | integer | all ones (`-1`) | Bitwise AND with `start`. |
| `llvm.vp.reduce.or.*` | integer | `0` | Bitwise OR with `start`. |
| `llvm.vp.reduce.xor.*` | integer | `0` | Bitwise XOR with `start`. |
| `llvm.vp.reduce.smax.*` | integer | `INT_MIN` | Signed max of `start` and enabled lanes. |
| `llvm.vp.reduce.smin.*` | integer | `INT_MAX` | Signed min. |
| `llvm.vp.reduce.umax.*` | integer | `0` | Unsigned max. |
| `llvm.vp.reduce.umin.*` | integer | all ones | Unsigned min. |
| `llvm.vp.reduce.fadd.*` | float | `-0.0` | Same as `llvm.vector.reduce.fadd(start, masked val)`, including its ordering rules. |
| `llvm.vp.reduce.fmul.*` | float | `1.0` | Same as `llvm.vector.reduce.fmul(start, masked val)`. |
| `llvm.vp.reduce.fmax.*` | float | no flags: `-QNaN`; `nnan` only: `-Inf`; `nnan`+`ninf`: smallest finite value | Max with `maxnum` semantics, as `llvm.vector.reduce.fmax`. |
| `llvm.vp.reduce.fmin.*` | float | no flags: `+QNaN`; `nnan` only: `+Inf`; `nnan`+`ninf`: largest finite value | Min with `minnum` semantics, as `llvm.vector.reduce.fmin`. |
| `llvm.vp.reduce.fmaximum.*` | float | no flags or `nnan` only: `-Inf`; `ninf`: smallest finite value | Max with `maximum` semantics. NaN propagates. `-0.0 < +0.0`. |
| `llvm.vp.reduce.fminimum.*` | float | no flags or `nnan` only: `+Inf`; `ninf`: largest finite value | Min with `minimum` semantics. NaN propagates. `-0.0 < +0.0`. |

**Smaugian note:** for the four FP min/max reductions the neutral value depends
on the call's fast-math flags. A lowering that inserts a select with a
neutral constant must read the flags first.

**Not documented:** the source's own `vp.reduce.fmax` example selects
`QNAN` (positive) for disabled lanes while the text says `-QNAN`. The text is
taken as authoritative here.

### VP memory operations

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.vp.load.<vty>.<pty>` | `(ptr p, M, evl) -> <W x T>` | Same as `llvm.masked.load` with the VP effective mask and a poison pass-through. |
| `llvm.vp.load.ff.<vty>.<pty>` | `(ptr p, M, evl) -> {<W x T>, i32}` | Fault-only-first load. Does not trap when fewer than `evl` lanes are readable. See below. |
| `llvm.vp.store.<vty>.<pty>` | `(<W x T> val, ptr p, M, evl)` | Same as `llvm.masked.store` with the VP effective mask. |
| `llvm.experimental.vp.strided.load.<vty>.<ity>` | `(ptr p, iK stride, M, evl) -> <W x T>` | **Experimental.** Gather from `p + i*stride` (stride in bytes, signed, arithmetic in the pointer type). Behaves like `vp.gather` on those addresses. |
| `llvm.experimental.vp.strided.store.<vty>.<ity>` | `(<W x T> val, ptr p, iK stride, M, evl)` | **Experimental.** Scatter `val` to `p + i*stride`, like `vp.scatter`. |
| `llvm.vp.gather.<vty>.<pvty>` | `(<W x ptr> ptrs, M, evl) -> <W x T>` | Same as `llvm.masked.gather` with the VP effective mask and a poison pass-through. Default alignment is the ABI alignment of the element. |
| `llvm.vp.scatter.<vty>.<pvty>` | `(<W x T> val, <W x ptr> ptrs, M, evl)` | Same as `llvm.masked.scatter` with the VP effective mask. Alignment comes from `align` on the pointer-vector operand. |

`llvm.vp.load.ff` details:

- If `evl != 0` and lane 0 is enabled, lane 0 must be in bounds of an
  allocation. Other enabled lanes below `evl` need not be in bounds of any
  allocation.
- The second result is the index of the first lane that could not be read,
  or `evl` if all could. Lanes at or above it in the vector result are
  poison.
- If `evl != 0`, the second result is at least 1, even when lane 0 is
  masked off.
- The second result may be smaller than necessary for any reason. A legal
  lowering is a single scalar load guarded by `evl != 0 && mask[0]` that
  reports 1.
- Enabled lanes outside the allocation that holds lane 0 are poison. The
  program must find its own terminator (for example a null byte).

**Smaugian note:** a simple and correct generic lowering of `vp.load.ff` is
the one-lane scalar load described above.

---

## Masked vector load and store

A mask bit per lane turns the lane on or off. Off lanes are never accessed.
They do not count as accesses for data races or `noalias`. Only the on
lanes must be in bounds, and they must all lie in the same allocation.
Alignment is given by an `align` parameter attribute on the pointer
operand.

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.masked.load.<vty>.<pty>` | `(ptr p, <W x i1> mask, <W x T> passthru) -> <W x T>` | Loads enabled lanes from `p`. Disabled lanes take `passthru`. Equivalent to a vector load plus `select`, without touching disabled lanes. T may be integer, FP or pointer. |
| `llvm.masked.store.<vty>.<pty>` | `(<W x T> value, ptr p, <W x i1> mask)` | Stores enabled lanes of `value` to `p`. Equivalent to load, select, store, but disabled lanes are not touched. |

**Not documented:** some examples in the source (in the expandload and
compressstore entries, and the `vp.store` comparison) still show an older
form with an explicit `i32` alignment operand. The syntax sections use the
`align` attribute form. **Smaugian note:** the reader should accept only the
form in the syntax sections unless the auto-upgrade chapter says otherwise.

## Masked vector gather and scatter

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.masked.gather.<vty>.<pvty>` | `(<W x ptr> ptrs, <W x i1> mask, <W x T> passthru) -> <W x T>` | Loads `*ptrs[i]` for enabled lanes. Disabled lanes take `passthru` and are not accessed. Alignment via `align` on `ptrs`. |
| `llvm.masked.scatter.<vty>.<pvty>` | `(<W x T> value, <W x ptr> ptrs, <W x i1> mask)` | Stores `value[i]` to `ptrs[i]` for enabled lanes. Overlapping stores happen in lane order, lowest lane first, so the highest lane wins. |

**Smaugian note:** the scatter ordering guarantee means a scalarised lowering
must emit stores in increasing lane order.

## Masked expanding load and compressing store

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.masked.expandload.<vty>` | `(ptr p, <W x i1> mask, <W x T> passthru) -> <W x T>` | Reads `popcount(mask)` consecutive elements from `p`. Places them, in order, into the enabled lanes. Disabled lanes take `passthru`. Default alignment is 1. |
| `llvm.masked.compressstore.<vty>` | `(<W x T> value, ptr p, <W x i1> mask)` | Writes the enabled lanes of `value`, in lane order, to consecutive elements starting at `p`. Default alignment is 1. |

If the mask is a run of ones followed by zeros, these equal
`masked.load`/`masked.store`. If the mask is all ones, `expandload` equals an
ordinary vector load.

## Masked vector arithmetic

All take `(<W x iN> op1, <W x iN> op2, <W x i1> mask) -> <W x iN>`. They have
no EVL.

| Intrinsic | Meaning |
| --- | --- |
| `llvm.masked.udiv.*` | `udiv` on enabled lanes. Disabled lanes are poison and can never cause UB (for example, division by zero there is fine). |
| `llvm.masked.sdiv.*` | `sdiv`, same masking rule. |
| `llvm.masked.urem.*` | `urem`, same masking rule. |
| `llvm.masked.srem.*` | `srem`, same masking rule. |

## Speculative loads

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.speculative.load.<ty>.<pty>` | `(ptr p, i1 from_end, ...) -> ty` | Loads S bytes (S = size of `ty`, a positive power of two; `ty` is a byte type or vector). Only N bytes are real: if `from_end` is false, bytes `[0, N)`; if true, bytes `[S-N, S)`. All other bytes are poison and do not count as accessed. UB if N > S, or if any byte actually read is not safe to access speculatively. |
| `llvm.can.load.speculatively.<pty>` | `(ptr p, i64 num_bytes) -> i1` | Target-dependent. True only if, for every `I >= 0` whose address does not wrap and whose first or last byte is in the same object as `p`, `num_bytes` bytes at `p + I*num_bytes` can be loaded speculatively. Poison if `num_bytes` is not a power of two. |

N for `speculative.load` comes from the variadic tail, in one of two forms:

- **Direct:** `i64 N`.
- **Oracle:** `ptr @f, args...`. `@f` must be a direct reference to a
  non-variadic function returning `i64`, marked `nounwind`, `nosync` and
  `willreturn`, that reads memory only through its arguments. N is
  `@f(args...)`.

`from_end` must be a constant. The N real bytes must lie inside an object
that `p` is based on.

**Smaugian note:** the verifier should check the oracle function's attributes
and the power-of-two size of the return type.

## Memory use markers

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.lifetime.start` | `(ptr captures(none) p)` | Marks the stack object as alive with uninitialised contents. Calling it on an already-live object resets contents to uninitialised. Address does not change across restarts. |
| `llvm.lifetime.end` | `(ptr captures(none) p)` | Marks the stack object dead. No-op if already dead. Objects also become dead when the function returns. |
| `llvm.invariant.start.<pty>` | `(i64 size, ptr captures(none) p) -> ptr` | Declares the object's contents constant until a matching `invariant.end` that uses the returned value. `size` is a constant, or `-1` for variable size. |
| `llvm.invariant.end.<pty>` | `(ptr start, i64 size, ptr captures(none) p)` | Ends the invariant region. `start` is the result of the matching `invariant.start`. |
| `llvm.launder.invariant.group.<pty>` | `(ptr p) -> ptr` | **Experimental.** Returns a pointer that aliases `p` but counts as distinct for `!invariant.group` metadata. Reads no accessible memory. Speculatable. Result is in the same address space as `p`. |

Lifetime rules:

- The operand must be `poison`, an `alloca` result, or a call to an
  `llvm.structured.alloca` intrinsic. Anything else is ill-formed IR.
  **Smaugian note:** enforce this in the verifier.
- If the operand is `poison`, the intrinsic does nothing.
- A stack object starts dead. It becomes live at `lifetime.start`.

---

## Constrained floating point (`llvm.experimental.constrained.*`)

**Experimental:** the whole family is in the `experimental` namespace.

### Shared rules

- Each intrinsic matches a normal FP operation. Data operands and result
  types are the same as that operation.
- If any FP operation in a function is constrained, all of them must be.
  To get default behaviour in such a function, use constrained intrinsics
  with `"round.tonearest"` and `"fpexcept.ignore"`.
- Every function definition that uses constrained intrinsics must have the
  `strictfp` attribute.
- Every call inside such a function must have `strictfp` on the call or on
  the callee's declaration or definition.
- The rounding mode and exception arguments only constrain the optimiser.
  They do not change the runtime FP environment.
- The number and order of FP exceptions raised is not guaranteed. For
  example, vectorisation may merge several exceptions into one.

**Smaugian note:** the verifier should reject mixed constrained and plain FP
operations in one function, and check the `strictfp` attributes.

**Not documented:** what counts as an "FP operation" for the mixing rule
(for example, whether `fneg` or FP intrinsics like `llvm.fabs` count).

#### Rounding mode argument (`metadata`)

Exactly one of these strings:

```
"round.dynamic"
"round.tonearest"
"round.downward"
"round.upward"
"round.towardzero"
"round.tonearestaway"
```

- `"round.dynamic"`: the mode is unknown and may change at runtime. No
  rounding-dependent transforms are allowed.
- The others name the IEEE modes. The optimiser may assume the runtime mode
  matches. If it does not match at runtime, behaviour is undefined.
- Example from the source: `x - 0 -> x` is invalid under `"round.downward"`
  and `"round.dynamic"`, because `+0 - 0` is `-0` when rounding down.

Some intrinsics have no rounding-mode argument. The table marks which.

#### Exception behaviour argument (`metadata`)

Exactly one of these strings:

```
"fpexcept.ignore"
"fpexcept.maytrap"
"fpexcept.strict"
```

- `"fpexcept.ignore"`: status flags are never read and exceptions are
  masked. The optimiser may change exception behaviour, including
  speculating FP operations.
- `"fpexcept.maytrap"`: do not add exceptions the original code would not
  raise (so no speculation). Exceptions may be lost, for example by constant
  folding.
- `"fpexcept.strict"`: preserve exactly the set of exceptions raised. Use
  this when code reads status flags or unmasks exceptions.

#### Condition codes for `fcmp` / `fcmps` (`metadata`)

`"oeq"`, `"ogt"`, `"oge"`, `"olt"`, `"ole"`, `"one"`, `"ord"`, `"ueq"`,
`"ugt"`, `"uge"`, `"ult"`, `"ule"`, `"une"`, `"uno"`. Ordered (`o`) codes
are false if either operand is NaN. Unordered (`u`) codes are true if
either operand is NaN. `"ord"` is true when neither is NaN; `"uno"` when
either is. Note there is no `true`/`false` code, unlike the `fcmp`
instruction.

### Basic constrained operations

Columns: **RM** = takes a rounding-mode argument. All take an exception
argument as the last operand.

| Intrinsic | Operands | RM | Meaning |
| --- | --- | --- | --- |
| `llvm.experimental.constrained.fadd` | `(T a, T b, rm, eb)` | yes | Sum. |
| `llvm.experimental.constrained.fsub` | `(T a, T b, rm, eb)` | yes | Difference. |
| `llvm.experimental.constrained.fmul` | `(T a, T b, rm, eb)` | yes | Product. |
| `llvm.experimental.constrained.fdiv` | `(T a, T b, rm, eb)` | yes | Quotient. |
| `llvm.experimental.constrained.frem` | `(T a, T b, rm, eb)` | yes (ignored) | Remainder, sign of the dividend. Never rounded; the RM operand exists only for uniformity. |
| `llvm.experimental.constrained.fma` | `(T a, T b, T c, rm, eb)` | yes | `a*b + c` with one rounding. |
| `llvm.experimental.constrained.fmuladd` | `(T a, T b, T c, rm, eb)` | yes | Like constrained `fmul` then `fadd`, but it is unspecified whether the intermediate is rounded. Never sets errno. |
| `llvm.experimental.constrained.fptoui` | `(FP v, eb) -> ty2` | no | FP to unsigned integer, rounding toward zero. |
| `llvm.experimental.constrained.fptosi` | `(FP v, eb) -> ty2` | no | FP to signed integer, rounding toward zero. |
| `llvm.experimental.constrained.uitofp` | `(int v, rm, eb) -> ty2` | yes | Unsigned integer to FP. Raises inexact if rounding happens. |
| `llvm.experimental.constrained.sitofp` | `(int v, rm, eb) -> ty2` | yes | Signed integer to FP. Raises inexact if rounding happens. |
| `llvm.experimental.constrained.fptrunc` | `(FP v, rm, eb) -> ty2` | yes | Narrow to a smaller FP type. Source must be larger than result. |
| `llvm.experimental.constrained.fpext` | `(FP v, eb) -> ty2` | no | Widen to a larger FP type. Same restrictions as the `fpext` instruction. |
| `llvm.experimental.constrained.fcmp` | `(T a, T b, metadata cc, eb) -> i1 or <N x i1>` | no | Quiet compare. Raises an exception only for a signalling NaN operand. |
| `llvm.experimental.constrained.fcmps` | `(T a, T b, metadata cc, eb) -> i1 or <N x i1>` | no | Signalling compare. Raises an exception for any NaN operand, but still produces a result. |

T is a floating-point scalar or vector; all `T` operands have identical type.
Vectors are processed element by element.

### Constrained libm-equivalent operations

Each returns what the named libm function returns and handles errors the
same way, except that `errno` is never set. T is an FP scalar or vector.

| Intrinsic | Operands | RM | Meaning |
| --- | --- | --- | --- |
| `llvm.experimental.constrained.sqrt` | `(T x, rm, eb)` | yes | Non-negative square root. For inputs below `-0.0`, an FP exception occurs and the result is target-specific. |
| `llvm.experimental.constrained.pow` | `(T x, T y, rm, eb)` | yes | `pow(x, y)`. |
| `llvm.experimental.constrained.powi` | `(T x, i32 n, rm, eb)` | yes | `x` to integer power `n`. Order of multiplications and roundings is unspecified. `n` stays scalar for vector `x`. |
| `llvm.experimental.constrained.ldexp` | `(T0 x, T1 e, rm, eb)` | yes | `x * 2^e`. `e` is integer with the same element count. NaN or infinity returns `x`. Underflow gives signed zero, overflow gives signed infinity. |
| `llvm.experimental.constrained.sin` | `(T x, rm, eb)` | yes | `sin`. |
| `llvm.experimental.constrained.cos` | `(T x, rm, eb)` | yes | `cos`. |
| `llvm.experimental.constrained.tan` | `(T x, rm, eb)` | yes | `tan`. |
| `llvm.experimental.constrained.asin` | `(T x, rm, eb)` | yes | `asin`. |
| `llvm.experimental.constrained.acos` | `(T x, rm, eb)` | yes | `acos`. |
| `llvm.experimental.constrained.atan` | `(T x, rm, eb)` | yes | `atan`. |
| `llvm.experimental.constrained.atan2` | `(T y, T x, rm, eb)` | yes | `atan2`, quadrant aware. |
| `llvm.experimental.constrained.sinh` | `(T x, rm, eb)` | yes | `sinh`. |
| `llvm.experimental.constrained.cosh` | `(T x, rm, eb)` | yes | `cosh`. |
| `llvm.experimental.constrained.tanh` | `(T x, rm, eb)` | yes | `tanh`. |
| `llvm.experimental.constrained.exp` | `(T x, rm, eb)` | yes | `exp` (base e). |
| `llvm.experimental.constrained.exp2` | `(T x, rm, eb)` | yes | `exp2`. |
| `llvm.experimental.constrained.log` | `(T x, rm, eb)` | yes | `log` (base e). |
| `llvm.experimental.constrained.log10` | `(T x, rm, eb)` | yes | `log10`. |
| `llvm.experimental.constrained.log2` | `(T x, rm, eb)` | yes | `log2`. |
| `llvm.experimental.constrained.rint` | `(T x, rm, eb)` | yes | Round to integer in the current mode. May raise inexact. The real mode is the runtime one; `rm` only describes it. |
| `llvm.experimental.constrained.nearbyint` | `(T x, rm, eb)` | yes | Like `rint` but never raises inexact. |
| `llvm.experimental.constrained.lrint` | `(FP x, rm, eb) -> iN` | yes | Round to integer in the runtime mode. Raises inexact if not integral. If out of range, raises invalid and returns a non-deterministic value (like `freeze poison`). Supported types as for `llvm.lrint`. |
| `llvm.experimental.constrained.llrint` | `(FP x, rm, eb) -> iN` | yes | As `lrint`, matching `llvm.llrint` types. |
| `llvm.experimental.constrained.maxnum` | `(T a, T b, eb)` | no | IEEE 754-2008 `maxNum`. |
| `llvm.experimental.constrained.minnum` | `(T a, T b, eb)` | no | IEEE 754-2008 `minNum`. |
| `llvm.experimental.constrained.maximum` | `(T a, T b, eb)` | no | IEEE 754-2019 maximum. NaN propagates. `-0.0 < +0.0`. |
| `llvm.experimental.constrained.minimum` | `(T a, T b, eb)` | no | IEEE 754-2019 minimum. NaN propagates. `-0.0 < +0.0`. |
| `llvm.experimental.constrained.ceil` | `(T x, eb)` | no | `ceil`. |
| `llvm.experimental.constrained.floor` | `(T x, eb)` | no | `floor`. |
| `llvm.experimental.constrained.round` | `(T x, eb)` | no | `round` (ties away from zero). |
| `llvm.experimental.constrained.roundeven` | `(T x, eb)` | no | IEEE `roundToIntegralTiesToEven`, independent of the current mode. May signal invalid for a signalling NaN. |
| `llvm.experimental.constrained.lround` | `(FP x, eb) -> iN` | no | Round to integer, ties away from zero. Raises inexact if not integral. Out of range: invalid, non-deterministic result (like `freeze poison`). |
| `llvm.experimental.constrained.llround` | `(FP x, eb) -> iN` | no | As `lround`, matching `llvm.llround` types. |
| `llvm.experimental.constrained.trunc` | `(T x, eb)` | no | Round toward zero. |

**Not documented:** the syntax for `maxnum`, `minnum`, `maximum` and
`minimum` in the source omits the comma before the metadata operand. This is
a typo; the operand list is `(T, T, metadata)`.

**Not documented:** the source shows these intrinsics without overload
suffixes. Calls in practice carry a type suffix (the `fmuladd` example uses
`.f32`), but the exact suffix scheme for the conversion forms with two
types is not given in this range.

## Noalias scope declaration

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.experimental.noalias.scope.decl` | `(metadata !scope_list)` | **Experimental.** Marks where a `noalias` scope is declared. The list must have exactly one element and uses the `noalias` metadata format. When code containing it is duplicated (for example, loop unrolling), the scope may need duplicating too. |

**Smaugian note:** the verifier must reject two declarations of the same scope
where one dominates the other.

---

## Floating-point environment

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.get.rounding` | `() -> i32` | Returns the current rounding mode in `FLT_ROUNDS` encoding (below). Other values are target-specific. |
| `llvm.set.rounding` | `(i32 mode)` | Sets the rounding mode, same encoding. Like `fesetround` but returns nothing. |
| `llvm.get.fpenv` | `() -> iN` | Returns the whole FP environment as an integer of target-specific width. |
| `llvm.set.fpenv` | `(iN env)` | Sets the FP environment from a value from `get.fpenv` or built in a target-specific way. |
| `llvm.reset.fpenv` | `()` | Sets the default environment, like `fesetenv(FE_DFL_ENV)`. |
| `llvm.get.fpmode` | `() -> iN` | Returns the dynamic control modes (rounding, precision, denormal handling and so on) as a target-specific integer. Like `fegetmode`. |
| `llvm.set.fpmode` | `(iN modes)` | Sets control modes from a `get.fpmode` value or a target-specific constant. Like `fesetmode`. |
| `llvm.reset.fpmode` | `()` | Sets default control modes, like `fesetmode(FE_DFL_MODE)`. |

Rounding mode encoding:

| Value | Mode |
| --- | --- |
| 0 | toward zero |
| 1 | to nearest, ties to even |
| 2 | toward positive infinity |
| 3 | toward negative infinity |
| 4 | to nearest, ties away from zero |

**Not documented:** behaviour when `llvm.set.rounding` gets a value the
target does not support.

## Floating-point test

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.is.fpclass.*` | `(FP op, i32 test) -> i1`, or vector form `-> <N x i1>` | True if `op` is in any class whose bit is set in `test`. Never raises exceptions. Does not canonicalise. Ignores the FP environment: a subnormal is seen as subnormal even under flush-to-zero modes. `test` must be a constant. |

`test` bits:

| Bit | Class |
| --- | --- |
| 0 | signalling NaN |
| 1 | quiet NaN |
| 2 | negative infinity |
| 3 | negative normal |
| 4 | negative subnormal |
| 5 | negative zero |
| 6 | positive zero |
| 7 | positive subnormal |
| 8 | positive normal |
| 9 | positive infinity |

Example: `0x108` (bits 3 and 8) tests for any normal value.

**Not documented:** whether bits above 9 must be zero.

---

## General intrinsics

### Annotations

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.var.annotation` | `(ptr val, ptr str, ptr file, i32 line)` | Attaches a string to a local variable. Ignored by optimisation and codegen. |
| `llvm.ptr.annotation.<pty>` | `(ptr val, ptr str, ptr file, i32 line) -> ptr` | Annotates a pointer value. Returns `val`. Passes may replace it with `val`. Dropped at instruction selection. The address space suffix is mandatory (`p0` for the default). |
| `llvm.annotation.<iN>` | `(iN val, ptr str, ptr file, i32 line) -> iN` | Annotates an integer expression. Returns `val`. May be replaced by `val`. Dropped at instruction selection. |
| `llvm.codeview.annotation` | `(metadata tuple)` | Emits a label and an `S_ANNOTATION` CodeView record carrying the tuple's strings (MSVC `__annotation`). The operand is an MDTuple of MDStrings. It is `noduplicate`, so it blocks inlining. |

`str` and `file` point at global strings; `file` is the source file name and
`line` the line number.

### Traps

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.trap` | `()`, `cold noreturn nounwind` | Target trap instruction, or a call to `abort()` if none exists. |
| `llvm.debugtrap` | `()`, `nounwind` | Traps to request a debugger's attention. Not `noreturn`. |
| `llvm.ubsantrap` | `(i8 immarg kind)`, `cold noreturn nounwind` | Trap that encodes `kind` where possible. Equal to `llvm.trap` otherwise. |
| `llvm.cond.loop` | `(i1 pred)` | If `pred`, spin forever; else do nothing. Same meaning as a conditional branch to a self-loop block. On X86 the loop is a short self-branch: first byte `0x70`-`0x7F`, second byte `0xFE`. No guarantees on other targets. |
| `llvm.looptrap` | `()`, `cold noreturn nounwind` | Same as `cond.loop(true)` but `noreturn`. A late pass turns it into `cond.loop(true)` or folds a guarding branch into `cond.loop(pred)`. |

(`llvm.cond.loop` and `llvm.looptrap` appear under "Preserving Debug
Information Intrinsics" in the source, but are grouped here by purpose.)

### Stack protection

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.stackprotector` | `(ptr guard, ptr slot)` | Stores `guard` (loaded from `@__stack_chk_guard`) into `slot`, an `alloca`. The frame lowering places `slot` before locals so overflows clobber it. |
| `llvm.stackguard` | `() -> ptr` | Returns the system stack guard value. For internal use only; frontends should not emit it. |

**Not documented:** `llvm.stackprotectorcheck` is mentioned as the check on
function exit (calling `__stack_chk_fail()` on mismatch) but has no entry of
its own. The source also notes some platforms (X86 Linux) load the guard
differently at IR level and are not yet handled by `llvm.stackguard`.

### Optimisation hints and facts

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.objectsize.<iN>` | `(ptr obj, i1 min, i1 nullunknown, i1 dynamic) -> i32/i64` | Size of the object `obj` points into. If unknown, returns `-1` when `min` is false and `0` when `min` is true. `min` picks a lower bound (true) or upper bound (false). With `nullunknown` false, `null` in address space 0 gives 0; otherwise null is unknown. `dynamic` allows runtime evaluation. The three flags must be constants. |
| `llvm.expect.<iN>` | `(iN val, iN expected) -> iN` | Hint that `val` is probably `expected`. Lowers to `val`. |
| `llvm.expect.with.probability.<iN>` | `(iN val, iN expected, double prob) -> iN` | Same, with a confidence `prob`. Lowers to `val`. |
| `llvm.assume` | `(i1 cond)` | The optimiser may assume `cond` is true wherever the call is reached. UB if false at runtime. Generates no code. Richer facts go in assume operand bundles. |
| `llvm.ssa.copy` | `(T returned x) -> T`, `memory(none)` | Returns `x`. A tool for passes building temporary renamed SSA forms (for example PredicateInfo). Not for general use. |
| `llvm.arithmetic.fence` | `(T x) -> T` | Returns `x`. Blocks fast-math reassociation across the boundary: nothing moves into or out of the operand's computation. T is FP scalar or vector. |
| `llvm.is.constant.*` | `(T x) -> i1`, `nounwind memory(none)` | True if `x` is a manifest compile-time constant. Always folds to a constant before codegen. Addresses of globals are not manifest. The answer may depend on optimisation (inlining). Any argument type is allowed. |
| `llvm.sideeffect` | `()`, `inaccessiblememonly nounwind willreturn` | Does nothing, but counts as an observable side effect. Stops an otherwise empty loop being assumed to terminate. |
| `llvm.donothing` | `()`, `nounwind memory(none)` | Does nothing. Removed by optimisers. One of three intrinsics that may be called with `invoke` (with `llvm.experimental.patchpoint` and `llvm.experimental.gc.statepoint`). |
| `llvm.fake.use` | `(...)` | No-op that counts as a use of its single operand, keeping it alive to that point. Variadic only so any type fits; more than one argument is an error. Operand must be a function-local SSA value. |

**Smaugian note:** the verifier must allow `invoke` of `llvm.donothing`,
`llvm.experimental.patchpoint` and `llvm.experimental.gc.statepoint`, and
reject `invoke` of other intrinsics (and specifically of
`llvm.experimental.deoptimize`, `llvm.experimental.guard` and
`llvm.experimental.widenable.condition`).

**Smaugian note:** `llvm.is.constant` must always be folded to `true` or
`false` before instruction selection. A fallback of `false` is always
legal.

### Type metadata and CFI

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.type.test` | `(ptr p, metadata type) -> i1`, `nounwind memory(none)` | True if `p` is associated with the type identifier. |
| `llvm.type.checked.load` | `(ptr p, i32 offset, metadata type) -> {ptr, i1}`, `nounwind memory(argmem: read)` | Loads a function pointer from vtable `p` at byte `offset` and checks the type. If the `i1` is false, the pointer is undefined. If true: when `p` has the type, the pointer is the real load; otherwise it is an unspecified choice of a load from some pointer of that type, or a side-effect-free function returning an unspecified value. The `i1` may be true even if `p` lacks the type. |
| `llvm.type.checked.load.relative` | `(ptr p, i32 offset, metadata type) -> {ptr, i1}` | As `type.checked.load`, but the vtable entry is a relative offset, resolved as in `llvm.load.relative`. |
| `llvm.load.relative.<iN>` | `(ptr p, iN offset) -> ptr`, `nounwind memory(argmem: read)` | Loads a 32-bit value from `p + offset` and returns `p` plus that value. Constant folding recognises initialisers of the form `i32 trunc(x - p)` and folds to `x`. |

### Deoptimisation and guards

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.experimental.deoptimize` | `(...) -> T` with `"deopt"(...)` bundle | **Experimental.** Runs the attached deopt continuation and returns its result. May have any side effect. Lowers to a call to `__llvm_deoptimize` (the frontend must define it), with arguments passed as fixed, not variadic. |
| `llvm.experimental.guard` | `(i1 pred, ...)` with `"deopt"(...)` bundle | **Experimental.** Deoptimises if `pred` is false. It may also deoptimise spuriously, because it is defined as branching on `pred AND undef`. May carry `!make.implicit`. Cannot be invoked. Being reformulated in terms of `widenable.condition`. |
| `llvm.experimental.widenable.condition` | `() -> i1` | **Experimental.** Returns true or false; the program must be correct either way. Each call yields one fixed value (unlike `undef`). Default lowering is `true`. A guard `br (cond AND wc)` may be widened to `br (cond AND (other AND wc))`. Cannot be invoked. |
| `llvm.allow.ubsan.check` | `(i8 immarg kind) -> i1` | True if compiler options enable the UBSan check of this kind in this block. The program must be correct either way. |
| `llvm.allow.runtime.check` | `(metadata kind) -> i1` | General form of `allow.ubsan.check`. `kind` is a string naming the check. |

`llvm.experimental.deoptimize` rules (**Smaugian note:** all are verifier
checks):

- It must not be called with `invoke`.
- The call must come immediately before a `ret`.
- The `ret` must return the call's value, or be `ret void`.
- So the call's return type equals the enclosing function's return type.
- All declarations of it must use the same calling convention.
- The inliner merges deopt continuations and rewrites inlined calls to
  return from the caller's frame.

### Pointers and addresses

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.ptrmask` | `(ptrty p, intty mask) -> ptrty`, `speculatable memory(none)` | Clears pointer bits using `mask` without `ptrtoint`/`inttoptr`. Defined as: `i = ptrtoint p` (to index width), `m = i & mask`, result `= gep i8, p, (m - i)`. Bits above the index width are untouched. Result is based on the same object as `p`. Captures `p` only through the result. Works on vectors of pointers too. `mask` width must equal the index width. |
| `llvm.threadlocal.address` | `(ptr g) -> ptr`, `nounwind willreturn memory(none)` | Address of thread-local global (or alias) `g` in the calling thread. The operand must be a thread-local global value. |
| `llvm.vscale.<iN>` | `() -> iN` | Returns `vscale`: a positive power of two, constant for the whole run, unknown at compile time. Poison if it does not fit in `iN`. |
| `llvm.protected.field.ptr` | `(ptr p, i64 disc, i1 use_hw_encoding) -> ptr` | Returns a pointer for storing a protected pointer at `p`. Stores through it blend the value with `disc`; loads undo the blend. With `use_hw_encoding = 1`, the value is signed and authenticated (pointer authentication or emulation). If the returned pointer escapes, blending is disabled via the deactivation-symbol operand bundle. Used for structure protection. |

**Not documented:** for `llvm.protected.field.ptr`, `use_hw_encoding = 1` is
only supported on AArch64, and `use_hw_encoding = 0` is not supported at
all. The weak target-independent blend is therefore described but not
usable.

### Profiling and linking

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.pseudoprobe` | `(i64 guid, i64 index, i32 attributes, i64 factor)`, `nounwind willreturn memory(inaccessiblemem: readwrite)` | Marks an original basic block for sample-based PGO. No machine code; lowers to a label recorded in `.pseudo_probe`. All four operands must be constant integers. |
| `llvm.reloc.none` | `(metadata !"symbol")` | Emits a no-op relocation against the named symbol, pulling its definition into the link. Emits no code or data. |

`llvm.pseudoprobe` operands:

- `guid`: GUID of the function the probe was made for (after inlining it may
  not be the containing function). Indexes `!llvm.pseudo_probe_desc`.
- `index`: unique probe index within that function.
- `attributes`: at most 3 bits. `0x1` reserved, `0x2` sentinel, `0x4`
  discriminator. LLVM emits 0 here; the other bits are added only in the
  object file.
- `factor`: distribution factor as a fraction of `UINT64_MAX`. When a block
  is duplicated, copies should split the factor so they sum to the original.

Passes should treat probes as having memory side effects by default, but may
update or drop them rather than give up a useful optimisation. Cost models
should ignore them. Call-site probes are encoded in DWARF discriminators, not
with this intrinsic.

---

## Stack maps

**Not documented:** the source only says these are experimental intrinsics
for runtime patching in JITs and refers to the separate document "Stack maps
and patch points in LLVM". No intrinsics are listed in this range. That
document is needed for `llvm.experimental.stackmap` and
`llvm.experimental.patchpoint.*`.

## Element-wise unordered-atomic memory intrinsics

These copy or set memory as a series of `unordered` atomic accesses, each a
whole multiple of `element_size` bytes and aligned to `element_size`.

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.memcpy.element.unordered.atomic.<pd>.<ps>.<iN>` | `(ptr dest, ptr src, iN len, i32 element_size)` | Copies `len` bytes. Regions must not overlap. Lowers to `__llvm_memcpy_element_unordered_atomic_<size>` or inline code. |
| `llvm.memmove.element.unordered.atomic.<pd>.<ps>.<iN>` | `(ptr dest, ptr src, iN len, i32 element_size)` | As above, but regions may overlap. Lowers to `__llvm_memmove_element_unordered_atomic_<size>`. |
| `llvm.memset.element.unordered.atomic.<pd>.<iN>` | `(ptr dest, i8 value, iN len, i32 element_size)` | Sets `len` bytes to `value`. Lowers to `__llvm_memset_element_unordered_atomic_<size>`. |

Shared rules:

- `len` must be a positive multiple of `element_size`, otherwise behaviour
  is undefined.
- `element_size` is a constant power of two, no larger than the target's
  atomic size limit.
- Every pointer operand must carry an `align` attribute that is a power of
  two and at least `element_size`.
- The order of element accesses is unspecified. Each destination element is
  written exactly once. Source elements may be read many times.
- Concurrent unordered-atomic accesses to the same memory are well defined.
  No ordering beyond `unordered` is given.

**Smaugian note:** these are verifier checks: constant power-of-two
`element_size`, and `align` present and `>= element_size` on each pointer.

## Objective-C ARC runtime

Each intrinsic lowers to a call to the runtime function with the same name
and an `objc_` prefix. LLVM knows their semantics and optimises them, but the
semantics themselves are defined in the separate ARC document.

| Intrinsic | Signature | Lowers to |
| --- | --- | --- |
| `llvm.objc.autorelease` | `(ptr) -> ptr` | `objc_autorelease` |
| `llvm.objc.autoreleasePoolPop` | `(ptr)` | `objc_autoreleasePoolPop` |
| `llvm.objc.autoreleasePoolPush` | `() -> ptr` | `objc_autoreleasePoolPush` |
| `llvm.objc.autoreleaseReturnValue` | `(ptr) -> ptr` | `objc_autoreleaseReturnValue` |
| `llvm.objc.copyWeak` | `(ptr, ptr)` | `objc_copyWeak` |
| `llvm.objc.destroyWeak` | `(ptr)` | `objc_destroyWeak` |
| `llvm.objc.initWeak` | `(ptr, ptr) -> ptr` | `objc_initWeak` |
| `llvm.objc.loadWeak` | `(ptr) -> ptr` | `objc_loadWeak` |
| `llvm.objc.loadWeakRetained` | `(ptr) -> ptr` | `objc_loadWeakRetained` |
| `llvm.objc.moveWeak` | `(ptr, ptr)` | `objc_moveWeak` |
| `llvm.objc.release` | `(ptr)` | `objc_release` |
| `llvm.objc.retain` | `(ptr) -> ptr` | `objc_retain` |
| `llvm.objc.retainAutorelease` | `(ptr) -> ptr` | `objc_retainAutorelease` |
| `llvm.objc.retainAutoreleaseReturnValue` | `(ptr) -> ptr` | `objc_retainAutoreleaseReturnValue` |
| `llvm.objc.retainAutoreleasedReturnValue` | `(ptr) -> ptr` | `objc_retainAutoreleasedReturnValue` |
| `llvm.objc.retainBlock` | `(ptr) -> ptr` | `objc_retainBlock` |
| `llvm.objc.storeStrong` | `(ptr, ptr)` | `objc_storeStrong` |
| `llvm.objc.storeWeak` | `(ptr, ptr) -> ptr` | `objc_storeWeak` |

**Not documented:** the meaning of each runtime call and the optimisations
LLVM may apply. These are defined outside the Language Reference.

## Preserving debug information

These keep source-level field and index information that a plain
`getelementptr` would lose (IR types differ from debug types, and unions
become structs). Each call carries `!llvm.preserve.access.index` metadata
naming the debug-info type (a `DICompositeType`, or `DIDerivedType` for the
array form).

| Intrinsic | Operands | Meaning |
| --- | --- | --- |
| `llvm.preserve.array.access.index.*` | `(ptr base, i32 dim, i32 index) -> ptr` | Same result as `getelementptr` on `base` with `dim` zero indices followed by `index`. `dim = 0` means `base` is a plain pointer. `base` must have an `elementtype` attribute at the call site. |
| `llvm.preserve.union.access.index.*` | `(ptr base, i32 di_index) -> ptr` | Returns `base` unchanged. Records the debug-info field index. Result type equals `base` type. |
| `llvm.preserve.struct.access.index.*` | `(ptr base, i32 gep_index, i32 di_index) -> ptr` | Same result as `getelementptr` on `base` with indices `{0, gep_index}`. `di_index` is the debug-info member index. `base` must have an `elementtype` attribute at the call site. |

**Not documented:** the overload suffixes in the source examples
(`p0s_union.anons`, `p0a10s_union.anons`, `p0i8.p0s_struct.anon.0s`) use the
old typed-pointer mangling. The suffix scheme with opaque pointers is not
stated in this range.

**Smaugian note:** the verifier should require the `elementtype` attribute on
`base` for the array and struct forms.

---

## Intrinsic count

166 intrinsics are listed in this chapter:

| Group | Count |
| --- | --- |
| Vector predication | 30 |
| Masked load/store, gather/scatter, expand/compress | 6 |
| Masked arithmetic | 4 |
| Speculative loads | 2 |
| Memory use markers | 5 |
| Constrained basic (including `fcmps`) | 15 |
| Constrained libm | 34 |
| `noalias.scope.decl` | 1 |
| FP environment | 8 |
| FP test | 1 |
| General (annotations through `reloc.none`) | 33 |
| Element-wise atomic | 3 |
| Objective-C ARC | 18 |
| Debug-info preserving, `protected.field.ptr`, `cond.loop`, `looptrap` | 6 |
