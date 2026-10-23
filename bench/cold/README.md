# Cold code

Code that runs rarely (error paths, set-up, the long tail of a program) is
mostly not in the instruction cache when it runs, so the time it takes is
mostly the time to fetch it: smaller code is faster, and code whose blocks
run in order touches fewer cache lines.

`coldgen.py` writes N distinct functions of cold code's shape: loads and
stores of a state's fields, arithmetic, diamonds of branches, and calls of
helpers with several arguments, so that values live across calls.
`cold.c` calls each once a round, through a table, and prints a checksum
of their results and the best time a call over the rounds. `run.sh` builds
the same functions with `epitome-llc` and with rustup's `llc -O3`, and
prints each one's text size, checksum (the two must agree) and time:

```sh
cargo build --release
bench/cold/run.sh 3000      # about a megabyte: past the L1 instruction cache
bench/cold/run.sh 60000     # about twenty: past the last-level cache
```

Times are only comparable on an otherwise idle machine.
