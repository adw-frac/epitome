# Common-subexpression elimination

CSE replaces an instruction that computes what a dominating instruction
already computed. It is in `opt/src/cse.rs` and runs in the pipeline after
the combiner, on each function. For sources and status labels, see the
[index](README.md).

## Keys

Each instruction gets a key, built so that instructions computing the same
value get the same key:

- the opcode and the attributes that change the result: a comparison's
  predicate, a cast's kind, `extractvalue` indices, a shuffle's mask;
- the result type;
- the operands, after the replacements made so far. Once `%b` is known to
  be `%a`, `add %b, 1` has the same key as `add %a, 1`, so equivalence
  carries through chains.

The keys are hashed into a table, so finding an earlier equal instruction
costs one lookup.

Keys are made canonical where an operation has more than one way to be
written:

- the operands of commutative operations (`add`, `mul`, `and`, `or`, `xor`,
  `fadd`, `fmul`) are sorted, so `a + b` and `b + a` match;
- comparisons put the smaller operand first and swap the predicate to suit,
  so `icmp sgt %x, %y` and `icmp slt %y, %x` match;
- phis in the same block match when they have the same entries, in any
  order.

Flags are not part of the key: `nsw`, `nuw`, `exact`, `disjoint`, `nneg`,
`samesign`, `inbounds`, and fast-math flags. When two instructions merge,
the one kept keeps only the flags both had. Its own stronger flags might
make poison where the other did not.

## Scope

The table is scoped by the dominator tree. The pass walks the tree in
preorder, adds each block's keys, visits the blocks it dominates, and then
takes its keys out again. A key is visible only in blocks its instruction
dominates, so a replacement always dominates what it replaces, and
computations in sibling branches are never merged.

Uses the walk cannot reach in order, such as phi entries along loop back
edges, are rewritten in one pass at the end. Debug records follow the
replacements.

## Loads

A load can reuse the value of an earlier load of the same address and
type, or the value an earlier store wrote there, as long as nothing in
between may have changed those bytes.

The pass keeps a log of the instructions on the current dominator path
that may write memory: stores, atomics, fences, `va_arg`, volatile or
atomic loads, and calls not known to be read-only. When a load finds a
remembered value, [alias analysis](aa.md) is asked whether any write
logged since then may modify the load's location. A store to another
object, or a call that cannot reach the location, does not stop the reuse.
Entering a block that can be reached other than from its dominator adds an
"unknown" entry to the log, which nothing gets past, since another path in
may have written. After 64 logged writes, the pass stops checking and
assumes the value is gone.

Volatile and atomic loads are never reused.

## What is never merged

- `freeze`: two freezes of the same poison may give different values.
- Calls, even to functions that read no memory. **Open:** merging calls
  marked `memory(none)` that are also `willreturn` and `nounwind`.
- Allocas, which each make a new object.

## Effect

On the test programs built without optimisation, which keep every local
in memory, CSE reuses 10 to 65 loads and forwards 65 to 136 stored values
per program; before alias analysis it was 10 to 49 and 36 to 56. That is
part of what `mem2reg` would do. On clang `-O2` output there is little
left to find.

On the 50,000-function synthetic module, CSE alone takes 306 ms on one
thread (83 ms on eight) for about 1 million instructions. After CSE, the
combiner runs again, but only from the instructions whose operands CSE
changed, since only those can combine further.

## Next

`gvn` would add partial redundancy (a computation available on some paths
into a block) and loads across blocks with more than one way in, given
memory dependence analysis.
