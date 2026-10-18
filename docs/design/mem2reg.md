# mem2reg

`mem2reg` turns local variables that a front end put in memory into SSA
values. It is in `opt/src/mem2reg.rs`. For sources and status labels, see
the [index](README.md).

## What it does

Front ends give each local variable an `alloca` and turn every read into a
`load` and every write into a `store`. For each alloca that qualifies, the
pass makes each store a definition of the variable and each load a use of
the definition that reaches it, adding phis where paths with different
definitions meet. The alloca, its loads and stores, and its lifetime
markers go.

```llvm
; before                              ; after
entry:                                entry:
  %s = alloca i32                       br label %cond
  store i32 0, ptr %s                 cond:
  br label %cond                        %s = phi i32 [ 0, %entry ], [ %add, %body ]
cond:                                   ...
  %sv = load i32, ptr %s              body:
  ...                                   %add = add i32 %s, %i
```

`opt/tests/examples/mem2reg.ll` has a loop, an if/else, several stores in
one block, a path with no store, and allocas that must stay.

## Which allocas

An alloca is promoted when:

- it is in the entry block and allocates one value;
- it is in address space 0;
- every use is a plain (not volatile, not atomic) load or store of the
  allocated type through the alloca itself, or a lifetime marker.

Anything else (an offset into it, passing it to a call, storing its
address, a load of another type) means the memory could be reached some
other way or is not one value, so the alloca stays. [SROA](sroa.md) runs
first and splits aggregates and mismatched accesses into promotable
pieces.

## How

The SSA updater (`ssa::SsaUpdater`, the method of Braun et al.) does the
work:

1. Each block's last store to the variable is its definition at the end of
   that block.
2. Walking each block in order, a load takes the latest store before it in
   the same block, or otherwise the value at the block's entry. The updater
   asks the predecessors for that value, adding a phi where they differ.
3. Phis that turn out to have a single value are removed.

A path with no store gives `undef`, which is what a load from
uninitialised memory gives. A store before `llvm.lifetime.start` may reach
a later load that would otherwise read uninitialised memory; that value is
one of those `undef` allows, so dropping the markers is sound.

## Debug information

A `#dbg_declare` describing a promoted alloca becomes a `#dbg_value` after
each store, describing the stored value. Other debug records naming the
alloca become `poison` (optimised out). **Open:** also add `#dbg_value` at
the phis the pass creates, where the variable's value changes too.

## In the pipeline

mem2reg runs first on each function, so every later pass sees SSA values,
and again on functions that had calls inlined into them: inlining often
makes an alloca promotable, because the callee that took its address is
now part of the caller.

On the test programs built by clang without its own passes, with
`opt/tests/programs`:

| Program | Input | Ours without mem2reg | Ours with mem2reg | LLVM `-O2` |
| --- | --- | --- | --- | --- |
| recursion | 949 instructions, 451 loads and stores | 735, 257 | 427, 69 | 459, 61 |
| inlining | 320, 165 | 466, 189 | 186, 4 | 124, 4 |

With the variables in SSA form, the default recursion mode now finds 9 tail
calls and 3 accumulator calls in the recursion program, where it found none
before.
