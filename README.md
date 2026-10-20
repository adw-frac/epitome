# Epitome of synaptic excellence

Epitome of synaptic excellence (Epitome for short) is a clean-room,
functional clone of LLVM, written in Rust.

## Clean-room policy

Epitome is built only from public specifications and documented behaviour,
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

- `ir` (`epitome-ir`): the IR, with a parser and printer for `.ll` files.
- `opt` (`epitome-opt`): optimisation passes, run on many functions in
  parallel. So far: the call graph, an inliner with a cost model,
  recursion removal, and a rule-driven combiner whose rules are in
  `opt/rules/combine.rules`. See `docs/design/parallel.md` and
  `docs/design/combine.md`.
- `codegen` (`epitome-codegen`): code generation from machine
  descriptions written in LLVM IR: instruction selection, register
  allocation, frames, and assembly, object files (Mach-O and ELF) and
  disassembly; `epitome-as` assembles, and `epitome-objdump`
  disassembles. AArch64 (`codegen/targets/aarch64/*.ll`) is built in;
  other machines and CPUs are description files read at run time, such as
  RISC-V RV64 (`codegen/targets/riscv64/`). See `docs/design/isel.md`,
  `docs/design/targets.md` and `docs/design/objects.md`.

## Running

```sh
# Read a .ll file and print it back.
cargo run --release -- file.ll

# Inline and remove recursion, using every core, explaining each decision.
cargo run --release -p epitome-opt -- -O2 --remarks --print-cycles --stats file.ll
```

```sh
# Compile to AArch64 assembly (Darwin), or show the machine code.
cargo run --release -p epitome-codegen --bin epitome-llc -- file.ll -o file.s
cargo run --release -p epitome-codegen --bin epitome-llc -- file.ll --disasm

# Compile to an object file (Mach-O here; ELF with --abi=aapcs64), link it
# and run it, and disassemble it with its relocations.
cargo run --release -p epitome-codegen --bin epitome-llc -- file.ll -o file.o
clang file.o main.c -o program && ./program
cargo run --release -p epitome-codegen --bin epitome-objdump -- -dr file.o

# Assemble assembly (epitome-llc's) into an object file.
cargo run --release -p epitome-codegen --bin epitome-as -- file.s -o file.o

# Another machine, from its description's files; with a CPU and features.
cargo run --release -p epitome-codegen --bin epitome-llc -- \
    --target=codegen/targets/riscv64 --mattr=+zbb file.ll -o file.o
cargo run --release -p epitome-codegen --bin epitome-llc -- --mcpu=apple-m1 --mattr=-neon file.ll

# Or by name, from the directories in EPITOME_TARGET_PATH (and objdump
# finds a description there by the object's ELF machine).
export EPITOME_TARGET_PATH=$PWD/codegen/targets
cargo run --release -p epitome-codegen --bin epitome-objdump -- -d file.o
```

`epitome-opt --help` lists the options. `opt/tests/examples` has small
inputs with their expected output.

## License

Copyright (c) 2026 Amy Thomason. No license has been chosen yet; see
[LICENSE](LICENSE).
