# draconian-measurement-with-love

A clean-room, functional clone of LLVM, written in Rust.

## Clean-room policy

Draconian is built only from public specifications and documented behaviour,
such as the LLVM Language Reference, the IR and bitcode format documentation,
and the observable behaviour of the tools. No LLVM source code is read,
copied or translated into this project.

## Building

```sh
cargo build
cargo test
```

## License

Copyright (c) 2026 Amy Thomason. No license has been chosen yet; see
[LICENSE](LICENSE).
