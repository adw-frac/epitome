# Epitome of synaptic excellence

Epitome of synaptic excellence (Epitome for short) is an alternative code
generation tool, written in Rust, that takes LLVM IR as its input. It is
not a clone of LLVM: it reads and writes the same IR, and its tools take
the same kinds of input and give the same kinds of output, but how it gets
there is its own.

- **Its own passes and algorithms.** The pass structure differs from
  LLVM's. Much of what LLVM does in separate passes (instcombine,
  reassociate, DSE, parts of GVN and memcpyopt) is one rule-driven
  combiner here, with its rules in a small language
  (`opt/rules/combine.rules`), and memory dependences are found on demand
  rather than kept up to date.
- **Data-driven code generation.** A machine is a description written as
  LLVM IR: each instruction is a function whose body says what it
  computes, with its encoding and assembly as attributes. Selection,
  encoding, assembly, disassembly and the checks are all made from it, so a
  new machine or CPU is a set of description files, not new code
  (`codegen/targets/`).
- **Multithreaded throughout.** Optimisation runs on many functions at
  once, in call-graph order, and so does code generation; the output is
  the same for any number of threads.
- **Large basic blocks.** Special attention is paid to compiling very large
  basic blocks, such as those generated from SystemVerilog by simulators:
  every pass is kept close to linear in a block's size, with budgets on the
  searches that could grow, and tests check that time grows in proportion
  as blocks and functions grow (`opt/tests/scaling.rs`,
  `codegen/tests/parallel.rs`).

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

- `epitome` (the root package): `epitome-rustc`, which builds Rust crates
  with Epitome (see below), and `examples/factorial.rs`.
- `ir` (`epitome-ir`): the IR, with a parser and printer for `.ll` files,
  and builders for making it in code (`epitome_ir::build`).
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
# Build a factorial function and a main in code, optimise and compile them,
# then link and run the program (needs clang).
cargo run --release --example factorial -- --run

# Run a Rust crate's tests with its code compiled by Epitome (from this
# directory; see "Building Rust crates with Epitome").
cargo build --release --bin epitome-rustc
W=$PWD/target/release/epitome-rustc
(cd /path/to/some-crate && RUSTC_WRAPPER=$W cargo test)

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

## Building IR in code

`epitome_ir::build` has chained builders for functions and globals
(`Function::builder`, `Global::builder`), and a `FunctionBuilder` that adds
instructions at the end of the current block, working out result types and
checking operands. Instructions with settings are chained too
(`build_call`, `build_load`, `build_store`, `build_gep`, `build_binary`):

```rust
use epitome_ir::module::{BinOp, Function, ICmpPred, Linkage, Module};

let mut m = Module::default();
let i64t = m.types.int(64);
let mut b = Function::builder("max")
    .returns(i64t)
    .param("a", i64t)
    .param("b", i64t)
    .linkage(Linkage::Internal)
    .attr("nounwind")
    .begin(&mut m);
let (x, y) = (b.param(0), b.param(1));
b.block("entry");
let gt = b.icmp(ICmpPred::Sgt, x, y);
let r = b.select(gt, x, y);
let r1 = b.build_binary(BinOp::Add, r, x).nsw().build();
b.ret(r1);
b.finish()?; // every block must end in a terminator
```

There are plain constructors as well (`Types::function`, `Constant::int`,
`Call::new`, `Global::variable`, `Module::declare`, `Module::const_int`).
The module can then go to `epitome_opt::pipeline::run` and
`epitome_codegen::compile` like a parsed one. `examples/factorial.rs`
builds a factorial function and a `main` that prints some factorials,
optimises and compiles them, and with `--run` links and runs the program:

```sh
cargo run --release --example factorial -- --run
```

## Building Rust crates with Epitome

`epitome-rustc` (in this package) is a `RUSTC_WRAPPER`: Cargo runs it with
each rustc command line. It runs rustc as asked, also writing the crate's
LLVM IR in one codegen unit, compiles that IR with Epitome, and puts our
object in place of rustc's: in the `.rlib` for a library, and at the link
(it is given as rustc's linker) for a binary or test harness.

```sh
cargo build --release --bin epitome-rustc
cd some-crate
RUSTC_WRAPPER=/path/to/epitome/target/release/epitome-rustc cargo test
cat target/debug/epitome-rustc.log   # which crates are ours, and why not
```

Rust's standard library comes built and stays LLVM's, and so do
proc-macro crates and build scripts (`EPITOME_RUSTC_BUILD_SCRIPTS=1` takes
build scripts too). A crate whose IR Epitome cannot compile yet keeps
rustc's object, and the log says why. `EPITOME_RUSTC_OPT=1` runs Epitome's
optimiser on rustc's unoptimised IR as well; `EPITOME_RUSTC_SKIP` and
`EPITOME_RUSTC_ONLY` take comma-separated crate names. This is a wrapper,
not a rustc codegen backend (`-Zcodegen-backend`), which would have to be
built against rustc's internals and turn its MIR into our IR.

## License

Copyright (c) 2026 Amy Thomason. No license has been chosen yet; see
[LICENSE](LICENSE).
