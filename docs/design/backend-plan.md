# Code generation: what is left, and a plan

This is a plan for the parts of code generation after selection that are
still simple: register allocation, scheduling, and passes over machine IR.
It comes from measuring Draconian against clang. For sources and status
labels, see the [index](README.md).

## 1. Where we stand

`scratchpad`'s `gap.py` counts machine instructions per function for the C
test programs of the optimiser and the code generator:

- **clang:** clang `-O2` all the way;
- **ours:** clang's unoptimised IR (`-O1 -Xclang -disable-llvm-passes`), then
  `draconian-opt`, then `draconian-llc`;
- **backend:** clang `-O2` IR, then `draconian-llc`.

| | Instructions | Against clang |
| --- | --- | --- |
| clang | 3,085 | 1.00x |
| ours | 3,811 | 1.24x |
| backend only | 3,689 | 1.20x |

Most of the gap is in code generation. Read function by function, it falls
into these kinds, largest first:

1. **Instructions the description lacks.** Add and subtract with an
   extended register (`add x0, x1, w2, sxtw #2`), sign extension written as
   a pair of shifts, `smaddl`, `rbit` for trailing zeros, `cnt` for
   population counts, `fmov` with an immediate for float constants. Each is
   description data, and the first four are now done (see section 5).
2. **Constants made again at each use.** clang keeps a constant in a
   register for a block and uses it again. The selector now does too, per
   block.
3. **Register allocation.** Copies around calls, values kept in
   callee-saved registers when one caller-saved would do, and spills where
   rematerialising a constant would be cheaper.
4. **Peepholes clang's machine passes do.** Folding a compare with zero into
   `cbz`/`tbz` (partly done by patterns), merging loads and stores into
   pairs (`ldp`, `stp`), and removing moves that allocation left behind.

## 2. Register allocation

The allocator is linear scan over live segments. It has hints from copies,
fixed stretches for arguments, results and calls, and it spills a whole
value: a load before every use and a store after the definition.

The plan, in order of what the measurements say it gains:

1. **Rematerialisation.** A value made by one instruction from nothing
   (`movz`, `fmov #imm`, `adrp` + `add` of a global) is made again where it
   is needed instead of being spilled. The allocator only needs to know the
   instruction that defines it, which selection can record.
2. **Splitting around calls.** A value live across a call but used densely
   on one side gets a caller-saved register there and a callee-saved
   register, or a slot, across the call. Today one segment's needs decide
   the whole value.
3. **Spill weights.** When something must go to memory, the value used
   least often, weighted by loop depth, goes, not the one that happened not
   to fit. This is the next interval to take from a linear-scan allocator
   with a priority queue (as in "Linear Scan Register Allocation" and its
   successors). The weights are use counts times 10 to the power of the
   loop depth, the usual heuristic.
4. **Coalescing before allocation.** Joining a copy's two sides into one
   value when their live ranges do not overlap, rather than only hinting.
   This is what makes the moves around calls and phis disappear.

All four keep the allocator a linear scan, and each can be checked by the
existing program tests, plus a count of moves and spills on SQLite.

## 3. Scheduling

The machines we target are wide and out of order (Apple's M-series) or
small and in order (RISC-V cores, accelerators). Scheduling matters for the
second kind, and less for the first.

- **A machine model in the description.** For each instruction, its latency
  and the units it uses, as attributes (`"latency"="3"`, `"units"="mul"`).
  The numbers come from public sources, the vendors' software optimisation
  guides for the cores, and are data like the rest of the description.
- **A list scheduler, before allocation, per block.** Instructions in a
  dependence graph (registers and memory, with memory SSA's answers within
  a block), ordered by the longest latency to the block's end, with
  register pressure tracked so that it never schedules past the available
  registers. This is the classic bottom-up list scheduler.
- **After allocation**, for in-order cores, a second pass that only fills
  latency gaps, with the registers fixed.

Without a model, a scheduler has nothing to go on, so the model comes first.

## 4. Peepholes and other passes over machine IR

Rules, like the combiner's, are the natural form. A machine rule is a
pattern over a short sequence of machine instructions in a block, with
conditions on registers (dead after, same register) and a replacement:

```text
# A compare with zero and a branch on equality: one instruction.
cbz:      cmp(x, 0); b.eq(^l) -> cbz(x, ^l) if flags_dead
# Two loads from neighbouring slots: a pair.
ldp:      ldr(a, [p, #k]); ldr(b, [p, #k+8]) -> ldp(a, b, [p, #k]) if k % 8 == 0 && a != p
# A move to itself.
self_mov: mov(x, x) -> ()
```

Instruction names come from the description, so the rules belong with it:
one file of machine rules per target, matched with the same discrimination
tree as the combiner, over windows of machine instructions. Each rule
application is an autochop step.

Other passes worth having, each small:

- **Block placement.** Order blocks so that the likely successor falls
  through. Loops are the main case: put the latch at the bottom, and so
  avoid a branch per iteration.
- **Load and store pairs**, outside the frame code, which already uses them:
  the `ldp`/`stp` rule above, applied after allocation.
- **Copy propagation and dead instructions after allocation**, for what
  allocation and frame lowering leave behind.
- **Shrink wrapping.** Put the prologue on the paths that need a frame
  only, so that early returns skip it.

## 5. Done so far, from the measurements

- **The description:** add and subtract with an extended register for every
  extension and shift (`15-extend.ll`, written by `gen_extend.py`); sign
  extension written as shifts; `smaddl`, `umaddl`, `smsubl`, `umsubl`;
  `rbit`, with trailing zeros as `clz` of the reversed bits; `fmov` with an
  8-bit floating-point immediate (`fp8s`, `fp8d` in encodings, `{c:f64}` in
  assembly).
- **Selection:** a constant made in a block is reused by later uses in the
  same block.
