# Autochop

Autochop counts every elective change the compiler makes to the code, so
that a miscompilation can be found by binary search to the one change that
causes it. The idea, and the name, come from a compiler for the PS3. The
counter is in `ir/src/chop.rs`; both `epitome-opt` and `epitome-llc`
use it, and `epitome-chop` runs the search. For sources and status
labels, see the [index](README.md).

**Status:** counting, limits, the search and its driver, every optimiser
pass, and code generation's elective choices: **Done**.

## 1. Steps

A *step* is one elective change: a rule applied, a value merged, a call
inlined, a pattern chosen. Before making one, a pass asks
`chop::allow(|| description)` and goes ahead only if the answer is yes.
Mandatory work, such as legalising, lowering, register allocation and
frames, never asks.

The description is a closure. It is called only for the step a limit stops
at, so counting costs an increment, and a description may be expensive.
Naming a value as the printer would, for example, numbers the whole
function.

A refused step must leave the code correct. In the combiner, a rule's
replacement is built and type-checked first, then the step is asked for;
if it is refused, what was built is undone, as for a replacement that does
not type-check. So every step counted is a change made.

| Where | One step |
| --- | --- |
| Combiner | a rule (including the memory rules), a fold (including a load from a constant global), a chain reassociated, a load reused, a dead store deleted, a dead instruction removed, a constant moved to the right, a branch or switch folded |
| CSE | an instruction merged into an earlier one, a load reusing a value |
| `mem2reg`, SROA | an alloca promoted, split, or removed (only ever written); an aggregate access split |
| `simplifycfg` and the CFG clean-ups | an empty block bypassed, a branch to one block made plain, a diamond turned into selects, a block merged into its predecessor, unreachable blocks removed |
| Inliner | a call inlined |
| Recursion removal | a function's recursion removed; a cycle collapsed |
| Loops | a loop rotated; an instruction moved out of a loop (`licm`); a counter simplified (`indvars`); a counter reduced (`loop-reduce`) |
| `memcpyopt` | a run of stores made a memset |
| Pipeline | an unused function deleted |
| Code generation | a pattern covering several instructions chosen where one covering only the root would do (a load folded into an operation, a post-increment); a division by a constant done with a multiply; a tail call (`musttail` is mandatory); a constant or address hoisted out of a loop; an address sunk into a block that loads or stores through it; a small memset or memcpy written out |

## 2. Limits

Functions with bodies are numbered in module order, from 0, and each
function counts its own steps. The limit `F:T` lets:

- functions before `F` make every step;
- function `F` make its first `T` steps;
- functions after `F` make none.

`F` alone means `F:0`.

The count for the function being worked on lives in a thread-local, which
whoever runs passes on a function installs (`Session::enter`). Passes need
no extra arguments. A function's count depends only on its own work, never
on which thread did it or when, so a limit means the same thing on any
number of threads. The tests check this: counts, and the code under every
limit tried, are the same on 1 thread and 8.

Both tools take `--chop=F[:T]` or an environment variable,
`EPITOME_OPT_CHOP` or `EPITOME_LLC_CHOP`, so that a limit reaches a
tool run deep inside a build. Each reports where it stopped and what the
last step allowed was:

```text
; chop: stopped in @seven (function 3) after step 1: combine bad_mul7 at %3
```

`--chop-counts` prints each function's count. With `EPITOME_CHOP_COUNTS`
set to a file, the counts are appended to it; with `EPITOME_CHOP_DUMP`,
the output (IR, or assembly) is written to that file.

## 3. The search

`chop::search` takes each function's count and a test, and finds the first
failing step in two binary searches:

1. **Over functions.** With "the first `k` functions every step, the rest
   none", the test passes at 0 and fails at all of them.
2. **Over the steps of the function found.**

A function may make more steps than its count from the full run says.
When the functions after it are held back, it inlines their unoptimised
bodies, which bring more to do. So the top of the second search is doubled
until the test fails, then bisected.

The search assumes that what fails with some steps also fails with more.
That holds when steps are independent. When they are not, the answer is
still a limit that fails while the one before it passes, and the driver
checks that again.

`epitome-chop [--tool=opt|llc] -- <test command>` runs it. Exit status 0
from the test is a pass. The driver gets the counts from one full run,
searches, and then prints the step, the limit, and what the step changed
in the output:

```text
The first failing change: function 0 (@main), change 36 (30 in all with no limit)
  @main (function 0) after step 36: combine bad_mul7 at %29
  limit: EPITOME_OPT_CHOP=0:36 fails, 0:35 passes (14 runs of the test)

What it changed in the output:
    %28 = mul nsw i32 %4, 5
-   %29 = mul nsw i32 %4, 7
+   %29 = shl i32 %4, 3
    %30 = add nsw i32 %28, %29
```

There, a wrong rule was planted (`--rules=` adds rules before the standard
ones). `@seven` uses it, but `@main` inlines `@seven`, so the change was
found in `@main`'s copy. The same search on `epitome-llc`, with a bug
planted in division by 7, found it at `@c`'s first choice, `divide by 7
with a multiply`, in 9 runs.

## 4. Checks

- **`ir/src/chop.rs`'s own tests:**
  - limits and counting;
  - the search finding a step;
  - the search finding a step past a function's full count.
- **`opt/tests/chop.rs`:**
  - counts and outputs are the same on 1 and 8 threads, at limits on
    every function boundary and half-way through each function;
  - `0:0` changes nothing;
  - a search, building and running the program with clang at each step,
    finds a planted wrong rule.
- **`codegen/tests/chop.rs`:**
  - every C test program at `-O0` and `-O2` still runs correctly with no
    elective choices at all, and with each function stopped half-way, so
    each elective choice has a correct fallback;
  - code and counts are the same on 1 and 8 threads.

## 5. What it found

Counting every change meant reading every pass again, which turned up
several things that took time growing with the square of a function's
size. Each is now linear, and `opt/tests/scaling.rs` checks them (see
[parallel](parallel.md)):

- **Dominance** was asked by walking up the dominator tree, as deep as a
  chain of diamonds is long. It is now answered from intervals of a
  depth-first walk.
- **`simplifycfg`** turned diamonds into selects one at a time, from the
  top again after each, with a sweep of the function per phi. It is now
  one walk with one sweep.
- **Block merging** started from the top again after each merge. It is now
  one walk that keeps predecessors up to date.
- **The inliner** swept the whole function for each call inlined
  (replacing the call's uses, debug records, finding the call's block and
  its place in the layout). The sweeps are now one at the end, and the
  layout is a linked list while it works.
- **Fresh names** tried `name1`, `name2` and so on from 1 every time, so
  the 10,000th copy of `small.exit` tried 10,000 names. The search now
  starts where the last one stopped.
- **`split_block`** left each head of a split with the whole block's
  capacity. 128,000 splits of one block kept tens of gigabytes reserved.
- **SROA** looked up an instruction's block by building the map again for
  each aggregate access.

**Open:** inlining many calls in one block still copies the rest of the
block at each call. That is about n²/2 instruction ids moved: 0.9 s at
128,000 calls in one block, and nothing measurable below 16,000. Avoiding
it needs either inlining a block's calls from last to first, which changes
the inliner's decisions, or a different representation of a block's
instructions.
