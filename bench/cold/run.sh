#!/bin/bash
# Cold code, by size and by speed: N functions of coldgen.py's shape, each
# called once a round, built by epitome-llc and by rustup's llc -O3, run,
# and their text sizes and nanoseconds a call printed. With enough
# functions (3000 is about a megabyte, past the instruction cache; 60000
# about twenty, past the last level), none is in the cache when it is
# called, so the time is mostly fetching it.
#
#   bench/cold/run.sh N [ROUNDS]     (from the repository's root, after
#                                     cargo build --release)
set -e
N=${1:-3000}; R=${2:-10}
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../.." && pwd)
host=$(rustc -vV | sed -n 's/^host: //p')
bin=$(rustc --print sysroot)/lib/rustlib/$host/bin
out=${COLD_OUT:-$root/target/cold}
mkdir -p "$out"
[ -f "$out/gen$N.ll" ] || python3 "$here/coldgen.py" "$N" 1 "$out/gen$N.ll" "$(clang -print-target-triple)"
"$root/target/release/epitome-llc" "$out/gen$N.ll" -o "$out/ours$N.o"
"$bin/llc" -O3 -filetype=obj "$out/gen$N.ll" -o "$out/llc$N.o"
for w in ours llc; do
  clang -O2 "$here/cold.c" "$out/$w$N.o" -o "$out/$w$N"
  text=$("$bin/llvm-size" -A "$out/$w$N.o" | awk '/text/{s+=$2} END{print s}')
  echo "$w text=$text $("$out/$w$N" "$R")"
done
