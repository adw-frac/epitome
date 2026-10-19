#!/bin/sh
# Writes smoke.ll from smoke.c: clang's IR (-O2, vectorised), without the
# target-specific parts (triple, data layout, attributes naming a CPU or
# features), so that any description may compile it.
cd "$(dirname "$0")"
clang --target=aarch64-linux-gnu -O2 -fno-unroll-loops -S -emit-llvm smoke.c -o - |
  sed -E -e '/^target (triple|datalayout)/d' \
         -e 's/ "target-(cpu|features)"="[^"]*"//g' \
         -e '/^!llvm.ident/d' -e '/^![0-9]+ = !\{!"(clang version|Apple clang)/d' > smoke.ll
