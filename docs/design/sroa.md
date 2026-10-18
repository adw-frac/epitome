# SROA

Scalar replacement of aggregates splits an alloca into one alloca per
independently used piece, so that [mem2reg](mem2reg.md) can promote the
pieces. It is in `opt/src/sroa.rs` and runs just before mem2reg. For
sources and status labels, see the [index](README.md).

## Why

mem2reg only promotes an alloca that is loaded and stored whole, at its
own type. Real code uses structs and arrays a field at a time, through
`getelementptr`, copies them with `memcpy`, clears them with `memset`, and,
on many targets, passes small structs in integer registers: the front end
stores a returned `{ i32, i32 }` as one `i64` and reads its fields as
`i32`s. SROA turns all of these into loads and stores of whole, separate
allocas.

`opt/tests/examples/sroa.ll` has one function for each case.

## Steps

1. **Aggregate accesses are split.** A load or store of a whole struct or
   array (up to 16 elements) through an entry-block alloca becomes one
   access per element, with `extractvalue` for stores and an
   `insertvalue` chain for loads, repeated for nested aggregates.
2. **Accesses are collected.** From each fixed-size entry-block alloca,
   the pass follows `getelementptr`s with constant indices and `bitcast`s,
   and records every plain load and store as a byte range. `memcpy`,
   `memmove` and `memset` with a constant length are recorded as copies
   and fills. Any other use (a call, a variable index, a stored address, a
   volatile access) leaves the alloca alone. So does a copy with the
   alloca on both sides.
3. **Partitions.** Overlapping loads and stores merge into partitions,
   pieces of the alloca used independently. Bytes nothing loads or stores
   are dropped. A copy or fill must take whole partitions. A copy out of
   the alloca must also have every byte it reads in some partition, or
   those bytes would be lost.
4. **Each partition gets an alloca:**
   - *Uniform*: every access covers the whole partition. The new alloca
     has the accessed type. Integer and float accesses of the same size
     share an integer type, with `bitcast`s at the floats.
   - *Packed integer*: some accesses cover only part of the partition, all
     integers or floats, and the partition is at most 128 bits. The new
     alloca is one integer that wide. A narrower load shifts and
     truncates; a narrower store masks and merges. The shifts follow the
     data layout's byte order.

   If any partition fits neither, the alloca is left as it is.
5. **Accesses are rewritten.** Loads and stores point at the new allocas,
   with their alignment reset to the type's own, since the old one may be
   more than the new alloca has. A copy in becomes, for each partition, a
   load from the source at the matching offset and a store into the piece;
   a copy out, the reverse; a fill, a store of the repeated byte (zero for
   any type, other bytes for integers and floats). Accesses on the far
   side of a copy say `align 1`.
6. **Repeat.** Splitting one alloca can turn a copy from another into
   plain loads, so the pass goes round again (up to four times) while
   anything changes. An alloca that is only ever written is deleted with
   everything that writes it.

## Debug information

Debug records that described the old alloca become `poison` (optimised
out). **Open:** describe each piece with a `DW_OP_LLVM_fragment`
expression instead, so a debugger can still show the variable.

## Effect

On `opt/tests/programs/aggregates.c`, built by clang without its own
passes:

| | Instructions | Loads and stores | Allocas |
| --- | --- | --- | --- |
| Input | 321 | 130 | 36 |
| Without SROA | 198 | 60 | 19 |
| With SROA | 115 | 1 | 1 |
| LLVM `-O2` | 40 | 0 | 1 |

The one alloca left is a buffer passed to `snprintf`. Most of the
remaining gap is the shifts and masks of packed integers: a value packed
into an integer and read straight back out leaves a chain like
`trunc(lshr(or(shl(zext x, 32), ...), 32))`, which is just `x`. Proving that
needs a known-bits analysis in the combiner (**Open**).
