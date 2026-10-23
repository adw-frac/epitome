# Epitome of synaptic excellence

Epitome of synaptic excellence (Epitome for short) is an alternative code
generation tool, written in Rust, that takes LLVM IR as its input. It is
not a clone of LLVM: it reads and writes the same IR, and its tools take
the same kinds of input and give the same kinds of output, but how it gets
there is its own.

**256 crates' own test suites pass with their code compiled by Epitome**
(on an AArch64 Mac; see [Crates that build](#crates-that-build)).

> **Experimental.** Epitome is young and changes quickly, and it is
> suitable only for the adventurous at the moment: expect missing features,
> rough edges and bugs, and check its output before relying on it.

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

## Crates that build

These crates' own tests (`cargo test --release`) pass with their code,
and their dependencies', compiled by Epitome through `epitome-rustc` (see
[Building Rust crates with Epitome](#building-rust-crates-with-epitome)),
on an AArch64 Mac with Rust 1.99.1: 256 crates, at the versions given.
chrono's pass too, but for 8 tests of time-zone files its package leaves
out. Crates whose tests fail for reasons of their own (files or crates
missing from the package, or failing under plain rustc) are not listed.

- **a**: adler2 2.0.1, ahash 0.8.12, aho-corasick 1.1.5, allocator-api2 0.4.0, anstyle 1.0.14, anyhow 1.0.104, approx 0.5.1, arbitrary 1.4.2, arrayref 0.3.9, arrayvec 0.7.8, assert_matches 1.5.0, async-channel 2.5.0, async-lock 3.4.2, async-task 4.7.1, atomic-waker 1.1.2
- **b**: base64 0.22.1, bincode 1.3.3, bit-set 0.9.1, bit-vec 0.9.1, bit_field 0.10.1, bitflags 2.13.2, bitstream-io 4.9.0, bitvec 1.0.1, block-buffer 0.12.1, bumpalo 3.20.3, bytecount 0.6.9, bytemuck 1.25.2, byteorder 1.5.0, bytes 1.12.1
- **c**: castaway 0.2.4, cfg-if 1.0.5, chacha20 0.10.2, cipher 0.5.2, cobs 0.3.0, color_quant 1.1.0, colorchoice 1.0.5, combine 4.6.8, compact_str 0.9.1, concurrent-queue 2.5.0, const-oid 0.10.2, constant_time_eq 0.4.2, crc32fast 1.5.3, crossbeam-channel 0.5.17, crossbeam-deque 0.8.8, crossbeam-epoch 0.9.21, crossbeam-queue 0.3.14, crossbeam-utils 0.8.23, crunchy 0.2.4, crypto-common 0.2.2, csv 1.4.0, csv-core 0.1.13, ctor 1.0.13
- **d**: dary_heap 0.3.9, data-encoding 2.11.1, deranged 0.5.9, diff 0.1.13, dissimilar 1.0.11, downcast-rs 2.0.2, dunce 1.0.5
- **e**: either 1.19.0, encode_unicode 1.0.0, encoding_rs 0.8.42, env_logger 0.11.11, equivalent 1.0.3, erased-serde 0.4.10, errno 0.3.14, euclid 0.22.14, event-listener 5.4.2
- **f**: fallible-iterator 0.3.0, fallible-streaming-iterator 0.1.9, fancy-regex 0.18.0, faster-hex 0.5.0, fastrand 2.5.0, fixedbitset 0.5.7, flate2 1.1.10, float-ord 0.3.0, flume 0.12.0, fnv 1.0.7, foldhash 0.2.0, foreign-types-shared 0.3.1, form_urlencoded 1.2.2, futures-lite 2.6.1, fxhash 0.2.1
- **g**: gethostname 1.1.0, gimli 0.34.0, glam 0.32.1, glob 0.3.4, globset 0.4.20
- **h**: half 2.7.1, hash32 0.3.1, hashbrown 0.17.1, hashlink 0.9.1, heapless 0.9.3, heck 0.5.0, hex 0.4.3, hexf-parse 0.2.1, hmac 0.13.0, httparse 1.10.1, httpdate 1.0.3, humantime 2.4.0
- **i**: ident_case 1.0.1, indexmap 2.14.2, inout 0.2.2, inventory 0.3.24, ipnet 2.12.2, itertools 0.14.0, itoa 1.0.18
- **j**: jobserver 0.1.35
- **l**: lexopt 0.3.1, libc 0.2.191, lock_api 0.4.14, log 0.4.34, lru-slab 0.1.3, lz4_flex 0.13.1
- **m**: matchers 0.2.0, matches 0.1.10, matrixmultiply 0.3.11, memchr 2.8.3, memmap2 0.9.11, memoffset 0.6.5, mime_guess 2.0.5, minimal-lexical 0.2.1, miniserde 0.1.45, miniz_oxide 0.9.1, multimap 0.10.1
- **n**: nb 1.1.0, nonmax 0.5.5, num-bigint 0.5.1, num-complex 0.4.6, num-conv 0.2.2, num-integer 0.1.47, num-iter 0.1.46, num-rational 0.4.2, num-traits 0.2.19
- **o**: once_cell 1.21.4, once_cell_polyfill 1.70.2, oneshot 0.1.13, oorandom 11.1.5, option-ext 0.2.0, ordered-float 5.5.0, os_str_bytes 6.6.1, owning_ref 0.4.1
- **p**: page_size 0.6.0, parking 2.2.1, parking_lot 0.12.5, pathdiff 0.2.3, percent-encoding 2.3.2, pest 2.8.0, petgraph 0.8.3, phf_shared 0.12.1, pico-args 0.5.0, pin-utils 0.1.0, piper 0.2.5, postcard 1.1.3, powerfmt 0.2.1, ppv-lite86 0.2.21, pulldown-cmark 0.9.6
- **q**: quick-error 2.0.1, quick-xml 0.41.0
- **r**: radium 0.7.0, radsort 0.1.1, rand 0.10.3, rand_chacha 0.9.0, rand_core 0.10.1, rand_distr 0.6.0, rand_isaac 0.3.0, rand_pcg 0.10.2, rand_xorshift 0.5.0, rand_xoshiro 0.8.0, rawpointer 0.2.1, rayon 1.12.0, regex-syntax 0.8.11, rgb 0.8.53, ron 0.12.2, rustc-demangle 0.1.27, rustc-hash 2.1.3, rustc-hex 2.1.0, rustc_version 0.4.1, ryu 1.0.23
- **s**: same-file 1.0.6, scoped-tls 1.0.1, scopeguard 1.2.0, seahash 4.1.0, semver 1.0.28, semver-parser 0.7.0, send_wrapper 0.6.0, serde-value 0.7.0, serde_bytes 0.11.19, serde_cbor 0.11.2, serde_json 1.0.154, serde_plain 1.0.2, serde_repr 0.1.21, serde_urlencoded 0.7.1, sha1 0.11.0, sha2 0.11.0, sharded-slab 0.1.7, shellexpand 3.1.2, shlex 2.0.1, simba 0.9.1, simdutf8 0.1.5, siphasher 1.0.3, slab 0.4.12, slotmap 1.1.1, smallvec 1.16.3, smawk 0.3.2, smol_str 0.2.2, snap 1.1.1, spin 0.10.1, spin_on 0.1.1, stable_deref_trait 1.2.1, static_assertions 1.1.0, statrs 0.18.0, strsim 0.11.1, subtle 2.6.1, symlink 0.1.0
- **t**: tap 1.0.1, target-lexicon 0.13.5, termcolor 1.4.1, textwrap 0.16.1, thiserror 2.0.21, thousands 0.2.0, thread_local 1.1.10, tinystr 0.8.4, tinytemplate 1.2.1, tinyvec 1.13.3, toml 1.1.8+spec-1.1.0, toml_edit 0.25.15+spec-1.1.0, twox-hash 2.1.5, typed-path 0.12.4, typeid 1.0.3, typenum 1.20.1, typetag 0.2.14
- **u**: unicase 2.10.0, unicode-bidi 0.3.18, unicode-linebreak 0.1.5, unicode-normalization 0.1.25, unicode-segmentation 1.13.3, unicode-width 0.2.2, unicode-xid 0.2.6, unicode_categories 0.1.1, untrusted 0.9.0, url 2.5.8, urlencoding 2.1.3, utf16_iter 1.0.5, utf8-zero 0.8.1, utf8_iter 1.0.4, utf8parse 0.2.2, uuid 1.26.1
- **v**: vec_map 0.8.2, version_check 0.9.5
- **w**: walkdir 2.5.0, wide 0.7.33, winnow 1.0.4
- **y**: yansi 1.0.1
- **z**: zeroize 1.9.1, zmij 1.0.23
