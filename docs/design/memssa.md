# Memory SSA

Memory SSA treats memory as one SSA variable, so that "the last write
before this load" is an edge to follow rather than a search. It is the
analysis that dead-store elimination, load forwarding across blocks,
`memcpyopt`, and `licm` for loads need. The plan is for the combiner to
match on these edges, as on any other operand (see [combines](combine.md)).
The code is in `opt/src/memssa.rs`. The form follows LLVM's
[MemorySSA](https://llvm.org/docs/MemorySSA.html) document. For sources and
status labels, see the [index](README.md).

**Status:** the form, the on-demand walker, a printer, and its users (the
combiner's memory rules and steps, `licm`): **Done**. Keeping the form up to
date as passes change the function: **Later** (it is built for each run,
and passes' edits only make its answers more cautious; see the combiner's
`Memory`).

## 1. The form

| Access | What it is |
| --- | --- |
| `MemoryDef(prev)` | An instruction that may write memory, defining a new version from `prev`: stores, calls that may write, `memcpy`/`memset`/`memmove`, lifetime markers, atomics, fences, `va_arg`, and volatile loads and stores, which are ordered as writes. |
| `MemoryUse(def)` | An instruction that only reads memory: loads, and calls that only read. |
| `MemoryPhi({pred, v}, ...)` | The version at the start of a block where paths with different versions meet. |
| `liveOnEntry` | The memory the function is called with. |

Debug intrinsics, `llvm.assume`, `noalias.scope.decl` and calls that touch
no memory are not accesses. What an instruction may do at all, whatever the
location, comes from alias analysis (`BasicAa::effects`). A call's effects
come from its `memory(...)` attributes and those of the callee's published
body, as `mod_ref` uses them.

Building the form is one walk in reverse postorder, so it is linear in the
function's size:

1. A block's first version is the entry's `liveOnEntry`, or the last
   version of its only predecessor, which reverse postorder visits first.
   Otherwise it is a new phi.
2. Each access in the block takes the current version, and a definition
   makes a new one.
3. The phis' entries are filled in from each predecessor's last version.
4. Phis whose entries are all one version, or themselves, are removed, as in
   Braun et al.'s SSA construction (see `ssa.rs`). A worklist re-checks only
   the phis that used a removed one, and every reference is redirected
   through a union-find with path compression.

## 2. Clobbers, on demand

The versions say nothing about locations: a store to `%a` is the version a
load of `%b` uses even when the two cannot alias. The write that can
actually change a load's bytes, its *clobber*, is found only when someone
asks (`Walker::clobber`, `clobber_of`). The walker:

- starts at the access's version, and walks up past each definition that
  alias analysis says cannot write the location (`mod_ref`);
- at a phi, walks every way in. If every way in reaches the same write,
  that write is the clobber. If they reach different writes, the phi itself
  is. A way back into the phi, a loop that writes nothing that matters,
  adds nothing;
- goes up through a phi only if the location's pointer is the same on every
  way in, meaning it is a constant or argument or is defined in a block
  that strictly dominates the phi's block. Otherwise it stops at the phi.

  Without that rule, going round a loop would compare a pointer with itself
  as it was in the previous iteration. That is the same SSA value but
  another address, and alias analysis would call it a must-alias.

  A join without a phi needs no such check: it has one version on every
  way in, and a loop that contains a write always has a phi at its header.

The answer is a `Clobber`: the write, the phi, or `liveOnEntry`, and whether
it is exact.

### Bounded costs

- **A budget per question.** Each question may make at most `Walker::BUDGET`
  (64) alias queries, counting each phi visited as one. When the budget runs
  out, the walk stops where it is and answers that access, marked not exact.
  That is still safe: something that may clobber. A long chain of unrelated
  writes, as in a big block, costs at most the budget per question.
- **A cache.** Answers are kept by (version, location). So is a phi's answer
  when its exploration did not run out of budget and never came back to a
  phi further up, because then it is the same however the phi was reached.
  Paths that meet again therefore do not explore it again. Without this, a
  chain of diamonds costs twice as much per diamond it passes; with it, one
  query per question.
- **Decompositions remembered.** Alias analysis now keeps each pointer's
  decomposition (base, offset, scaled terms) once worked out. A walk asks
  about the same few pointers many times.

| Input | Accesses | Clobber questions | Alias queries | Gave up | Build | Walks |
| --- | --- | --- | --- | --- | --- | --- |
| SQLite, clang `-O2` | 35,473 defs, 42,236 uses, 11,297 phis | 61,881 | 78,380 | 101 | 14.0 ms | 23.2 ms |
| SQLite, clang `-O0` | 46,433 defs, 91,150 uses, 10,249 phis | 123,836 | 564,011 | 7,055 | 13.3 ms | 61.1 ms |
| One block of 64,000 loads and stores through two pointers that may alias | 25,799 defs, 38,201 uses | 64,000 | 123,858 | 0 | 1.6 ms | 12.2 ms |
| A chain of 16,000 diamonds | 32,001 defs, 32,001 uses, 16,000 phis | 64,002 | 64,003 | 0 | 7.0 ms | 12.3 ms |

Times are on one thread, asking for every load's and store's clobber. The
generated inputs take time in proportion to their size: each doubling
doubles it. At `-O0` every local is in memory, so chains of stores are
long and about 6% of questions run out of budget. The pipeline runs
`mem2reg` first, which removes most of those chains.

## 3. Printing

`epitome-opt --print-memssa` prints the module with each access as a
comment before its instruction, and phis after the block's label. For each
load and store it adds the clobber, found by the walker:

```llvm
join:                                             ; preds = %else, %then
  ; 4 = MemoryPhi({%then,3},{%else,2})
  ; MemoryUse(4) -- clobbered by 4
  %v = load i32, ptr %p
  ; MemoryUse(4) -- clobbered by 1
  %u = load i32, ptr %n
```

Here `%p` was written on both arms, so the phi is its clobber. `%n` is a
`noalias` argument, so the walk goes past the phi to the store before the
branch. With `--passes=` and no passes, it prints the analysis of the input.
`--stats` adds the counts and times above.

The analysis runs on every function at once. All the bodies are published
first and only read, because alias analysis reads callees' published
bodies. If a callee were published or not depending on which thread got
there first, the answers would depend on timing.

## 4. Checks

`opt/tests/memssa.rs`:

- **Soundness, by brute force.** For every load and store, a search
  backwards over the CFG, which knows nothing of memory SSA, follows every
  path from the access. Each path must reach the clobber the walker gave.
  It must not pass a write that alias analysis says may touch the location,
  and it must not go up through a memory phi where the pointer is not the
  same on every way in. This runs on a hand-written example, 300 random
  functions (loops, joins, pointers that may and may not alias, opaque
  calls), and every C test program of the optimiser and code generator at
  `-O0` and `-O2`. With the dominating-pointer rule removed from the
  walker, it fails on both the random functions and a C program.
- **The printed form** of the example (`tests/memssa/demo.ll`) matches
  `demo.expected.ll`; `BLESS=1` updates it.
- **Costs.** A big block, a chain of diamonds and deeply nested loops must
  take less than ten times as long at four times the size. No question may
  make more alias queries than its budget.

## 5. Next

- **Updates as passes change the function.** For now the form is built
  fresh, which is linear and cheap enough to repeat after a batch of edits.
- **Cheaper walks in unoptimised code:** skipping writes to allocas whose
  address never escapes, without asking alias analysis about each one.
