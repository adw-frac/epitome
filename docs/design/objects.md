# Object files and disassembly

This document covers how Draconian writes object files (ELF, for AArch64
Linux) instead of assembly, and `draconian-objdump`, which reads object
files (ELF and Mach-O) and disassembles them with the machine description.
For the description itself and instruction selection, see
[isel.md](isel.md).

**Status:** ELF relocatable files: **Done**, and checked against clang's
assembler over SQLite. Mach-O object files: **Planned**. Unwind tables
(`.eh_frame`) and debug info in objects: **Later**.

## Sources

| Document | Used for |
| --- | --- |
| System V Application Binary Interface, *Object Files* (the generic ELF chapters) | File and section headers, symbol tables, `SHT_RELA`, string tables |
| Arm, *ELF for the Arm 64-bit Architecture* (AAELF64) | `EM_AARCH64`, relocation numbers and what each fills in, mapping symbols `$x` and `$d` |
| Apple's published `<mach-o/loader.h>`, `<mach-o/nlist.h>`, `<mach-o/reloc.h>`, `<mach-o/arm64/reloc.h>`, `<mach-o/fat.h>` | Reading Mach-O: load commands, sections, symbols, arm64 relocation types, universal files |
| Arm Architecture Reference Manual | The `adrp` immediate (`immhi:immlo`, signed, in pages); the shift-by-immediate encodings (`immh:immb`) |
| clang's assembler on our own assembly | What an assembler does where the documents leave a choice; see below |

## The object model

`codegen/src/object.rs` describes an object file without committing to a
format: sections (`Text`, `Data`, `Bss`, `ReadOnly`, `RelRo`) with their
bytes and alignment, symbols (function, object or undefined; local or
global; with section, value and size), and relocations (offset, kind,
target, addend). `elf.rs` writes it as ELF. A Mach-O writer would take the
same model.

Globals are described once, as `GlobalData`: their section, alignment and a
list of items (integers of 1, 2, 4 or 8 bytes, strings, zeros, and
addresses of symbols with an offset). Both the assembly printer and the
object builder read that list, so the two outputs cannot disagree about
what a global holds. Zero-initialised writable data goes in `.bss` (ELF
only so far), where only its size is stored.

### Relocations are data

The description says how each instruction with a symbol operand is fixed
up, in a `"reloc"` attribute:

| Instruction | `"reloc"` | ELF | Mach-O |
| --- | --- | --- | --- |
| `bl sym` | `call26` | `R_AARCH64_CALL26` | `ARM64_RELOC_BRANCH26` |
| `adrp x, sym` | `adrp` | `R_AARCH64_ADR_PREL_PG_HI21` | `ARM64_RELOC_PAGE21` |
| `add x, x, :lo12:sym` | `add_lo12` | `R_AARCH64_ADD_ABS_LO12_NC` | `ARM64_RELOC_PAGEOFF12` |
| `adrp x, :got:sym` | `adrp_got` | `R_AARCH64_ADR_GOT_PAGE` | `ARM64_RELOC_GOT_LOAD_PAGE21` |
| `ldr x, [x, :got_lo12:sym]` | `ld64_got_lo12` | `R_AARCH64_LD64_GOT_LO12_NC` | `ARM64_RELOC_GOT_LOAD_PAGEOFF12` |
| `.quad sym+off` (data) | `abs64` | `R_AARCH64_ABS64` | `ARM64_RELOC_UNSIGNED` |

The code generator only ever reaches globals with `adrp` and `add` (then
loads through the register), so the load and store page-offset
relocations are not needed. Code never carries an addend: an offset from a
symbol is added by a separate instruction. Data does (`&table[3]`).

### What an assembler does, and so what we do

Where the documents leave a choice, Draconian does what clang's assembler
does with the same program, so that the two object files can be compared:

- A call to a **local** function in the same section is resolved in place,
  with no relocation: the distance is known. A call to a global function
  keeps its `R_AARCH64_CALL26`, since the linker may bind it to another
  library's definition.
- Other references to a local symbol are made against its **section** (a
  section symbol), with the symbol's offset in the addend: `.data+0x28`, not
  `counter`. References through the GOT stay against the symbol.
- References to global and undefined symbols are made against them.
- The bytes a relocation fills in are zero; the addend is in the
  relocation (ELF's RELA form).
- Mapping symbols: `$x` at the start of a code section, `$d` at the start
  of each data section, `.bss` included.
- A section symbol only for sections that relocations refer to.
- An empty `.note.GNU-stack`: the stack need not be executable.

The assembly gained what the object has, so that the assembler's object
says the same: `.size` for each function and object, `.bss` for zeros,
and the `.note.GNU-stack` section.

One encoding had to change: `mov w0, #0xffff0000` fits both `movn w0,
#0xffff` and `movz w0, #0xffff, lsl #16`, and an assembler prefers `movz`.
Where a constant's only nonzero 16 bits are above the lowest, the selector
now writes the shifted `movz` out, so that our encoding and the
assembler's are the same.

## `draconian-llc -o file.o`

A name ending in `.o`, or `--filetype=obj`, writes an ELF object instead of
assembly. The convention must use ELF (a Linux triple, `--abi=aapcs64`, or
`--syntax=elf`).

The file has the null section; the object's sections in order (`.text`,
`.data`, `.bss`, `.rodata`, `.data.rel.ro`); a `.rela` section for each with
relocations; `.note.GNU-stack`; then `.symtab`, `.strtab` and `.shstrtab`.
Local symbols come first, as ELF requires: section symbols, mapping
symbols, then the object's own; then global ones, defined and undefined.

## `draconian-objdump`

```sh
draconian-objdump -d file.o        # disassemble (the default)
draconian-objdump -dr file.o       # with each instruction's relocation
draconian-objdump -h -t file.o     # section headers, symbols
draconian-objdump -s file.o        # contents in hex
draconian-objdump --canonical a.o  # sorted text, for diffing two objects
```

It reads ELF (relocatable or linked) and 64-bit Mach-O (objects and linked
images, and the arm64 slice of a universal file) into one form, an
`Image`: sections with addresses and bytes, symbols, and relocations
against names. Disassembly then works the same for both.

Each word is decoded as the description's entry whose literal bits it has
(see isel.md). Where a relocation fills the word in, the word is decoded as
the entry that carries that kind of relocation, and the symbol is printed in
its place, as assembly writes it in that format:

```
      30: 91000000     	add x0, x0, :lo12:counter
		0000000000000030:  R_AARCH64_ADD_ABS_LO12_NC	.data+0x28
```

(A reference against a section is printed with the symbol at that
address, if there is one.) In Mach-O, the same is `add x0, x0,
_counter@PAGEOFF`. Branch targets are printed with the symbol they are in,
`0x98 <use+0x90>`; `adrp` and `bl` in a linked image without relocations
are printed as the addresses they reach. Mapping symbols decide what is
code: words after a `$d` are printed as `.word`. So are words the
description does not have.

`--canonical` prints an ELF file as sorted text without offsets or order:
each section's type, flags, size and bytes, its relocations (with section
symbols named by their section), and the symbols other than section
symbols. Two files that say the same print the same.

### Decoding fixes

Reading code we did not generate found two kinds of wrong decode, both in
the description's encodings:

- **`adrp`** split its operand as `immlo:2=s%4` and `immhi:19=s/4`.
  Decoding used `immhi` alone and dropped `immlo`; and the immediate is
  signed (`immhi:immlo` is a signed count of pages), which `/` and `%`
  round the wrong way for. It is now `immlo:2=s&3` and `immhi:s19=s>>2`,
  and the decoder puts back the low bits of an operand split over a
  `name>>k` field and a `name&m` field (or `name/k` and `name%k`).
- **Shifts by immediate** (`shl`, `ushr`, `sshr`) had the whole of
  `immh:immb` as a field holding `2*esize - shift`, so a word with `immh`
  zero, which is `movi` or `mvni`, decoded as a shift by a too-large amount.
  The element size is now literal bits (`immh`'s leading one) and only the
  shift is a field.

## Checks

- `codegen/tests/programs.rs`, for each test program in each of its four
  builds:
  - **3b.** clang's assembly of our Mach-O assembly, read back by
    `draconian-objdump`, gives our assembly: every mnemonic (or an alias),
    and every instruction a relocation fills in, whole.
  - **5.** Our ELF object for the Linux build says what clang's assembler
    makes of our Linux assembly, compared in canonical form: the same
    sections with the same bytes, the same relocations against the same
    targets with the same addends, and the same symbols with the same
    bindings, types, values and sizes.
  - **6.** Our ELF object, read back by `draconian-objdump`, gives our
    assembly.
- `codegen/tests/sqlite.rs`: the same as 5 and 6 for SQLite, from clang's
  `-O2` IR with and without vectorising, compiled to ELF: about 357,000
  and 375,000 instructions, with every relocation and symbol.
- `codegen/tests/objdump.rs`: clang's own `-O2` builds of the test programs
  and of SQLite (237,143 words), disassembled by `draconian-objdump` and by
  the system's objdump. Every word we decode must be, to objdump, the same
  instruction (mnemonic, or an alias). About 89% of SQLite's words decode;
  the rest are instructions the description does not have yet (`ldp`,
  `stp`, and others).

What is not checked here: linking and running the ELF objects, which needs
Linux. The canonical comparison with clang's assembler covers what a linker
reads, but an arm64 Linux machine (or a CI runner) linking the objects with
glibc and running the test programs and SQLite would be the end-to-end
proof.

## Not yet

- Mach-O object files (writing): Mach-O relocations carry addends in a
  separate `ARM64_RELOC_ADDEND`, and the file is laid out by load commands.
  With it, object files could be linked and run on this machine.
- `.eh_frame` unwind tables, and debug info.
- Weak and `linkonce` definitions (written as global), common symbols,
  thread-local storage, and sections chosen by attribute.
- Disassembling instructions the description does not have (`ldp`, `stp`,
  pointer authentication, system instructions): they print as `.word`.
