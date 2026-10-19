# Targets, CPUs and features

A machine is its description: `.ll` files read at run time. Adding a
machine, a CPU or a relocation means writing a description file. You don't
change Draconian's Rust or rebuild `draconian-llc`. AArch64 is built in for
convenience. RISC-V RV64 (`codegen/targets/riscv64/`) is not: it is read
from disk like any description someone else might write.

This document covers:

- how a description is found;
- what it says about the machine as a whole;
- how CPUs and features gate its entries;
- what the code generator needs from it;
- what adding RISC-V took.

[isel.md](isel.md) describes the instruction entries themselves.

## Finding a description

`draconian-llc`, `draconian-as` and `draconian-objdump` take `--target`
and `--target-add`, and `draconian-llc` takes `--mcpu` and `--mattr` too:

| Option | Meaning |
| --- | --- |
| `--target=<path>` | a `.ll` file, or a directory whose `.ll` files are read in name order as one module |
| `--target=<name>` | `aarch64` (built in), or directory `<name>` in one of the directories of `DRACONIAN_TARGET_PATH` (colon-separated) |
| `--target-add=<path>` | more files (or directories) read after the description, as part of it; may be repeated |
| `--mcpu=<name>` | the CPU, as the description names it |
| `--mattr=+f,-g` | features turned on or off; may be repeated |

Without `--target`, `draconian-llc` looks at the module's target triple:

- `aarch64` and `arm64` use the built-in description;
- any other architecture name is looked up in `DRACONIAN_TARGET_PATH`, so
  `riscv64-unknown-linux-gnu` finds `<dir>/riscv64/`.

`draconian-objdump` finds the description for an ELF object by its
`e_machine`, among the built-in one and those in `DRACONIAN_TARGET_PATH`.

### Overlays

The files of a description are one module, so `--target-add` can extend a
description without copying it. A file can add:

- new instructions;
- recipes;
- a calling convention;
- CPUs (`!target.cpus`);
- relocations (`!target.relocs`).

Named metadata from the different files is joined, and of two equal
patterns the first one read wins. For example, to add a CPU without
Advanced SIMD to the built-in AArch64:

```llvm
; my-core.ll
!target.cpus = !{!9000}
!9000 = !{!"my-core", !"fp-armv8"}
```

```sh
draconian-llc --target-add=my-core.ll --mcpu=my-core sum.ll -o sum.s
```

The loop that is vectorised for `generic` (`v0.4s` and so on) is then
compiled lane by lane. One thing to watch: the module's own
`"target-features"` are applied after the CPU, as llc applies them. So
clang's IR, which says `+neon`, turns NEON back on. `--mattr=-neon`, which
comes last, is what turns it off for such IR.

## The machine as a whole

`codegen/src/machine.rs` reads four lists of named metadata. AArch64's are
in `targets/aarch64/01-target.ll`, and RISC-V's in
`targets/riscv64/00-base.ll`.

### Registers

`!target.registers` gives each register class the names of its registers,
in number order:

```llvm
!1000 = !{!"x", !"zero", !"ra", !"sp", !"gp", !"tp", !"t{0-2}", !"s{0-1}", !"a{0-7}", !"s{2-11}", !"t{3-6}"}
!1004 = !{!"d", !"ft{0-7}", !"fs{0-1}", !"fa{0-7}", !"fs{2-11}", !"ft{8-11}"}
```

The numbering has a few fixed points:

- Integer classes number from 0.
- Floating-point and vector classes (`d`, `s`, `q`, `v`) number from 32.
- `{0-30}` is a range.

Templates print these names, and the assembler and the conventions' lists
read them. Extra *views* name the same registers differently for
templates. AArch64 uses `b` and `h`, and `lanes` (the `v3` of `v3.4s`).

### Parameters

`!target.params` holds:

| Parameter | AArch64 | RISC-V | Meaning |
| --- | --- | --- | --- |
| `sp`, `zero` | `sp`, `xzr` | `sp`, `zero` | the stack pointer and the zero register |
| `vector-bits` | `128`, `neon` | `0` | a vector register's width, and the feature that brings the vector registers |
| `narrow-results` | `zero` | `sign` | how a 32-bit result sits in a 64-bit register |
| `external-via-got` | `yes` | `no` | whether symbols defined elsewhere are reached through the GOT |
| `boolean-branches` | `bit` | `compare` | whether a branch can test a boolean's low bit, or must compare whole registers |
| `elf-machine`, `elf-flags`, `macho-cpu` | 183, 0, `0x0100000c` | 243, 4 | the object files' identity |
| `cpu` | `generic` | `generic-rv64` | the CPU when none is named |

`narrow-results` decides which casts are free:

- **`zero`:** zero extension from 32 bits, and truncation to 32 bits, cost
  nothing.
- **`sign`:** sign extension costs nothing, but truncation needs
  `sext.w`.

`boolean-branches = compare` makes `prepare` rewrite a branch on a boolean
that isn't a comparison into a comparison with zero.

### CPUs

`!target.cpus` lists CPUs by LLVM's names for them, each followed by its
features:

```llvm
!1150 = !{!"generic", !"fp-armv8", !"neon"}
!1151 = !{!"apple-m1", !"fp-armv8", !"neon", !"lse"}
```

### Relocations

`!target.relocs` lists every relocation as property pairs:

```llvm
!1201 = !{!"name", !"adrp", !"elf", !"275", !"elf-name", !"R_AARCH64_ADR_PREL_PG_HI21",
          !"macho", !"3", !"macho-name", !"ARM64_RELOC_PAGE21", !"macho-pcrel", !"yes",
          !"macho-length", !"2", !"elf-syntax", !"{s}", !"macho-syntax", !"{s}@PAGE",
          !"target", !"(pc & -4096) + (v << 12)"}
```

| Property | Meaning |
| --- | --- |
| `name` | what an instruction's `"reloc"` attribute names |
| `elf`, `elf-name` | the ELF number and name |
| `macho`, `macho-name`, `macho-pcrel`, `macho-length` | Mach-O's number, name, PC-relative flag and log2 size |
| `elf-syntax`, `macho-syntax` | how assembly writes the operand, with `{s}` for the symbol (`%lo({s})`, `{s}@PAGEOFF`) |
| `use` | `call` (resolved in place within a section), `got` (through the GOT) or `data8` (a pointer in data) |
| `target` | for the disassembler: the address reached, from the instruction's address `pc` and the operand's value `v` |

Code uses `"reloc"` attributes. The object writers use the numbers and
`use`. The assembly printer and the assembler use the syntax, as a template
and in reverse. The objdump reader uses the names and `target`.

Relocations that have only a number and a name aren't used by any
instruction. They're listed so that other compilers' objects can be read.
Inside the code generator a relocation is an index into this list
(`RelocKind`), so no relocation is named in Rust.

## Features

An entry needs features through `"feature"="zbb"` (comma-separated when it
needs several). AArch64's generated vector entries all carry
`"feature"="neon"`.

`codegen/src/features.rs` works out each function's features, in this
order:

1. The CPU's features. The CPU is the one `--mcpu` names; failing that,
   the IR's `"target-cpu"` if the description knows it; failing that, the
   default `cpu`.
2. Then the IR's `"target-features"` (`+neon,-lse`) are applied.
3. Then `--mattr` is applied.

Features the description never mentions are ignored, which is why the long
`target-features` strings clang writes cause no trouble. A description that
names no CPUs starts with every feature on.

When a feature is off:

- Patterns that would emit an instruction needing it are skipped, and so
  are constants built with such an instruction.
- Recipes that use such an instruction are skipped, so a cheaper or a
  more general route is chosen instead.
- If it is the vector feature, `vector-bits` counts as 0. Legalisation then
  splits every vector into scalars, partial reductions included.

So RISC-V without Zbb computes `smax` with a branch-free recipe, and with
`+zbb` it uses `max`. Intrinsics with no instruction, such as a funnel
shift on a machine with no `fshl` entry, are expanded generically in IR by
`prepare`.

## What the code generator asks of a description

The Rust code refers to no instruction by name. Where it must emit an
instruction that no pattern selected, such as a spill, a frame adjustment,
a call or a jump, it asks for one by **role**. An instruction can have
several roles: `"role"="addi,addi12"`.

| Roles | Used for | Needed |
| --- | --- | --- |
| `load.x`, `store.x`, and `load.b/h/w/s/d`, `store.b/h/w/s/d` | spills, saves, arguments on the stack, by size | `x` always; the others where values of that size are spilled or passed |
| `addi`, `subi`, `addi.neg`, `addi12`, `subi12`, `addi.w`, `add`, `shli` | frame adjustment, addresses of stack slots, building large constants | `addi` and `add` |
| `call`, `callr`, `jump`, `ret`, `trap` | calls, branches, returns, `unreachable` | yes |
| `addr.hi`, `addr.lo`, `got.hi`, `got.lo` | the address of a global: the two halves of its address, and of its GOT entry's | `addr.*`; `got.*` with `external-via-got` |
| `movz.*`, `movk.*`, `movi.zero` | AArch64's constant building | no: otherwise `lui`/`addi`/`shli` pieces are found from the constants the description allows |
| `zext.1/8/16`, `sext.1/8/16` | extending `zeroext`/`signext` arguments and results | for the widths a program passes so |
| `fmov.*`, `copy.q`, `dup.*`, `ins.*` | moves between classes, vector building | where the machine has those classes |
| `load.pair.*`, `store.pair.*`, `load.q`, `store.q` | saving pairs of registers, 128-bit spills | no |

The calling convention adds a few registers:

- `scratch` and `fp-scratch`: for spill code;
- `far-scratch`: for the address of a stack slot further away than an
  instruction's offset can reach (beyond 2,047 bytes on RISC-V).

## RISC-V RV64

`targets/riscv64/` is written by `gen_riscv64.py`, from the RISC-V
Instruction Set Manual and the ELF psABI. It has 208 instructions in these
files:

| File | Contents |
| --- | --- |
| `00-base.ll` | registers, parameters, CPUs, relocations |
| `10-integer.ll` | RV64I |
| `20-m.ll` | M |
| `30-zbb.ll` | Zbb, behind `"feature"="zbb"` |
| `40-float.ll` | F and D |
| `60-recipes.ll` | 54 recipes: comparisons into registers, selects, minimum and maximum, extensions, `abs`, floating-point predicates |
| `70-abi.ll` | the LP64D convention |

Globals use the medlow model (`lui %hi`, `addi %lo`) and no GOT.

RISC-V showed where the Rust still assumed AArch64. Each of these is now
general, or is driven by a parameter:

- **Operands split across fields.** B- and J-type immediates are scattered
  across the word. Encoding concatenates slices (`imm[12|10:5]`), and
  decoding now joins them back. Fields that repeat the same bits, such as
  the two halves of `fmv.d`'s `rs1 = rs2`, are kept apart rather than
  summed.
- **Sign-extended 32-bit values** (`narrow-results`).
- **Branches that compare registers** (`boolean-branches`).
- **Large constants.** Built from the constants the description allows,
  as `lui` + `addi` + `slli` pieces, instead of AArch64's `movz`/`movk`.
- **Short offsets.**
  - Frames larger than an `addi` can reach are allocated in two steps.
  - Slots beyond 2,047 bytes are reached through `far-scratch`.
  - Branches out of range are relaxed by inserting a `.far` block that
    holds a `jal`.
- **No vector registers.** Every vector is done lane by lane.

`codegen/tests/riscv.rs` tests it without a RISC-V toolchain:

- **Compiling.** `basic`, `divs`, `loops`, `calls`, `floats` and `vectors`
  from `tests/programs/` are built from clang's IR (LP64, unsigned `char`).
  There are four configurations: `-O2` and vectorised `-O2`, each with and
  without `+zbb`.
- **Round trip.** `draconian-as` must make the same bytes from our
  assembly, and `draconian-objdump` must read it back.
- **Running.** The objects are linked and run on a small RV64IMFD+Zbb
  emulator (`tests/riscv/emu.rs`). Its static linker resolves the four
  relocations, and its C library provides a `printf` that prints as
  glibc's does. Each program must print exactly what the native build
  prints.

All 24 runs pass. The test was also what found the bugs listed above.

Not yet:

- compressed instructions (C), atomics (A) and vectors (V);
- position-independent code and the GOT;
- `varargs.c`, whose IR's `va_list` is AArch64's because clang here has
  no RISC-V target.

Adding V would mean:

1. vector register classes;
2. `vector-bits` with the feature `v`;
3. vector entries tagged `"feature"="v"`.

The Rust would not need to change, beyond any vector shapes it doesn't
know yet.
