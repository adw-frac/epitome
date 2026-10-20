# Intrinsic functions, part 1

Source: LLVM Language Reference, sections "Intrinsic Functions" to "Trampoline Intrinsics".

## General rules

An intrinsic is a function with a well-known name and fixed semantics. Intrinsics let LLVM grow
new operations without changing every pass, the parser, or the bitcode reader and writer.

- **The `llvm.` prefix.** Every intrinsic name starts with `llvm.`. The prefix is reserved.
  An ordinary function may not have a name that starts with it.
- **Declarations only.** An intrinsic is always an external function. You cannot give it a body.
  The text says nothing more about the declaration itself (for example, whether a `declare`
  line must appear before use). The examples always show one.
- **Calls only.** An intrinsic may only appear as the callee of a `call` or `invoke`. Taking its
  address is illegal.
- **Must be documented.** Any intrinsic added to LLVM must be documented in the reference.

**Epitome note:** the verifier should reject a `define` of an `llvm.*` name, a non-intrinsic
function with that prefix, and any use of an intrinsic other than as a direct callee.

### Overloading

Some intrinsics are *overloaded*: one name stands for a family of functions that do the same
thing on different types. The return type, one or more argument types, or both may be
overloaded. An argument may also be declared to have exactly the same type as an earlier
argument or as the result. Such a "matched" type is not overloaded on its own.

### Name mangling

- Each overloaded type adds a suffix to the name, preceded by a period.
- Only overloaded types add suffixes. Matched types do not.
- Suffixes appear in the order of the overloaded types. The examples put the return type first
  when it is overloaded, then overloaded arguments in order (for example
  `llvm.lround.i32.f64`, `llvm.memcpy.p0.p0.i64`, `llvm.vector.extract.v2f64.nxv4f32`).
- Example: `llvm.ctpop` returns the same type as its argument. Only the return type is
  overloaded, so there is one suffix: `i8 @llvm.ctpop.i8(i8)`, `i29 @llvm.ctpop.i29(i29)`.

Type encodings shown in the examples:

| Type | Suffix |
| --- | --- |
| `iN` | `iN` (for example `i1`, `i29`, `i256`) |
| `half`, `float`, `double` | `f16`, `f32`, `f64` |
| `x86_fp80`, `fp128`, `ppc_fp128` | `f80`, `f128`, `ppcf128` |
| `ptr addrspace(N)` | `pN` (`p0` for the default address space) |
| `<N x T>` | `vN` followed by the element suffix (for example `v4i32`, `v4f32`, `v8p0`) |
| `<vscale x N x T>` | `nxvN` followed by the element suffix (for example `nxv4i32`) |
| unnamed (literal) struct | `s_s` |

- An overloaded intrinsic that depends on an unnamed type gets an extra `.<number>` suffix,
  for example `llvm.ssa.copy.p0s_s.2`. The module tracks the number so names are unique.
  When two modules are linked, names can still clash; one is then renumbered.

**Not documented:** the full mangling grammar. The table above is collected from examples.
Encodings for named structs, arrays, function types, `bfloat`, target types and nested
vectors are not given in this range.

**Epitome note:** the parser must map a mangled name back to an intrinsic ID by stripping
suffixes, then check the suffixes against the actual call types. The printer must produce the
same suffixes, including the `.<number>` suffix for unnamed types.

### Advice to target authors

Do not rely on overloading alone to separate integer and floating-point forms that need
different code generation. Define two separate intrinsics instead.

### `immarg` and constant operands

Some parameters carry the `immarg` attribute in the declarations (for example the `isvolatile`
flag of `llvm.memcpy`). The attribute itself is defined in the attributes chapter: the operand
must be an immediate constant. Many other operands below are described as "must be a constant"
without the attribute appearing in the shown declaration. This chapter marks both kinds as
"constant".

**Not documented:** in this range, whether every "must be constant" operand is formally
`immarg`.

## Variable argument handling

All three take a pointer to a target-specific `va_list` object. The reference does not define
`va_list`; passes must handle these calls whatever the type is. They are overloaded on the
pointer address space. A `va_list` must not outlive the function that created it.

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.va_start.*` | `void (ptr %arglist)` | Initialise the `va_list` so the next `va_arg` reads the first variadic argument. Unlike C, no "last named argument" is needed. |
| `llvm.va_end.*` | `void (ptr %arglist)` | Destroy a `va_list`. Every `va_start` and `va_copy` must be matched by exactly one `va_end`. |
| `llvm.va_copy.*` | `void (ptr %dest, ptr %src)` | Copy the current argument position from `src` to `dest`. Both pointers must be in the same address space. |

**Epitome note:** the reference says `llvm.va_copy` is equivalent to `memcpy` on all currently
supported targets, so a `memcpy` of the `va_list` is a valid lowering.

## Accurate garbage collection

The classic `gcroot`/`gcread`/`gcwrite` intrinsics may only be used in a function that names a
GC strategy. The statepoint set is an alternative to `gcroot` and is fully described in a
separate document ("Garbage Collection Safepoints in LLVM").

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.gcroot` | `void (ptr %ptrloc, ptr %metadata)` | Declares a stack slot holding a GC root. At run time it stores null into `ptrloc`. `metadata` must be a constant or global address. |
| `llvm.gcread` | `ptr (ptr %ObjPtr, ptr %Ptr)` | A load of a reference from the heap, for read barriers. `ObjPtr` is the start of the object, or null. Same semantics as `load`, but the GC may replace it. |
| `llvm.gcwrite` | `void (ptr %P1, ptr %Obj, ptr %P2)` | A store of reference `P1` into field `P2` of object `Obj`, for write barriers. Same semantics as `store`. `Obj` may be null. |
| `llvm.experimental.gc.statepoint` | `token (i64 id, i32 numPatchBytes, ptr elementtype(fnty) target, i64 numCallArgs, i64 flags, ...callArgs, i64 0, i64 0)` | A call the runtime can parse. Reads and writes all memory; must not be `readonly`/`readnone`. See notes below. |
| `llvm.experimental.gc.result` | `T (token %statepoint)` | The return value of the call wrapped by the statepoint. `T` must equal the callee's return type. Absent for void callees. Pure (`readnone`). |
| `llvm.experimental.gc.relocate` | `ptrty (token %statepoint, i32 %base_idx, i32 %derived_idx)` | The possibly moved value of a pointer after the safepoint. Both indices point into the statepoint's `gc-live` operand bundle. Pure. |
| `llvm.experimental.gc.get.pointer.base` | `ptrty (ptrty %derived)` | Base pointer of a derived pointer. Return type equals argument type. `memory(none)`, `nounwind`, `willreturn`. |
| `llvm.experimental.gc.get.pointer.offset` | `i64 (ptrty %derived)` | Offset of a derived pointer from its base. `memory(none)`, `nounwind`, `willreturn`. |

Statepoint details:

- `id` is copied into the stack map unchanged. LLVM may duplicate statepoints, so `id` is not
  guaranteed unique.
- If `numPatchBytes` is non-zero, no call is emitted. Instead that many bytes of nops are
  emitted, with argument setup before and result retrieval after. Nop alignment is not
  guaranteed. There are no shadow bytes.
- `target` must carry `elementtype` with the callee's function type. It may be any pointer.
- `numCallArgs` must equal the number of call arguments that follow.
- `flags` bit 0 marks a GC transition. Bits 1 to 63 must be zero.
- The two trailing `i64 0` operands are obsolete length prefixes. **Deprecated:** they will be
  removed in a future revision; their role moved to operand bundles.
- After a statepoint, code reachable from it must not access memory through an unrelocated GC
  pointer argument; it must use the `gc.relocate` result.
- `gc.result` is really a family of three intrinsics because of an implementation limit.
  **Not documented:** which three, and their names.
- For `gc.relocate`, the integer value of the returned pointer is unspecified. Only "same
  object, same offset" and the based-on relationship are guaranteed.
- `gc.get.pointer.base` and `gc.get.pointer.offset` are removed by the `RewriteStatepointsForGC`
  pass.

**Experimental:** all `llvm.experimental.gc.*` intrinsics.

## Code generator intrinsics

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.returnaddress` | `ptr (i32 constant level)` | Return address of frame `level` (0 = current function). Returns 0 if unknown. Values for `level > 0` are often wrong; debugging only. |
| `llvm.addressofreturnaddress` | `ptr ()` | Address of the stack slot holding the current function's return address. Only implemented on x86 and AArch64. |
| `llvm.sponentry` | `ptr ()` | Stack pointer value at entry to the current function. Only verified on AArch64 and ARM. |
| `llvm.stackaddress.*` | `ptr ()` (overloaded on address space) | The logical stack pointer: the boundary between this frame and space callees may use. Equal to `sponentry` minus frame size. Differs from the physical SP on some targets (for example SPARCv9). |
| `llvm.frameaddress` | `ptr (i32 constant level)` | Frame pointer of frame `level`, or 0 if unknown. Same caveats as `returnaddress`. |
| `llvm.swift.async.context.addr` | `ptr ()` | Address of the Swift async context slot in the extended frame record. Holds the `swiftasync` argument if present, otherwise null. |
| `llvm.localescape` | `void (ptr ...)` | Publishes the frame offsets of static allocas. Called at most once, in the entry block. Blocks inlining of the function. |
| `llvm.localrecover` | `ptr (ptr %func, ptr %fp, i32 %idx)` | Address of the `idx`-th escaped alloca of `func`, given live frame pointer `fp`. `func` must be a constant function defined in this module. |
| `llvm.seh.try.begin` | `void ()` | Start of a `__try` region for Windows SEH asynchronous EH (`-EHa`). Stops exceptions moving across the boundary. |
| `llvm.seh.try.end` | `void ()` | End of that `__try` region. |
| `llvm.seh.scope.begin` | `void ()` | Start of a C++ object lifetime region under `-EHa`. Always called with `invoke`; its unwind edge is the cleanup for faulting instructions in the region. |
| `llvm.seh.scope.end` | `void ()` | End of that region; the cleanup is no longer needed. |
| `llvm.read_register.*` | `iN (metadata !regname)` | Read a named register. Not for allocatable registers. |
| `llvm.read_volatile_register.*` | `iN (metadata !regname)` | Same, but treated as having side effects; never moved or removed. Not for allocatable registers. |
| `llvm.write_register.*` | `void (metadata !regname, iN %value)` | Write a named register. Not for allocatable registers. |
| `llvm.write_volatile_register.*` | `void (metadata !regname, iN %value)` | Write with side effects. May write allocatable registers (only on AArch64 today); the value is placed there at the call and a fake use keeps it alive until register allocation. |
| `llvm.stacksave.*` | `ptr ()` (overloaded on address space) | Opaque token for the current stack state. Address space should be the alloca address space. |
| `llvm.stackrestore.*` | `void (ptr %saved)` | Restore the stack to a `stacksave` state, freeing allocas made since. |
| `llvm.structured.gep` | `ptr (ptr elementtype(T) %src, iN %idx...)` | Logical address of a sub-element of `T`. Physical layout is target-defined and may differ from the data layout. See notes. |
| `llvm.structured.alloca` | `elementtype(T) ptr ()` | Stack allocation for logical type `T` with target-opaque layout. Result is in the alloca address space. Memory is uninitialised. |
| `llvm.get.dynamic.area.offset.*` | `iN ()` | Non-negative offset from native SP to the most recent dynamic alloca. Usually 0; a known constant on PowerPC. Return type must match the target's alloca address space type. |
| `llvm.prefetch` | `void (ptr %addr, i32 rw, i32 locality, i32 cachetype)` | Prefetch hint, or a no-op. `rw`: 0 read, 1 write. `locality`: 0 to 3. `cachetype`: 1 data, 0 instruction. Last three are constant. Never traps. |
| `llvm.pcmarker` | `void (i32 %id)` | Exports a PC marker for simulators. No effect on behaviour; may be ignored. |
| `llvm.readcyclecounter` | `i64 ()` | Cycle counter (x86 `RDTSC`). Lowered to constant 0 where unsupported. |
| `llvm.readsteadycounter` | `i64 ()` | Fixed-frequency clock. Frequency is implementation-defined. Lowered to constant 0 where unsupported. |
| `llvm.clear_cache` | `void (ptr %begin, ptr %end)` | Make code written in a range visible to instruction fetch. No-op on coherent targets. |
| `llvm.instrprof.increment` | `void (ptr name, i64 hash, i32 numCounters, i32 index)` | Increment profile counter `index` for `name`. Lowered by the `-instrprof` pass. |
| `llvm.instrprof.increment.step` | `void (ptr name, i64 hash, i32 numCounters, i32 index, i64 step)` | Same, adding `step` instead of 1. |
| `llvm.instrprof.callsite` | `void (ptr name, i64 hash, i32 numCounters, i32 index, ptr callee)` | Placed before a real call site for contextual profiling. Has side effects. Lowered in IR; back ends never see it. |
| `llvm.instrprof.timestamp` | `void (ptr name, i64 hash, i32 numCounters, i32 index)` | Records when the function first ran (temporal profiling). `index` is always 0. |
| `llvm.instrprof.cover` | `void (ptr name, i64 hash, i32 numCounters, i32 index)` | Coverage: stores zero to the counter to mark the function as covered. |
| `llvm.instrprof.value.profile` | `void (ptr name, i64 hash, i64 value, i32 kind, i32 index)` | Point at which to call the runtime to profile `value`. |
| `llvm.instrprof.mcdc.parameters` | `void (ptr name, i64 hash, i32 bitmapBits)` | Starts MC/DC coverage for a function with the given bitmap size. |
| `llvm.instrprof.mcdc.tvbitmap.update` | `void (ptr name, i64 hash, i32 bitmapIndex, ptr condBitmapAddr)` | Records an executed MC/DC test vector in the global bitmap. |
| `llvm.thread.pointer.*` | `ptr ()` (overloaded on address space) | Pointer into the current thread's TLS area. Where it points is target-specific. Not all targets support it. Must use the globals address space. |
| `llvm.call.preallocated.setup` | `token (i32 %numArgs)` | Starts a preallocated call. The token goes in the call's `"preallocated"` bundle. Setups must be properly nested. |
| `llvm.call.preallocated.arg` | `ptr (token %setup, i32 %argIndex)` | Pointer to the storage for a preallocated argument. Call site needs a matching `preallocated(T)` attribute. |
| `llvm.call.preallocated.teardown` | `ptr (token %setup)` | Frees the stack from a setup when the call is not made (for example on an exception). Calling both teardown and the call is UB. |

Notes:

- `returnaddress`, `addressofreturnaddress` and `frameaddress` do not block inlining, so the
  result may not match the source-level caller.
- `localescape`: arguments must be static allocas or casts of them. `localrecover`'s `idx` is
  zero-based. `fp` may come from `llvm.localaddress` (part 2) or a platform mechanism.
- `read_register` family: the verifier does not check register names. An unsupported name is a
  fatal error in code generation. Supported names are target-specific. The example metadata is
  `!{!"sp\00"}`.
- `structured.gep`: indices are unsigned `i32` or `i64`, mixable. Struct indices must be
  constants in `[0, N)`. Array and vector indices may be variables but are assumed in bounds;
  out of bounds gives poison, except for zero-length arrays, whose size is taken as known at
  run time. A poison source gives poison. All indices must be consumed; indexing into a scalar
  is illegal. The result is in the source's address space and is not dereferenced. A result
  may only access memory inside the indexed sub-object. Two results from the same pointer and
  type do not alias unless one index list is a prefix of the other.
- `structured.alloca`: size and layout are constant for the module, so two allocations of the
  same type have the same size. GEP, ptradd and lifetime intrinsics are allowed on the result.
- `prefetch` and `frameaddress` are shown with no suffix. **Not documented:** whether they are
  overloaded on the pointer address space.
- `instrprof.*`: `hash` and `numCounters` must agree across all uses of the same `name`.
  `index` should be in `[0, numCounters)`. The value-profile `kind` values are listed in a
  separate header, not in the reference. **Not documented:** the exact layout and lowering
  beyond the outline given (counters, contextual profiling TLS slots
  `__llvm_ctx_profile_expected_callee` and `__llvm_ctx_profile_callsite`).
- `instrprof.timestamp` is declared with `i8*` in the reference, an old typed-pointer spelling.
  Treat it as `ptr`.
- `preallocated.arg` with a token whose call already happened, or after another setup was
  made, is UB.

**Epitome note:** `llvm.clear_cache` lowers by default to a call to `__clear_cache` from the
runtime library. `readcyclecounter` and `readsteadycounter` lower to constant 0 on targets
without support. `prefetch` and `pcmarker` may be dropped.

## Standard C/C++ library intrinsics

These let front ends pass alignment and other facts to the code generator.

### Integer min, max, abs, compare

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.abs.*` | `T (T %x, i1 constant %is_int_min_poison)` | Absolute value, per element for vectors. For `INT_MIN`: returns `INT_MIN` if the flag is 0, poison if it is 1. |
| `llvm.smax.*` | `T (T %a, T %b)` | Signed maximum, per element. |
| `llvm.smin.*` | `T (T %a, T %b)` | Signed minimum, per element. |
| `llvm.umax.*` | `T (T %a, T %b)` | Unsigned maximum, per element. |
| `llvm.umin.*` | `T (T %a, T %b)` | Unsigned minimum, per element. |
| `llvm.scmp.*` | `R (T %a, T %b)` | -1 if `a < b` (signed), 0 if equal, 1 if greater. `R` is at least `i2` wide. Overloaded on both `R` and `T` (`llvm.scmp.i2.i32`). |
| `llvm.ucmp.*` | `R (T %a, T %b)` | Same, comparing unsigned. |

`T` is any integer or integer vector.

### Memory operations

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.memcpy.*` | `void (ptr %dst, ptr %src, iN %len, i1 immarg %isvolatile)` | Copy `len` bytes. Regions must be equal or non-overlapping. No return value. |
| `llvm.memcpy.inline.*` | same as `memcpy` | Same as `memcpy` (regions must not overlap), but generated code never calls an external function. |
| `llvm.memmove.*` | same as `memcpy` | Copy `len` bytes; regions may overlap. |
| `llvm.memset.*` | `void (ptr %dst, i8 %val, iN %len, i1 immarg %isvolatile)` | Fill `len` bytes with `val`. |
| `llvm.memset.inline.*` | same as `memset` | Same as `memset`, but never calls an external function. |
| `llvm.experimental.memset.pattern.*` | `void (ptr %dst, T %val, iN %count, i1 %isvolatile)` | Store `val` `count` times, advancing by the allocation size of `T` each time. Stores follow normal store rules (endianness, padding). |

Shared rules:

- Name suffixes are the pointer address spaces then the length type: `llvm.memcpy.p0.p0.i64`,
  `llvm.memset.p0.i32`, `llvm.experimental.memset.pattern.p0.i128.i64`.
- `align` may be placed on the pointer arguments.
- `len` (or `count`) of 0 is a no-op, apart from the effect of argument attributes.
- If `len` is not a well-defined value, behaviour is undefined.
- If `len` is non-zero, the pointers must be well-defined, otherwise behaviour is undefined.
- `isvolatile` true makes the call volatile. **Not documented:** the exact access pattern of a
  volatile memory intrinsic. The reference says it is not cleanly specified.
- Not all targets support all length widths.

**Experimental:** `llvm.experimental.memset.pattern`. Its `isvolatile` is not shown as
`immarg`.

**Epitome note:** `memcpy`, `memmove` and `memset` may be lowered to libc calls. The `.inline`
forms must always be expanded inline. `memset.pattern` may become an inline loop, a store
sequence, or a libcall.

### Floating-point math

All take and return the same floating-point type or vector of it, unless noted. They are
overloaded on that type (`f32`, `f64`, `f80`, `f128`, `ppcf128`, vectors). Not all targets
support all types.

For the libm-like functions: the result equals the libm function, but the intrinsic never
traps and never sets `errno`. With the `afn` fast-math flag, a less accurate approximation is
allowed.

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.sqrt.*` | `F (F)` | Square root. Matches a conforming libm for IEEE types. |
| `llvm.powi.*` | `F (F %x, iN %power)` | `x` raised to an integer power. Rounding sequence is unspecified. Power stays scalar for vectors. Name: `llvm.powi.f64.i16`. Usually only the C `int` width is supported. |
| `llvm.sin.*` | `F (F)` | Sine. |
| `llvm.cos.*` | `F (F)` | Cosine. |
| `llvm.tan.*` | `F (F)` | Tangent. |
| `llvm.asin.*` | `F (F)` | Arcsine. |
| `llvm.acos.*` | `F (F)` | Arccosine. |
| `llvm.atan.*` | `F (F)` | Arctangent. |
| `llvm.atan2.*` | `F (F %y, F %x)` | Arctangent of `y/x`, using signs to pick the quadrant. |
| `llvm.sinh.*` | `F (F)` | Hyperbolic sine. |
| `llvm.cosh.*` | `F (F)` | Hyperbolic cosine. |
| `llvm.tanh.*` | `F (F)` | Hyperbolic tangent. |
| `llvm.sincos.*` | `{F, F} (F)` | Sine and cosine together, as if calling `llvm.sin` and `llvm.cos`. |
| `llvm.sincospi.*` | `{F, F} (F)` | Sine and cosine of `pi * x`, computed more accurately than scaling first. |
| `llvm.modf.*` | `{F, F} (F)` | `{fractional, integral}` parts, both with the operand's sign. Zero gives two zeros of that sign. Infinity gives `{±0, ±inf}`. |
| `llvm.pow.*` | `F (F %x, F %y)` | `x` to the power `y`. |
| `llvm.exp.*` | `F (F)` | `e^x`. |
| `llvm.exp2.*` | `F (F)` | `2^x`. |
| `llvm.exp10.*` | `F (F)` | `10^x`. |
| `llvm.ldexp.*` | `F (F %x, I %exp)` | `x * 2^exp`. NaN and infinity pass through. Underflow gives signed zero; overflow gives signed infinity. `I` has the same element count. Name: `llvm.ldexp.f32.i32`. |
| `llvm.frexp.*` | `{F, I} (F)` | Split into a mantissa with magnitude in `[0.5, 1)` and the operand's sign, plus an exponent. Zero gives `{±0, 0}`. NaN gives NaN with unspecified exponent. Infinity gives infinity with unspecified exponent. |
| `llvm.log.*` | `F (F)` | Natural logarithm. |
| `llvm.log10.*` | `F (F)` | Base-10 logarithm. |
| `llvm.log2.*` | `F (F)` | Base-2 logarithm. |
| `llvm.fma.*` | `F (F %a, F %b, F %c)` | IEEE fused multiply-add, one rounding. Never traps or sets `errno`. |
| `llvm.fabs.*` | `F (F)` | Clear the sign bit. All other bits, including NaN payload and quiet bit, are kept. |
| `llvm.minnum.*` | `F (F, F)` | Minimum. A quiet NaN operand is ignored if the other is a number. Signalling NaN: returns NaN or acts as quiet, non-deterministically. `-0.0 < +0.0`. |
| `llvm.maxnum.*` | `F (F, F)` | Maximum, same NaN rules as `minnum`. |
| `llvm.minimum.*` | `F (F, F)` | Minimum that propagates NaN: any NaN operand gives NaN. `-0.0 < +0.0`. C23 `fminimum`. |
| `llvm.maximum.*` | `F (F, F)` | Maximum that propagates NaN. C23 `fmaximum`. |
| `llvm.minimumnum.*` | `F (F, F)` | Minimum that ignores any NaN (quiet or signalling) if the other is a number. Both NaN gives NaN. C23 `fminimum_num`. |
| `llvm.maximumnum.*` | `F (F, F)` | Maximum version of `minimumnum`. C23 `fmaximum_num`. |
| `llvm.copysign.*` | `F (F %mag, F %sgn)` | `mag` with the sign bit of `sgn`. Other bits of `mag` are kept exactly. |
| `llvm.floor.*` | `F (F)` | Round toward minus infinity, as libm `floor`. |
| `llvm.ceil.*` | `F (F)` | Round toward plus infinity, as libm `ceil`. |
| `llvm.trunc.*` | `F (F)` | Round toward zero, as libm `trunc`. |
| `llvm.rint.*` | `F (F)` | Round to nearest, ties to even (the default mode is assumed). May raise inexact. |
| `llvm.nearbyint.*` | `F (F)` | Round to nearest, ties to even (default mode assumed). As libm `nearbyint`. |
| `llvm.round.*` | `F (F)` | Round to nearest, as libm `round` (ties away from zero). |
| `llvm.roundeven.*` | `F (F)` | IEEE roundToIntegralTiesToEven. Ignores rounding mode and raises no exceptions. |
| `llvm.lround.*` | `iN (F)` | Round to nearest, ties away from zero, to an integer. Out of range gives `freeze poison` (any value). Name: `llvm.lround.i32.f64`. |
| `llvm.llround.*` | `i64 (F)` | Same as `lround`. Scalar types only per the text. |
| `llvm.lrint.*` | `iN (F)` | Round to nearest (current mode, assumed default) to an integer. Out of range gives `freeze poison`. |
| `llvm.llrint.*` | `i64 (F)` | Same as `lrint`. |

Min/max notes:

- With the `nsz` flag, a `+0.0`/`-0.0` pair may return either operand. But if both operands
  have the same sign, the result must keep it. This applies to all six min/max intrinsics.
- `minnum`/`maxnum` with `nsz` match C `fmin`/`fmax` and IEEE 754-2008 minNum/maxNum, except
  for signalling NaN.
- `minnum` may be refined to `minimumnum`, and `maxnum` to `maximumnum`.
- **Not documented / unreliable:** without `nsz`, not all back ends honour the `-0.0 < +0.0`
  ordering for `minnum`/`maxnum` (LLVM issue #174730).

Other notes:

- `pow` and `powi` can turn a NaN input into a non-NaN result (`pow(QNaN, 0) = 1.0`). A
  signalling NaN may be treated as quiet non-deterministically, so `pow(SNaN, 0)` may be `1.0`
  or NaN.
- `rint` and `nearbyint` assume round-to-nearest. Use constrained intrinsics (part 2) to avoid
  that assumption.
- **Not documented:** whether `lround`, `lrint` and `llrint` truly accept vectors. The overview
  says vectors are allowed but every example is scalar.

**Epitome note:** most of these have no instruction on common targets and must be lowered to
libm calls (`sin`, `cos`, `pow`, `exp`, `log`, and so on). The default lowering of
`llvm.sincospi` relies on `sincospi`, `sincospif` or `sincospil` existing in the target runtime.

### Floating-point min/max summary

| Intrinsic | NaN handling | C function | IEEE 754 |
| --- | --- | --- | --- |
| `minnum` with `nsz` | quiet NaN ignored; signalling NaN non-deterministic | `fmin` | minNum (2008) |
| `minimum` | NaN propagates | `fminimum` | minimum (2019) |
| `minimumnum` | any NaN ignored | `fminimum_num` | minimumNumber (2019) |

## Bit manipulation

`T` is any integer or integer vector. Vector forms work per element.

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.bitreverse.*` | `T (T)` | Reverse bit order: bit `M` moves to bit `N-M-1`. |
| `llvm.bswap.*` | `T (T)` | Reverse byte order. Bit width must be a multiple of 16. |
| `llvm.ctpop.*` | `T (T)` | Count set bits. |
| `llvm.ctlz.*` | `T (T %x, i1 constant %is_zero_poison)` | Count leading zeros. For `x == 0`: bit width if the flag is 0, poison if 1. |
| `llvm.cttz.*` | `T (T %x, i1 constant %is_zero_poison)` | Count trailing zeros. Same zero rule as `ctlz`. |
| `llvm.fshl.*` | `T (T %a, T %b, T %c)` | Funnel shift left: concatenate `a:b`, shift left by `c mod width`, take the high half. `fshl(x, x, c)` is rotate left. |
| `llvm.fshr.*` | `T (T %a, T %b, T %c)` | Funnel shift right: concatenate `a:b`, shift right by `c mod width`, take the low half. `fshr(x, x, c)` is rotate right. |
| `llvm.clmul.*` | `T (T %a, T %b)` | Carry-less (XOR) multiply; returns the low half. |
| `llvm.pext.*` | `T (T %val, T %mask)` | Gather the bits of `val` at set bits of `mask` into the low bits of the result; other bits are zero. Like x86 `PEXT`. |
| `llvm.pdep.*` | `T (T %val, T %mask)` | Scatter the low bits of `val` to the set bit positions of `mask`; other bits are zero. Like x86 `PDEP`. `pdep(pext(v, m), m) == v & m`. |

Note: a funnel shift amount is taken modulo the width, so it never produces poison.

## Arithmetic with overflow

Each returns `{T, i1}` (or `{<N x iM>, <N x i1>}` for vectors). Element 0 is the wrapped result,
the same as the plain instruction without `nsw`/`nuw`. Element 1 is 1 if the operation
overflowed. Overflow means the result differs from the exact result computed in a wider type
(sign-extended for signed, zero-extended for unsigned). These are defined for all inputs; they
never return poison.

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.sadd.with.overflow.*` | `{T, i1} (T, T)` | Signed add with overflow flag. |
| `llvm.uadd.with.overflow.*` | `{T, i1} (T, T)` | Unsigned add with carry flag. |
| `llvm.ssub.with.overflow.*` | `{T, i1} (T, T)` | Signed subtract with overflow flag. |
| `llvm.usub.with.overflow.*` | `{T, i1} (T, T)` | Unsigned subtract with borrow flag. |
| `llvm.smul.with.overflow.*` | `{T, i1} (T, T)` | Signed multiply with overflow flag. |
| `llvm.umul.with.overflow.*` | `{T, i1} (T, T)` | Unsigned multiply with overflow flag. |

## Saturation arithmetic

Results are clamped to the range of the type instead of wrapping.

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.sadd.sat.*` | `T (T, T)` | Signed add, clamped to `[INT_MIN, INT_MAX]`. |
| `llvm.uadd.sat.*` | `T (T, T)` | Unsigned add, clamped to the unsigned maximum. |
| `llvm.ssub.sat.*` | `T (T, T)` | Signed subtract, clamped to the signed range. |
| `llvm.usub.sat.*` | `T (T, T)` | Unsigned subtract, clamped at 0. |
| `llvm.sshl.sat.*` | `T (T %a, T %b)` | Signed shift left, clamped to the signed range. Poison if `b >= bit width`. |
| `llvm.ushl.sat.*` | `T (T %a, T %b)` | Unsigned shift left, clamped to the unsigned maximum. Poison if `b >= bit width`. |

## Fixed-point arithmetic

Operands are integers holding fixed-point values with `scale` fractional bits. `scale` is an
`i32` constant. The result has the same scale.

When the exact result cannot be represented, it is rounded. **Not documented:** the rounding
direction is deliberately unspecified and comes from a target hook. The result must be within
one unit of the last place (error below `1/2^scale`). Folding and analysis passes must not
assume a direction.

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.smul.fix.*` | `T (T %a, T %b, i32 constant %scale)` | Signed fixed-point multiply. UB if the result does not fit. |
| `llvm.umul.fix.*` | `T (T %a, T %b, i32 constant %scale)` | Unsigned fixed-point multiply. UB if the result does not fit. |
| `llvm.smul.fix.sat.*` | `T (T %a, T %b, i32 constant %scale)` | Signed fixed-point multiply, clamped to the signed range. |
| `llvm.umul.fix.sat.*` | `T (T %a, T %b, i32 constant %scale)` | Unsigned fixed-point multiply, clamped to `[0, UMAX]`. |
| `llvm.sdiv.fix.*` | `T (T %a, T %b, i32 constant %scale)` | Signed fixed-point divide. UB if the result does not fit or `b` is 0. |
| `llvm.udiv.fix.*` | `T (T %a, T %b, i32 constant %scale)` | Unsigned fixed-point divide. UB if the result does not fit or `b` is 0. |
| `llvm.sdiv.fix.sat.*` | `T (T %a, T %b, i32 constant %scale)` | Signed fixed-point divide, clamped. UB if `b` is 0. |
| `llvm.udiv.fix.sat.*` | `T (T %a, T %b, i32 constant %scale)` | Unsigned fixed-point divide, clamped. UB if `b` is 0. |

The reference gives reference expansions: multiply in double width, then arithmetic shift right
by `scale`; divide by shifting `a` left by `scale` in double width, then dividing.

## Specialized arithmetic

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.canonicalize.*` | `F (F)` | Return the canonical encoding of the value. See notes. |
| `llvm.fmuladd.*` | `F (F %a, F %b, F %c)` | `a * b + c`, where fusing into one rounding is allowed but not required. Never sets `errno`. Use `llvm.fma` when fusion is required. |
| `llvm.smulh.*` | `T (T, T)` | High half of the signed double-width product. |
| `llvm.umulh.*` | `T (T, T)` | High half of the unsigned double-width product. |

`llvm.canonicalize` notes:

- Equivalent to an IEEE 754-2008 convert to the same format. Signalling NaNs are quieted.
- Non-canonical inputs include x87 pseudo-denormals and similar, and subnormals on hardware
  without subnormal support (they flush to a same-signed zero).
- Must preserve equality: `canonicalize(x) == x` iff `x == x`, and
  `canonicalize(x) == canonicalize(y)` iff `x == y`.
- Must preserve the sign of zero.
- Must preserve NaN payload, unless the environment has a single canonical NaN, or the NaN is
  signalling (it is quieted).
- May be removed if the input is already canonical, or if only floating-point operations use
  the result.

**Epitome note:** `llvm.canonicalize` can be implemented as a multiply by 1.0 (if not
constant-folded), a divide by 1.0, `minnum(x, x)`, or adding -0.0 (unless rounding toward
minus infinity).

## Hardware-loop intrinsics

These are hints for back ends with hardware loop support. The back end must either lower them
to target instructions or turn the loop back into a normal loop. Front ends and mid-level passes
must not create them. **Experimental:** the reference says they "may be modified in the
future" and are not meant for use outside the back end.

The trip-count operand is the loop trip count, not the back-edge count.

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.set.loop.iterations.*` | `void (iN %count)` | Set the hardware-loop count. In the preheader. Not duplicable. |
| `llvm.start.loop.iterations.*` | `iN (iN %count)` | Same, and return `count` unchanged to feed the induction PHI. |
| `llvm.test.set.loop.iterations.*` | `i1 (iN %count)` | Set the count and return `count != 0`, to guard a while-loop. In the preheader's predecessor. Not duplicable. |
| `llvm.test.start.loop.iterations.*` | `{iN, i1} (iN %count)` | Return `{count, count != 0}`. |
| `llvm.loop.decrement.reg.*` | `iN (iN %counter, iN %step)` | `counter - step`, which must not wrap. Returns the remaining count. Passes may treat it as a `sub`. Not duplicable. |
| `llvm.loop.decrement.*` | `i1 (iN %step)` | Decrement the hidden loop counter by `step`; return false when the loop should exit. Must not wrap. |

"Not duplicable" refers to an internal `IntrNoDuplicate` property. **Epitome note:** passes that
clone code (unrolling, tail duplication) must not duplicate these calls.

## Vector reduction

Each reduces a vector to one scalar of its element type.

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.vector.reduce.add.*` | `E (<N x E>)` | Integer sum. |
| `llvm.vector.reduce.fadd.*` | `E (E %start, <N x E>)` | Float sum, starting from `start`. Strictly in element order unless the call has `reassoc`. Use `-0.0` as a neutral start. |
| `llvm.vector.reduce.mul.*` | `E (<N x E>)` | Integer product. |
| `llvm.vector.reduce.fmul.*` | `E (E %start, <N x E>)` | Float product, starting from `start`. Ordered unless `reassoc`. Use `1.0` as a neutral start. |
| `llvm.vector.reduce.and.*` | `E (<N x E>)` | Bitwise AND. |
| `llvm.vector.reduce.or.*` | `E (<N x E>)` | Bitwise OR. |
| `llvm.vector.reduce.xor.*` | `E (<N x E>)` | Bitwise XOR. |
| `llvm.vector.reduce.smax.*` | `E (<N x E>)` | Signed maximum. |
| `llvm.vector.reduce.smin.*` | `E (<N x E>)` | Signed minimum. |
| `llvm.vector.reduce.umax.*` | `E (<N x E>)` | Unsigned maximum. |
| `llvm.vector.reduce.umin.*` | `E (<N x E>)` | Unsigned minimum. |
| `llvm.vector.reduce.fmax.*` | `E (<N x E>)` | Float maximum with `maxnum` semantics. Order is non-deterministic; visible only with signalling NaNs. |
| `llvm.vector.reduce.fmin.*` | `E (<N x E>)` | Float minimum with `minnum` semantics. Same ordering rule. |
| `llvm.vector.reduce.fmaximum.*` | `E (<N x E>)` | Float maximum with `maximum` semantics. Any NaN element gives NaN. |
| `llvm.vector.reduce.fminimum.*` | `E (<N x E>)` | Float minimum with `minimum` semantics. Any NaN element gives NaN. |
| `llvm.vector.reduce.fmaximumnum.*` | `E (<N x E>)` | Float maximum with `maximumnum` semantics. |
| `llvm.vector.reduce.fminimumnum.*` | `E (<N x E>)` | Float minimum with `minimumnum` semantics. |

Example for `fmax` over `<sNaN, 0.0, 1.0>`: NaN, 0.0 and 1.0 are all allowed results.

## Vector partial reduction

These reduce the concatenation of an accumulator and a wider input down to the accumulator's
width. Apart from the operator, how lanes are combined is unspecified. They are meant for the
in-loop phase of a reduction; a final full reduction follows.

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.vector.partial.reduce.add.*` | `<N x E> (<N x E> %acc, <K*N x E> %in)` | Integer partial sum. `in` length is a known integer multiple of `N`. Name: `llvm.vector.partial.reduce.add.v4i32.v4i32.v8i32`. |
| `llvm.vector.partial.reduce.fadd.*` | `<N x F> (<N x F> %acc, <K*N x F> %in)` | Float partial sum. Reassociation and contraction are assumed allowed, so results may vary. |

**Not documented:** the exact lane grouping. It is unspecified by design. Note the add example
shows three suffixes while the fadd example shows two, so the mangling shown is inconsistent.

## Vector manipulation

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.vector.insert.*` | `V (V %vec, S %subvec, i64 constant %idx)` | Overwrite elements `idx .. idx+len(subvec)-1` of `vec` with `subvec`. |
| `llvm.vector.extract.*` | `R (V %vec, i64 constant %idx)` | Extract `len(R)` elements starting at `idx`. |
| `llvm.vector.repeat.*` | `<vscale x N x T> (<N x T>)` | Fill a scalable vector with `vscale` copies of the fixed vector. |
| `llvm.vector.reverse.*` | `V (V)` | Reverse lane order. Fixed and scalable. |
| `llvm.vector.deinterleave2` ... `llvm.vector.deinterleave8` (`.*`) | `{V, ..., V} (W)` | Split `W` into 2 to 8 vectors by taking every k-th lane. |
| `llvm.vector.interleave2` ... `llvm.vector.interleave8` (`.*`) | `W (V, ..., V)` | Inverse of deinterleave: merge 2 to 8 vectors lane by lane. |
| `llvm.vector.splice.left.*` | `V (V %a, V %b, i32 %offset)` | Concatenate `a:b`, shift left by `offset`, take the low half. Poison if `offset > N`. |
| `llvm.vector.splice.right.*` | `V (V %a, V %b, i32 %offset)` | Concatenate `a:b`, shift right by `offset`, take the high half. Poison if `offset > N`. |
| `llvm.stepvector.*` | `<N x iM> ()` | `<0, 1, 2, ...>`. Elements must be at least `i8`. Values that do not fit are truncated. |

Insert and extract rules:

- `idx` must be a constant multiple of the sub-vector's known minimum length. For scalable
  sub-vectors it is scaled by `vscale` first.
- A scalable vector can only be inserted into, or extracted from, a scalable vector. Fixed into
  scalable and fixed into fixed are allowed.
- If the range is out of bounds and that cannot be seen statically, the result is poison.
- For extract, `idx` must be a "vector index constant type", usually the pointer-sized integer.

The full set of interleave/deinterleave names is `interleave2` through `interleave8` and
`deinterleave2` through `deinterleave8`: 14 intrinsics. For fixed vectors with factor 2,
`reverse`, splice with a constant offset and `stepvector`, the reference recommends
`shufflevector` or constants instead.

## Vector mask

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.get.active.lane.mask.*` | `<N x i1> (iN %base, iN %n)` | Lane `i` is `(base + i) < n` (unsigned), computed with unbounded integers, so no wrap. |
| `llvm.loop.dependence.war.mask.*` | `<N x i1> (iN %addrA, iN %addrB, iN immarg %eltSize)` | Lanes safe from a write-after-read hazard (load from A, then store to B). Lane `i` is `addrA >= addrB` or `eltSize * i < addrB - addrA`. |
| `llvm.loop.dependence.raw.mask.*` | `<N x i1> (iN %addrA, iN %addrB, iN immarg %eltSize)` | Lanes safe from read-after-write and store-to-load forwarding hazards (store to A, then load from B). Lane `i` is `addrA == addrB` or `eltSize * i < |addrA - addrB|`. |
| `llvm.mask.beforefirst.*` | `<N x i1> (<N x i1>)` | Ones in all lanes before the first set lane, zeros from there on. All-zero input gives all ones. Any poison lane gives poison. |

For both dependence masks: if the distance between `addrA` and `addrB` is not a multiple of
`eltSize`, the result is poison.

## Experimental vector intrinsics

All are **Experimental:**.

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.experimental.cttz.elts.*` | `iN (<M x iK> %src, i1 constant %is_zero_poison)` | Number of trailing zero elements. All-zero gives `M`, or poison if the flag is set. Poison if `iN` is too narrow or any element is poison. |
| `llvm.experimental.get.vector.length.*` | `i32 (iN %cnt, i32 immarg %vf, i1 immarg %scalable)` | Number of elements to process this iteration (explicit vector length). See constraints below. Poison if the value does not fit. |
| `llvm.experimental.vector.histogram.add.*` | `void (<N x ptr> %ptrs, iM %inc, <N x i1> %mask)` | For each active lane, add `inc` to `*ptr`, correctly handling lanes with the same address. |
| `llvm.experimental.vector.histogram.uadd.sat.*` | `void (<N x ptr>, iM %inc, <N x i1>)` | Same, with unsigned saturating add. |
| `llvm.experimental.vector.histogram.umax.*` | `void (<N x ptr>, iM %val, <N x i1>)` | Same, storing the unsigned maximum. |
| `llvm.experimental.vector.histogram.umin.*` | `void (<N x ptr>, iM %val, <N x i1>)` | Same, storing the unsigned minimum. |
| `llvm.experimental.vector.extract.last.active.*` | `E (<N x E> %data, <N x i1> %mask, E %passthru)` | Element at the highest active mask lane, or `passthru` if no lane is active. |
| `llvm.experimental.vector.compress.*` | `V (V %value, <N x i1> %mask, V %passthru)` | Pack selected lanes to the low end in order; fill the rest from the same lanes of `passthru`. |
| `llvm.experimental.vector.match.*` | `<N x i1> (<N x T> %op1, <M x T> %op2, <N x i1> %mask)` | Lane `i` is 1 if `op1[i]` is active and equals any element of `op2`. `op2` must be fixed length. |

`get.vector.length` constraints, with `max_lanes` = `vf` (times `vscale` if `scalable`):

- `cnt == 0` gives 0.
- The result is at most `max_lanes`.
- The result is at least `ceil(cnt / ceil(cnt / max_lanes))` when `cnt` is non-zero.
- Results never increase from one loop iteration to the next.
- So the loop runs `ceil(C / max_lanes)` times, and `cnt <= max_lanes` returns `cnt`.

`vector.compress` rules: an all-zero mask returns `passthru`. Any poison mask lane makes the
whole result poison; otherwise any undef mask lane makes it all undef. If `passthru` is undef,
lanes past the selected count are undefined.

`histogram` semantics: a gather, an update (for `add`: count duplicates, multiply by `inc`,
add), then a scatter. The mask applies at least to the gather and scatter. More update kinds
may be added.

**Not documented:** the mangling of `llvm.experimental.vector.match`. The declarations show the
bare name with no suffixes.

## Matrix intrinsics

Matrices are passed as flat vectors in column-major order: element `i` of column `j` of an
`R x C` matrix is at index `j * R + i`. Shape arguments are constant `i32` values and must be
positive. Integer and floating-point elements are both supported.

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.matrix.transpose.*` | `V (V %in, i32 constant R, i32 constant C)` | Transpose an `R x C` matrix. Result has `R*C` elements. |
| `llvm.matrix.multiply.*` | `V3 (V1 %A, V2 %B, i32 constant M, i32 constant K, i32 constant N)` | `(M x K) * (K x N)`. Result has `M*N` elements; all three have the same element type. |
| `llvm.matrix.column.major.load.*` | `V (ptr %p, iS %stride, i1 constant volatile, i32 constant R, i32 constant C)` | Load `C` columns of `R` elements; column `c` starts at `p + c * stride`. `stride >= R`. |
| `llvm.matrix.column.major.store.*` | `void (V %in, ptr %p, iS %stride, i1 constant volatile, i32 constant R, i32 constant C)` | Store with the same stride rule. |

- `stride` may be any integer up to 64 bits. The offset is computed in the data layout's pointer
  index type regardless. **Not documented:** the unit of `stride`; the examples imply elements.
- `align` may be placed on `%p`.
- **Not documented:** whether row-major layout will ever be supported ("currently column-major
  is assumed"). The mangling of `transpose` and `multiply` is shown only as `.*`.

## Saturating floating-point to integer conversion

`fptoui` and `fptosi` give poison when out of range. These saturate instead.

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.fptoui.sat.*` | `I (F)` | NaN gives 0. Below 0 (including `-inf`) gives 0. Above the unsigned maximum (including `+inf`) gives the maximum. Otherwise truncate toward zero. |
| `llvm.fptosi.sat.*` | `I (F)` | NaN gives 0. Out-of-range values (including infinities) clamp to the signed minimum or maximum. Otherwise truncate toward zero. |

Any integer and float types (or vectors with equal element counts). Names put the result first:
`llvm.fptoui.sat.i32.f32`.

## Floating-point conversion

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.fptrunc.round` | `F2 (F1 %val, metadata !rounding)` | Truncate to a smaller float type with the given rounding mode. Otherwise uses the default FP environment. `"round.dynamic"` is not allowed. Not supported on all targets. |
| `llvm.convert.to.arbitrary.fp.*` | `iN (F %val, metadata !format, metadata !rounding, i1 immediate %saturate)` | Convert a native float to a small float format, returning its bits in an integer of exactly that format's width. |
| `llvm.convert.from.arbitrary.fp.*` | `F (iN %bits, metadata !format)` | Decode small-float bits into a native float. Exact widening. |

Format names: `Float8E5M2`, `Float8E5M2FNUZ`, `Float8E4M3`, `Float8E4M3FN`, `Float8E4M3FNUZ`,
`Float8E4M3B11FNUZ`, `Float8E3M4`, `Float8E8M0FNU`, `Float8E5M3FNU` (8 bits); `Float6E3M2FN`,
`Float6E2M3FN` (6 bits); `Float4E2M1FN` (4 bits). The integer width must match: `i8`, `i6`,
`i4`. For vectors this applies per element.

`convert.to.arbitrary.fp` rules:

- Rounding uses the same strings as `fptrunc.round`. It only matters if the value is not exact.
- Rounding happens first, then range handling.
- Overflow (including infinity input) with `saturate = true` clamps to the largest finite value
  of the right sign.
- Overflow with `saturate = false` gives signed infinity if the format has one, otherwise
  poison.
- NaN keeps its quiet/signalling kind; the payload is truncated or extended. If the format has
  no NaN, the result is poison.
- Unsigned formats (for example `Float8E5M3FNU`): `-0.0` becomes zero; other negatives clamp
  to the minimum with `saturate = true`, otherwise poison. A negative NaN still becomes the NaN
  encoding if there is one.
- For FP6 and FP4, producers should use `saturate = true`. With `false`, NaN, infinity or
  overflow gives poison.

`convert.from.arbitrary.fp` rules: finite values convert exactly. NaN keeps its kind. Infinity
stays infinity. A value too large for the result type (for example `Float8E8M0FNU` to `half`)
becomes signed infinity.

**Not documented:** the mangled name of `fptrunc.round`. The declaration shows no suffix,
although the result and source types must vary. The rounding-mode strings are defined in the
constrained-intrinsics section (part 2).

## Convergence, debugger, exception handling and pointer authentication

The reference only names these families here. Their members are defined in other documents.

| Family | Prefix | Defined in |
| --- | --- | --- |
| Convergence | `llvm.experimental.convergence.*` | "Convergent Operation Semantics" |
| Debugger | `llvm.dbg.*` | "LLVM Source Level Debugging" |
| Exception handling | `llvm.eh.*` | "LLVM Exception Handling" |
| Pointer authentication | `llvm.ptrauth.*` | "Pointer Authentication" |

**Not documented:** in the Language Reference. Epitome needs those separate documents to
implement these families. Convergence intrinsics are **Experimental:**.

## Trampoline intrinsics

A trampoline removes one `nest` parameter from a function. The result is a callable pointer
whose signature lacks that parameter; the stored `nest` value is spliced in when it is called.
This implements GCC nested-function addresses.

| Intrinsic | Signature | Meaning |
| --- | --- | --- |
| `llvm.init.trampoline` | `void (ptr %tramp, ptr %func, ptr %nval)` | Write executable code into `tramp`. `func` must be a constant function pointer. Calling the result is like calling `func` with `nval` as the `nest` argument. |
| `llvm.adjust.trampoline` | `ptr (ptr %tramp)` | Return the executable address for an initialised trampoline, after any target-specific adjustment. |

- `tramp` must be large and aligned enough. Size and alignment are target-specific, and LLVM
  offers no portable way to query them. The reference's x86 example uses 10 bytes, align 4.
- `func` may have at most one `nest` argument, and it must be a pointer.
- Modifying the trampoline memory after `init.trampoline` makes later calls through it
  undefined.

**Epitome note:** the front end or Epitome itself must know each target's trampoline size and
alignment; there is no IR-level query.
