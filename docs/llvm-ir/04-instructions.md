# Instructions

Source: LLVM Language Reference, sections "Instruction Reference" to "Debug Records".

This chapter describes every LLVM IR instruction. For each one it gives the
exact text syntax, the type rules a verifier must check, and the meaning,
including exactly when the result is poison or the behaviour is undefined.

Some words used throughout:

- **Poison**: a special value that means "this result is wrong". Using poison
  in most operations gives poison again. Branching on poison is undefined
  behaviour. Poison and `undef` are described in the types and constants
  chapter.
- **Undefined behaviour (UB)**: the program has no meaning at all. The
  optimiser may assume UB never happens.
- **First-class type**: a type a single instruction can produce as a value
  (integers, floats, pointers, vectors, structs, arrays, and so on, but not
  `void`, `label`, function types or metadata).
- **Lane-wise** (or element-wise): for a vector, the operation is done on each
  element separately, and poison in one result element does not affect others
  unless stated.
- **Terminator**: the last instruction of a basic block. It says which block
  runs next.
- **Fast-math flags**: optional keywords (`nnan`, `ninf`, `nsz`, `arcp`,
  `contract`, `afn`, `reassoc`, `fast`) that let the optimiser assume things
  about floating-point values. They are defined in the module structure
  chapter. In syntax lines below they appear as `[fast-math flags]*`.
- **Atomic orderings**: `unordered`, `monotonic`, `acquire`, `release`,
  `acq_rel`, `seq_cst`. They are defined in the memory model section of the
  module structure chapter.
- **syncscope**: `syncscope("<target-scope>")` names the set of threads an
  atomic operation synchronises with. Without it, the scope is the whole
  system. `"singlethread"` means only the current thread (useful for signal
  handlers). Other names such as `"agent"` are target-specific.

## Summary table

| Instruction | Category | Meaning |
| --- | --- | --- |
| `ret` | Terminator | Return from the function, optionally with a value. |
| `br` | Terminator | Jump unconditionally, or to one of two blocks on an `i1`. |
| `switch` | Terminator | Jump to the block matching an integer, or to a default. |
| `indirectbr` | Terminator | Jump to a block whose address is in a pointer. |
| `invoke` | Terminator | Call a function; continue normally or at an unwind block. |
| `callbr` | Terminator | Call inline asm "goto" or certain intrinsics that may jump to listed labels. |
| `resume` | Terminator | Continue propagating an exception caught by `landingpad`. |
| `catchswitch` | Terminator (and pad) | Choose between catch handlers (funclet EH). |
| `catchret` | Terminator | Leave a `catchpad` and continue normally. |
| `cleanupret` | Terminator | Leave a `cleanuppad` and keep unwinding. |
| `unreachable` | Terminator | Marks code that can never execute. |
| `fneg` | Unary | Flip the sign bit of a float. |
| `add` | Binary | Integer addition. |
| `fadd` | Binary | Floating-point addition. |
| `sub` | Binary | Integer subtraction. |
| `fsub` | Binary | Floating-point subtraction. |
| `mul` | Binary | Integer multiplication. |
| `fmul` | Binary | Floating-point multiplication. |
| `udiv` | Binary | Unsigned integer division. |
| `sdiv` | Binary | Signed integer division (rounds toward zero). |
| `fdiv` | Binary | Floating-point division. |
| `urem` | Binary | Unsigned integer remainder. |
| `srem` | Binary | Signed integer remainder (sign of dividend). |
| `frem` | Binary | Floating-point remainder (like C `fmod`). |
| `shl` | Bitwise | Shift left. |
| `lshr` | Bitwise | Logical shift right (zero fill). |
| `ashr` | Bitwise | Arithmetic shift right (sign fill). |
| `and` | Bitwise | Bitwise AND. |
| `or` | Bitwise | Bitwise inclusive OR. |
| `xor` | Bitwise | Bitwise exclusive OR. |
| `bitextract` | Byte | Read a bit range out of a byte-type value. |
| `bitinsert` | Byte | Write a bit range into a byte-type value. |
| `extractelement` | Vector | Read one vector element. |
| `insertelement` | Vector | Replace one vector element. |
| `shufflevector` | Vector | Build a vector by picking elements from two vectors. |
| `extractvalue` | Aggregate | Read a field of a struct or array value. |
| `insertvalue` | Aggregate | Replace a field of a struct or array value. |
| `alloca` | Memory | Allocate stack memory in the current frame. |
| `load` | Memory | Read from memory. |
| `store` | Memory | Write to memory. |
| `fence` | Memory | Add ordering (happens-before) between memory operations. |
| `cmpxchg` | Memory | Atomic compare and exchange. |
| `atomicrmw` | Memory | Atomic read-modify-write. |
| `getelementptr` | Memory (addressing) | Compute an address inside an object; no memory access. |
| `trunc` | Conversion | Drop high bits of an integer. |
| `zext` | Conversion | Widen an integer with zero bits. |
| `sext` | Conversion | Widen an integer by copying the sign bit. |
| `fptrunc` | Conversion | Convert float to a smaller float type. |
| `fpext` | Conversion | Convert float to a larger float type. |
| `fptoui` | Conversion | Float to unsigned integer (toward zero). |
| `fptosi` | Conversion | Float to signed integer (toward zero). |
| `uitofp` | Conversion | Unsigned integer to float. |
| `sitofp` | Conversion | Signed integer to float. |
| `ptrtoint` | Conversion | Pointer to integer (captures address and provenance). |
| `ptrtoaddr` | Conversion | Pointer to its address bits (no provenance capture). |
| `inttoptr` | Conversion | Integer to pointer. |
| `bitcast` | Conversion | Reinterpret bits as another type of the same size. |
| `addrspacecast` | Conversion | Convert a pointer between address spaces. |
| `icmp` | Other | Integer or pointer comparison giving `i1`. |
| `fcmp` | Other | Floating-point comparison giving `i1`. |
| `phi` | Other | SSA merge: value depends on which predecessor ran. |
| `select` | Other | Choose one of two values by a condition, without branching. |
| `freeze` | Other | Turn `undef`/poison into an arbitrary fixed value. |
| `call` | Other | Call a function. |
| `va_arg` | Other | Read the next variadic argument from a `va_list`. |
| `landingpad` | Other (EH) | Start of an Itanium-style exception landing pad. |
| `catchpad` | Other (EH) | Start of a funclet catch handler. |
| `cleanuppad` | Other (EH) | Start of a funclet cleanup block. |

Debug records (`#dbg_value` and friends) are not instructions. They are
covered at the end of the chapter.

## Terminator instructions

Every basic block ends with exactly one terminator. Terminators produce
control flow, not values, and their type is `void`. The exceptions are
`invoke` and `callbr`, which produce the call result, and `catchswitch`, which
produces a `token`.

### ret

Syntax:

```
ret <type> <value>
ret void
```

Type rules:

- The value must be of a first-class type.
- If the function returns non-`void`, `ret` must have a value and the value's
  type must equal the function's return type.
- If the function returns `void`, `ret` must have no value (`ret void`).

Semantics: control returns to the caller. After a `call`, execution continues
at the next instruction. After an `invoke`, execution continues at the start
of the invoke's normal destination. The returned value becomes the result of
the `call` or `invoke`.

Example:

```
ret { i32, i8 } { i32 4, i8 2 }
```

### br

Syntax:

```
br i1 <cond>, label <iftrue>, label <iffalse>
br label <dest>
```

Type rules: the condition must be `i1` (a scalar, not a vector). Destinations
must be labels (basic blocks) in the same function.

Semantics: the unconditional form jumps to `dest`. The conditional form jumps
to `iftrue` if `cond` is true, otherwise to `iffalse`. If `cond` is `undef` or
poison, the behaviour is undefined.

Example:

```
%cond = icmp eq i32 %a, %b
br i1 %cond, label %IfEqual, label %IfUnequal
```

### switch

Syntax:

```
switch <intty> <value>, label <defaultdest> [ <intty> <val>, label <dest> ... ]
```

Type rules:

- `value` must be an integer.
- Each case value must be an integer constant of the same type as `value`.
- No case value may appear twice.
- The case list may be empty (`[ ]`).

Semantics: if `value` equals a case constant, jump to its destination;
otherwise jump to `defaultdest`. If `value` is `undef` or poison, the
behaviour is undefined. A code generator may lower it as a chain of branches
or a jump table.

Example:

```
switch i32 %val, label %otherwise [ i32 0, label %onzero
                                    i32 1, label %onone ]
```

### indirectbr

Syntax:

```
indirectbr ptr <address>, [ label <dest1>, label <dest2>, ... ]
```

Type rules: `address` is a pointer. The list holds labels in the current
function. A block may appear more than once (harmless).

Semantics: jump to the block whose address is in `address`. The address must
come from a `blockaddress` constant. The destination list must contain every
block the address could point to; it exists so that analyses know the full
control-flow graph. Undefined behaviour if:

- the actual target is not in the list (this includes blocks in other
  functions);
- `address` is `undef` or poison.

Example:

```
indirectbr ptr %Addr, [ label %bb1, label %bb2, label %bb3 ]
```

### invoke

Syntax:

```
<result> = invoke [cconv] [ret attrs] [addrspace(<num>)] <ty>|<fnty> <fnptrval>(<function args>) [fn attrs]
              [operand bundles] to label <normal label> unwind label <exception label>
```

Parts:

- `cconv`: calling convention. Default is the C convention.
- `ret attrs`: only `zeroext`, `signext`, `noext` and `inreg` are allowed.
- `addrspace(<num>)`: address space of the callee. Default is the program
  address space from the data layout.
- `ty`: the return type (also the instruction's type). `void` if no value.
- `fnty`: the full function type. It is only needed when the callee is
  variadic; otherwise `ty` alone is enough.
- `fnptrval`: the callee, either a function or any pointer to a function.
- Arguments: all of first-class type, matching the signature's parameter
  types. Extra arguments are allowed only for a variadic signature.

Type rules:

- The `unwind` block must be a landing pad: its first non-phi instruction must
  be a `landingpad` (or, with funclet EH, an EH pad such as `catchswitch` or
  `cleanuppad`; see the EH documentation).

Semantics: behaves like `call`. If the callee returns with `ret`, control goes
to `normal label`. If the callee (or something it calls) unwinds via `resume`
or another exception mechanism, control goes to the dynamically nearest
`exception label`. For SSA purposes, the result is defined on the edge from
the current block to the normal label, so it may only be used where that edge
dominates. If the callee unwinds, there is no result value.

**Draconian note:** the dominance check for an `invoke` result must treat the
definition as living on the normal edge, not in the invoke's own block. A use
in the unwind block is invalid.

Example:

```
%retval = invoke coldcc i32 %Testfnptr(i32 15) to label %Continue
            unwind label %TestCleanup
```

### callbr

Syntax:

```
<result> = callbr [cconv] [ret attrs] [addrspace(<num>)] <ty>|<fnty> <fnptrval>(<function args>) [fn attrs]
              [operand bundles] to label <fallthrough label> [indirect labels]
```

The parts are the same as for `invoke`. `indirect labels` is a bracketed,
comma-separated list of `label %x` entries (it may be empty).

Type rules: the verifier must reject `callbr` unless the callee is either:

- inline assembly (the GCC "asm goto" feature), or
- one of a selected set of intrinsics.

**Not documented:** the reference does not list which intrinsics may be used
with `callbr`. Its only example is `@llvm.amdgcn.kill`.

Semantics: like `call`, but after the call control can go to the fallthrough
label (asm fell off the end, or the intrinsic returned) or to one of the
indirect labels. Inline asm label constraints (`!i`) refer to the indirect
labels in order. The result value is available in the fallthrough block and
in every indirect block.

Notes:

- To support outputs on indirect edges, the compiler may split critical edges.
  So the address of an indirect label seen by this `callbr` may differ from a
  `blockaddress` of the same block. The asm may only jump to addresses given
  in this instruction's indirect label list.
- On targets with branch target enforcement (such as AArch64 `bti`), the
  called code must not reach the indirect labels with an indirect branch. So
  the compiler need not place a `bti` at those labels.

Example:

```
%r = callbr i32 asm "", "=r,r,!i"(i32 %x)
        to label %fallthrough [label %indirect]
```

### resume

Syntax:

```
resume <type> <value>
```

Type rules: the operand's type must equal the result type of the
`landingpad` instructions in the same function.

Semantics: re-throws an in-flight exception whose unwinding was stopped by a
`landingpad`. It has no successors.

Example:

```
resume { ptr, i32 } %exn
```

### catchswitch

Syntax:

```
<resultval> = catchswitch within <parent> [ label <handler1>, label <handler2>, ... ] unwind to caller
<resultval> = catchswitch within <parent> [ label <handler1>, label <handler2>, ... ] unwind label <default>
```

Type rules:

- The result has type `token`.
- `parent` is the token of the enclosing funclet pad, or the constant `none`
  if not inside a funclet.
- The handler list must be non-empty. Each handler block must begin with a
  `catchpad`.
- The optional unwind block must begin with a `cleanuppad` or `catchswitch`,
  and must be a legal target given the parent links (rules are in the
  exception handling document).
- `catchswitch` is both a terminator and a pad. It must be the first non-phi
  instruction and also the last instruction, so it is the only non-phi
  instruction in its block.

Semantics: the personality routine transfers control to one of the handlers
if one is suitable, otherwise unwinding continues to the unwind label or to
the caller.

Example:

```
%cs1 = catchswitch within none [label %handler0, label %handler1] unwind to caller
```

### catchret

Syntax:

```
catchret from <token> to label <normal>
```

Type rules: `token` must be the result of a `catchpad`. There is one
successor.

Semantics: ends the in-flight exception that was caught by the `catchpad`.
The personality function may run code (for example, to destroy the exception
object). Control then goes to `normal`. Undefined behaviour if the `catchpad`
is not the most recently entered funclet pad that has not yet been exited.

Example:

```
catchret from %catch to label %continue
```

### cleanupret

Syntax:

```
cleanupret from <value> unwind label <continue>
cleanupret from <value> unwind to caller
```

Type rules:

- `value` must be the result of a `cleanuppad`.
- The optional `continue` block must begin with a `cleanuppad` or
  `catchswitch`, and must be a legal unwind target given the parent links.

Semantics: tells the personality function that the cleanup has finished, then
continues unwinding to `continue` or out of the function. Undefined behaviour
if the `cleanuppad` is not the most recently entered, not-yet-exited funclet
pad.

Example:

```
cleanupret from %cleanup unwind label %continue
```

### unreachable

Syntax:

```
unreachable
```

Semantics: tells the optimiser that this point can never be reached (for
example, after a call to a function that never returns). The reference says
only that it has "no defined semantics".

**Not documented:** this section never says in so many words that executing
`unreachable` is undefined behaviour. Treating it as UB is the only reading
consistent with "no defined semantics".

Example:

```
call void @abort()
unreachable
```

## Unary operations

### fneg

Syntax:

```
<result> = fneg [fast-math flags]* <ty> <op1>
```

Type rules: `ty` is a floating-point type or a vector of floating-point
type. The result has the same type.

Semantics: returns a copy of the operand with the sign bit flipped. Nothing
else changes. For a NaN, the quiet/signalling bit and the payload are kept
exactly. Fast-math flags are allowed.

Example:

```
%r = fneg float %val
```

## Binary operations

All binary operations take two operands of the same type and give a result of
that type. Vectors are handled lane-wise.

Integer operations (`add`, `sub`, `mul`, `udiv`, `sdiv`, `urem`, `srem`)
need an integer or vector-of-integer type. Floating-point operations (`fadd`,
`fsub`, `fmul`, `fdiv`, `frem`) need a floating-point or vector-of-float type,
accept fast-math flags, and are assumed to run in the default floating-point
environment (default rounding, no exceptions observed).

### add

Syntax:

```
<result> = add [nuw] [nsw] <ty> <op1>, <op2>
```

Semantics: integer sum, wrapping modulo 2^n where n is the bit width. Because
integers are two's complement, it works for signed and unsigned values.

Poison:

- `nuw` (no unsigned wrap): poison if the unsigned sum overflows.
- `nsw` (no signed wrap): poison if the signed sum overflows.

Example:

```
%r = add nsw i32 4, %var
```

### fadd

Syntax:

```
<result> = fadd [fast-math flags]* <ty> <op1>, <op2>
```

Semantics: floating-point sum.

Example:

```
%r = fadd float 4.0, %var
```

### sub

Syntax:

```
<result> = sub [nuw] [nsw] <ty> <op1>, <op2>
```

Semantics: integer difference, wrapping modulo 2^n. There is no `neg`
instruction; `sub 0, %x` is used instead.

Poison: `nuw` gives poison on unsigned overflow (that is, when `op2 > op1`
as unsigned); `nsw` gives poison on signed overflow.

Example:

```
%neg = sub i32 0, %val
```

### fsub

Syntax:

```
<result> = fsub [fast-math flags]* <ty> <op1>, <op2>
```

Semantics: floating-point difference.

Example:

```
%r = fsub float 4.0, %var
```

### mul

Syntax:

```
<result> = mul [nuw] [nsw] <ty> <op1>, <op2>
```

Semantics: integer product, keeping the low n bits. Correct for both signed
and unsigned values. To get a full-width product (for example `i32 * i32 ->
i64`), extend the operands first.

Poison: `nuw` on unsigned overflow; `nsw` on signed overflow.

Example:

```
%r = mul i32 4, %var
```

### fmul

Syntax:

```
<result> = fmul [fast-math flags]* <ty> <op1>, <op2>
```

Semantics: floating-point product.

Example:

```
%r = fmul float 4.0, %var
```

### udiv

Syntax:

```
<result> = udiv [exact] <ty> <op1>, <op2>
```

Semantics: unsigned quotient.

- Undefined behaviour if the divisor is zero. For vectors, UB if any divisor
  element is zero.
- `exact`: poison if `op1` is not a multiple of `op2`.

**Draconian note:** division by zero is UB, not poison. So `udiv`, `sdiv`,
`urem` and `srem` cannot be speculated (hoisted past a check) unless the
divisor is known non-zero (and, for signed ops, the overflow case is ruled
out).

Example:

```
%r = udiv exact i32 %x, 4
```

### sdiv

Syntax:

```
<result> = sdiv [exact] <ty> <op1>, <op2>
```

Semantics: signed quotient, rounded toward zero.

- UB if the divisor is zero (any lane, for vectors).
- UB on overflow: the minimum signed value divided by -1 (for example
  `-2147483648 / -1` in `i32`).
- `exact`: poison if the division would need rounding (remainder not zero).

Example:

```
%r = sdiv i32 %x, %y
```

### fdiv

Syntax:

```
<result> = fdiv [fast-math flags]* <ty> <op1>, <op2>
```

Semantics: floating-point quotient.

Example:

```
%r = fdiv float 4.0, %var
```

### urem

Syntax:

```
<result> = urem <ty> <op1>, <op2>
```

Semantics: unsigned remainder. UB if the divisor is zero (any lane).

Example:

```
%r = urem i32 %x, 10
```

### srem

Syntax:

```
<result> = srem <ty> <op1>, <op2>
```

Semantics: signed remainder. The result is zero or has the sign of the
dividend (`op1`). This is a remainder, not a modulo (a modulo would take the
sign of the divisor).

- UB if the divisor is zero (any lane).
- UB for the minimum signed value with divisor -1. The true remainder is 0,
  but this rule lets targets use a combined divide-and-remainder instruction.

Example:

```
%r = srem i32 %x, %y
```

### frem

Syntax:

```
<result> = frem [fast-math flags]* <ty> <op1>, <op2>
```

Semantics: floating-point remainder. It gives the same result as C `fmod`,
but never sets `errno`. The result has the sign of the dividend.

**Draconian note:** on some targets `frem` is lowered to a call to `fmod`, so
programs using it may need to link the maths library.

Example:

```
%r = frem float 4.0, %var
```

## Bitwise binary operations

Both operands must be the same integer or vector-of-integer type. The result
has the same type.

For shifts, `op2` is treated as unsigned. If `op2` is greater than or equal to
the bit width of `op1` (known statically or only at run time), the result is
poison. For vectors, each lane of `op1` is shifted by the matching lane of
`op2`.

### shl

Syntax:

```
<result> = shl [nuw] [nsw] <ty> <op1>, <op2>
```

Semantics: `op1 * 2^op2 mod 2^n`.

Poison:

- shift amount `>=` bit width;
- `nuw`: any non-zero bit is shifted out;
- `nsw`: any shifted-out bit differs from the result's sign bit.

Example:

```
%r = shl i32 1, 10      ; 1024
```

### lshr

Syntax:

```
<result> = lshr [exact] <ty> <op1>, <op2>
```

Semantics: logical shift right. High bits are filled with zeros.

Poison: shift amount `>=` bit width; with `exact`, if any shifted-out bit is
non-zero.

Example:

```
%r = lshr i8 -2, 1      ; 0x7F
```

### ashr

Syntax:

```
<result> = ashr [exact] <ty> <op1>, <op2>
```

Semantics: arithmetic shift right. High bits are filled with the sign bit of
`op1`.

Poison: shift amount `>=` bit width; with `exact`, if any shifted-out bit is
non-zero.

Example:

```
%r = ashr i8 -2, 1      ; -1
```

### and

Syntax:

```
<result> = and <ty> <op1>, <op2>
```

Semantics: bitwise AND. Each result bit is 1 only if both input bits are 1.

Example:

```
%r = and i32 15, 40     ; 8
```

### or

Syntax:

```
<result> = or [disjoint] <ty> <op1>, <op2>
```

Semantics: bitwise inclusive OR. Each result bit is 1 if either input bit is
1.

Poison: `disjoint` says no bit position is 1 in both inputs. Then the OR is
the same as an `add` (no carries). If both inputs have a 1 in the same
position, the result is poison. For vectors, only the lane containing that
bit is poison.

Example:

```
%r = or disjoint i32 %hi, %lo
```

### xor

Syntax:

```
<result> = xor <ty> <op1>, <op2>
```

Semantics: bitwise exclusive OR. Each result bit is 1 if the input bits
differ. `xor %x, -1` is the bitwise NOT (C `~`).

Example:

```
%not = xor i32 %V, -1
```

## Byte operations

These instructions work on values of the byte type (`b8`, `b32`, `b64` and
so on). The byte type is described in the types chapter. Bit 0 is the least
significant bit.

### bitextract

Syntax:

```
<result> = bitextract <ty>, <bty> <source>, i32 <offset>
```

Type rules:

- `ty` (the result type) must be an integer, floating-point, pointer or byte
  type. Vector result types are not supported yet.
- `source` must be of a byte type.
- `offset` must be `i32`.

Semantics: takes bits `[offset, offset + bitwidth(ty))` of `source` and
reinterprets them as `ty`, as if by `bitcast`. Poison if
`offset + bitwidth(ty) > bitwidth(source)`.

**Not documented:** what happens when `offset` itself is poison, and what
"bit width" means for a pointer result type (presumably the pointer size from
the data layout).

Example:

```
%top = bitextract i8, b32 %src, i32 24   ; bits 24..31
```

### bitinsert

Syntax:

```
<result> = bitinsert <bty> <base>, <ty> <val>, i32 <offset>
```

Type rules:

- `base` must be of a byte type; the result has the same byte type.
- `ty` must be an integer, floating-point, pointer or byte type. Vectors are
  not supported yet.
- `val` has type `ty`. `offset` is `i32`.

Semantics: returns `base` with bits `[offset, offset + bitwidth(ty))`
replaced by the bits of `val` (reinterpreted as if by `bitcast`). Poison if
`offset + bitwidth(ty) > bitwidth(base)`.

Example:

```
%r = bitinsert b64 %x, i16 %y, i32 32    ; overwrite bits 32..47
```

## Vector operations

### extractelement

Syntax:

```
<result> = extractelement <n x <ty>> <val>, <ty2> <idx>
<result> = extractelement <vscale x n x <ty>> <val>, <ty2> <idx>
```

Type rules: `val` is a fixed or scalable vector. `idx` may be any integer
type and need not be constant. The result type is the element type.

Semantics: returns element number `idx` (treated as unsigned). Poison if
`idx` is at or beyond the vector length (for scalable vectors, the run-time
length).

Example:

```
%e = extractelement <4 x i32> %vec, i64 0
```

### insertelement

Syntax:

```
<result> = insertelement <n x <ty>> <val>, <ty> <elt>, <ty2> <idx>
<result> = insertelement <vscale x n x <ty>> <val>, <ty> <elt>, <ty2> <idx>
```

Type rules: `val` is a vector. `elt` has the vector's element type. `idx` is
any integer type. The result has the type of `val`.

Semantics: returns `val` with element `idx` replaced by `elt`. Poison (the
whole result) if `idx` is out of range.

Example:

```
%v2 = insertelement <4 x i32> %vec, i32 1, i64 0
```

### shufflevector

Syntax:

```
<result> = shufflevector <n x <ty>> <v1>, <n x <ty>> <v2>, <m x i32> <mask>
<result> = shufflevector <vscale x n x <ty>> <v1>, <vscale x n x <ty>> <v2>, <vscale x m x i32> <mask>
```

Type rules:

- `v1` and `v2` have the same vector type.
- `mask` is a constant vector of `i32`. Each element is a constant integer
  or `poison` (`undef` is accepted for backward compatibility).
- For scalable vectors, the only legal masks are `zeroinitializer`, `undef`
  and `poison`.
- The result has `m` elements (the mask length) of the input element type.
  Fixed `m` may differ from `n`.

Semantics: number the elements of `v1` then `v2` from 0 to `2n - 1`. Result
element `i` is the input element selected by `mask[i]`. A `poison` or `undef`
mask element gives a poison result element. If the selected input element is
`undef`, the result element is `undef`.

**Not documented:** what happens if a mask index is `>= 2n`. Presumably the
verifier rejects it.

Example:

```
%r = shufflevector <4 x i32> %v1, <4 x i32> %v2,
                   <4 x i32> <i32 0, i32 4, i32 1, i32 5>
```

## Aggregate operations

### extractvalue

Syntax:

```
<result> = extractvalue <aggregate type> <val>, <idx>{, <idx>}*
```

Type rules:

- `val` is a struct or array value.
- Indices are constant integers (written as bare numbers), as in
  `getelementptr` but without the leading pointer index.
- At least one index is required.
- Every index must be in bounds, for arrays as well as structs.
- The result type is the type of the field the indices select.

Semantics: returns that field.

Example:

```
%f = extractvalue {i32, float} %agg, 0
```

### insertvalue

Syntax:

```
<result> = insertvalue <aggregate type> <val>, <ty> <elt>, <idx>{, <idx>}*
```

Type rules: `val` is a struct or array. `elt` is first-class and its type
must equal the type of the field the indices select. Index rules are as for
`extractvalue`. The result has the type of `val`.

Semantics: returns `val` with the selected field replaced by `elt`.

Example:

```
%agg3 = insertvalue {i32, {float}} poison, float %val, 1, 0
```

## Memory access and addressing operations

Memory locations are not in SSA form. Memory is reached only through these
instructions (and calls).

### alloca

Syntax:

```
<result> = alloca [inalloca] <type> [, <ty> <NumElements>] [, align <alignment>] [, addrspace(<num>)]
```

Type rules:

- `type` must be a sized type.
- A struct containing scalable vectors is allowed only if all its fields are
  the same scalable vector type.
- `NumElements` is an integer value; it defaults to 1.
- `align` is at most 2^32.
- The result is a pointer in address space `num` (default 0).

Semantics: reserves `sizeof(type) * NumElements` bytes in the current stack
frame and returns a pointer to it. The memory is uninitialised (loads give an
undefined value) and is freed when the function returns via `ret` or
`resume`.

- A zero-byte allocation is legal; the pointer may not be unique.
- The direction of stack growth is not specified.
- UB if there is not enough stack space.
- UB if `NumElements` is `undef` or poison.
- If the pointer is used by `llvm.lifetime.start`, the object starts out dead.
- An `alloca` outside the data layout's alloca address space only means
  something if the target defines it. If the data layout's alloca address
  space is non-zero, the instruction must name it explicitly.

`align` is optional only in textual IR. In memory it is always present. If
omitted, the target may pick any alignment compatible with the type.

**Draconian note:** the parser must fill in an alignment when `align` is
missing, because the in-memory form always has one.

**Not documented:** what `inalloca` means here; see the `inalloca` parameter
attribute in the module structure chapter.

Example:

```
%ptr = alloca i32, i32 4, align 1024
```

### load

Syntax:

```
<result> = load [volatile] <ty>, ptr <pointer>[, align <alignment>][, !nontemporal !<nontemp_node>][, !invariant.load !<empty_node>][, !invariant.group !<empty_node>][, !nonnull !<empty_node>][, !dereferenceable !<deref_bytes_node>][, !dereferenceable_or_null !<deref_bytes_node>][, !align !<align_node>][, !noundef !<empty_node>]
<result> = load atomic [volatile] [elementwise] <ty>, ptr <pointer> [syncscope("<target-scope>")] <ordering>, align <alignment> [, !invariant.group !<empty_node>]
```

Metadata node shapes:

```
!<nontemp_node> = !{ i32 1 }
!<empty_node> = !{}
!<deref_bytes_node> = !{ i64 <dereferenceable_bytes> }
!<align_node> = !{ i64 <value_alignment> }
```

Type rules:

- `ty` must be a first-class type of known size (no opaque struct inside).
- Atomic loads:
  - `release` and `acq_rel` orderings are not allowed.
  - `align` is required.
  - The type must be an integer, pointer, floating-point or vector type
    whose bit width is a power of two and at least 8.
- `elementwise` (atomic only): the type must be a fixed vector whose total
  bit width is a power of two, and whose element type is legal for a scalar
  atomic load. Each element is loaded atomically on its own.
- `!nonnull` and `!align` are only allowed when loading a pointer type.
- `!align` value must be a power of two.
- Maximum `align` is 2^32.

Semantics:

- Reads the value at `pointer`.
- A scalar load reads no more bytes than needed to hold the type (an `i24`
  reads at most 3 bytes).
- A type whose size is not a whole number of bytes (such as `i20`) is loaded
  as the next byte-sized type (`i24`) and truncated. If any dropped bit is
  non-zero, the result is poison. So it acts like a byte load followed by
  `trunc nuw`.
- For aggregates, padding bytes may be read but are ignored.
- UB if `pointer` is not a well-defined value (for example `undef` or
  poison).
- Loading with a different type from the one stored follows the `bitcast`
  rules.
- `volatile`: the optimiser may not change the number or order of volatile
  operations.

Alignment:

- `align` states the alignment of the address. Overstating it is UB.
  Understating it only costs speed. `align 1` is always safe.
- A large alignment does not mean the bytes up to that alignment can be read
  safely.
- If `align` is omitted (only possible in text), the operation uses the
  target's ABI alignment for the type.
- If an atomic access is less aligned than its size (or element size for
  `elementwise`), it probably needs a lock.

Metadata meaning:

- `!nontemporal`: the value is unlikely to be reused from cache. No defined
  meaning on atomic loads.
- `!invariant.load`, `!invariant.group`, `!dereferenceable`,
  `!dereferenceable_or_null`: see the metadata chapter.
- `!nonnull`: if the loaded pointer is null, the result is poison.
- `!align`: if the loaded pointer is not aligned to this value, the result is
  poison.
- `!noundef`: if the loaded value is not well defined (undef or poison), the
  behaviour is undefined. Combined with `!nonnull` or `!align`, a violation of
  those also becomes UB instead of poison.

Example:

```
%val = load i32, ptr %ptr, align 4
%a = load atomic i32, ptr %p syncscope("singlethread") acquire, align 4
```

### store

Syntax:

```
store [volatile] <ty> <value>, ptr <pointer>[, align <alignment>][, !nontemporal !<nontemp_node>][, !invariant.group !<empty_node>]
store atomic [volatile] [elementwise] <ty> <value>, ptr <pointer> [syncscope("<target-scope>")] <ordering>, align <alignment> [, !invariant.group !<empty_node>]
```

Type rules:

- `value` must be first-class with a known size.
- `pointer` must be a pointer.
- Atomic stores: `acquire` and `acq_rel` orderings are not allowed; `align`
  is required; the type rules are the same as for atomic loads.
- `elementwise`: as for `load`.
- The result type is `void`.

Semantics:

- Writes `value` to `pointer`.
- A scalar store writes no more bytes than needed (an `i24` writes at most 3).
- A non-byte-sized type (such as `i20`) is zero-extended to the next byte
  size (`i24`) and then stored.
- For aggregates, padding bytes become `undef`.
- UB if `pointer` is not a well-defined value.
- `volatile`, `align` and `!nontemporal` mean the same as for `load`.

Example:

```
store i32 3, ptr %ptr, align 4
```

### fence

Syntax:

```
fence [syncscope("<target-scope>")] <ordering>
```

Type rules: the ordering must be `acquire`, `release`, `acq_rel` or
`seq_cst`. (`unordered` and `monotonic` are not allowed.) The type is `void`.

Semantics: creates happens-before edges. A fence A with at least `release`
synchronises with a fence B with at least `acquire` when there is some atomic
object M such that:

- A comes before an atomic operation X in A's thread,
- X modifies M,
- an atomic operation Y reads M and comes before B in B's thread.

Instead of one of the fences, X itself may carry `release` (or Y may carry
`acquire`). A `seq_cst` fence also takes part in the single global order of
`seq_cst` operations, and that order must fit with the total order of each
`monotonic` (or stronger) access. The reference defers the exact rules to the
C++ standard's [atomics.order] section.

Example:

```
fence syncscope("singlethread") seq_cst
```

### cmpxchg

Syntax:

```
cmpxchg [weak] [volatile] ptr <pointer>, <ty> <cmp>, <ty> <new> [syncscope("<target-scope>")] <success ordering> <failure ordering>[, align <alignment>]
```

The result type is `{ ty, i1 }`.

Type rules:

- `cmp` and `new` have the same type: an integer or pointer whose bit width
  is a power of two and at least 8.
- `pointer` is a pointer.
- Both orderings must be at least `monotonic`.
- The failure ordering may not be `release` or `acq_rel`.
- The pointer's alignment must be at least the size of the operand.

Alignment: optional only in text. If omitted, it defaults to the size of the
type. This is different from `load` and `store`, where the default is the ABI
alignment.

**Draconian note:** the parser's default alignment differs between
`cmpxchg`/`atomicrmw` (type size) and `load`/`store` (ABI alignment).

Semantics: atomically reads the value at `pointer` and compares it with
`cmp`. If they are equal, `new` is written. The result holds the original
value and a success flag.

- Strong (default): the flag is 1 exactly when the loaded value equalled
  `cmp`.
- `weak`: may fail spuriously, that is, not write `new` even when the values
  matched.
- A successful `cmpxchg` counts as a read-modify-write for release sequences.
- A failed `cmpxchg` acts like an atomic load with the failure ordering.

**Not documented:** the reference does not say if the failure ordering may be
stronger than the success ordering.

Example:

```
%pair = cmpxchg ptr %ptr, i32 %cmp, i32 %squared acq_rel monotonic
%ok = extractvalue { i32, i1 } %pair, 1
```

### atomicrmw

Syntax:

```
atomicrmw [volatile] [elementwise] <operation> ptr <pointer>, <ty> <value> [syncscope("<target-scope>")] <ordering>[, align <alignment>]
```

The result type is `ty` (the old value).

Type rules:

- `value`'s type must have a bit width that is a power of two and at least 8.
- Integer operations need an integer or fixed vector of integers.
- Floating-point operations need a float or fixed vector of floats.
- `xchg` accepts an integer, float, pointer, or fixed vector of any of these.
- `pointer` is a pointer.
- Alignment default (when omitted in text) is the size of the type, as for
  `cmpxchg`.

**Not documented:** which orderings are legal on `atomicrmw`. The reference
does not restrict them in this section.

Semantics: atomically reads the value at `pointer`, computes a new value,
writes it back, and returns the old value. `elementwise` gives elementwise
atomic semantics (each lane separately).

The operations (`old` is the value in memory, `val` is the operand):

| Operation | Types | New value |
| --- | --- | --- |
| `xchg` | int, float, ptr | `val` |
| `add` | int | `old + val` |
| `sub` | int | `old - val` |
| `and` | int | `old & val` |
| `nand` | int | `~(old & val)` |
| `or` | int | `old \| val` |
| `xor` | int | `old ^ val` |
| `max` | int | signed maximum of `old` and `val` |
| `min` | int | signed minimum |
| `umax` | int | unsigned maximum |
| `umin` | int | unsigned minimum |
| `fadd` | float | `old + val` (floating point) |
| `fsub` | float | `old - val` (floating point) |
| `fmax` | float | `maxnum(old, val)`, as `llvm.maxnum` |
| `fmin` | float | `minnum(old, val)`, as `llvm.minnum` |
| `fmaximum` | float | `maximum(old, val)`, as `llvm.maximum` |
| `fminimum` | float | `minimum(old, val)`, as `llvm.minimum` |
| `fmaximumnum` | float | `maximumnum(old, val)`, as `llvm.maximumnum` |
| `fminimumnum` | float | `minimumnum(old, val)`, as `llvm.minimumnum` |
| `uinc_wrap` | int | `old u>= val ? 0 : old + 1` |
| `udec_wrap` | int | `(old == 0 \|\| old u> val) ? val : old - 1` |
| `usub_cond` | int | `old u>= val ? old - val : old` |
| `usub_sat` | int | `old u>= val ? old - val : 0` |

Example:

```
%old = atomicrmw add ptr %ptr, i32 1 acquire
```

### getelementptr

Syntax:

```
<result> = getelementptr <ty>, ptr <ptrval>{, <ty> <idx>}*
<result> = getelementptr inbounds <ty>, ptr <ptrval>{, <ty> <idx>}*
<result> = getelementptr nusw <ty>, ptr <ptrval>{, <ty> <idx>}*
<result> = getelementptr nuw <ty>, ptr <ptrval>{, <ty> <idx>}*
<result> = getelementptr inrange(S,E) <ty>, ptr <ptrval>{, <ty> <idx>}*
<result> = getelementptr <ty>, <N x ptr> <ptrval>, <vector index type> <idx>
```

The flags `inbounds`, `nusw` and `nuw` may be combined. `inrange` is only
allowed in constant expressions, not in the instruction.

Overview: GEP ("get element pointer") computes the address of a sub-element
of an object. It does arithmetic only and never touches memory.

Type rules:

- The first operand `ty` is the source element type, the base of the
  calculation.
- `ptrval` is a pointer or vector of pointers.
- The first index steps over whole `ty` objects from the pointer. Each later
  index steps into the current type, which must be a struct, array or vector.
  It can never be a pointer (that would need a load).
- Indexing into a struct (packed or not): the index must be an `i32`
  constant. With vector indices, every lane must be the same `i32` constant.
- Indexing over the pointer, an array or a vector: any integer width, not
  necessarily constant. Treated as signed.
- If any operand is a vector, the result is a vector of pointers. All vector
  operands must have the same element count. Scalar operands are broadcast
  to every lane.

Semantics:

1. Each index is turned into an offset in the pointer's index type (from the
   data layout).
   - For a struct index: the field's byte offset, sign-extended or truncated
     to the index type.
   - Otherwise: the index is sign-extended or truncated to the index type,
     then multiplied by the alloc size of the current type (its size rounded
     up to its ABI alignment).
2. The offsets are added to the low bits of the base address (up to the
   index type width) with wrapping two's complement arithmetic. If the
   pointer is wider than the index type, the high bits are unchanged.

The result may point outside the base object. Such a pointer may not
necessarily be used to access memory, even if it happens to point into
allocated storage (see the pointer aliasing rules).

Poison rules. If any rule for a present flag is broken, the result is
poison. For vector GEPs, the rules apply per lane.

- `nusw` (no unsigned-signed wrap):
  - truncating an index to the index type keeps its signed value
    (`trunc nsw`);
  - index times type size does not overflow as signed (`mul nsw`);
  - adding the offsets together (without the base) does not overflow as
    signed (`add nsw`);
  - adding each signed offset to the unsigned current address does not wrap.
- `nuw` (no unsigned wrap):
  - truncating an index keeps its unsigned value (`trunc nuw`);
  - index times type size does not overflow as unsigned (`mul nuw`);
  - adding the offsets together does not overflow as unsigned (`add nuw`);
  - adding each unsigned offset to the unsigned current address does not
    wrap (`add nuw`).
- `inbounds`: all `nusw` rules apply. In addition, if any index is non-zero:
  - the base pointer must be in bounds of the allocated object it is based
    on (inside it, or exactly one past its end). The object may already be
    freed. For a growable object, the relevant size is the largest size it
    could have;
  - after adding each offset, the pointer must still be in bounds of that
    object.
  A GEP whose indices are all zero is always in bounds, even on a pointer
  that is not to any object. As a result, the only pointer in bounds of null
  (in address space 0) is null itself.
- `inrange(S, E)` (constant expressions only): a load or store through any
  pointer derived from the GEP is UB if it touches memory outside
  `[S, E)` relative to the GEP result. Comparing such a pointer, or
  `ptrtoint` on it, gives an undefined result, except that comparisons are
  fine when both pointers are in the closed range `[S, E]`.

**Draconian note:** `inbounds` implies `nusw`. The in-memory form should set
both, and the printer must not print `nusw` when `inbounds` is present.

Example:

```
%struct.ST = type { i32, double, %struct.RT }
%p = getelementptr inbounds %struct.ST, ptr %s, i64 1, i32 2, i32 1, i64 5, i64 13
%vp = getelementptr i8, <4 x ptr> %ptrs, <4 x i64> %offsets   ; yields <4 x ptr>
```

## Conversion operations

Each cast takes one operand and a destination type, written
`<op> <ty> <value> to <ty2>`. For vector casts the element counts of source
and destination must match, and the cast is done lane-wise.

Summary of legal type pairs:

| Cast | Source | Destination | Size rule | Flags |
| --- | --- | --- | --- | --- |
| `trunc` | int (or vector) | int (or vector) | source strictly wider | `nuw`, `nsw` |
| `zext` | int | int | source strictly narrower | `nneg` |
| `sext` | int | int | source strictly narrower | none |
| `fptrunc` | float | float | source strictly larger | fast-math |
| `fpext` | float | float | source strictly smaller | fast-math |
| `fptoui` | float | int | any | none |
| `fptosi` | float | int | any | none |
| `uitofp` | int | float | any | fast-math, `nneg` |
| `sitofp` | int | float | any | fast-math |
| `ptrtoint` | ptr | int | any (truncate or zero-extend) | none |
| `ptrtoaddr` | ptr | int | must equal the index width of the pointer's address space | none |
| `inttoptr` | int | ptr | any (truncate or zero-extend) | none (metadata only) |
| `bitcast` | non-aggregate first-class | non-aggregate first-class | equal bit size; see below | none |
| `addrspacecast` | ptr | ptr in a different address space | any | `nonnull` |

### trunc

Syntax:

```
<result> = trunc [nuw] [nsw] <ty> <value> to <ty2>
```

Type rules: both integer, or both integer vectors with the same element
count. The source must be strictly wider than the destination; equal sizes
are not allowed.

Semantics: drops the high bits.

Poison:

- `nuw`: any dropped bit is non-zero.
- `nsw`: any dropped bit differs from the top bit of the result.

Example:

```
%X = trunc i32 257 to i8      ; 1
```

### zext

Syntax:

```
<result> = zext [nneg] <ty> <value> to <ty2>
```

The reference's syntax line omits `nneg`, but its examples write it right
after `zext`, as above.

Type rules: both integer (or matching integer vectors). Source strictly
narrower than destination.

Semantics: fills the new high bits with zeros. From `i1`, the result is 0 or
1. `nneg` (non-negative) says the operand's sign bit is clear, so an
optimiser may turn this into `sext`. If `nneg` is set and the operand is
negative, the result is poison.

Example:

```
%b = zext nneg i8 -1 to i16   ; poison
```

### sext

Syntax:

```
<result> = sext <ty> <value> to <ty2>
```

Type rules: as for `zext`.

Semantics: fills the new high bits with copies of the sign bit. From `i1`,
the result is 0 or -1.

Example:

```
%Y = sext i1 true to i32      ; -1
```

### fptrunc

Syntax:

```
<result> = fptrunc [fast-math flags]* <ty> <value> to <ty2>
```

Type rules: both floating-point (or matching vectors). The source must be
strictly larger, so it is never a no-op.

Semantics: rounds to the smaller type, in the default floating-point
environment. Values too large become infinity. If a NaN payload is carried
over from the input, its low bits that do not fit are dropped. If that leaves
an all-zero payload, the result cannot be a signalling NaN (that bit pattern
would be infinity), so "unchanged NaN propagation" is not possible in that
case.

Example:

```
%Y = fptrunc double 1.0E+300 to half   ; +infinity
```

### fpext

Syntax:

```
<result> = fpext [fast-math flags]* <ty> <value> to <ty2>
```

Type rules: both floating-point (or matching vectors). Source strictly
smaller. Use `bitcast` for a no-op float reinterpretation.

Semantics: converts to the larger type exactly. If a NaN payload is carried
over, it goes into the high bits of the new payload and the low bits become
zero.

Example:

```
%X = fpext float 3.125 to double
```

### fptoui

Syntax:

```
<result> = fptoui <ty> <value> to <ty2>
```

Type rules: float (or float vector) to integer (or integer vector with the
same element count).

Semantics: rounds toward zero to an unsigned integer. Poison if the rounded
value does not fit in `ty2`. So `-0.999` gives 0, but `-1.0` gives poison.
NaN and infinity do not fit, so they give poison.

Example:

```
%W2 = fptoui double -1.0 to i32   ; poison
```

### fptosi

Syntax:

```
<result> = fptosi <ty> <value> to <ty2>
```

Type rules: as for `fptoui`.

Semantics: rounds toward zero to a signed integer. Poison if it does not fit.
So `-128.9` to `i8` gives -128, but `-129.0` gives poison.

Example:

```
%W1 = fptosi double -128.9 to i8  ; -128
```

### uitofp

Syntax:

```
<result> = uitofp [fast-math flags]* [nneg] <ty> <value> to <ty2>
```

Type rules: integer (or vector) to floating-point (or vector with the same
element count).

Semantics: treats the operand as unsigned and converts it. If the value is
not exactly representable, it is rounded with the default rounding mode.
`nneg`: poison if the operand is negative (sign bit set); lets the optimiser
switch to `sitofp`. With `nsz`, a zero input may produce either +0.0 or -0.0.

**Not documented:** whether fast-math flags and `nneg` may appear in either
order. The syntax line puts fast-math flags first.

Example:

```
%Y = uitofp i8 -1 to double   ; 255.0
```

### sitofp

Syntax:

```
<result> = sitofp [fast-math flags]* <ty> <value> to <ty2>
```

Type rules: as for `uitofp`.

Semantics: treats the operand as signed and converts it, rounding with the
default rounding mode. With `nsz`, a zero input may produce either sign of
zero.

Example:

```
%Y = sitofp i8 -1 to double   ; -1.0
```

### ptrtoint

Syntax:

```
<result> = ptrtoint <ty> <value> to <ty2>
```

Type rules: pointer (or pointer vector) to integer (or integer vector).

Semantics: reads all the bits of the pointer's representation as an integer
(like a `bitcast`), then zero-extends or truncates to `ty2`. If sizes are
equal it is a no-op apart from the type. It always captures both the address
and the provenance of the pointer. (Provenance is the pointer's permission to
access a particular object; see the pointer aliasing rules.)

Example:

```
%Y = ptrtoint ptr %P to i64
```

### ptrtoaddr

Syntax:

```
<result> = ptrtoaddr <ty> <value> to <ty2>
```

Type rules: pointer (or pointer vector) to integer (or integer vector). `ty2`
must be exactly the integer type whose width is the pointer index width of
the source address space.

Semantics: reads only the low "index width" bits of the pointer (the
address) as an integer. Other pointer bits are ignored. It captures the
address but not the provenance.

Example (address space 1 pointers are 64 bits with a 32-bit address,
data layout `p1:64:64:64:32`):

```
%X = ptrtoaddr ptr addrspace(1) %P to i32
```

### inttoptr

Syntax:

```
<result> = inttoptr <ty> <value> to <ty2>[, !dereferenceable !<deref_bytes_node>][, !dereferenceable_or_null !<deref_bytes_node>][, !nofreeobj !<empty_node>]
```

Type rules: integer (or vector) to pointer (or pointer vector).
`!dereferenceable` and `!dereferenceable_or_null` take a node with one `i64`.
`!nofreeobj` takes an empty node.

Semantics: zero-extends or truncates the integer to the pointer size, then
reinterprets it (like a `bitcast`). The result is not guaranteed to be
dereferenceable (for example, for non-integral pointer types).
`!nofreeobj` says the memory it points to will not be freed after this point.

Example:

```
%X = inttoptr i32 255 to ptr
```

### bitcast

Syntax:

```
<result> = bitcast <ty> <value> to <ty2>
```

Type rules:

- Both types must be non-aggregate first-class types (no structs or arrays).
- They must have the same bit size.
- If the source is a pointer (or pointer vector), the destination must be a
  pointer in the same address space, or a byte type (or byte vector) of the
  same size. Other conversions from pointers need `ptrtoint`, and conversions
  between address spaces need `addrspacecast`.
- Vectors may be cast to integers and to other vector types of the same
  total size.

Semantics: no bits change. The result is as if `value` were stored to memory
and loaded back as `ty2`. So vector-to-scalar casts depend on endianness: in
`bitcast <2 x i8> %v to i16`, element 0 becomes the low bits on little-endian
targets and the high bits on big-endian targets.

Extra rules when the source is a byte type:

- To a byte type: the bits are unchanged.
- To a pointer type:
  - poison if any input bit is poison;
  - if all bits come from one pointer in the right order, the result is that
    pointer (with its provenance);
  - otherwise, a pointer with the integer's address and no provenance.
- To an integer or floating-point type:
  - poison if any input bit is poison;
  - otherwise, the value those bits encode, with provenance removed but not
    exposed.
- To a vector type: the bits are split into lane-sized pieces, and each lane
  follows the scalar rules above.

Example:

```
%Z = bitcast <2 x i32> %V to i64   ; layout depends on endianness
%d = bitcast b64 %bi to ptr        ; pointer with no provenance
```

### addrspacecast

Syntax:

```
<result> = addrspacecast [nonnull] <pty> <ptrval> to <pty2>
```

Type rules: a pointer (or pointer vector) cast to a pointer type in a
different address space. Same-address-space casts must use `bitcast`.

Semantics: converts the pointer to the other address space. This may be a
no-op or may change the value, depending on the target. It has no side
effects and does not capture the pointer. If the result can be dereferenced,
it refers to the same memory as the operand.

- Poison if the source is poison.
- If the source is not poison, both address spaces use integral pointers,
  and the result is dereferenceable, then casting back gives the original
  bit pattern.
- Unsupported address space pairs (target-dependent) give poison.
- `nonnull`: poison if `ptrval` is the null value of its address space.

Example:

```
%Y = addrspacecast ptr addrspace(1) %y to ptr addrspace(2)
```

## Other operations

### icmp

Syntax:

```
<result> = icmp [samesign] <cond> <ty> <op1>, <op2>
```

Type rules: both operands have the same type, which is an integer, a
pointer, or a vector of either. The result is `i1`, or `<N x i1>` for
N-element vector operands.

Condition codes:

| Code | Meaning |
| --- | --- |
| `eq` | equal (no sign interpretation) |
| `ne` | not equal (no sign interpretation) |
| `ugt` | unsigned greater than |
| `uge` | unsigned greater or equal |
| `ult` | unsigned less than |
| `ule` | unsigned less or equal |
| `sgt` | signed greater than |
| `sge` | signed greater or equal |
| `slt` | signed less than |
| `sle` | signed less or equal |

Semantics: compares `op1` with `op2`, lane-wise for vectors. Pointers are
compared by their address bits only, exactly like comparing their
`ptrtoaddr` values. Non-address bits and any outside state are ignored.

Poison: with `samesign`, poison if the two operands have different signs
(one has its sign bit set and the other does not).

Example:

```
%r = icmp ule i16 -4, 5       ; false
```

### fcmp

Syntax:

```
<result> = fcmp [fast-math flags]* <cond> <ty> <op1>, <op2>
```

Type rules: both operands are the same floating-point type or vector of
floating-point type. The result is `i1`, or an `i1` vector with the same
element count.

"Ordered" means neither operand is a NaN. "Unordered" means at least one is.
(The reference says "QNAN"; it does not separately discuss signalling NaNs.)

Condition codes:

| Code | True when |
| --- | --- |
| `false` | never |
| `oeq` | ordered and `op1 == op2` |
| `ogt` | ordered and `op1 > op2` |
| `oge` | ordered and `op1 >= op2` |
| `olt` | ordered and `op1 < op2` |
| `ole` | ordered and `op1 <= op2` |
| `one` | ordered and `op1 != op2` |
| `ord` | ordered (no NaN) |
| `ueq` | unordered or `op1 == op2` |
| `ugt` | unordered or `op1 > op2` |
| `uge` | unordered or `op1 >= op2` |
| `ult` | unordered or `op1 < op2` |
| `ule` | unordered or `op1 <= op2` |
| `une` | unordered or `op1 != op2` |
| `uno` | unordered (at least one NaN) |
| `true` | always |

Fast-math flags: any set is legal, but only `nnan`, `ninf` and `reassoc`
change the meaning, because they let the optimiser assume things about the
inputs.

Example:

```
%r = fcmp olt float 4.0, 5.0  ; true
```

### phi

Syntax:

```
<result> = phi [fast-math-flags] <ty> [ <val0>, <label0>], ...
```

Type rules:

- `ty` is first-class. Every incoming value has type `ty`.
- There is one `[value, label]` pair for each predecessor block of the
  current block. The labels must be blocks.
- Phi nodes must come first in their block, before any non-phi instruction.
- Fast-math flags are allowed only when `ty` is a supported floating-point
  type.

Semantics: the phi takes the value paired with the predecessor block that ran
just before this block. For SSA dominance, each incoming value is used on the
edge from its predecessor (after any `invoke` result defined on that edge).

**Draconian note:** for the verifier, an incoming value must dominate the end of
its predecessor block, not the phi itself.

**Not documented:** in this section, how a predecessor that reaches the block
by several edges (for example, a `switch` with two cases to the same block)
must be listed.

Example:

```
Loop:
  %indvar = phi i32 [ 0, %LoopHeader ], [ %nextindvar, %Loop ]
```

### select

Syntax:

```
<result> = select [fast-math flags] selty <cond>, <ty> <val1>, <ty> <val2>
```

`selty` is `i1` or `<N x i1>`.

Type rules:

- `val1` and `val2` have the same first-class type `ty`.
- If `cond` is a vector, both values must be vectors with the same element
  count.
- Fast-math flags are allowed only when `ty` is a supported floating-point
  type.

Semantics:

- Scalar `i1` condition: returns `val1` if true, otherwise `val2`. If the
  values are vectors, the whole vector is chosen.
- Vector condition: chooses lane by lane.
- Poison condition: the result is poison.
- `undef` condition: the result is an `undef` that may be either value at
  each use.
- Poison in the arm that is not chosen does not make the result poison.
- Fast-math flags apply only to the result, not to the arms. So
  `select nnan i1 false, float 0.0, float NaN` is poison.

Example:

```
%X = select i1 true, i8 17, i8 42      ; 17
```

### freeze

Syntax:

```
<result> = freeze <ty> <val>
```

Type rules: one operand; the result has the same type.

**Not documented:** which types are allowed. Examples use integers, vectors,
and byte types; the text mentions pointers and aggregates.

Semantics: if `val` is `undef` or poison, returns some arbitrary but fixed
value of type `ty`. Otherwise returns `val` unchanged. Every use of one
`freeze` result sees the same value; two different `freeze` instructions may
choose differently.

- A frozen `undef` or poison pointer is not dereferenceable.
- Byte-type values are frozen bit by bit.
- Aggregates and vectors are frozen element by element. Padding is not
  frozen (it cannot be seen without going through memory).

Example:

```
%c = freeze i1 %maybe_poison
br i1 %c, label %a, label %b    ; defined, but either branch may be taken
```

### call

Syntax:

```
<result> = [tail | musttail | notail ] call [fast-math flags] [cconv] [ret attrs] [addrspace(<num>)]
           <ty>|<fnty> <fnptrval>(<function args>) [fn attrs] [ operand bundles ]
```

Parts:

- `tail`: a hint that the call may be tail-call optimised. It can be
  ignored.
- `musttail`: the call must be tail-call optimised for the program to be
  correct, even with attributes like `"disable-tail-calls"`.
- `notail`: optimisers must not add `tail` or `musttail`.
- Fast-math flags: only allowed when the call returns a supported
  floating-point type.
- `cconv`: calling convention (default C). It must match the callee's
  convention, or the behaviour is undefined.
- `ret attrs`: only `zeroext`, `signext`, `noext`, `inreg`.
- `addrspace`, `ty`, `fnty`, `fnptrval`, arguments, function attributes and
  operand bundles: as for `invoke`.

Meaning of `tail` and `musttail`: both promise that the callee does not use
anything from the caller's stack frame, which is torn down first. That
includes allocas, `va_arg` state, `byval` arguments, and frame addresses
(from `llvm.frameaddress` with level 0, `llvm.localaddress`, or
`llvm.stacksave` in the caller). One exception: an alloca or `byval`
argument may be passed as a `byval` argument, because it is copied.

`musttail` also guarantees:

- no unbounded stack growth through recursion;
- `inalloca` and `preallocated` arguments are forwarded in place;
- in a function with the `"thunk"` attribute where caller and callee are both
  variadic, unprototyped arguments are forwarded and the callee's return
  value reaches the caller's caller, even with a `void` return type.

Verifier rules for `musttail`:

- The call is immediately followed by `ret`, or by a pointer `bitcast` and
  then `ret`.
- The `ret` returns the call's (possibly bitcast) value, `undef`, or `void`.
- Caller and callee calling conventions match.
- The callee is variadic if and only if the caller is. (A non-variadic
  function may be called through a variadic type if the fixed parts match.)
- The return type must not be turned into an `sret` pointer automatically.
- If the convention is not `tailcc` or `swifttailcc`: all ABI-affecting
  attributes (`sret`, `byval`, `inreg`, `returned`, `inalloca`, ...) must
  match, and the prototypes must match (pointer types may not differ in
  address space).
- If the convention is `tailcc` or `swifttailcc`: only the ABI-affecting
  attributes `sret`, `byval`, `swiftself` and `swiftasync` are allowed, and
  prototypes need not match.

A `tail` call is guaranteed to become a tail call when all of these hold:
caller and callee both use `fastcc` or `tailcc`; the call is in tail position
(followed by `ret` of its value or `ret void`); the `-tailcallopt` option is
on, `llvm::GuaranteedTailCallOpt` is true, or the convention is `tailcc`; and
target-specific limits are met.

Semantics: transfers control to the callee with arguments bound to the given
values. When the callee runs `ret`, execution continues after the call and
the result is bound.

- Calling an intrinsic: the call signature must match exactly.
- Otherwise, if the call signature differs from the callee's real signature,
  the behaviour is target-specific, and probably UB for big mismatches. A
  call that looks direct (`call void @f()`) can still mismatch.
- LLVM treats calls to functions with standard C99 library names and
  signatures as those library functions. UB in those functions is UB in the
  IR.

**Draconian note:** signature mismatch is not a verifier error for ordinary
functions (only for intrinsics), so the verifier must accept it.

Example:

```
call i32 (ptr, ...) @printf(ptr %msg, i32 12, i8 42)
%X = tail call fastcc i32 @foo()
```

### va_arg

Syntax:

```
<resultval> = va_arg <va_list*> <arglist>, <argty>
```

Type rules: `arglist` is a pointer to a `va_list` (whose layout is
target-specific). `argty` is the type to read; the result has that type.

Semantics: reads the next variadic argument of type `argty` from the list
and advances the list to the following argument. It may be used in a
function that is not itself variadic (like `vfprintf`). It is an instruction
rather than an intrinsic because it takes a type operand. See the variadic
argument intrinsics (`llvm.va_start`, `llvm.va_copy`, `llvm.va_end`).

**Not documented:** the code generator does not fully support `va_arg` on
many targets, and does not support aggregate `argty` on any target. The
reference gives no example here.

Example:

```
%tmp = va_arg ptr %ap, i32
```

### landingpad

Syntax:

```
<resultval> = landingpad <resultty> <clause>+
<resultval> = landingpad <resultty> cleanup <clause>*

<clause> := catch <type> <value>
<clause> := filter <array constant type> <array constant>
```

Type rules:

- It needs at least one clause or the `cleanup` flag.
- `catch` takes a global representing a type that can be caught.
- `filter` takes an array constant listing the types that may be thrown.
  `[0 x ptr] undef` means nothing may be thrown.
- A landing pad block is the unwind destination of an `invoke`. Its first
  non-phi instruction must be a `landingpad`.
- A landing pad block holds exactly one `landingpad`.
- A block that is not a landing pad may not hold a `landingpad`.
- All `landingpad`s in a function have the same result type (implied by the
  `resume` rule).

Semantics: defines the values the personality function supplies when the
function is re-entered during unwinding. How they are represented is
target-specific. Clauses are tried top to bottom. If no clause matches and
`cleanup` is not set, unwinding continues to the caller. When inlining merges
two landing pads, the caller's clauses are appended.

Example:

```
%res = landingpad { ptr, i32 }
         catch ptr @_ZTIi
         filter [1 x ptr] [ptr @_ZTId]
```

### catchpad

Syntax:

```
<resultval> = catchpad within <catchswitch> [<args>*]
```

Type rules:

- The operand must be a `token` produced by a `catchswitch` in the
  (single) predecessor block. So each `catchpad` has exactly one predecessor,
  and that block ends in a `catchswitch`.
- Each argument must be an `alloca` or a constant.
- The result has type `token`.
- `catchpad` must be the first non-phi instruction in its block.

Semantics: when an exception unwinds, the personality routine compares it to
`args` (whose meaning is personality-specific). Control reaches the
`catchpad` only if this is the first matching handler. While the `catchpad`
is entered and not yet exited, any `call` or `invoke` without the right
`"funclet"` operand bundle is UB.

Example:

```
%tok = catchpad within %cs [ptr @_ZTIi]
```

### cleanuppad

Syntax:

```
<resultval> = cleanuppad within <parent> [<args>*]
```

Type rules:

- `parent` is the token of the enclosing funclet pad, or `none`.
- `args` are arbitrary values interpreted by the personality function.
- The result has type `token`.
- A cleanup block is the unwind destination of an instruction that can
  unwind. Its first non-phi instruction must be a `cleanuppad`. It may hold
  only one `cleanuppad`. Other blocks may not hold one.

Semantics: during unwinding, the personality function transfers control here
to run cleanup code. While the `cleanuppad` is entered and not yet exited,
any `call` or `invoke` without the right `"funclet"` bundle is UB.

Example:

```
%tok = cleanuppad within %cs []
```

## Debug records

Debug records are not instructions. They describe changes to debug
information at a point in the program and have no effect on generated code.
In text they are written on their own line, indented one level more than
instructions, and start with `#`:

```
%inst1 = op1 %a, %b
  #dbg_value(%inst1, !10, !DIExpression(), !11)
%inst2 = op2 %inst1, %c
```

They replace the older debug intrinsics (`llvm.dbg.*`). They are turned off
if LLVM is run with `--experimental-debuginfo-iterators=false`. A module may
not contain both debug records and debug intrinsics.

**Draconian note:** the parser must reject a module that mixes `#dbg_*` records
with `llvm.dbg.*` intrinsic calls.

**Not documented:** this section does not list the record kinds or their
operands. Only `#dbg_value` appears. The details are in the separate
"Source Level Debugging" document.
