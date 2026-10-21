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

// Matrix products in BF16 ("weights = bf16"), for B a constant: as
// @__epitome_sme_matmul_f32_64, but with B packed as BF16, each 64-column
// panel k/2 rows of 64 pairs (rows k and k + 1 of a column, in the bottom
// and top half of a word), and A rounded to BF16 as it is transposed (a
// row of 32 f32 becomes 16 pairs in a slice of za0.s, stored a column of
// pairs at a time). bfmopa adds both products of a pair into each f32 of
// ZA, so a weight is half the bytes and each instruction does twice the
// work. The pass uses it only for B whose columns are whole panels and k a
// multiple of 32; ldb and panel are then in words (64, and 32 k).
"epitome.kernel"() <{op = "matmul", element = f32, weights = "bf16",
    indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d2, d1)>,
                     affine_map<(d0, d1, d2) -> (d0, d1)>],
    iterator_types = ["parallel", "parallel", "reduction"],
    body = ["arith.mulf", "arith.addf"],
    tile = array<i64: 64, 16>, whole_rows, pack_b = 64, transpose_a,
    function = @__epitome_sme_matmul_bf16_64}> : () -> ()

func.func private @__epitome_sme_matmul_bf16_64(%c: !llvm.ptr, %ldc: i64, %a: !llvm.ptr, %lda: i64, %at: !llvm.ptr, %b: !llvm.ptr, %ldb: i64, %k: i64, %n: i64, %panel: i64) attributes {llvm.no_inline} {
  "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.start"}> : () -> ()
  "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.ptrue.p0.h"}> : () -> ()
  "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.ptrue.p1.h"}> : () -> ()
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c4 = arith.constant 4 : index
  %c16 = arith.constant 16 : index
  %c32 = arith.constant 32 : index
  %c64 = arith.constant 64 : index
  %all = arith.constant 16 : i64
  %ld64 = "llvm.mlir.constant"() <{value = 64 : i64}> : () -> i64
  %one = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
  %ni = arith.index_cast %n : i64 to index
  %ki = arith.index_cast %k : i64 to index
  %c2 = arith.constant 2 : index
  %kp = arith.divui %ki, %c2 : index
  // A as BF16 pairs, transposed a word at a time: AT[k/2][64].
  "scf.for"(%c0, %ki, %c32) ({
  ^bb0(%tk: index):
    %tkk = arith.index_cast %tk : index to i64
    %tkp = "llvm.lshr"(%tkk, %one) : (i64, i64) -> i64
    %ta = "llvm.getelementptr"(%a, %tkk) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %tto = "llvm.mul"(%tkp, %ld64) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %tt = "llvm.getelementptr"(%at, %tto) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "scf.for"(%c0, %c4, %c1) ({
    ^bb0(%tq: index):
      %tqq = arith.index_cast %tq : index to i64
      %trow0 = "llvm.mul"(%tqq, %all) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %tro = "llvm.mul"(%trow0, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %tab = "llvm.getelementptr"(%ta, %tro) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %ttb = "llvm.getelementptr"(%tt, %trow0) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      "scf.for"(%c0, %c16, %c1) ({
      ^bb0(%tr: index):
        %tri = arith.index_cast %tr : index to i64
        %ts = arith.trunci %tri : i64 to i32
        %tro2 = "llvm.mul"(%tri, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %tp = "llvm.getelementptr"(%tab, %tro2) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
        "llvm.call_intrinsic"(%tp, %ts) <{intrin = "llvm.epitome.sme.bf16.row.za0h"}> : (!llvm.ptr, i32) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.for"(%c0, %c16, %c1) ({
      ^bb0(%tr: index):
        %tri = arith.index_cast %tr : index to i64
        %ts = arith.trunci %tri : i64 to i32
        %tro2 = "llvm.mul"(%tri, %ld64) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %tp = "llvm.getelementptr"(%ttb, %tro2) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
        "llvm.call_intrinsic"(%tp, %ts) <{intrin = "llvm.epitome.sme.st1w.za0v.s"}> : (!llvm.ptr, i32) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  "scf.for"(%c0, %ni, %c64) ({
  ^bb0(%wj: index):
    %wjj = arith.index_cast %wj : index to i64
    %wcj = "llvm.getelementptr"(%c, %wjj) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %six = "llvm.mlir.constant"() <{value = 6 : i64}> : () -> i64
    %wpn = "llvm.lshr"(%wjj, %six) : (i64, i64) -> i64
    %wpo = "llvm.mul"(%wpn, %panel) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %wbj = "llvm.getelementptr"(%b, %wpo) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "scf.for"(%c0, %c4, %c1) ({
    ^bb0(%wq: index):
      %wqq = arith.index_cast %wq : index to i64
      %wrow0 = "llvm.mul"(%wqq, %all) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %wco = "llvm.mul"(%wrow0, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %wci = "llvm.getelementptr"(%wcj, %wco) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %wai = "llvm.getelementptr"(%at, %wrow0) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      // C's 16 x 64 block into za0.s-za3.s, a row of each at a time.
      "scf.for"(%c0, %c16, %c1) ({
      ^bb0(%wr: index):
        %wri = arith.index_cast %wr : index to i64
        %ws = arith.trunci %wri : i64 to i32
        %wro = "llvm.mul"(%wri, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %wrow = "llvm.getelementptr"(%wci, %wro) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          %wt0 = arith.constant 0 : i64
          %wp0 = "llvm.getelementptr"(%wrow, %wt0) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp0, %ws) <{intrin = "llvm.epitome.sme.ld1w.za0h.s"}> : (!llvm.ptr, i32) -> ()
          %wt1 = arith.constant 16 : i64
          %wp1 = "llvm.getelementptr"(%wrow, %wt1) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp1, %ws) <{intrin = "llvm.epitome.sme.ld1w.za1h.s"}> : (!llvm.ptr, i32) -> ()
          %wt2 = arith.constant 32 : i64
          %wp2 = "llvm.getelementptr"(%wrow, %wt2) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp2, %ws) <{intrin = "llvm.epitome.sme.ld1w.za2h.s"}> : (!llvm.ptr, i32) -> ()
          %wt3 = arith.constant 48 : i64
          %wp3 = "llvm.getelementptr"(%wrow, %wt3) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp3, %ws) <{intrin = "llvm.epitome.sme.ld1w.za3h.s"}> : (!llvm.ptr, i32) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.for"(%c0, %kp, %c1) ({
      ^bb0(%wi: index):
        %wii = arith.index_cast %wi : index to i64
        %wao = "llvm.mul"(%wii, %ld64) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %wap = "llvm.getelementptr"(%wai, %wao) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
        %wbo = "llvm.mul"(%wii, %ldb) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %wbp = "llvm.getelementptr"(%wbj, %wbo) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
        "llvm.call_intrinsic"(%wap, %wbp) <{intrin = "llvm.epitome.sme.bfmopa4w.za.s"}> : (!llvm.ptr, !llvm.ptr) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.for"(%c0, %c16, %c1) ({
      ^bb0(%wr: index):
        %wri = arith.index_cast %wr : index to i64
        %ws = arith.trunci %wri : i64 to i32
        %wro = "llvm.mul"(%wri, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %wrow = "llvm.getelementptr"(%wci, %wro) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          %wt0 = arith.constant 0 : i64
          %wp0 = "llvm.getelementptr"(%wrow, %wt0) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp0, %ws) <{intrin = "llvm.epitome.sme.st1w.za0h.s"}> : (!llvm.ptr, i32) -> ()
          %wt1 = arith.constant 16 : i64
          %wp1 = "llvm.getelementptr"(%wrow, %wt1) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp1, %ws) <{intrin = "llvm.epitome.sme.st1w.za1h.s"}> : (!llvm.ptr, i32) -> ()
          %wt2 = arith.constant 32 : i64
          %wp2 = "llvm.getelementptr"(%wrow, %wt2) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp2, %ws) <{intrin = "llvm.epitome.sme.st1w.za2h.s"}> : (!llvm.ptr, i32) -> ()
          %wt3 = arith.constant 48 : i64
          %wp3 = "llvm.getelementptr"(%wrow, %wt3) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp3, %ws) <{intrin = "llvm.epitome.sme.st1w.za3h.s"}> : (!llvm.ptr, i32) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.stop"}> : () -> ()
  "func.return"() : () -> ()
}

// Matrix products 64 rows at a time, with all four tiles of ZA: the
// function works out C[64, n] += AT[k, 64]^T B[k, n] for every column, in
// one stretch of streaming mode: 64 columns at a time (the tiles side by
// side, four 16-row blocks in turn), then 16 at a time (the tiles one above
// another). Its arguments are as above, but the last is the number of
// columns, n ("whole_rows"), and one more follows: how far apart, in
// elements, B's panels of 64 columns are. That is 64 for B as it is; when B
// is a constant, the pass may pack it into panels ("pack_b = 64"), each
// k x 64 and contiguous, which then lie 64 k apart with rows 64 apart (ldb),
// so that a weight streams from memory in one run. The function takes A
// as it is ("transpose_a"), not transposed: (c, ldc, a, lda, at, b, ldb, k,
// n, panel), at a buffer of k x 64 elements for the function to transpose
// A into, through ZA.
"epitome.kernel"() <{op = "matmul", element = f32,
    indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d2, d1)>,
                     affine_map<(d0, d1, d2) -> (d0, d1)>],
    iterator_types = ["parallel", "parallel", "reduction"],
    body = ["arith.mulf", "arith.addf"],
    tile = array<i64: 64, 16>, whole_rows, pack_b = 64, transpose_a,
    function = @__epitome_sme_matmul_f32_64}> : () -> ()

"epitome.kernel"() <{op = "batch_matmul", element = f32,
    indexing_maps = [affine_map<(d0, d1, d2, d3) -> (d0, d1, d3)>, affine_map<(d0, d1, d2, d3) -> (d0, d3, d2)>,
                     affine_map<(d0, d1, d2, d3) -> (d0, d1, d2)>],
    iterator_types = ["parallel", "parallel", "parallel", "reduction"],
    body = ["arith.mulf", "arith.addf"],
    tile = array<i64: 64, 16>, whole_rows, pack_b = 64, transpose_a,
    function = @__epitome_sme_matmul_f32_64}> : () -> ()

func.func private @__epitome_sme_matmul_f32_64(%c: !llvm.ptr, %ldc: i64, %a: !llvm.ptr, %lda: i64, %at: !llvm.ptr, %b: !llvm.ptr, %ldb: i64, %k: i64, %n: i64, %panel: i64) attributes {llvm.no_inline} {
  "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.start"}> : () -> ()
  "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.ptrue.p0.s"}> : () -> ()
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c16 = arith.constant 16 : index
  %ni = arith.index_cast %n : i64 to index
  %ki = arith.index_cast %k : i64 to index
  // 64 columns at a time while there are 64: for each, the four blocks of
  // 16 rows in turn, so that B's 64 x k panel comes from memory once, in
  // rows of 256 bytes, and from the cache for the other three blocks.
  %c64 = arith.constant 64 : index
  %c4 = arith.constant 4 : index
  %all = arith.constant 16 : i64
  // A transposed into AT (k x 64), a 16 x 16 block at a time through
  // za0.s: its rows loaded as horizontal slices, stored as vertical ones,
  // so that each k's column of A is a contiguous row of AT. The last block
  // of k may be narrower; p1 masks its columns.
  %ld64 = "llvm.mlir.constant"() <{value = 64 : i64}> : () -> i64
  "scf.for"(%c0, %ki, %c16) ({
  ^bb0(%tk: index):
    %tkk = arith.index_cast %tk : index to i64
    %tleft = arith.subi %ki, %tk : index
    %twidth = arith.minsi %tleft, %c16 : index
    %tw = arith.index_cast %twidth : index to i64
    "llvm.call_intrinsic"(%tw) <{intrin = "llvm.epitome.sme.whilelt.p1.s"}> : (i64) -> ()
    %ta = "llvm.getelementptr"(%a, %tkk) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %tto = "llvm.mul"(%tkk, %ld64) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %tt = "llvm.getelementptr"(%at, %tto) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "scf.for"(%c0, %c4, %c1) ({
    ^bb0(%tq: index):
      %tqq = arith.index_cast %tq : index to i64
      %trow0 = "llvm.mul"(%tqq, %all) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %tro = "llvm.mul"(%trow0, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %tab = "llvm.getelementptr"(%ta, %tro) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %ttb = "llvm.getelementptr"(%tt, %trow0) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      "scf.for"(%c0, %c16, %c1) ({
      ^bb0(%tr: index):
        %tri = arith.index_cast %tr : index to i64
        %ts = arith.trunci %tri : i64 to i32
        %tro2 = "llvm.mul"(%tri, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %tp = "llvm.getelementptr"(%tab, %tro2) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
        "llvm.call_intrinsic"(%tp, %ts) <{intrin = "llvm.epitome.sme.ld1w.za0h.s"}> : (!llvm.ptr, i32) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.for"(%c0, %twidth, %c1) ({
      ^bb0(%tr: index):
        %tri = arith.index_cast %tr : index to i64
        %ts = arith.trunci %tri : i64 to i32
        %tro2 = "llvm.mul"(%tri, %ld64) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %tp = "llvm.getelementptr"(%ttb, %tro2) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
        "llvm.call_intrinsic"(%tp, %ts) <{intrin = "llvm.epitome.sme.st1w.za0v.s"}> : (!llvm.ptr, i32) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  "llvm.call_intrinsic"(%all) <{intrin = "llvm.epitome.sme.whilelt.p1.s"}> : (i64) -> ()
  %nrem = arith.remsi %ni, %c64 : index
  %nwide = arith.subi %ni, %nrem : index
  "scf.for"(%c0, %nwide, %c64) ({
  ^bb0(%wj: index):
    %wjj = arith.index_cast %wj : index to i64
    %wcj = "llvm.getelementptr"(%c, %wjj) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %six = "llvm.mlir.constant"() <{value = 6 : i64}> : () -> i64
    %wpn = "llvm.lshr"(%wjj, %six) : (i64, i64) -> i64
    %wpo = "llvm.mul"(%wpn, %panel) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %wbj = "llvm.getelementptr"(%b, %wpo) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "scf.for"(%c0, %c4, %c1) ({
    ^bb0(%wq: index):
      %wqq = arith.index_cast %wq : index to i64
      %wrow0 = "llvm.mul"(%wqq, %all) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %wco = "llvm.mul"(%wrow0, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %wci = "llvm.getelementptr"(%wcj, %wco) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %wai = "llvm.getelementptr"(%at, %wrow0) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      // C's 16 x 64 block into za0.s-za3.s, a row of each at a time.
      "scf.for"(%c0, %c16, %c1) ({
      ^bb0(%wr: index):
        %wri = arith.index_cast %wr : index to i64
        %ws = arith.trunci %wri : i64 to i32
        %wro = "llvm.mul"(%wri, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %wrow = "llvm.getelementptr"(%wci, %wro) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          %wt0 = arith.constant 0 : i64
          %wp0 = "llvm.getelementptr"(%wrow, %wt0) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp0, %ws) <{intrin = "llvm.epitome.sme.ld1w.za0h.s"}> : (!llvm.ptr, i32) -> ()
          %wt1 = arith.constant 16 : i64
          %wp1 = "llvm.getelementptr"(%wrow, %wt1) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp1, %ws) <{intrin = "llvm.epitome.sme.ld1w.za1h.s"}> : (!llvm.ptr, i32) -> ()
          %wt2 = arith.constant 32 : i64
          %wp2 = "llvm.getelementptr"(%wrow, %wt2) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp2, %ws) <{intrin = "llvm.epitome.sme.ld1w.za2h.s"}> : (!llvm.ptr, i32) -> ()
          %wt3 = arith.constant 48 : i64
          %wp3 = "llvm.getelementptr"(%wrow, %wt3) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp3, %ws) <{intrin = "llvm.epitome.sme.ld1w.za3h.s"}> : (!llvm.ptr, i32) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.for"(%c0, %ki, %c1) ({
      ^bb0(%wi: index):
        %wii = arith.index_cast %wi : index to i64
        %wao = "llvm.mul"(%wii, %ld64) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %wap = "llvm.getelementptr"(%wai, %wao) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
        %wbo = "llvm.mul"(%wii, %ldb) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %wbp = "llvm.getelementptr"(%wbj, %wbo) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
        "llvm.call_intrinsic"(%wap, %wbp) <{intrin = "llvm.epitome.sme.fmopa4w.za.s"}> : (!llvm.ptr, !llvm.ptr) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.for"(%c0, %c16, %c1) ({
      ^bb0(%wr: index):
        %wri = arith.index_cast %wr : index to i64
        %ws = arith.trunci %wri : i64 to i32
        %wro = "llvm.mul"(%wri, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %wrow = "llvm.getelementptr"(%wci, %wro) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          %wt0 = arith.constant 0 : i64
          %wp0 = "llvm.getelementptr"(%wrow, %wt0) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp0, %ws) <{intrin = "llvm.epitome.sme.st1w.za0h.s"}> : (!llvm.ptr, i32) -> ()
          %wt1 = arith.constant 16 : i64
          %wp1 = "llvm.getelementptr"(%wrow, %wt1) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp1, %ws) <{intrin = "llvm.epitome.sme.st1w.za1h.s"}> : (!llvm.ptr, i32) -> ()
          %wt2 = arith.constant 32 : i64
          %wp2 = "llvm.getelementptr"(%wrow, %wt2) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp2, %ws) <{intrin = "llvm.epitome.sme.st1w.za2h.s"}> : (!llvm.ptr, i32) -> ()
          %wt3 = arith.constant 48 : i64
          %wp3 = "llvm.getelementptr"(%wrow, %wt3) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
          "llvm.call_intrinsic"(%wp3, %ws) <{intrin = "llvm.epitome.sme.st1w.za3h.s"}> : (!llvm.ptr, i32) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  // The columns left, 16 at a time, the four tiles one above another.
  // Each 64 x 16 block of C, the last perhaps narrower.
  "scf.for"(%nwide, %ni, %c16) ({
  ^bb0(%j: index):
    %left = arith.subi %ni, %j : index
    %w = arith.minsi %left, %c16 : index
    %cols = arith.index_cast %w : index to i64
    "llvm.call_intrinsic"(%cols) <{intrin = "llvm.epitome.sme.whilelt.p1.s"}> : (i64) -> ()
    %jj = arith.index_cast %j : index to i64
    %cj = "llvm.getelementptr"(%c, %jj) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %bj = "llvm.getelementptr"(%b, %jj) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    // C's block into za0.s-za3.s, a row of each at a time.
    "scf.for"(%c0, %c16, %c1) ({
    ^bb0(%r: index):
      %ri = arith.index_cast %r : index to i64
      %slice = arith.trunci %ri : i64 to i32
      %rt0 = arith.constant 0 : i64
      %rr0 = "llvm.add"(%ri, %rt0) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %ro0 = "llvm.mul"(%rr0, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %rp0 = "llvm.getelementptr"(%cj, %ro0) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      "llvm.call_intrinsic"(%rp0, %slice) <{intrin = "llvm.epitome.sme.ld1w.za0h.s"}> : (!llvm.ptr, i32) -> ()
      %rt1 = arith.constant 16 : i64
      %rr1 = "llvm.add"(%ri, %rt1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %ro1 = "llvm.mul"(%rr1, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %rp1 = "llvm.getelementptr"(%cj, %ro1) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      "llvm.call_intrinsic"(%rp1, %slice) <{intrin = "llvm.epitome.sme.ld1w.za1h.s"}> : (!llvm.ptr, i32) -> ()
      %rt2 = arith.constant 32 : i64
      %rr2 = "llvm.add"(%ri, %rt2) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %ro2 = "llvm.mul"(%rr2, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %rp2 = "llvm.getelementptr"(%cj, %ro2) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      "llvm.call_intrinsic"(%rp2, %slice) <{intrin = "llvm.epitome.sme.ld1w.za2h.s"}> : (!llvm.ptr, i32) -> ()
      %rt3 = arith.constant 48 : i64
      %rr3 = "llvm.add"(%ri, %rt3) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %ro3 = "llvm.mul"(%rr3, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %rp3 = "llvm.getelementptr"(%cj, %ro3) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      "llvm.call_intrinsic"(%rp3, %slice) <{intrin = "llvm.epitome.sme.ld1w.za3h.s"}> : (!llvm.ptr, i32) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    // For each k: a column of A (64 elements of AT) by a row of B.
    "scf.for"(%c0, %ki, %c1) ({
    ^bb0(%i: index):
      %ii = arith.index_cast %i : index to i64
      %ao = "llvm.mul"(%ii, %ld64) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %ap = "llvm.getelementptr"(%at, %ao) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %bo = "llvm.mul"(%ii, %ldb) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %bp = "llvm.getelementptr"(%bj, %bo) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      "llvm.call_intrinsic"(%ap, %bp) <{intrin = "llvm.epitome.sme.fmopa4.za.s"}> : (!llvm.ptr, !llvm.ptr) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    // The block back to C.
    "scf.for"(%c0, %c16, %c1) ({
    ^bb0(%r: index):
      %ri = arith.index_cast %r : index to i64
      %slice = arith.trunci %ri : i64 to i32
      %rt0 = arith.constant 0 : i64
      %rr0 = "llvm.add"(%ri, %rt0) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %ro0 = "llvm.mul"(%rr0, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %rp0 = "llvm.getelementptr"(%cj, %ro0) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      "llvm.call_intrinsic"(%rp0, %slice) <{intrin = "llvm.epitome.sme.st1w.za0h.s"}> : (!llvm.ptr, i32) -> ()
      %rt1 = arith.constant 16 : i64
      %rr1 = "llvm.add"(%ri, %rt1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %ro1 = "llvm.mul"(%rr1, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %rp1 = "llvm.getelementptr"(%cj, %ro1) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      "llvm.call_intrinsic"(%rp1, %slice) <{intrin = "llvm.epitome.sme.st1w.za1h.s"}> : (!llvm.ptr, i32) -> ()
      %rt2 = arith.constant 32 : i64
      %rr2 = "llvm.add"(%ri, %rt2) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %ro2 = "llvm.mul"(%rr2, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %rp2 = "llvm.getelementptr"(%cj, %ro2) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      "llvm.call_intrinsic"(%rp2, %slice) <{intrin = "llvm.epitome.sme.st1w.za2h.s"}> : (!llvm.ptr, i32) -> ()
      %rt3 = arith.constant 48 : i64
      %rr3 = "llvm.add"(%ri, %rt3) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %ro3 = "llvm.mul"(%rr3, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %rp3 = "llvm.getelementptr"(%cj, %ro3) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      "llvm.call_intrinsic"(%rp3, %slice) <{intrin = "llvm.epitome.sme.st1w.za3h.s"}> : (!llvm.ptr, i32) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.stop"}> : () -> ()
  return
}

// 16 rows at a time, with one tile: for rows left over.
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
