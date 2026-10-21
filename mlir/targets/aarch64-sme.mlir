// Kernels for AArch64 with the Scalable Matrix Extension: data for
// `mlir/src/linalg_kernels.rs` (`--pass=linalg-to-kernels=aarch64-sme`).
// See docs/design/mlir.md, section 5.8.
//
// An `epitome.kernel` says which `linalg.generic` a kernel computes (its
// indexing maps, its iterators, the operations of its body, and the element
// type), how big a tile of the output one call computes, and which function
// does it. The pass multiplies by tiles: it packs the first input
// transposed, so that its columns are rows, then calls the function for each
// tile of the output; rows left over at the edge are left to a
// `linalg.generic` (and so to loops), and the last tile of columns may be
// narrower, which the function's predicate handles.
//
// The function takes (c, ldc, at, lda, b, ldb, k, cols): pointers to the
// output tile, to the transposed first input's tile and to the second
// input's tile, each with its row stride in elements; the length of the sum;
// and how many of the tile's columns are in the matrix. It works out
// C[16, cols] += AT[k, 16]^T B[k, cols] with outer products into ZA, using
// the intrinsics of the code generator's 45-sme.ll.
//
// A tile of 32-bit elements is 16 x 16 when the streaming vector length is
// 512 bits, as on Apple's M4.

"epitome.kernel"() <{op = "matmul", element = f32,
    indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d2, d1)>,
                     affine_map<(d0, d1, d2) -> (d0, d1)>],
    iterator_types = ["parallel", "parallel", "reduction"],
    body = ["arith.mulf", "arith.addf"],
    tile = array<i64: 16, 16>,
    function = @__epitome_sme_matmul_f32}> : () -> ()

// The same for each matrix of a batch: the pass takes views of each.
"epitome.kernel"() <{op = "batch_matmul", element = f32,
    indexing_maps = [affine_map<(d0, d1, d2, d3) -> (d0, d1, d3)>, affine_map<(d0, d1, d2, d3) -> (d0, d3, d2)>,
                     affine_map<(d0, d1, d2, d3) -> (d0, d1, d2)>],
    iterator_types = ["parallel", "parallel", "parallel", "reduction"],
    body = ["arith.mulf", "arith.addf"],
    tile = array<i64: 16, 16>,
    function = @__epitome_sme_matmul_f32}> : () -> ()

// Not inlined: streaming mode, and the saves it needs, stay in it.
func.func private @__epitome_sme_matmul_f32(%c: !llvm.ptr, %ldc: i64, %at: !llvm.ptr, %lda: i64, %b: !llvm.ptr, %ldb: i64, %k: i64, %cols: i64) attributes {llvm.no_inline} {
  // Streaming mode and ZA on; p0 all lanes, p1 the tile's columns.
  "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.start"}> : () -> ()
  "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.ptrue.p0.s"}> : () -> ()
  "llvm.call_intrinsic"(%cols) <{intrin = "llvm.epitome.sme.whilelt.p1.s"}> : (i64) -> ()
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %rows = arith.constant 16 : index
  // The output's tile into za0.s, a row at a time.
  "scf.for"(%c0, %rows, %c1) ({
  ^bb0(%r: index):
    %ri = arith.index_cast %r : index to i64
    %off = "llvm.mul"(%ri, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %row = "llvm.getelementptr"(%c, %off) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %slice = arith.trunci %ri : i64 to i32
    "llvm.call_intrinsic"(%row, %slice) <{intrin = "llvm.epitome.sme.ld1w.za0h.s"}> : (!llvm.ptr, i32) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  // za0.s += column i of A (row i of AT) times row i of B, for each i.
  %n = arith.index_cast %k : i64 to index
  "scf.for"(%c0, %n, %c1) ({
  ^bb0(%i: index):
    %ii = arith.index_cast %i : index to i64
    %ao = "llvm.mul"(%ii, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %ap = "llvm.getelementptr"(%at, %ao) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %bo = "llvm.mul"(%ii, %ldb) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %bp = "llvm.getelementptr"(%b, %bo) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.call_intrinsic"(%ap, %bp) <{intrin = "llvm.epitome.sme.fmopa.za0.s"}> : (!llvm.ptr, !llvm.ptr) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  // za0.s back to the output, a row at a time.
  "scf.for"(%c0, %rows, %c1) ({
  ^bb0(%r: index):
    %ri = arith.index_cast %r : index to i64
    %off = "llvm.mul"(%ri, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %row = "llvm.getelementptr"(%c, %off) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %slice = arith.trunci %ri : i64 to i32
    "llvm.call_intrinsic"(%row, %slice) <{intrin = "llvm.epitome.sme.st1w.za0h.s"}> : (!llvm.ptr, i32) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.stop"}> : () -> ()
  return
}
