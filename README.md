# smaugian-reduction

A clean-room, functional clone of LLVM, written in Rust.

## Clean-room policy

Smaugian is built only from public specifications and documented behaviour,
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

- `ir` (`smaugian-ir`): the IR, with a parser and printer for `.ll` files.
- `opt` (`smaugian-opt`): optimisation passes, run on many functions in
  parallel. So far: the call graph, an inliner with a cost model,
  recursion removal, and a rule-driven combiner whose rules are in
  `opt/rules/combine.rules`. See `docs/design/parallel.md` and
  `docs/design/combine.md`.

## Running

```sh
# Read a .ll file and print it back.
cargo run --release -- file.ll

# Inline and remove recursion, using every core, explaining each decision.
cargo run --release -p smaugian-opt -- -O2 --remarks --print-cycles --stats file.ll
```

`smaugian-opt --help` lists the options. `opt/tests/examples` has small
inputs with their expected output.

## License

Copyright (c) 2026 Amy Thomason. No license has been chosen yet; see
[LICENSE](LICENSE).
