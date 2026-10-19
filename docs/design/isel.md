# Machine descriptions and instruction selection

A target is described by an LLVM IR module. Each machine instruction is a
function whose body says what the instruction does, and whose attributes say
how it is encoded and printed. Instruction selection matches the IR of a
basic block against those bodies, taking the longest match, so the same data
drives selection, assembly printing, binary encoding and disassembly. The
description is read at start-up and kept as data; nothing is generated from
it at build time.

The code is in the `codegen` crate. The AArch64 description is in
`codegen/targets/aarch64/`: one module in nine files, read in name order
(base and conditions, integer, memory, load and store pairs, bits,
floating point, vectors, recipes, calling conventions; `00-base.ll` lists
them). For sources and status labels, see the [index](README.md).

### Arm's machine-readable specification

Arm publishes the A-profile architecture as data: AARCHMRS, whose
open-source package (under the BSD 3-clause license) has every
instruction's encoding and assembly syntax as JSON, though not its
pseudocode. Two scripts read a copy of it (downloaded separately; nothing
of Arm's is checked in except as below):

- `check_mrs.py` checks every entry against it. An entry's literal bits must
  lie inside one of Arm's encodings, and its mnemonic must be Arm's for that
  encoding or an alias's. It also says how much of the instruction set the
  description covers: at present 154 of Arm's 301 base A64 encodings, 151 of
  1,116 floating-point and SIMD ones, and none of the optional extensions,
  SVE or SME.
- `gen_from_mrs.py` writes entries whose bit layouts come from Arm's
  encodings: which bits are fixed, and which belong to which field. How the
  fields are filled from the operands, the assembly template and the body
  are ours. `25-pairs.ll` (the load and store pairs) is written this way,
  and carries Arm's copyright notice and license, as the license asks.

## Why LLVM IR

- **The meaning of an instruction is already a piece of IR.** `add w0, w1,
  w2` is `add i32 %n, %m`; `ldr x0, [x1, #8]` is a `getelementptr` and a
  `load`; `madd` is a `mul` feeding an `add`. Writing the instruction's
  meaning in the language the selector reads means matching is comparing
  like with like.
- **We already have the parser, printer and tools.** The description is
  valid IR: our parser reads it, and so does clang, which catches typing
  mistakes.
- **It can be checked.** Bodies can be evaluated. A recipe (several
  instructions for one IR operation) can be checked by evaluating the IR
  it replaces against the instructions' bodies, and the encodings can be
  checked against an assembler.

## The description

### Instructions

```llvm
define i32 @ADDWrr(i32 "reg"="w" %n, i32 "reg"="w" %m)
    "enc"="0 0 0 01011 00 0 m:5 000000 n:5 d:5" "asm"="add {d}, {n}, {m}" {
  %r = add i32 %n, %m
  ret i32 %r
}
```

- **Name**: the opcode. Names follow the usual AArch64 pattern: the
  mnemonic, the register width (`W` for 32 bits, `X` for 64) and the
  operand forms (`rr` registers, `ri` immediate, `rs` shifted register,
  `ui` unsigned scaled offset).
- **Parameters** are the operands. Their attributes say what kind:

  | Attribute | Operand |
  | --- | --- |
  | `"reg"="w"`, `"reg"="x"` | A register; number 31 is the zero register. |
  | `"reg"="wsp"`, `"reg"="xsp"` | A register; number 31 is the stack pointer. |
  | `"imm"` | A constant encoded in the instruction. Which values fit is decided by the encoding (below). |
  | `"label"` | A branch target, a `ptr` parameter. |
  | `"sym"` | A symbol, such as a called function or a global. |
  | `"cond"` | A condition, an `i1` parameter, filled in by a condition form. |
  | `"tied"` | Must be in the same register as the result (two-address). |

- **The result** is called `d` in the encoding and the assembly template.
- **`"enc"`** is the encoding, most significant bit first, written as in
  the Arm Architecture Reference Manual's diagrams. Each space-separated
  token is either literal bits (`01011`) or a field `name:width`, where
  `name` is an operand. `name:s19` is a signed field. A field can be an
  expression of operands: `imm12:12=off/8` stores a byte offset divided by
  8, and `imms:6=31-sh` stores 31 minus a shift amount. The tokens must add
  up to 32 bits.
- **`"asm"`** is the assembly template: `{n}` prints an operand, and
  `{=expr}` prints the value of an expression of operands.
- Other attributes: `"nodecode"` keeps an entry out of the disassembler,
  where another entry has the same encoding and reads better (for example,
  `cset` for `csinc` with both sources the zero register).

### Immediates are what the encoding can hold

An immediate operand has no separate range. It fits if encoding it and
decoding it again gives the same value: a 12-bit field divided by 8 holds
multiples of 8 from 0 to 32760, a signed 9-bit field holds -256 to 255, and
a logical-immediate field holds the bit patterns that the bitmask encoding
can express. One description gives the selector its constraint, the
encoder its fields and the disassembler its operands.

The same trick gives variants for free. `add w0, w1, #-5` cannot be
encoded, but `sub w0, w1, #5` can, so a second entry with the body `add i32
%n, %imm` and the field `imm12:12=0-imm` uses `sub`'s encoding: it fits
exactly when `-imm` is a 12-bit unsigned number.

### Conditions and flags

The flags are modelled lazily, as the pair of values last compared:

```llvm
%nzcv = type { i64, i64 }

define %nzcv @CMPWrr(i32 "reg"="w" %n, i32 "reg"="w" %m)
    "enc"="0 1 1 01011 00 0 m:5 000000 n:5 11111" "asm"="cmp {n}, {m}" "sets"="nzcv" {
  %a = sext i32 %n to i64
  %b = sext i32 %m to i64
  %f0 = insertvalue %nzcv poison, i64 %a, 0
  %f = insertvalue %nzcv %f0, i64 %b, 1
  ret %nzcv %f
}
```

Sign extension keeps both the signed and the unsigned order of 32-bit
values, so one flags type serves both widths.

A *condition form* says what a condition code means:

```llvm
define i1 @cc.lt(%nzcv %f) "cond"="11" "asm"="lt" "reads"="nv" {
  %a = extractvalue %nzcv %f, 0
  %b = extractvalue %nzcv %f, 1
  %c = icmp slt i64 %a, %b
  ret i1 %c
}
```

and an instruction that tests a condition takes it as a `"cond"` operand:

```llvm
define void @Bcc(i1 "cond" %c, ptr "label" %dest)
    "enc"="01010100 dest:s19=dest/4 0 c:4" "asm"="b.{c} {dest}" {
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}
```

`indirectbr` to a label operand means "jump there"; `ret void` means "fall
through". When the tables are built, each condition form is put in for the
`"cond"` operand, and each instruction that sets the flags is put in for
the flags. The result is simplified (an `extractvalue` of an `insertvalue`
is the inserted value, and a comparison of two sign extensions from the same
type is a comparison of the unextended values). `CMPWrr` with `Bcc` and
`cc.lt` becomes

```llvm
  %c = icmp slt i32 %n, %m
  br i1 %c, label %taken, label %next
```

which is what the IR says, and the match emits two instructions: `cmp`,
then `b.lt`.

Not every flag-setting instruction sets all four flags the way a
comparison would. `tst` (an `and` that sets flags) leaves the carry clear,
which a comparison of the result with 0 would not. So instructions say
which flags they set correctly (`"sets"="nzv"`), condition forms say which
they read (`lt` reads N and V; `hs` reads C), and the two are combined only
when every flag read is set.

### Recipes

Some IR operations have no single instruction. A recipe is a function with
the IR operation as its body, and a second function made of calls to
instructions:

```llvm
define i32 @srem.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="srem.w.expand" {
  %r = srem i32 %a, %b
  ret i32 %r
}

define i32 @srem.w.expand(i32 %a, i32 %b) {
  %q = call i32 @SDIVWrr(i32 %a, i32 %b)
  %r = call i32 @MSUBWrrr(i32 %q, i32 %b, i32 %a)
  ret i32 %r
}
```

Casts between integer types that live in the same register class are free
in an expansion: they name the same register.

### Instructions with two results

A post-increment load writes the loaded value and the stepped base:
`ldrsw x3, [x0], #4`. Its body returns both, and its base operand is
marked `"writeback"`, read and written:

```llvm
define { i64, ptr } @LDRSWpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off)
    "enc"="10 111 0 00 10 0 off:s9 01 n:5 d:5" "asm"="ldrsw {d}, [{n}], #{off}" {
  %v = load i32, ptr %n
  %r = sext i32 %v to i64
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i64, ptr } poison, i64 %r, 0
  %b = insertvalue { i64, ptr } %a, ptr %next, 1
  ret { i64, ptr } %b
}
```

A load pair writes two registers: `ldp x19, x20, [sp, #16]`. The second is
a result too, the operand called `d2`, which the attribute `"result2"`
asks for (and with pre- or post-indexing, the written-back base is a third
result):

```llvm
define { i64, i64 } @LDPXi(ptr "reg"="xsp" %n, i64 "imm" %off)
    "enc"="1010100101 imm7:s7=off/8 d2:5 n:5 d:5"
    "asm"="ldp {d}, {d2}, [{n}, #{off}]" "result2" "role"="load.pair.x" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  %a = load i64, ptr %p
  %q = getelementptr i8, ptr %p, i64 8
  %b = load i64, ptr %q
  %r0 = insertvalue { i64, i64 } poison, i64 %a, 0
  %r1 = insertvalue { i64, i64 } %r0, i64 %b, 1
  ret { i64, i64 } %r1
}
```

Pairs are not patterns yet; frames use them by role, saving and restoring
two registers of the same file at neighbouring slots with one `stp` or
`ldp` (one `str` or `ldr` for any left over, or where the offset does not
fit a pair's 7-bit field).

For a post-increment load, the first result is the pattern, as usual. The
second is an *extra root*:
after a match, the selector looks for an instruction later in the same
block that matches it with the parameters already bound (here, a
`getelementptr` of the same base by a constant that fits). That
instruction is then covered by the match, and its value is the
instruction's written-back base: the base is copied into its register
first, and the instruction steps it. Stores work the same way, with the
store as the pattern and the stepped base as the extra root.

### Immediates as constants of a shape

`log2(x)` in a field expression is defined only for powers of two, so an
entry can accept a family of constants. Multiplying by `2^k + 1` is adding
a value to itself shifted:

```llvm
define i32 @ADDWmul(i32 "reg"="w" %n, i32 "imm" %c)
    "enc"="0 0 0 01011 00 0 m:5=n imm6:6=log2(c-1)%32 n:5 d:5" "asm"="add {d}, {n}, {n}, lsl #{=log2(c-1)}" {
  %r = mul i32 %n, %c
  ret i32 %r
}
```

`mul i32 %x, 5` fits (`log2(4) = 2`) and becomes `add w0, w0, w0, lsl #2`;
`mul i32 %x, 6` does not, and stays a `mul`.

## Selection

### Selection form

Before matching, a copy of each function is put into *selection form*, so
that the IR and the bodies meet in the same shape:

- Every `getelementptr` becomes `getelementptr i8, ptr %base, i64 %offset`,
  with the offset worked out in `i64`: constant parts added up, and
  multiplications by powers of two written as `shl`. `a[i]` for `i32`
  elements is `getelementptr i8, ptr %a, i64 (shl %i, 2)`, which is what
  the scaled register-offset `ldr` says.
- `switch` becomes a chain of comparisons.
- Division and remainder by constants become multiplications by a magic
  number, keeping the high half, and shifts (Granlund and Montgomery,
  1994, as in Warren's *Hacker's Delight*, chapter 10; `codegen/src/
  divconst.rs`). Powers of two are shifts, corrected so that signed
  division rounds towards zero. The high half of a 32-bit product is
  `smull` or `umull` and a shift; for 64 bits it is written with `i128`
  and covered whole by `smulh` or `umulh`, so the wide values never need a
  register. `x / 7` is `smull`, `asr`, `add`, `asr`, `add ... lsr #31`.
- Critical edges are split, so that phis can become copies at the end of
  predecessors.

The input is expected to have been through `draconian-opt`, so it is in the
combiner's canonical form already.

### Vectors

Advanced SIMD instructions are described like the rest, with vector types
in their bodies: `add <4 x i32>` is `add v0.4s, v1.4s, v2.4s`. 128-bit
vectors live in q registers and 64-bit ones in d registers; templates print
a register with an arrangement (`{n:4s}`), a lane (`{n:.s}[{idx}]`) or a
scalar view (`{d:s}`). A vector of `i1` is a *mask*: lanes of all ones or
all zeros, as `cmeq` and its kin make them, in a q register. Shuffles match
by their constant masks (`rev64` is `shufflevector` with `<1, 0, 3, 2>`),
and reductions with no single instruction are recipes (`addv` then `umov`).
The vector part of the description (`50-vectors.ll`, 482 instructions) is
written by `codegen/targets/aarch64/gen_vectors.py`, one entry per
arrangement; the output is checked in and is data like the rest.

What the instructions cannot take directly, `codegen/src/legalize.rs`
reshapes first, as LLVM's type legalisation does:

- Vectors wider than 128 bits are split into 128-bit parts, each
  operation done per part. Extensions double one step at a time, each part
  giving two (`sxtl`, `sxtl2`); truncations halve, two parts giving one
  (`xtn`, `xtn2`). Reductions combine the parts, then reduce one.
- Vectors whose lane count is not a power of two (`<10 x i32>`), and those
  narrower than a d register (`<4 x i8>`), are scalarised: a value for
  each lane.
- Shuffles with no instruction are built lane by lane from `umov` and
  `ins`; whole parts are reused and splats splatted.
- Masks get the lane width of the comparison that made them. A mask used
  at another width (a `select` of `i32` lanes by an `i16` comparison, or
  two masks of different widths combined) is extended or truncated as
  integers and compared with zero again. A splat of one boolean becomes a
  register of all ones or zeros, right at any width. `icmp eq (bitcast
  mask to iN), 0`, whether any lane is set, is `umaxv`.
- What has no instruction is rewritten: `icmp ne` against other than zero
  is `cmtst` of an `eor`; shifts by amounts that are not one constant are
  `ushl` and `sshl` (with the amount negated for right shifts); divisions,
  64-bit multiplications and reductions without an across-lanes
  instruction go lane by lane; ordered floating-point reductions are added
  in order, as written. Vectors of pointers become vectors of `i64`.

### Patterns and the trie

Each instruction body (after condition forms, flags and recipes are filled
in) becomes a *pattern*: a tree rooted at what the body produces: the
returned value, the store, or the branch. Leaves are operands; interior
nodes are IR operations. Operands that can be zero get a specialised
pattern too, simplified, so `ldr x0, [x1]` comes from the same entry as
`ldr x0, [x1, #8]`. Conditional branches get a second pattern with the
condition inverted and the targets swapped, so that either target can be
the fall-through.

Patterns are stored in a discrimination trie keyed by their preorder
traversal: each interior node's operation (with its types), literal
constants, and a wildcard for each operand. Matching walks the trie and the
IR together; at each IR value it may follow the wildcard edge (the value
stays in a register, or is an immediate or label) or, if the value can be
folded into the pattern, the edge for its operation.

A value can be folded into a pattern rooted elsewhere when it is defined in
the same block, has no other use, and has no side effects, or is a load
with no store or call between it and the root.

### Choosing

Blocks are covered from the bottom up. An instruction is a *root* if it has
side effects, is a terminator, or its value is used outside what has been
folded. For each root the trie gives every pattern that matches; the
selector takes the one that covers the most IR operations, then the one
that needs no extra branch, then the one with fewer instructions. Operands
of the chosen match that are instructions become roots in turn.

Constants that end up in registers are made by the patterns whose body is
just `ret %imm` (`movz`, `movn`, `orr` with a logical immediate), or failing
that by `movz` followed by `movk`s. Addresses of globals are made with
`adrp` and `add`.

### Machine IR

The result is machine IR: blocks of machine instructions, each an opcode
from the description and a list of operands (virtual or physical
registers, immediates, labels, symbols), plus a few pseudo-instructions:
`COPY`, and the frame-index form of `add` used for allocas and spill slots.
Phis become copies at the end of each predecessor, through temporaries so
that swaps are right.

### Register allocation

Linear scan over live intervals. Liveness is worked out per block, and each
virtual register gets one interval spanning every point where it is live.
Calls clobber the caller-saved registers, so values live across a call get
callee-saved ones. Copies to and from argument registers are hints. When no
register is free the value is spilled to a stack slot, and reloaded into a
scratch register (`x16`, `x17`, `x15`) around each use.

### Calling conventions

Conventions are data too: named metadata in the description, one block per
convention and platform (`codegen/src/abi.rs` reads them).

```llvm
!abi.aapcs64 = !{!200, !201, ...}
!200 = !{!"args", !"x0-x7"}
!201 = !{!"result", !"x0"}
!202 = !{!"clobbers", !"x0-x18", !"x30"}
!203 = !{!"saved", !"x19-x28"}
!204 = !{!"reserved"}
!205 = !{!"scratch", !"x15-x17"}
!206 = !{!"frame", !"x29", !"x30"}
!207 = !{!"stack-args", !"slots"}
!208 = !{!"variadic", !"named"}
!209 = !{!"syntax", !"elf"}
!210 = !{!"triples", !"linux", !"elf", !"none"}
```

Two are described:

| | `darwin` (Apple) | `aapcs64` (Linux) |
| --- | --- | --- |
| `x18` | reserved for the platform | an ordinary temporary |
| Stack arguments | packed, each at its own size and alignment | each in an 8-byte slot |
| Variadic arguments | always on the stack, in 8-byte slots | where named ones would go |
| Assembler | Mach-O: `_f`, `_g@PAGE`, `_g@PAGEOFF`, `L` labels | ELF: `f`, `g`, `:lo12:g`, `.L` labels |

The convention comes from the module's target triple (`--abi=` chooses
one). Arguments past `x0`–`x7` are stored by the caller at the bottom of
its frame, which is sized for its largest call, and loaded by the callee
from above its own frame. Narrow arguments marked `zeroext` or `signext`
are extended by the caller, as Apple requires; values without those marks
have undefined upper bits, as everywhere. Calls clobber the convention's
registers, so values live across them get saved ones. A function saves
`x29` and `x30` only if it makes calls, and any saved registers it uses.

Floating-point arguments and results use `d0`–`d7` and `d0`, counted
apart from the integer registers, and `d8`–`d15` are saved (the low 64
bits; the `fp-*` properties). Small structs, which clang passes as
`[2 x i64]`, take two consecutive registers if both fit, and otherwise go
on the stack whole. A variadic function under Apple's convention finds its
variable arguments on the caller's stack: `va_start` points the `va_list`
just past the named stack arguments, and each `va_arg` loads through it and
steps it by 8.

Symbols a module only declares (in another library) are reached through
the global offset table (`adrp` of `@GOTPAGE`, then a load), and constants
holding addresses go where the loader can write (`__DATA,__const`,
`.data.rel.ro`).

A convention may also name a `far-scratch` register, never allocated, for
the addresses of stack slots further than an instruction's offset reaches
(RISC-V's 2,047 bytes); AArch64's reach 32KB and need none.

Not yet: `byval` and `sret` arguments, homogeneous floating-point
aggregates and vectors, defining variadic functions under AAPCS64 (whose
`va_list` is a struct with register save areas), and tail calls.

## Output

- **Assembly** in the convention's dialect (Mach-O or ELF), from the
  templates, with each `{s}` written as its relocation's `elf-syntax` or
  `macho-syntax` says (`:lo12:g`, `g@PAGEOFF`). It can be assembled with clang and linked with C.
- **Binary**: the encoding of each instruction, with branches within a
  function resolved, and fixups for symbols.
- **Object files**: Mach-O and ELF, whose relocations come from each
  instruction's `"reloc"`, and which say what clang's assembler makes of
  our assembly; see [objects.md](objects.md).
- **Disassembly**: for each 32-bit word, the entries whose literal bits
  match are candidates, most literal bits first (so `cmp` beats `subs`,
  which it is an alias of). Operand values come from inverting the fields
  (`off = imm12*8`, `sh = 31-imms`), and are kept only if encoding them
  again gives the same word.

## Checks

- `codegen/tests/describe.rs`: every instruction encodes and decodes back
  to itself over a spread of operands; each recipe's instructions, by
  their bodies, compute what the IR it replaces computes, on edge values;
  the table has the combinations it should, and not those it must not
  (`tst` with a condition that reads the carry).
- `codegen/tests/programs.rs`: C functions in `tests/programs/*.c`, built
  four ways (clang `-O0`, that through `draconian-opt`, clang `-O2` without
  vectorising, and clang `-O2` as it is, vectorised and unrolled) and
  compiled by us, are linked with a main built by clang and must print what
  clang's own build prints. Our assembly is assembled by clang and each word
  checked against our encoder (except where we leave a fixup), and each word
  is disassembled with the description and must encode back to itself, with
  objdump's mnemonic or an alias of it. Each program is also built from
  clang's IR for Linux with the AAPCS64 convention, assembled by clang for
  Linux, and checked word by word.
- `codegen/tests/abi.rs`: AAPCS64 code built by us and by clang (for Linux,
  its assembly rewritten for this machine's assembler) is linked in every
  pairing of caller and callee and run, so that any difference in how
  arguments are laid out on the stack shows. With the stack layout set
  wrongly, the mixed pairings fail and ours with ours does not, which is
  why the test pairs us with clang.

  `vectors.c` is 26 loops for the vectoriser (sums, dot products, widening
  and narrowing, compares and selects, conversions, a de-interleave), run
  at lengths around the vector widths (0 to 1000) and checked by hashes of
  every output array.
- `codegen/tests/sqlite.rs`: SQLite, as above (needs the amalgamation).

## Status

It compiles SQLite. Every function of the 3.50 amalgamation (1,578, about
357,000 instructions, in 1.5 seconds) compiles, and the result, linked with
SQLite's shell built by clang, answers the SQL in `tests/sqlite/` exactly as
clang's build does: from clang's `-O2` IR, from the same vectorised (2,981
vector values, among them `<16 x ptr>` from vector `getelementptr`s and
masks reduced with `bitcast`), and from clang's `-O0` IR through
`draconian-opt`. It runs those scripts in about twice the time
clang's build takes. `tests/sqlite.rs` repeats this when `DRACONIAN_SQLITE`
names the amalgamation.

Covered: integer and floating-point arithmetic, logic, shifts,
multiply-add, division and remainder (by constants, without dividing),
conversions, loads and stores of every scalar width with immediate,
register and post-increment addressing, integer and floating-point
comparisons, conditional branches (relaxed when out of range), selects,
minimum and maximum, byte swaps, bit counts, funnel shifts, atomic loads,
stores and fences, switches, calls (with arguments on the stack, small
structs, and to and from variadic functions) under Apple's convention and
AAPCS64, locals, frames of any size up to 32KB, globals, and odd widths
such as `i33`. The description has 786 instructions, 22 condition forms
and 45 recipes; the table built from it has 1,814 patterns.

Instructions in the test programs, built without vectorising or unrolling,
by LLVM's back end and ours:

| Program | IR from | LLVM | Ours |
| --- | --- | --- | --- |
| `basic.c` (38 functions) | clang `-O2` | 429 | 496 |
| `divs.c` (division by 90 constants) | clang `-O2` | 793 | 814 |
| `loops.c` (9 array loops) | clang `-O2` | 106 | 119 |
| `loops.c` | clang `-O0`, then `draconian-opt` | 106 (from `-O2`) | 103 |

And vectorised and unrolled (clang `-O2` as it is):

| Program | LLVM | Ours |
| --- | --- | --- |
| `vectors.c` (26 loops) | 1,719 | 2,381 |
| `loops.c` | 619 | 885 |
| `basic.c` | 901 | 1,147 |

(The counts first recorded here for vectorised code were measured partway
through the vector work; these are for the code as it is now.)

Much of the difference is in lanes done one at a time (scalarised odd
vectors, shuffles built from `umov` and `ins`) where LLVM has a better
sequence, and in spills of the many vector accumulators an unrolled loop
keeps.

clang's `-O2` IR still indexes arrays by counter, since LLVM reduces
strength in its code generator; ours does it in `draconian-opt`
([loops](loops.md)), so it shows in the last row. In `basic.c` the
remaining differences are mostly loops built with `-fwrapv` (whose
counters cannot be widened or reduced) and phi copies the allocator does
not coalesce.

After allocation and frames, blocks are placed so that most branches fall
through (`codegen/src/layout.rs`): small return blocks are copied into the
blocks that jump to them, blocks are chained with each followed by a
successor that stays in the function, and conditional branches are
inverted where that lets them fall through. Which branch inverts to which
is in the description (`"inverse"`); a condition's inverse is the
condition form with the inverse comparison.

When the layout is final, a conditional branch whose target is out of its
range (`tbz` reaches 32KB, `b.cond` and `cbz` 1MB) becomes the opposite
branch around an unconditional `b`, which reaches 128MB.

Selection form also does what LLVM's type legalisation does for the cases
above: values narrower than 32 bits live in W registers with their upper
bits undefined, and odd widths live in the next register width; operations
that read every bit get their operands extended in place first.

Not yet: dynamic allocas, exception handling, `i128` beyond the high half
of products, frames over 32KB, object files (the output is assembly), load
and store pairs, pre-index addressing, scalable vectors, and vector
floating-point minimum, maximum and unordered comparisons.
