# A matrix product, lowered to SME

`matmul.mlir` is C[16, 20] = A[16, 4] B[4, 20] as torch-mlir writes a
matrix product: `linalg.fill` of zero, then `linalg.matmul`, on tensors.
These files are each stage of its lowering by Epitome, made with:

```sh
P=linalg-generalize-named-ops,bufferize,linalg-to-kernels=aarch64-sme,linalg-to-loops,to-llvm
epitome-mlir-opt matmul.mlir --pass=<the first n of P>     # stage<n>-*.mlir
epitome-mlir-translate matmul.mlir --pass=$P -o matmul.ll
epitome-opt -O2 matmul.ll -o matmul.opt.ll
epitome-llc --mcpu=apple-m4 matmul.opt.ll -o matmul.s
```

| File | Stage |
| --- | --- |
| `stage1-linalg-generalize-named-ops.mlir` | `linalg.matmul` becomes `linalg.generic`, its indexing maps written out |
| `stage2-bufferize.mlir` | memrefs; the result an argument; the fill and the product written in place in one buffer |
| `stage3-linalg-to-kernels.mlir` | the product as calls to the SME kernel from `mlir/targets/aarch64-sme.mlir`, a 16 x 16 tile at a time: A packed transposed, pointers to each tile, and the width of the last tile (4) |
| `stage4-linalg-to-loops.mlir` | the fill and the packing as `scf.for` loops |
| `stage5-to-llvm.mlir` | the `llvm` dialect: branches between blocks, `malloc` and `free`, bare pointers |
| `matmul.ll`, `matmul.opt.ll` | LLVM IR, and after `epitome-opt` |
| `matmul.s` | AArch64 for Apple M4: in the kernel, `smstart`, a row of C into each slice of `za0.s`, `ld1w`, `ld1w`, `fmopa` for each k, the slices back to C, `smstop`; `d8`-`d15` saved, as `smstart` zeroes them |

The object, linked with a Rust driver, gives the same product as a plain
one (`mlir/tests/sme.rs` checks a larger one).
