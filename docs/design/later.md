# Correct, but not yet good

Code generation that gives the right answers the long way. Each entry says
what it does now, where, and what would be better. Correctness comes
first (see [the plan](backend-plan.md) for the measured gap to clang);
these are for after.

## Through memory

- **Bitcasts no register holds whole** (`prepare.rs`, `vector_int_bitcasts`):
  a 128-bit vector and `i128`, vectors narrower than a register, vectors
  wider than one and their integers go through a stack slot, a store and
  a load. Better: lane moves (`fmov x0, d0; mov x1, v0.d[1]` for
  `<16 x i8>` to `i128`), and the planned bit maps of
  [the combiner](combine.md#bit-maps-planned) for the rest.
- **Lanes chosen by a variable** (`prepare.rs`, `variable_lanes`): the
  vector is stored and the lane loaded (or stored and the vector reloaded).
  Better: `tbl` with an index vector for bytes, or a compare-and-select.

## Lane by lane

- **Shuffles with no single instruction** (`legalize.rs`): built from
  `umov`/`ins` a lane at a time; a full reversal of `<4 x i32>` is eight
  moves. Better: decompose into two table shuffles (`rev64` then `ext`),
  or `tbl` with a constant mask.
- **Vector bit counts of lanes wider than a byte** (`ctpop`, `ctlz`,
  `cttz`, `bswap` of `<2 x i64>`, `<4 x i32>`): a scalar instruction per
  lane. Better: `cnt` then `uaddlp` steps for `ctpop`, NEON `clz` for
  `ctlz`, `rev` for byte swaps.
- **Masks to integers** (`bitcast <16 x i1> to i16`): `umov` and a shift
  per lane. Better: `and` with a lane-weight vector and `addv` (the
  movemask idiom).
- **Masks of more than 64 lanes and their integers** (`prepare.rs`,
  `wide_mask_bits`): through bytes, a sign extension, shuffles of 64
  bytes and a comparison with zero again for each 64 lanes. Better: the
  movemask idiom on the mask's own parts.
- **Vector floating-point reductions** (`fmax`, `fmin`): a scalar `fmaxnm`
  per lane. Better: `fmaxnmp`/`fmaxnmv`.
- **Vector saturating conversions** (`fptosi.sat` of vectors): a scalar
  `fcvtzs` per lane. Better: vector `fcvtzs`, then `sqxtn` to narrow.
- **Integer vectors to narrower floats** (`uitofp <2 x i64> to <2 x
  float>`, `legalize.rs`, `rewrite_vector_ops`): a scalar `ucvtf` per
  lane, as clang does. Better, where the integers are known to fit in 53
  bits: `ucvtf .2d` then `fcvtn`.
- **Vector intrinsics with no instruction** (`prepare.rs`, the catch-all
  in `expand_intrinsics`): a scalar call per lane; around C library calls
  (`sin` of `<2 x double>`) the vector is spilled and reloaded for each
  lane. Better: keep lanes in callee-saved registers, or call the vector
  library (`_simd_sin_d2` on Darwin) where there is one.
- **Integer vectors' lanes as 128-bit values** (`wide_vectors.rs`): every
  operation lane by lane, each lane two halves.

## Extra instructions

- **128-bit atomics** (`atomics.rs`, `library_atomic`): calls of the C
  library's generic functions, the values through stack slots, and a
  loop of them for a read-modify-write. Better, as clang does on AArch64:
  `ldp`/`stp` (FEAT_LSE2) and `casp` loops, or `ldaxp`/`stlxp`.

- **Half precision** (`prepare.rs`, `half_as_int`, `half_arith`): halves
  live as the i16s of their bits in integer registers, and every
  operation moves them to a floating-point register, widens to float,
  computes, narrows and moves back (`fmov w0, s0` then `fmov s0, w0`
  between two). Better: an `h` register class, and FEAT_FP16's own
  arithmetic where the CPU has it; vectors with `fcvtl`/`fcvtn` rather
  than lane by lane.
- **Fused multiply-adds of halves** go through `double`: the product is
  exact, but the sum is rounded to double before half, which is almost
  always the half the fused operation gives, not always.

- **Splats of a constant mask, and negated masks** (`legalize.rs`,
  `mask_constants`, `vector_fcmps`): a comparison against zero to make a
  mask of the right lane width (`cmtst` of a `dup`), where a `movi` of the
  constant would do.
- **Unordered vector comparisons**: the ordered one, then inverted as
  integers (extend, `eor`, compare). Better: `mvn` of the mask.
- **A select by one boolean**: the boolean splatted, extended, compared,
  then `bsl`. Better: `dup` of the extended boolean straight into `bsl`.
- **Inline assembly operands in another register file** (`isel.rs`,
  `emit_asm`): a copy in, and the result copied out (`fmov s1, s0`), where
  allocation could place them there.
- **Chains of copies** (`regalloc.rs`): a value copied from one virtual
  register to another and on (an aggregate's parts taken by
  `extractvalue`s) keeps the copies, a dead one included, where
  coalescing them would leave none. `aggregates.rs` leaves wide integers'
  `[2 x i64]` halves whole for this reason.
- **Vector arguments no register holds** (`prepare.rs`,
  `vector_arguments`): put together from their parts by shuffles at the
  callee's entry and taken apart by shuffles at each call, where a split
  vector's parts are already the registers; legalisation may not see
  through them.
- **Struct results and phis** of fields: copies between result registers
  and their vregs that coalescing could remove (`mov x2, x0; mov x0, x1;
  mov x1, x2`).
- **`fptosi.sat` to narrow integers**: the generic compare-and-select
  expansion; `fcvtzs` to 32 bits then a saturating narrow (`sqxtn`) would
  do.
- **`llvm.is.fpclass`**: a comparison per class, or-ed. Better: `fcmp`
  and flags for the common masks (NaN, infinity, zero).
- **ELF thread-local variables** (`prepare.rs`, `thread_locals`): always
  by descriptor (TLSDESC), a call per access, whatever the variable's
  model says; a linker relaxes it in a program, but not to nothing.
  Better: `localexec`/`initialexec` as their models ask (`tprel` adds,
  a GOT load), and one descriptor call per variable per function.
- **Zero-initialised ELF thread-local variables** (`asm.rs`): in `.tdata`
  as zeros, where `.tbss` would count them.
- **Dead stripping** (`macho.rs`, `asm.rs`): objects are written without
  `MH_SUBSECTIONS_VIA_SYMBOLS` (assembly without
  `.subsections_via_symbols`), so the linker keeps all of each object
  where it could keep only what is reached. Setting it needs
  `@llvm.used`'s globals marked `N_NO_DEAD_STRIP` (`.no_dead_strip`).
  (clang's assembler on our assembly, without it, trips an assertion in
  Apple's linker for a section of a name of its own.)
- **Branch relaxation** (`layout.rs`, `relax`): the positions are found
  again after each branch changed, which is quadratic in a function with
  many far branches. Better: one pass, adjusting the positions after the
  change.
- **`llvm.global_ctors` priorities on ELF**: one `.init_array` in
  priority order within the object, where `.init_array.N` sections would
  order them across objects.
- **Address differences in data** between two globals (`sub (ptrtoint
  @a, ptrtoint @b)`): unsupported (those within one global are folded);
  they need a pair of relocations (Mach-O's `SUBTRACTOR`).
- **Intrinsics lowered for correctness only** (`intrinsics.rs`,
  `neon.rs`): carry-less products (`llvm.clmul`, NEON's `pmul`, `pmull`,
  `pmull64`) bit by bit, where PMULL does bytes and 64-bit halves at
  once; `pdep`/`pext` bit by bit; masked loads and stores and
  compressions lane by lane through stack slots; structured stores
  (`st3`) element by element; vectors of halves converted to single
  precision lane by lane (where `fcvtl`/`fcvtn` do four at once); the
  padding of `<3 x float>` reductions rebuilt lane by lane;
  `llvm.prefetch` dropped (no `prfm`).
- **Half-precision NEON operations** (`fabd`, `fmulx`, the pairwise ones,
  `fmlal`...) on `<4 x half>`/`<8 x half>`: not done, as vectors of halves
  are integers here (`prepare::half_as_int`).
- **Reporting to the user** (`epitome-rustc`): a crate Epitome cannot
  compile keeps rustc's object and says why only in
  `epitome-rustc.log`. Better: errors and warnings on stderr in rustc's
  form (its JSON when Cargo asks for `--error-format=json`), at the Rust
  source line from the IR's debug information (`!dbg`) where the crate has
  it. rustc's own mechanism (LLVM's diagnostic handler, inline
  assembly's `!srcloc` cookies) belongs to a codegen backend running
  inside rustc, which a wrapper is not.
- **Hardware limits as diagnostics**: a description should be able to
  say what the machine cannot do (no writable memory, so no stack slots,
  spills or calls that save a return address; no runtime to call; only
  some operations), and a compilation should report, at the source line,
  each thing the program asks for that the machine lacks, all of them
  rather than the first, so that the program can be changed to fit.
- **Quad precision's code** (`runtime.rs`, `65-runtime.ll`): every fp128
  value is spilled around each runtime call (q registers are all the
  callee's), and its sign is changed through a stack slot and two `eor`s
  (one with `xzr`) where `eor v.16b` with a constant would do.
