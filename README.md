# draconian-measurement

A clean-room, functional clone of LLVM, written in Rust.

## Clean-room policy

Draconian is built only from public specifications and documented behaviour,
such as the LLVM Language Reference, the IR and bitcode format documentation,
and the observable behaviour of the tools. No LLVM source code is read,
copied or translated into this project.

## Building

```sh
cargo build --release --workspace
cargo test --release --workspace
```

The tests in `opt/tests/programs.rs` and `opt/tests/examples.rs` also build
and run their output with `clang` when it is installed.

## Crates

- `ir` (`draconian-ir`): the IR, with a parser and printer for `.ll` files.
- `opt` (`draconian-opt`): optimisation passes, run on many functions in
  parallel. So far: the call graph, an inliner with a cost model,
  recursion removal, and a rule-driven combiner whose rules are in
  `opt/rules/combine.rules`. See `docs/design/parallel.md` and
  `docs/design/combine.md`.
- `codegen` (`draconian-codegen`): AArch64 code generation from a machine
  description written in LLVM IR (`codegen/targets/aarch64.ll`):
  instruction selection, register allocation, frames, and assembly, ELF
  object files and disassembly; `draconian-objdump` reads ELF and Mach-O.
  See `docs/design/isel.md` and `docs/design/objects.md`.

## Running

```sh
# Read a .ll file and print it back.
cargo run --release -- file.ll

# Inline and remove recursion, using every core, explaining each decision.
cargo run --release -p draconian-opt -- -O2 --remarks --print-cycles --stats file.ll
```

```sh
# Compile to AArch64 assembly (Darwin), or show the machine code.
cargo run --release -p draconian-codegen --bin draconian-llc -- file.ll -o file.s
cargo run --release -p draconian-codegen --bin draconian-llc -- file.ll --disasm

# Compile to an ELF object file (the convention must be ELF's), and
# disassemble it, with its relocations.
cargo run --release -p draconian-codegen --bin draconian-llc -- --abi=aapcs64 file.ll -o file.o
cargo run --release -p draconian-codegen --bin draconian-objdump -- -dr file.o
```

`draconian-opt --help` lists the options. `opt/tests/examples` has small
inputs with their expected output.

## License

Copyright (c) 2026 Amy Thomason. No license has been chosen yet; see
[LICENSE](LICENSE).
