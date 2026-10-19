# Alias analysis and data layout

Alias analysis answers two questions for other passes:

- can two memory accesses touch the same bytes (`BasicAa::alias`)?
- can an instruction read or write a given location (`BasicAa::mod_ref`)?

It is in `opt/src/aa.rs`. It needs the sizes of types, which come from the
data layout, in `ir/src/layout.rs`. For sources and status labels, see the
[index](README.md).

## Data layout

`DataLayout::parse` reads `target datalayout = "..."` on top of the default
values the Language Reference lists (summarised in `docs/llvm-ir`, section
12.2). It provides:

- `size_in_bits`, `store_size` (the bytes a store writes), and
  `alloc_size` (the store size rounded up to the ABI alignment, which is
  the step between array elements and what `getelementptr` multiplies by);
- ABI and preferred alignments;
- struct layouts: each field at the next multiple of its alignment, the
  struct's alignment is its largest field's (at least the aggregate
  alignment), and its size is rounded up to that. Packed structs have no
  padding and alignment 1;
- pointer size, alignment and index width per address space.

An integer width with no entry of its own uses the smallest wider entry,
or else the widest, as the reference says. Where the reference is silent,
for vector and float widths with no entry, Draconian aligns to the size
rounded up to a power of two.

## Alias rules

A pointer is traced back through `getelementptr` and `bitcast`, both
instructions and constant expressions, to the value it is based on. Along
the way, constant indices give a byte offset and variable indices give
terms `index × element size`. An index `x + C` counts as `x` plus `C`
elements when the addition cannot wrap differently from address
arithmetic: it is as wide as the index type, or it is `nsw`.

Two locations do not alias if:

- they have the same base and the same variable terms, and their byte
  ranges do not overlap. `a[i]` and `a[i + 1]` are 4 bytes apart for any
  `i`;
- they are based on different identified objects: allocas, globals,
  results of calls marked `noalias` (allocators), and `noalias` or `byval`
  arguments;
- one is based on an alloca, a `noalias` allocation or a `noalias`
  argument whose address never escapes the function, and the other is
  based on anything else. Every pointer to such an object leads back to it
  through offsets, so a pointer with another base points elsewhere;
- one is null: nothing may be accessed through null in address space 0.

They *must* alias if they start at the same address, and *partially*
alias if the ranges overlap but start apart. Otherwise the answer is *may
alias*.

An object's address escapes if it is used other than as the address of a
load or store, as the base of a `getelementptr` or `bitcast` (whose results
are followed in turn), or by a lifetime marker. Storing it, passing it to a
call, comparing it, putting it in a phi or select, or returning it all
count as escaping.

These rules follow the reference's pointer aliasing rules: memory may only
be accessed through a pointer based on the object it belongs to.

## Calls

`mod_ref` answers for loads, stores and calls; anything else touches no
memory, apart from atomics, fences and `va_arg`, which count as reading and
writing everything.

For a call:

- no call can reach an alloca or allocation whose address never escapes;
- `memory(...)` on the call and on the callee, and the older `readnone`,
  `readonly`, `writeonly` and `argmemonly`, give what it may do to memory
  through its pointer arguments and to everything else. Both apply, so
  they are intersected. `inaccessiblemem` and target state cannot be a
  location in this module, and are ignored; `errnomem` counts as other
  memory;
- argument memory counts only if the location may alias one of the
  call's pointer arguments;
- lifetime markers count as writing their object, so nothing is carried
  across them;
- `memcpy` and `memmove` write their destination's bytes and read their
  source's, and `memset` writes its destination's, the length being the
  size when it is a constant. Volatile ones are ordinary calls.

`effects` gives what an instruction may do to memory at all, whatever the
location, which is how [memory SSA](memssa.md) decides what is a write and
what is a read.

Each pointer's decomposition (base, constant offset, scaled terms) is
worked out once per function and kept, since walks ask about the same
pointers many times. A pointer's address never changes: an SSA value is
defined once, and a pass that replaces an operand puts an equal value in
its place.

A `noalias` argument that does not escape is treated as reachable only
through itself for the function's own accesses, but not for calls: its
guarantee concerns pointers not based on it, and a callee given another
pointer to the same memory may still read it.

## Users

CSE asks `mod_ref` for every write between a remembered load or store and
a later load of the same address (see [CSE](cse.md)). With it, CSE on the
unoptimised test programs reuses or forwards about twice as many values as
before.

## Next

- `sroa`, which splits allocas that `mem2reg` cannot promote whole.
- Dead-store elimination, which needs the reverse question: is a store
  overwritten before anything reads it?
- Variable terms that differ by a known amount (`a[i]` and `a[j]` with
  `j = i + 2` computed elsewhere), phis and selects of pointers, and type
  metadata (`!tbaa`).
