# Types, Constants and Other Values

Source: LLVM Language Reference, sections "Type System" to "Other Values" (ending at "Inline Asm Metadata").

This chapter covers three things:

1. The type system: every type that can appear in LLVM IR and how it is written.
2. Constants: every literal and constant form, including `undef`, `poison` and constant expressions.
3. Other values: inline assembler expressions, their constraint strings and template modifiers.

LLVM IR is strongly typed. Every value has a type, and the type is usually written right next to the value in the text format (for example `i32 4`). The type system lets optimisations work on the IR directly, without extra analysis to discover what kind of data a value holds.

## Type System

### Overview of type categories

The documentation groups types like this:

| Category | Types |
|---|---|
| Not first class | `void`, function types, opaque structure types |
| First class, single value | integer `iN`, byte `bN`, floating point, `x86_amx`, pointer `ptr`, target extension `target(...)`, vector |
| First class, other | `label`, `token`, `metadata` |
| First class, aggregate | array, structure |

A *first-class* type is one whose values can be produced by instructions. A *single value* type is one that code generation can hold in a register. An *aggregate* type is a derived type that contains several member values; arrays and structures are aggregates, but vectors are not.

### Void type

`void` represents no value and has no size.

```
void
```

### Function type

A function type is a signature: a return type plus a list of parameter types.

```
<returntype> (<parameter list>)
```

- `<parameter list>` is a comma-separated list of types.
- The list may end with `...`, meaning the function is variadic (takes a variable number of arguments). Variadic arguments are read with the variable-argument intrinsics.
- The return type may be `void` or any first-class type, except `label` and `metadata`.

Examples:

| Type | Meaning |
|---|---|
| `i32 (i32)` | takes an `i32`, returns an `i32` |
| `i32 (ptr, ...)` | variadic, at least one pointer argument, returns `i32` (the signature of `printf`) |
| `{i32, i32} (i32)` | takes an `i32`, returns a struct of two `i32` values |

### Opaque structure types

An opaque structure type is a structure with no body. It is like a forward-declared struct in C. It can be named (`%X`) or numbered (`%52`).

```
%X = type opaque
%52 = type opaque

@g = external global %X
```

You cannot create SSA values of an opaque struct type. In practice they are mostly used as the value type of external globals.

### Integer type

```
iN
```

`N` is the bit width. Any width from 1 to 2^23 (about 8 million) bits is allowed.

| Type | Meaning |
|---|---|
| `i1` | single-bit integer |
| `i32` | 32-bit integer |
| `i1942652` | an integer of over a million bits |

Integer types carry no signedness. Signedness lives in the instructions (for example `sdiv` vs `udiv`).

**Smaugian note:** The lexer must accept `i` followed by any decimal width up to 2^23 (8388608). The type representation must not assume widths fit a machine word.

### Byte type

```
bN
```

The byte type holds raw memory data in an SSA register. `N` is the bit width, from 1 to 2^23, as for integers. Each bit of a byte value may be:

- an integer bit (0 or 1),
- part of a pointer value (so pointer provenance can be carried through), or
- poison.

Frontends should use a byte type when:

- lowering `memcpy` / `memmove` into load/store pairs without knowing the underlying type,
- handling a union that can hold a pointer as well as a non-pointer,
- handling possibly uninitialized data.

When the real type is known, the real type should be used instead.

These per-bit semantics apply only in the middle end (the optimiser). At the IR-to-machine-IR boundary, both instruction selectors lower `bN` to the integer of the same width. Backend passes never see the byte type and do not keep its bit-level meaning.

| Type | Meaning |
|---|---|
| `b1` | single-bit byte value |
| `b32` | 32-bit byte value |
| `b128` | 128-bit byte value |

**Smaugian note:** The byte type is a recent addition. Smaugian must lex `b` + digits as a type, which may clash with identifier-like tokens; treat it exactly like `iN` in the lexer. Codegen can lower it to `iN`.

**Not documented:** The section does not list which instructions accept byte operands, or how byte values convert to and from integers and pointers. Those rules, if any, live in the instruction chapters.

### Floating-point types

| Keyword | Bits | Format |
|---|---|---|
| `half` | 16 | IEEE 754 binary16 |
| `bfloat` | 16 | "brain float": same 8 exponent bits as `float`, 7-bit significand. Used by Intel AVX-512 BF16, Arm v8.6-A and others. |
| `float` | 32 | IEEE 754 binary32 |
| `double` | 64 | IEEE 754 binary64 |
| `fp128` | 128 | IEEE 754 binary128 |
| `x86_fp80` | 80 | x87 extended precision |
| `ppc_fp128` | 128 | PowerPC double-double (two 64-bit doubles) |

### x86_amx type

```
x86_amx
```

A value held in an x86 AMX tile register. It is very restricted:

- Only a few intrinsics may use it: strided load, strided store, zero, and dot product.
- No instruction may use it.
- There are no arguments, arrays, pointers, vectors or constants of this type.

### Pointer type

```
ptr
ptr addrspace(N)
ptr addrspace("A")
ptr addrspace("G")
ptr addrspace("P")
```

`ptr` is the type of memory addresses. Pointers are *opaque*: the type does not say what they point to.

Address spaces:

- The default address space is 0. `ptr` means `ptr addrspace(0)`.
- `addrspace(N)` takes an integer address-space number.
- It may also take one of three symbolic names that refer to address spaces set in the module's data layout string:
  - `addrspace("A")`: the alloca address space,
  - `addrspace("G")`: the default globals address space,
  - `addrspace("P")`: the program (code) address space.

Representation:

- Each address space may represent pointers differently. A pointer need not be a plain integer (see non-integral pointers).
- Each address space has a *representation size* (bits in the pointer) and an *index size* (width of indexing arithmetic and of integer addresses). Example: a CHERI capability on a 32-bit system is 64 bits wide but has a 32-bit address.

Semantics:

- The meaning of non-zero address spaces is target-specific.
- Memory access through a non-dereferenceable pointer is undefined behaviour in every address space.
- A pointer whose bits are all zero is assumed non-dereferenceable only in address space 0, and only if the function does not have the `null_pointer_is_valid` attribute.
- A `volatile` access to a non-dereferenceable address may have target-defined behaviour; this does not need the attribute, even at address 0.
- If an object can be proven reachable through a pointer in a different address space, the optimiser may rewrite the access to use that address space, except for volatile operations.

**Deprecated:** Before LLVM 15, pointer types named a pointee type (`i8*`, `[4 x i32]*`, `i32 (i32*)*`). These "typed pointers" survived in LLVM 15 only behind non-default options.

**Smaugian note:** Smaugian only needs opaque `ptr`. Rejecting or rewriting `T*` syntax is acceptable. The data layout must be consulted to resolve `"A"`, `"G"`, `"P"`.

### Target extension types

```
target("label")
target("label", void)
target("label", void, i32)
target("label", 0, 1, 2)
target("label", void, i32, 0, 1, 2)
```

A target extension type is a type the optimiser must preserve but otherwise treats as opaque. It has:

- a name (a quoted string),
- zero or more type parameters, then
- zero or more integer parameters. All type parameters must come before all integer parameters.

The target defines what the name and parameters mean.

Allowed uses:

- function parameters and arguments,
- `phi` and `select`,
- for some types: `alloca`, global variables, and therefore `load` and `store`.

Forbidden uses:

- `bitcast` (as source or destination),
- `ptrtoint` and `inttoptr`,
- `icmp`.

The only constants allowed are `zeroinitializer`, `undef` and `poison`. Other values come from target intrinsics and functions.

Specific target extension types are registered with properties that restrict them further, for example whether they may be a global's type, whether `zeroinitializer` is valid, or whether they may be a vector element (`CanBeVectorElement`).

**Not documented:** The full property list is only referenced (as `llvm::TargetExtType::Property` in the API documentation); it is not given in the language reference. The set of registered names is also not listed.

### Vector type

```
< <# elements> x <elementtype> >            ; fixed-length vector
< vscale x <# elements> x <elementtype> >   ; scalable vector
```

A vector holds several elements of one primitive type, for SIMD operations. Vectors are first class but are not aggregates.

Rules:

- The element count is a constant integer greater than 0. Zero-length vectors are not allowed.
- The element type may be an integer, floating-point or pointer type, or a sized target extension type with the `CanBeVectorElement` property.
- For scalable vectors, the real element count is `vscale` times the written count. `vscale` is a positive power of two, unknown at compile time, and the same for every scalable vector at run time. So the size is a fixed (symbolic) quantity within the IR even though the byte size is only known at run time.

| Type | Meaning |
|---|---|
| `<4 x i32>` | 4 x 32-bit integers |
| `<8 x float>` | 8 x 32-bit floats |
| `<2 x i64>` | 2 x 64-bit integers |
| `<4 x ptr>` | 4 pointers |
| `<vscale x 4 x i32>` | a multiple of 4 x 32-bit integers |

**Not documented:** The type section does not say whether the byte type `bN` may be a vector element type; its element-type list omits it.

#### Vector memory layout

For byte-sized elements, a vector is laid out in memory like an array.

For elements that are not byte-sized, think of a store of `<N x iM>` as:

1. bitcast the vector to an integer of `N*M` bits, then
2. store that integer.

The bitcast packs elements with no padding. On little-endian targets element 0 goes into the least significant bits. On big-endian targets element 0 goes into the most significant bits.

Example with `<4 x i4> <i4 1, i4 2, i4 3, i4 5>` bitcast to `i16` and stored:

| Endianness | `i16` value | byte at `%ptr+0` | byte at `%ptr+1` |
|---|---|---|---|
| Big | `0x1235` | `0x12` | `0x35` |
| Little | `0x5321` | `0x21` | `0x53` |

If `N*M` is not a multiple of the byte size, the exact memory layout is unspecified, just as for an integer of that width, because targets may put the padding in different places.

### Label type

```
label
```

The type of code labels (basic blocks).

### Token type

```
token
```

A token is a value tied to an instruction, which users may not inspect or hide. Because of this, a `phi` or `select` of type `token` is not appropriate. The only token constant is `none` (see below).

### Metadata type

```
metadata
```

The type of embedded metadata. No derived types may be built from it, except that function parameters may have type `metadata`.

### Array type

```
[<# elements> x <elementtype>]
```

Elements are laid out one after another in memory. The count is a constant integer (zero is allowed). The element type may be any type that has a size.

| Type | Meaning |
|---|---|
| `[40 x i32]` | 40 x 32-bit integers |
| `[41 x i32]` | 41 x 32-bit integers |
| `[4 x i8]` | 4 x 8-bit integers |
| `[3 x [4 x i32]]` | 3x4 array of 32-bit integers |
| `[12 x [10 x float]]` | 12x10 array of floats |
| `[2 x [3 x [4 x i16]]]` | 2x3x4 array of 16-bit integers |

Indexing past the static end of an array type is not restricted by the type (though it can be restricted by the bounds of the allocated object). So a zero-length array can model a variable-sized trailing array, for example a Pascal-style array `{ i32, [0 x float] }`.

### Structure type

```
{ <type list> }        ; literal struct
<{ <type list> }>      ; literal packed struct
%T1 = type { <type list> }     ; identified normal struct
%T2 = type <{ <type list> }>   ; identified packed struct
```

A structure groups members together in memory. Each member may be any sized type.

- In memory, fields are reached with `getelementptr` and then `load` / `store`.
- In registers, fields are reached with `extractvalue` / `insertvalue`.

Packing:

- A *packed* struct (`<{ ... }>`) has alignment 1 and no padding between members.
- A normal struct gets padding as specified by the module's data layout string, which must match what the code generator expects.

Literal vs identified:

- A *literal* struct is written inline (for example `[2 x {i32, i32}]`). Literal structs are uniqued by contents: two literal structs with the same members are the same type. They can never be recursive or opaque.
- An *identified* struct is defined at top level with a name. Identified structs are never uniqued: two different names are two different types even if their bodies match. They may be opaque. They must not be recursive.

| Type | Meaning |
|---|---|
| `{ i32, i32, i32 }` | three `i32` values (a "homogeneous" struct) |
| `{ float, ptr }` | a float and a pointer |
| `<{ i8, i32 }>` | packed struct, 5 bytes |

**Smaugian note:** Type interning must key literal structs by (members, packed) and identified structs by name/identity. Identified structs need a mutable body slot so `opaque` can be filled in later.

## Constants

### Simple constants

| Form | Type | Notes |
|---|---|---|
| `true`, `false` | `i1` | Boolean constants |
| `4`, `-1234` | integer | Decimal; `-` prefix for negatives |
| `u0x8000`, `s0x8000` | integer | Hexadecimal; must be prefixed `u` (unsigned) or `s` (signed) |
| `42` used with `bN` | byte | Same as integer constants: `store b8 42, ptr %p` equals `store i8 42, ptr %p` |
| see below | floating point | Must have a floating-point type |
| `null` | pointer | Null pointer constant |
| `none` | `token` | Empty token constant |

Hexadecimal integer details:

- `u0x8000` is 32768. `s0x8000` is -32768.
- Signed hex is sign-extended from its *active bits*: the bit width minus leading zeros of the written value. So `s0x0001` of type `i16` is -1, not 1 (the single active bit is the sign bit).

**Not documented:** The text does not say what happens if a hex literal has more active bits than the type width, nor whether an unprefixed `0x...` is accepted for integers. It says the prefix is required.

### Floating-point constants

Decimal and hexadecimal literals are converted with round-to-nearest, ties-to-even. A conversion that underflows to zero or overflows to infinity is an error.

| Syntax | Meaning |
|---|---|
| `+4.5e-13` | Decimal. Sign optional. Exponent optional. Decimal point required, with at least one digit before it. |
| `-0x1.fp13` | Hexadecimal (C99 style). Sign optional. Decimal point required. `p` exponent required. |
| `+inf`, `-inf` | Infinity. Sign required. |
| `+qnan`, `-qnan` | Preferred quiet NaN: quiet bit set, other payload bits 0. Sign required. |
| `+nan(0x1)` | Quiet NaN with the given hex payload (payload excludes the quiet bit). Sign required. |
| `+snan(0x1)` | Signalling NaN with the given hex payload (payload excludes the quiet bit). Sign required. |
| `f0x3c00` | Exact bit pattern, as if bitcast to an integer. Must have exactly the number of hex digits the type needs. |

**Deprecated:** A legacy hexadecimal bit-pattern syntax will be removed in future:

| Type | Prefix | Hex digits | Notes |
|---|---|---|---|
| `float`, `double` | `0x` | 16 | The value written as the equivalent `double`, bitcast to integer (so `float` is also written as 16 digits) |
| `bfloat` | `0xR` | 4 | |
| `half` | `0xH` | 4 | |
| `x86_fp80` | `0xK` | 20 | |
| `fp128` | `0xL` | 32 | Low 64 bits first (big-endian), then high 64 bits (big-endian) |
| `ppc_fp128` | `0xM` | 32 | Low 64 bits first (big-endian), then high 64 bits (big-endian) |

**Smaugian note:** The parser must accept the legacy forms because existing `.ll` files use them heavily (`0x...` for float/double especially). The printer should decide which form to emit; the reference does not say which form current tools print.

There are no constants of type `x86_amx`.

### Complex constants

Complex constants combine simple constants and smaller complex constants, possibly recursively.

| Form | Syntax | Example |
|---|---|---|
| Structure | `{ <ty> <val>, ... }` | `{ i32 4, float 17.0, ptr @G }` |
| Array | `[ <ty> <val>, ... ]` | `[ i32 42, i32 11, i32 74 ]` |
| Character array | `c"..."` | `c"Hello World\0A\00"` |
| Vector | `< <ty> <val>, ... >` | `< i32 42, i32 11, i32 74, i32 100 >` |
| Splat vector | `splat (<ty> <val>)` | `splat (i32 11)` |
| Zero | `zeroinitializer` | any type |
| Metadata node | `!{ ... }` | `!{!0, !{!2, !0}, !"test"}` |

Rules:

- Structure, array and vector constants must have the matching kind of type, and their element count and element types must match the type exactly.
- `c"..."` is a special form for arrays of characters (`[N x i8]`). `\XX` is a two-digit hex escape.
- `splat` is the preferred way to write a vector whose elements are all the same constant. The vector's element type must match the splat operand's type.
- `zeroinitializer` zero-initialises a value of any type, scalar or aggregate. It is exactly equivalent to writing all the zeros out.
- A metadata node is an untyped constant tuple. It may refer to typed constants, for example `!{!0, i32 0, ptr @global, ptr @function, !"str"}`. Metadata is not part of the instruction stream; it carries extra information such as debug info.

**Not documented:** The section does not say whether `splat` is valid for scalable vectors, though the wording ("vector type") does not exclude it.

### Global variable and function addresses

The name of a global variable or function, used as a value, is a constant: its address. These are link-time constants and always have pointer type.

```
@X = global i32 17
@Y = global i32 42
@Z = global [2 x ptr] [ ptr @X, ptr @Y ]
```

### Undefined values (`undef`)

`undef` may be used wherever a constant is expected, with any type except `label` and `void`. A user of `undef` may see an unspecified bit pattern.

`poison` should be used instead of `undef` wherever possible. Poison is stronger and permits more optimisations. The mere presence of `undef` blocks some optimisations.

The key ideas:

- Each *use* of `undef` may observe a different value. Two `undef` operands are not necessarily equal, and even one `undef` used twice may give different values each time.
- `undef` can be chosen per bit. The optimiser may pick whatever bits make the transformation valid.
- An undefined value is not undefined behaviour. But if *some* choice of the value would cause undefined behaviour, the optimiser may assume that choice.
- `freeze` turns an `undef` into one fixed, arbitrary value that all uses agree on.

The documented examples, restated:

**Arithmetic where every output bit depends on the undef bits.** These may fold to `undef`:

```
%A = add %X, undef     ->  %A = undef
%B = sub %X, undef     ->  %B = undef
%C = xor %X, undef     ->  %C = undef
```

Any output bit can be 0 or 1 depending on the undef input, so the result is fully undefined.

**Bitwise operations where some output bits do not depend on the undef.**

```
%A = or  %X, undef
%B = and %X, undef
Safe:   %A = -1        ; choose undef = all ones
        %B = 0         ; choose undef = all zeros
Safe:   %A = %X        ; choose undef = 0
        %B = %X        ; choose undef = -1
Unsafe: %A = undef
        %B = undef
```

If `%X` has a zero bit, `and` always produces zero there, whatever the undef bit is. So the result is not fully undefined, and folding to `undef` is wrong. But picking one concrete value for the undef is fine.

**`select` with undef.**

```
%A = select undef, %X, %Y
%B = select undef, 42, %Y
%C = select %X, %Y, undef
Safe:   %A = %X   (or %Y)
        %B = 42   (or %Y)
        %C = %Y   (only if %Y is provably not poison)
Unsafe: %A = undef
        %B = undef
        %C = undef
```

An undef condition can go either way, but the result must be one of the two operands. If both `%X` and `%Y` have a clear low bit, `%A` must too. For `%C` the undef may be assumed equal to `%Y`, removing the select, but only if `%Y` is not poison (because poison is stronger than undef).

**Two undefs are not the same.**

```
%A = xor undef, undef

%B = undef
%C = xor %B, %B

%D = undef
%E = icmp slt %D, 4
%F = icmp sge %D, 4

Safe: %A, %B, %C, %D, %E, %F = undef
```

`X ^ X` is not necessarily zero when `X` is undef. An undef "variable" has no stable live range: conceptually it is read from whatever register is handy each time. `%A` and `%C` must mean the same thing, or replace-all-uses-with would be unsound. Likewise `%E` and `%F` may both be true (or both false). Use `freeze` to make all uses agree.

**Undefined value vs undefined behaviour (division).**

```
%A = sdiv undef, %X
%B = sdiv %X, undef
Safe:   %A = 0
        b: unreachable
```

For `%A`, the undef could be 0, and 0 divided by anything is 0. For `%B`, the undef could be 0, and dividing by zero is undefined behaviour. So the optimiser may assume the division never executes, and delete it and everything after it.

**Stores.**

```
a: store undef -> %X
b: store %X -> undef
Safe:   a: <deleted>   (if the value in %X is provably not poison)
        b: unreachable
```

Storing an undef value may be treated as having no effect: assume it wrote the bits already there. This holds only if the memory is provably not poison. Storing *to* an undef address could hit any memory, so it is undefined behaviour.

**Branching on undef is undefined behaviour.** This is what lets passes like Correlated Value Propagation and Global Value Numbering derive facts from branch conditions. A `switch` condition must be frozen too.

```
Unsafe:
  br undef, BB1, BB2                       ; UB

  %X = and i32 undef, 255
  switch %X, label %ret [ .. ]             ; UB

  store undef, ptr %ptr
  %X = load ptr %ptr                       ; %X is undef
  switch i8 %X, label %ret [ .. ]          ; UB

Safe:
  %X = or i8 undef, 255                    ; always 255
  switch i8 %X, label %ret [ .. ]          ; well-defined

  %X = freeze i1 undef
  br %X, BB1, BB2                          ; well-defined, non-deterministic jump
```

**Smaugian note:** Constant folders and peephole passes must follow these rules exactly. In particular: never fold `and`/`or` with undef to undef; never assume `x == x` or `x ^ x == 0` for possibly-undef `x`; and check "provably not poison" before using undef to pick a value equal to another operand.

### Poison values (`poison`)

A poison value is the result of an erroneous operation. To make speculative execution safe, many instructions do not trigger immediate undefined behaviour on bad operands; they return poison instead. For example, `add` with the `nsw` flag returns poison on signed overflow. The literal `poison` may be used wherever a constant is expected.

Propagation:

- Most instructions return poison if any operand is poison.
- `select` is a notable exception (it does not always propagate poison from the unselected operand).
- `freeze` stops propagation.

Refinement: poison may be replaced by `undef` or by any value of its type. So poison is "more undefined" than undef.

Poison causes immediate undefined behaviour when used as an operand where some value would cause undefined behaviour. This includes, but is not limited to:

- the pointer operand of `load`, `store`, or any memory-dereferencing instruction, in any address space;
- the divisor of `udiv`, `sdiv`, `urem`, `srem`;
- the condition of `br`;
- the callee of `call` or `invoke`;
- a `call` / `invoke` argument whose parameter (at the function or call site) has `noundef`;
- the operand of `ret` when the function or call site has `noundef` on the return value.

Documented example, annotated:

```
entry:
  %poison = sub nuw i32 0, 1           ; unsigned wrap: poison
  %poison2 = sub i32 poison, 1         ; poison in, poison out
  %still_poison = and i32 %poison, 0   ; numerically 0, but still poison
  %poison_yet_again = getelementptr i32, ptr @h, i32 %still_poison
  store i32 0, ptr %poison_yet_again   ; UB: store to a poison address

  store i32 %poison, ptr @g            ; poison stored to memory
  %poison3 = load i32, ptr @g          ; poison loaded back
  %poison4 = load i16, ptr @g          ; poison (part of a poison value)
  %poison5 = load i64, ptr @g          ; poison (overlaps a poison value)

  %cmp = icmp slt i32 %poison, 0       ; poison
  br i1 %cmp, label %end, label %end   ; UB, even though both targets match
end:
```

Note that `and %poison, 0` is still poison: poison is not "a value with unknown bits", so masking does not clear it. This is the main difference from undef, where `and undef, 0` is 0.

### Well-defined values

A value is *well defined* in a given execution if it has no undef bits and is not poison.

- An aggregate or vector is well defined if each element is. Padding is ignored, since it is only visible by storing and reloading with a different type.
- A single-value, non-vector constant is well defined unless it is the `undef` or `poison` constant.
- The result of `freeze` is always well defined.

### Addresses of basic blocks (`blockaddress`)

```
blockaddress(@function, %block)
```

The address of a basic block in a function.

- Its type is `ptr addrspace(P)`, where `P` is the address space of the function (usually 0).
- Taking the address of the entry block is illegal.
- Defined behaviour only as the operand of `indirectbr`, or when compared against `null`. No block address equals null.
- Comparing two block addresses for equality is undefined behaviour.
- It may be passed around as an opaque pointer-sized value, provided its bits are not inspected. `ptrtoint` and arithmetic are allowed as long as the original value is rebuilt before it reaches `indirectbr`.
- Some targets give defined meaning to block addresses used as inline asm operands. This is target-specific.

### DSO-local equivalent (`dso_local_equivalent`)

```
dso_local_equivalent @func
```

A function that behaves the same as `@func` but is guaranteed to be defined in the current linkage unit (DSO: dynamic shared object, the executable or shared library being built).

- Its type is the same as `@func`'s.
- It may or may not equal a plain pointer to `@func`, and may differ between translation units.
- `@func` must not have `extern_weak` linkage.

Implementation options:

- If `@func` has local linkage, hidden visibility, or is `dso_local`, it can just be a pointer to `@func`.
- Otherwise use a stub that tail-calls `@func` (a "PLT stub"). Many targets have relocations that resolve to either the function or a stub at link time; LLVM uses these when available. Elsewhere the stub may be emitted explicitly.

Use case: computing static offsets between a function and another `dso_local` symbol, notably for the Relative VTables C++ ABI.

Supported only for ELF object files at present.

### No CFI (`no_cfi`)

```
no_cfi @func
```

Under Control-Flow Integrity (CFI), function references are normally redirected to a CFI jump table by the LowerTypeTests pass. A `no_cfi` reference is not redirected; it points to the real function body. This is useful in low-level code such as kernels.

### Pointer authentication constants (`ptrauth`)

```
ptrauth (ptr CST, i32 KEY[, i64 DISC[, ptr ADDRDISC[, ptr DS]?]?]?)
```

A pointer with a cryptographic signature embedded in some of its bits.

- Type: same as `CST`.
- `DISC` (integer discriminator) defaults to `i64 0`.
- `ADDRDISC` (address discriminator) defaults to `ptr null`.
- `DS` (deactivation symbol) is optional.
- Each later operand may only appear if the earlier ones do.

Meaning, when `ADDRDISC` is null:

```
%tmp = call i64 @llvm.ptrauth.sign(i64 ptrtoint (ptr CST to i64), i32 KEY, i64 DISC)
%val = inttoptr i64 %tmp to ptr
```

Meaning, otherwise:

```
%tmp1 = call i64 @llvm.ptrauth.blend(i64 ptrtoint (ptr ADDRDISC to i64), i64 DISC)
%tmp2 = call i64 @llvm.ptrauth.sign(i64 ptrtoint (ptr CST to i64), i32 KEY, i64 %tmp1)
%val = inttoptr i64 %tmp2 to ptr
```

If `DS` is non-null, it is as if the `llvm.ptrauth.sign` calls carried a deactivation-symbol operand bundle with `DS` as its only operand.

**Not documented:** The printer's rule for omitting trailing default operands is not stated. Printing omitted operands only when they differ from the defaults is the natural reading.

### Constant expressions

A constant expression applies an operation to constants and is itself a constant. It may have any first-class type and may use any operation with no side effects (so not `load` or `call`).

| Syntax | Meaning |
|---|---|
| `trunc (CST to TYPE)` | integer truncation |
| `ptrtoint (CST to TYPE)` | pointer to integer |
| `ptrtoaddr (CST to TYPE)` | pointer to its address (integer of index width) |
| `inttoptr (CST to TYPE)` | integer to pointer ("really dangerous") |
| `bitcast (CST to TYPE)` | bit reinterpretation; same operand rules as the `bitcast` instruction |
| `addrspacecast (CST to TYPE)` | pointer (or vector of pointers) to another address space; same rules as the instruction |
| `getelementptr (TY, CSTPTR, IDX0, IDX1, ...)` | address arithmetic |
| `getelementptr inbounds (TY, CSTPTR, IDX0, IDX1, ...)` | address arithmetic, in-bounds |
| `extractelement (VAL, IDX)` | read a vector element |
| `insertelement (VAL, ELT, IDX)` | replace a vector element |
| `shufflevector (VEC1, VEC2, IDXMASK)` | shuffle two vectors |
| `add (LHS, RHS)` | addition |
| `sub (LHS, RHS)` | subtraction |
| `xor (LHS, RHS)` | bitwise xor |

Operands are written with their types, as in the instruction form (for example `ptrtoint (ptr @X to i64)`).

For `getelementptr`, the index list has one or more indices, which must make sense for "pointer to `TY`". Indices may be implicitly sign-extended or truncated to the index width of `CSTPTR`'s address space.

**Not documented:** The list does not mention whether other `getelementptr` flags (such as `nuw`, `nusw`, `inrange`) or wrap flags on `add`/`sub` (`nuw`, `nsw`) are accepted in constant-expression form. Those are described with the instructions. Smaugian should parse the same flag sets as the instructions to be safe.

**Smaugian note:** This is the complete list of constant-expression opcodes in the reference. Any operation not in the table (for example `mul`, `and`, `icmp`, `zext`) should be rejected in constant-expression position.

## Other Values

### Inline assembler expressions

An inline asm expression is a special value that holds:

- a template string (the assembly to emit),
- a constraint string (operand constraints),
- a side-effect flag,
- an align-stack flag,
- a dialect flag,
- an unwind flag.

Grammar:

```
<fnty> asm [sideeffect] [alignstack] [inteldialect] [unwind] "<template>", "<constraints>"
```

The keywords, when present, must appear in exactly this order: `sideeffect`, `alignstack`, `inteldialect`, `unwind`.

Inline asm may only be the callee of a `call` or `invoke`. (The label-constraint section below also uses it with `callbr`, though this sentence of the reference does not list `callbr`.) Examples:

```
i32 (i32) asm "bswap $0", "=r,r"
%X = call i32 asm "bswap $0", "=r,r"(i32 %Y)
call void asm sideeffect "eieio", ""()
call void asm alignstack "eieio", ""()
call void asm inteldialect "eieio", ""()
call void asm unwind "call func", ""()
```

Keywords:

| Keyword | Meaning |
|---|---|
| `sideeffect` | The asm has side effects not visible in its constraint list. Must be set in that case. |
| `alignstack` | The asm needs the stack aligned (for example it makes calls or uses SSE). The function prologue should do its usual stack alignment conservatively. |
| `inteldialect` | Template uses Intel syntax. The default is AT&T. These are the only two dialects. |
| `unwind` | The asm may unwind the stack; unwind info must be emitted. Unwinding without this keyword is undefined behaviour. |

Correctness rule: the compiler must not assume the code run at run time matches the template text. Correctness-critical analyses may use only the constraints and the flags. This keeps things correct even if the code is later changed (for example by self-modifying code), as long as the replacement obeys the constraints and flags.

#### Template string

- `$N` substitutes operand `N` (a register or memory location chosen per the constraint string).
- `${N:MODIFIER}` substitutes operand `N` printed with a target-specific modifier (see the modifier tables below).
- `$$` is a literal `$`.
- `\XX` hex escapes work as in other strings.
- `${:uid}`: a decimal integer unique to this asm blob. Used to make local labels unique when inlining duplicates the blob. Implements GCC's `%=`.
- `${:comment}`: the target's assembly comment string (often `#`; others use `;`, `//`, `!`).
- `${:private}`: the assembler-private label prefix (labels with it stay out of the symbol table), typically `L` or `.L`.

After substitution, the result is parsed by LLVM's integrated assembler unless that is disabled, even when emitting a `.s` file. So it must be syntax LLVM's assembler understands.

The design follows Clang's GCC-compatible inline asm, but the template and constraint syntax shown here is not GCC's syntax. Most GCC constraint letters pass through Clang unchanged; some are translated.

#### Constraint string

The constraint string is a comma-separated list. Each element has an optional prefix and one or more constraint codes. Operands are numbered `$0`, `$1`, ... in list order.

Element kinds, which must appear in this order (never interleaved):

1. **Outputs** (prefix `=`)
2. **Inputs** (no prefix)
3. **Clobbers** (prefix `~`)

Label constraints (prefix `!`) are also described; the text does not place them in the ordering.

Constraint code categories:

- **Register**: a register class or a specific physical register. The value is bitcast to the register type if needed.
- **Memory**: for instructions that take a memory operand. Different codes allow different addressing modes.
- **Immediate**: an integer or other immediate rendered directly into the instruction, with target-specific range checks.

##### Output constraints

- Prefix `=`, for example `=r`.
- The asm writes the operand. The value becomes a return value of the asm call.
- Outputs do not consume a call argument (except indirect outputs, below).
- Normally LLVM assumes all inputs are read before any output is written, so it may reuse an input register for an output.
- `&` marks an *early-clobber* output (`=&r`): written before all inputs are read. LLVM will then not give it the same register as any input, except an input tied to it.

##### Input constraints

- No prefix. Each consumes one call argument.
- The asm may not write an input's register or memory unless that input is tied to an output.
- Several inputs may share a register if LLVM knows they hold the same value.
- *Tied input*: an integer instead of a code, naming an output. Example: `=r,0` uses the same register for the output and the input. Tied inputs still consume a call argument and still take a template number.
- An input may be tied to an early-clobber output. Then no other input may share that register, even with the same value.
- Only outputs with a register constraint (not memory) can be tied to. Only one input may tie to a given output.
- If a register class register is too small for the input type, the value is split across several registers, all passed to the asm. These registers are not guaranteed to be consecutive, so this does not help with instructions that use register pairs. Some targets offer template modifiers for the second register (for example MIPS `L`, `M`, `D`), but splitting the value into separate operands is usually clearer. The x86 `A` constraint exists only for this feature and is discouraged.

##### Indirect inputs and outputs

- Modifier `*`, after `=` for outputs: `=*m`, `*m`, `=*r`.
- The asm reads from or writes to memory at an address passed as an argument. An indirect output therefore consumes a call argument like an input and does not produce a return value.
- Typical use: `=*m`, passing a variable's address.
- Indirect *register* constraints are only allowed on outputs (`=*r`). LLVM allocates a register as usual and then emits a store to the given address after the asm. The documentation recommends against it: it is no better than an explicit store and blocks optimisation.
- Arguments for indirect constraints must be pointers and must carry the `elementtype` attribute giving the pointee type.

##### Clobber constraints

- Prefix `~`. Consumes no input and produces no output.
- Only explicit register names are allowed, for example `~{eax}`. General letters may not be used.
- `~{memory}` means the asm reads and writes arbitrary undeclared memory, and may synchronise with other threads (like fences or atomics).
- A register named in an output constraint may not also be clobbered.

##### Label constraints

- Prefix `!`, usually `!i`.
- They consume indirect destination labels of a `callbr` instruction, not call arguments.
- Only valid with `callbr`. Their number must equal the number of indirect destinations.

##### Constraint code syntax

A constraint code is one of:

- a single letter, for example `r`;
- `^` followed by two letters, for example `^wc`;
- `{` register-name `}`, for example `{eax}`.

The one- and two-letter codes generally match GCC's.

Alternatives (mainly for translating GCC asm):

- **Code set**: concatenate codes, for example `im` or `{eax}m`. Any one may be chosen, independently for each operand.
- **Alternative sets**: separate with `|`, for example `rm|r,ri|rm`. Every element must have the same number of alternatives, and the same alternative index is chosen for all elements together. In the example: if operand 0 is `r` or `m`, operand 1 is `r` or `i`; if operand 0 is `r`, operand 1 is `r` or `m`; they cannot both be `m`.

The documentation advises against both features. LLVM picks the option most likely to compile, not the fastest. Given `rm` it always picks memory. Given several registers or classes it picks the first. It does not even ensure listed physical registers are unique: `{r11}{r12},{r11}{r12}` assigns `r11` to both.

**Smaugian note:** A constraint string parser needs: prefixes `=`, `&`, `*`, `~`, `!`; tied-operand digits; single letters; `^xy`; `{name}`; concatenated sets; and `|` alternatives. Multi-letter codes in the tables below (such as `Uci`, `Upl`, `VA`, `ZC`, `Ws`, `jr`, `vd`) show that target code lists also need multi-character lookahead. The text describes only `^` as the two-letter syntax, but these appear as plain multi-letter codes in the lists.

**Not documented:** How multi-letter target codes without `^` (for example `Uci`, `ZB`, `DA`, `jR`) are tokenised is not explained. Presumably each target defines its own code lengths.

#### Supported constraint codes

Codes are meant to behave as in GCC. Support is added "as needed"; a mismatch with GCC probably indicates a bug.

##### Target-independent (typically supported by all targets)

| Code | Meaning |
|---|---|
| `r` | general purpose register |
| `m` | memory operand; target-specific addressing modes (for example register, register+register, register+immediate) |
| `p` | address operand, like `m`, for "load address" instructions that do not touch memory |
| `i` | integer constant of target width; may be relocatable |
| `n` | integer constant, not relocatable |
| `s` | symbol or label reference with a constant offset |
| `X` | any operand at all; useful for passing a label to an asm branch or call |
| `{register-name}` | exactly the named physical register |

##### AArch64

| Code | Meaning |
|---|---|
| `z` | immediate 0; prints `WZR` or `XZR` |
| `I` | immediate valid for `ADD`/`SUB`: 0 to 4095, optional shift by 12 |
| `J` | immediate whose negation is valid for `ADD`/`SUB`: -1 to -4095, optional shift by 12 |
| `K` | 32-bit logical "bitmask immediate" (`AND`, `EOR`, `ORR`) |
| `L` | 64-bit logical bitmask immediate |
| `M` | immediate for 32-bit `MOV` alias: superset of `K`, plus single `MOVZ`/`MOVL` values |
| `N` | immediate for 64-bit `MOV` alias: superset of `L` |
| `Q` | memory address in a single register, no offset (LLVM currently does this for `m` too) |
| `r` | 32- or 64-bit integer register (`W*` or `X*`) |
| `S` | symbol or label reference with constant offset (generic `s` is not supported) |
| `Uci` | like `r`, registers 8 to 11 |
| `Ucj` | like `r`, registers 12 to 15 |
| `w` | 32/64/128-bit FP, SIMD or SVE vector register |
| `x` | like `w`, registers 0 to 15 |
| `y` | like `w`, SVE vector registers Z0 to Z7 |
| `Uph` | upper SVE predicate registers P8 to P15 |
| `Upl` | lower SVE predicate registers P0 to P7 |
| `Upa` | any SVE predicate register P0 to P15 |

##### AMDGPU

| Code | Meaning |
|---|---|
| `r` | 32- or 64-bit integer register |
| `s` | SGPR register or tuple |
| `v` | VGPR register or tuple |
| `a` | AGPR register or tuple (gfx908+) |
| `VA` | VGPR or AGPR register or tuple (gfx90a+) |
| `v[0-9]` | 32-bit VGPR number 0-9 |
| `s[0-9]` | 32-bit SGPR number 0-9 |
| `a[0-9]` | 32-bit AGPR number 0-9 |
| `I` | integer inline constant, -16 to 64 |
| `J` | 16-bit signed integer constant |
| `A` | integer or floating-point inline constant |
| `B` | 32-bit signed integer constant |
| `C` | 32-bit unsigned integer constant, or integer inline constant -16 to 64 |
| `DA` | 64-bit constant splittable into two `A` constants |
| `DB` | 64-bit constant splittable into two `B` constants |

**Not documented:** Whether `v[0-9]` means the literal text `v0`..`v9` (one digit), or a bracketed range syntax, is not made clear.

##### ARM (all modes)

| Code | Meaning |
|---|---|
| `Q`, `Um`, `Un`, `Uq`, `Us`, `Ut`, `Uv`, `Uy` | memory operand; currently treated like `m` |
| `Te` | even 32-bit GPR: r0, r2, ..., r12, r14 |
| `To` | odd 32-bit GPR: r1, r3, ..., r11 |

##### ARM and Thumb2 modes

| Code | Meaning |
|---|---|
| `j` | immediate 0 to 65535 (for `MOVW`) |
| `I` | immediate valid for a data-processing instruction |
| `J` | immediate -4095 to 4095 |
| `K` | immediate whose bitwise inverse is valid for data processing (print inverted with modifier `B`) |
| `L` | immediate whose negation is valid for data processing (print negated with modifier `n`) |
| `M` | power of two, or integer 0 to 32 |
| `N` | invalid immediate constraint |
| `O` | invalid immediate constraint |
| `r` | 32-bit GPR r0-r15 |
| `l` | Thumb2: low GPR r0-r7. ARM: same as `r` |
| `h` | Thumb2: high GPR r8-r15. ARM: invalid |
| `w` | FP/SIMD register: s0-s31, d0-d31, or q0-q15 (32/64/128-bit) |
| `t` | FP/SIMD register: s0-s31, d0-d15, or q0-q7 |
| `x` | FP/SIMD register: s0-s15, d0-d7, or q0-q3 |

##### ARM Thumb1 mode

| Code | Meaning |
|---|---|
| `I` | immediate 0 to 255 |
| `J` | immediate -255 to -1 |
| `K` | immediate 0 to 255, optionally shifted left |
| `L` | immediate -7 to 7 |
| `M` | multiple of 4, 0 to 1020 |
| `N` | immediate 0 to 31 |
| `O` | multiple of 4, -508 to 508 |
| `r` | low GPR r0-r7 |
| `l` | low GPR r0-r7 |
| `h` | "high GPR register (r0-r7)" as written |
| `w` | FP/SIMD register: s0-s31, d0-d31, or q0-q15 |
| `t` | FP/SIMD register: s0-s31, d0-d15, or q0-q7 |
| `x` | FP/SIMD register: s0-s15, d0-d7, or q0-q3 |

**Not documented:** The Thumb1 `h` entry says "high GPR register (r0-r7)". This looks like a documentation error (high registers are r8-r15, as in the Thumb2 entry). The real range is not stated reliably.

##### Hexagon

| Code | Meaning |
|---|---|
| `o`, `v` | memory operand; currently treated like `m` |
| `r` | 32- or 64-bit register |

##### LoongArch

| Code | Meaning |
|---|---|
| `f` | floating-point register (if available) |
| `k` | memory operand: base register plus (optionally scaled) index register |
| `l` | signed 16-bit constant |
| `m` | memory operand: base register plus offset, addressing mode of `st.w` / `ld.w` |
| `q` | GPR except `$r0` and `$r1` (for `csrxchg`) |
| `I` | signed 12-bit constant (arithmetic instructions) |
| `J` | immediate zero |
| `K` | unsigned 12-bit constant (logic instructions) |
| `ZB` | address held in a GPR, offset zero |
| `ZC` | memory operand: base register plus offset, addressing mode of `ll.w` / `sc.w` |

##### MSP430

| Code | Meaning |
|---|---|
| `r` | 8- or 16-bit register |

##### MIPS

| Code | Meaning |
|---|---|
| `I` | signed 16-bit immediate |
| `J` | immediate zero |
| `K` | unsigned 16-bit immediate |
| `L` | 32-bit immediate with low 16 bits zero |
| `N` | immediate -65535 to -1 |
| `O` | signed 15-bit immediate |
| `P` | immediate 1 to 65535 |
| `m` | memory operand. MIPS-SE: base register + 16-bit offset. MIPS: base register only |
| `R` | memory operand. MIPS-SE: base register + 9-bit signed offset. MIPS: same as `m` |
| `ZC` | memory operand suitable for `pref`, `ll`, `sc` on the subtarget (details vary) |
| `r`, `d`, `y` | 32- or 64-bit GPR |
| `f` | 32/64-bit FPU register (F0-F31) or 128-bit MSA register (W0-W31); for MSA, use modifier `w` for GCC compatibility |
| `c` | 32/64-bit GPR suitable for indirect jump (always register 25) |
| `l` | the `lo` register, 32 or 64 bits |
| `x` | invalid |

**Not documented:** The MIPS `m` and `R` entries contrast "MIPS-SE mode" with "MIPS mode" without defining the latter (probably microMIPS, but the text does not say).

##### NVPTX

| Code | Meaning |
|---|---|
| `b` | 1-bit integer register |
| `c` or `h` | 16-bit integer register |
| `r` | 32-bit integer register |
| `l` or `N` | 64-bit integer register |
| `q` | 128-bit integer register |
| `f` | 32-bit float register |
| `d` | 64-bit float register |

##### PowerPC

| Code | Meaning |
|---|---|
| `I` | signed 16-bit immediate |
| `J` | unsigned 16-bit immediate shifted left 16 |
| `K` | unsigned 16-bit immediate |
| `L` | signed 16-bit immediate shifted left 16 |
| `M` | immediate greater than 31 |
| `N` | immediate that is an exact power of 2 |
| `O` | immediate 0 |
| `P` | immediate whose negation is a signed 16-bit constant |
| `es`, `o`, `Q`, `Z`, `Zy` | memory operand; currently treated like `m` |
| `r` | 32- or 64-bit integer register |
| `b` | 32- or 64-bit integer register excluding R0 (R1-R31) |
| `f` | 32- or 64-bit float register (F0-F31) |
| `v` | for `4 x f32` or `4 x f64`: 128-bit AltiVec vector register (V0-V31) |
| `y` | condition register (CR0-CR7) |
| `wc` | an individual bit of a CR register |
| `wa`, `wd`, `wf` | any 128-bit VSX register (full VSX set, overlapping FP and vector files) |
| `ws` | 32- or 64-bit FP register from the full VSX set |

**Not documented:** `wc` is listed without the `^` prefix here, although the general syntax section uses `^wc` as its example of a two-letter code. Presumably `^wc` is the IR spelling and `wc` the GCC spelling.

##### RISC-V

| Code | Meaning |
|---|---|
| `A` | address in a GPR, no offset |
| `I` | 12-bit signed immediate |
| `J` | zero immediate |
| `K` | 5-bit unsigned immediate |
| `f` | 32/64-bit FP register (needs F or D extension) |
| `r` | 32/64-bit GPR (depends on XLEN) |
| `S` | alias for `s` |
| `vd` | vector register except v0 (needs V) |
| `vm` | vector register v0 (needs V) |
| `vr` | any vector register (needs V) |

##### Sparc

| Code | Meaning |
|---|---|
| `I` | signed 13-bit immediate |
| `r` | 32-bit integer register |
| `f` | SparcV8: any FP register. SparcV9: FP register in the low half |
| `e` | any FP register (same as `f` on SparcV8) |

##### SystemZ

| Code | Meaning |
|---|---|
| `I` | unsigned 8-bit immediate |
| `J` | unsigned 12-bit immediate |
| `K` | signed 16-bit immediate |
| `L` | signed 20-bit immediate |
| `M` | the immediate `0x7fffffff` |
| `Q` | memory: base + 12-bit unsigned displacement |
| `R` | memory: base + 12-bit unsigned displacement + index register |
| `S` | memory: base + 20-bit signed displacement |
| `T` | memory: base + 20-bit signed displacement + index register |
| `r` or `d` | 32/64/128-bit integer register |
| `a` | 32/64/128-bit integer address register (excludes R0, which reads as zero in addresses) |
| `h` | 32-bit value in the high half of a 64-bit data register (LLVM-specific) |
| `f` | 16/32/64/128-bit FP register |

##### X86

| Code | Meaning |
|---|---|
| `I` | immediate 0 to 31 |
| `J` | immediate 0 to 64 |
| `K` | signed 8-bit immediate |
| `L` | immediate `0xff`, `0xffff`, or (64-bit mode only) `0xffffffff` |
| `M` | immediate 0 to 3 |
| `N` | unsigned 8-bit immediate |
| `O` | immediate 0 to 127 |
| `e` | signed 32-bit immediate |
| `Z` | unsigned 32-bit immediate |
| `q` | 8/16/32/64-bit register accessible as an 8-bit low register. x86-32: a, b, c, d. x86-64: all integer registers. Extended to gpr32 when features `egpr` and `inline-asm-use-gpr32` are both on |
| `Q` | 8/16/32/64-bit register accessible as an 8-bit high register: a, b, c, d |
| `r` or `l` | 8/16/32/64-bit integer register. Extended to gpr32 when `egpr` and `inline-asm-use-gpr32` are both on |
| `R` | 8/16/32/64-bit "legacy" register (exists since i386, no REX prefix needed) |
| `f` | 32/64/80-bit x87 FPU stack pseudo-register |
| `y` | 64-bit MMX register, if MMX enabled |
| `v` | with SSE: 32/64-bit scalar or 128-bit vector in an SSE register; with AVX also 256-bit; with AVX-512 also 512-bit. Error otherwise |
| `Ws` | symbolic reference with optional constant addend, or a label reference |
| `x` | like `v`, but with AVX-512 only the first 16 registers (`v` may use all 32) |
| `Y` | like `x` if SSE2 is enabled; error otherwise |
| `A` | special: allocates EAX then EDX for one operand (in 32-bit mode a 64-bit value is split). Not recommended; in 64-bit mode it allocates only RAX |
| `jr` | 8/16/32/64-bit gpr16 register; never extended to gpr32 |
| `jR` | 8/16/32/64-bit gpr32 register when `egpr` is on; otherwise same as `r` |

##### XCore

| Code | Meaning |
|---|---|
| `r` | 32-bit integer register |

#### Asm template argument modifiers

Written as `${N:M}`, for example `${0:n}`. Expected to match GCC; mismatches are probably bugs.

##### Target-independent

| Modifier | Meaning |
|---|---|
| `a` | print a memory reference (targets may customise) |
| `c` | print an immediate integer unadorned (no target immediate prefix such as `$`) |
| `n` | negate an immediate integer and print it unadorned |
| `l` | print as an unadorned label (no target label punctuation) |

##### AArch64

| Modifier | Meaning |
|---|---|
| `w` | print a GPR with its `w` name (for example `w30` not `x30`) |
| `x` | print a GPR with its `x` name (the default) |
| `b`, `h`, `s`, `d`, `q` | print an FP/SIMD register as `b*`, `h*`, `s*`, `d*` or `q*` instead of `v*` |

##### AMDGPU

| Modifier | Meaning |
|---|---|
| `r` | no effect |

##### ARM

| Modifier | Meaning |
|---|---|
| `a` | print operand as an address (`[` register `]`) |
| `P` | no effect |
| `q` | no effect |
| `y` | print a VFP single register as an indexed double (`d4[1]` instead of `s9`) |
| `B` | bitwise-invert an immediate and print without `#` |
| `L` | print the low 16 bits of an immediate |
| `M` | print as a register set for `ldm`/`stm`; also prints all following register operands (use with care) |
| `Q` | low-order register of a pair or two-register operand |
| `R` | high-order register of a pair or two-register operand |
| `H` | second register of a pair (big-endian: same as `Q`; little-endian: same as `R`) |
| `e` | low doubleword register of a NEON quad register |
| `f` | high doubleword register of a NEON quad register |
| `m` | base register of a memory operand without `[` `]` |

##### Hexagon

| Modifier | Meaning |
|---|---|
| `L` | second register of a two-register operand (must be allocated consecutively) |
| `I` | print `i` if the operand is an integer constant, else nothing (`addi` vs `add`) |

##### LoongArch

| Modifier | Meaning |
|---|---|
| `u` | print an LASX register |
| `w` | print an LSX register |
| `z` | print `$zero` if the operand is zero, else print normally |

##### MSP430

No additional modifiers.

##### MIPS

| Modifier | Meaning |
|---|---|
| `X` | immediate as hexadecimal |
| `x` | low 16 bits of an immediate as hexadecimal |
| `d` | immediate as decimal |
| `m` | immediate minus one, as decimal |
| `z` | `$0` if immediate zero, else print normally |
| `L` | low-order register of a two-register operand, or address of the low word of a double-word memory operand |
| `M` | high-order register of a two-register operand, or address of the high word of a double-word memory operand |
| `D` | second register of a two-register operand, or second word of a double-word memory operand (big-endian: same as `L`; little-endian: same as `M`) |
| `w` | no effect; for GCC compatibility when printing MSA registers with constraint `f` |

##### NVPTX

| Modifier | Meaning |
|---|---|
| `r` | no effect |

##### PowerPC

| Modifier | Meaning |
|---|---|
| `L` | second register of a two-register operand (must be allocated consecutively) |
| `I` | print `i` if the operand is an integer constant, else nothing |
| `y` | for a memory operand, print the two-register X-form (currently always `r0,OPERAND`) |
| `U` | print `u` for an update-form memory operand (LLVM never uses update form, so prints nothing) |
| `X` | print `x` for an indexed-form memory operand (LLVM never uses indexed form, so prints nothing) |

##### RISC-V

| Modifier | Meaning |
|---|---|
| `i` | print `i` if the operand is not a register, else nothing |
| `z` | print register `zero` if immediate zero, else print normally |

##### Sparc

| Modifier | Meaning |
|---|---|
| `L` | low-order register of a two-register operand |
| `H` | high-order register of a two-register operand |
| `r` | no effect |

##### SystemZ

Only the target-independent `n` is implemented. The other target-independent modifiers are not supported.

##### X86

| Modifier | Meaning |
|---|---|
| `a` | memory reference; `sym(%rip)` on x86-64. i386 should use it only with the static relocation model |
| `c` | unadorned integer, or symbol name (the symbol case is x86-specific) |
| `A` | register name preceded by `*` |
| `b` | 8-bit register name (for example `al`); nothing on memory operands |
| `h` | upper 8-bit register name (for example `ah`); nothing on memory operands |
| `w` | 16-bit register name (for example `ax`); nothing on memory operands |
| `k` | 32-bit register name (for example `eax`); nothing on memory operands |
| `q` | 64-bit register name (for example `rax`) if available, else 32-bit; nothing on memory operands |
| `n` | negate and print an unadorned integer; for non-immediates (for example a relocatable symbol expression) print `-` before the operand (the latter is x86-specific) |
| `H` | memory reference with an extra offset of +8 |
| `p` | raw symbol name, without syntax-specific prefixes |
| `P` | memory reference for a call operand, or with explicit base and index registers as offset; uses no extra registers (for example omits `(rip)` even though PC-relative) |

##### XCore

No additional modifiers.

### Inline asm metadata

A call that wraps inline asm may carry a `!srcloc` metadata node holding a list of integer constants:

```
call void asm sideeffect "something bad", ""(), !srcloc !42
...
!42 = !{ i64 1234567 }
```

If present, the code generator uses the integer as a *location cookie* when reporting inline asm errors through the context's error reporting. The frontend chooses what the numbers mean, so it can map backend errors back to source. If the node has several integers, the code generator uses the one for the asm line where the error occurred.

**Smaugian note:** Smaugian's diagnostics for inline asm should carry the `!srcloc` cookie(s) through to error reports, indexed by line within the template.
