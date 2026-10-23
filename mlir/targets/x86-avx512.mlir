// Kernels for x86-64 with AVX-512 and AVX512-BF16: data for
// `mlir/src/linalg_kernels.rs` (`--pass=linalg-to-kernels=x86-avx512`).
// Written by gen_x86_avx512.py; do not edit. See aarch64-sme.mlir for what
// an `epitome.kernel` says and the arguments its function takes.
//
// Matrix products in BF16 ("weights = bf16"), for B a constant, packed
// as for aarch64-sme.mlir's BF16 kernel: each 64-column panel k/2 rows of
// 64 words, a word two rows of a column (row 2i in the bottom half). A
// block of rows of A is rounded to BF16 into at (vcvtneps2bf16), each row
// k/2 pairs; vdpbf16ps adds both products of a pair of A, broadcast, and
// of a word of B into each f32 lane of C. The kernels are the same but for
// how many rows of C they keep in registers: four (16 vectors of the 32),
// then one for the rows left over. The functions alone use AVX-512
// ("target-features"), so the rest of a program needs only AVX2.

"epitome.kernel"() <{op = "matmul", element = f32, weights = "bf16",
    indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d2, d1)>,
                     affine_map<(d0, d1, d2) -> (d0, d1)>],
    iterator_types = ["parallel", "parallel", "reduction"],
    body = ["arith.mulf", "arith.addf"],
    tile = array<i64: 4, 64>, whole_rows, pack_b = 64, transpose_a,
    function = @__epitome_avx512_matmul_bf16_r4}> : () -> ()

func.func private @__epitome_avx512_matmul_bf16_r4(%c: !llvm.ptr, %ldc: i64, %a: !llvm.ptr, %lda: i64, %at: !llvm.ptr, %b: !llvm.ptr, %ldb: i64, %k: i64, %n: i64, %panel: i64) attributes {llvm.no_inline, llvm.passthrough = [["target-features", "+avx512f,+avx512bf16"]]} {
  %i1 = arith.constant 0 : index
  %i2 = arith.constant 1 : index
  %k3 = arith.index_cast %k : i64 to index
  %n4 = arith.index_cast %n : i64 to index
  %i5 = arith.constant 16 : index
  %i6 = arith.constant 64 : index
  %i7 = arith.constant 2 : index
  %h8 = arith.divui %k3, %i7 : index
  %c9 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
  %n10 = "llvm.lshr"(%k, %c9) : (i64, i64) -> i64
  %c11 = "llvm.mlir.constant"() <{value = 6 : i64}> : () -> i64
  "scf.for"(%i1, %k3, %i5) ({
  ^bb0(%iv12: index):
    %x13 = arith.index_cast %iv12 : index to i64
    %c14 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %n15 = "llvm.lshr"(%x13, %c14) : (i64, i64) -> i64
    %c16 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n17 = "llvm.mul"(%c16, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n18 = "llvm.add"(%n17, %x13) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p19 = "llvm.getelementptr"(%a, %n18) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v20 = "llvm.load"(%p19) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v21 = "llvm.call_intrinsic"(%v20) <{intrin = "llvm.epitome.x86.cvtneps2bf16.512"}> : (vector<16xf32>) -> vector<8xi32>
    %c22 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n23 = "llvm.mul"(%c22, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n24 = "llvm.add"(%n23, %n15) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p25 = "llvm.getelementptr"(%at, %n24) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%v21, %p25) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<8xi32>, !llvm.ptr) -> ()
    %c26 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %n27 = "llvm.mul"(%c26, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n28 = "llvm.add"(%n27, %x13) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p29 = "llvm.getelementptr"(%a, %n28) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v30 = "llvm.load"(%p29) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v31 = "llvm.call_intrinsic"(%v30) <{intrin = "llvm.epitome.x86.cvtneps2bf16.512"}> : (vector<16xf32>) -> vector<8xi32>
    %c32 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %n33 = "llvm.mul"(%c32, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n34 = "llvm.add"(%n33, %n15) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p35 = "llvm.getelementptr"(%at, %n34) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%v31, %p35) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<8xi32>, !llvm.ptr) -> ()
    %c36 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
    %n37 = "llvm.mul"(%c36, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n38 = "llvm.add"(%n37, %x13) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p39 = "llvm.getelementptr"(%a, %n38) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v40 = "llvm.load"(%p39) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v41 = "llvm.call_intrinsic"(%v40) <{intrin = "llvm.epitome.x86.cvtneps2bf16.512"}> : (vector<16xf32>) -> vector<8xi32>
    %c42 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
    %n43 = "llvm.mul"(%c42, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n44 = "llvm.add"(%n43, %n15) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p45 = "llvm.getelementptr"(%at, %n44) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%v41, %p45) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<8xi32>, !llvm.ptr) -> ()
    %c46 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
    %n47 = "llvm.mul"(%c46, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n48 = "llvm.add"(%n47, %x13) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p49 = "llvm.getelementptr"(%a, %n48) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v50 = "llvm.load"(%p49) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v51 = "llvm.call_intrinsic"(%v50) <{intrin = "llvm.epitome.x86.cvtneps2bf16.512"}> : (vector<16xf32>) -> vector<8xi32>
    %c52 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
    %n53 = "llvm.mul"(%c52, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n54 = "llvm.add"(%n53, %n15) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p55 = "llvm.getelementptr"(%at, %n54) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%v51, %p55) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<8xi32>, !llvm.ptr) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  "scf.for"(%i1, %n4, %i6) ({
  ^bb0(%iv56: index):
    %x57 = arith.index_cast %iv56 : index to i64
    %n58 = "llvm.lshr"(%x57, %c11) : (i64, i64) -> i64
    %n59 = "llvm.mul"(%n58, %panel) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p60 = "llvm.getelementptr"(%b, %n59) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c61 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n62 = "llvm.mul"(%c61, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c63 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n64 = "llvm.add"(%x57, %c63) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n65 = "llvm.add"(%n62, %n64) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p66 = "llvm.getelementptr"(%c, %n65) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c67 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n68 = "llvm.mul"(%c67, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c69 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %n70 = "llvm.add"(%x57, %c69) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n71 = "llvm.add"(%n68, %n70) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p72 = "llvm.getelementptr"(%c, %n71) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c73 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n74 = "llvm.mul"(%c73, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c75 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %n76 = "llvm.add"(%x57, %c75) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n77 = "llvm.add"(%n74, %n76) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p78 = "llvm.getelementptr"(%c, %n77) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c79 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n80 = "llvm.mul"(%c79, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c81 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %n82 = "llvm.add"(%x57, %c81) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n83 = "llvm.add"(%n80, %n82) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p84 = "llvm.getelementptr"(%c, %n83) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c85 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %n86 = "llvm.mul"(%c85, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c87 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n88 = "llvm.add"(%x57, %c87) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n89 = "llvm.add"(%n86, %n88) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p90 = "llvm.getelementptr"(%c, %n89) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c91 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %n92 = "llvm.mul"(%c91, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c93 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %n94 = "llvm.add"(%x57, %c93) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n95 = "llvm.add"(%n92, %n94) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p96 = "llvm.getelementptr"(%c, %n95) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c97 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %n98 = "llvm.mul"(%c97, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c99 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %n100 = "llvm.add"(%x57, %c99) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n101 = "llvm.add"(%n98, %n100) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p102 = "llvm.getelementptr"(%c, %n101) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c103 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %n104 = "llvm.mul"(%c103, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c105 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %n106 = "llvm.add"(%x57, %c105) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n107 = "llvm.add"(%n104, %n106) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p108 = "llvm.getelementptr"(%c, %n107) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c109 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
    %n110 = "llvm.mul"(%c109, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c111 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n112 = "llvm.add"(%x57, %c111) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n113 = "llvm.add"(%n110, %n112) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p114 = "llvm.getelementptr"(%c, %n113) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c115 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
    %n116 = "llvm.mul"(%c115, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c117 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %n118 = "llvm.add"(%x57, %c117) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n119 = "llvm.add"(%n116, %n118) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p120 = "llvm.getelementptr"(%c, %n119) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c121 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
    %n122 = "llvm.mul"(%c121, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c123 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %n124 = "llvm.add"(%x57, %c123) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n125 = "llvm.add"(%n122, %n124) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p126 = "llvm.getelementptr"(%c, %n125) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c127 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
    %n128 = "llvm.mul"(%c127, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c129 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %n130 = "llvm.add"(%x57, %c129) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n131 = "llvm.add"(%n128, %n130) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p132 = "llvm.getelementptr"(%c, %n131) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c133 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
    %n134 = "llvm.mul"(%c133, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c135 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n136 = "llvm.add"(%x57, %c135) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n137 = "llvm.add"(%n134, %n136) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p138 = "llvm.getelementptr"(%c, %n137) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c139 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
    %n140 = "llvm.mul"(%c139, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c141 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %n142 = "llvm.add"(%x57, %c141) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n143 = "llvm.add"(%n140, %n142) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p144 = "llvm.getelementptr"(%c, %n143) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c145 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
    %n146 = "llvm.mul"(%c145, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c147 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %n148 = "llvm.add"(%x57, %c147) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n149 = "llvm.add"(%n146, %n148) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p150 = "llvm.getelementptr"(%c, %n149) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c151 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
    %n152 = "llvm.mul"(%c151, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c153 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %n154 = "llvm.add"(%x57, %c153) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n155 = "llvm.add"(%n152, %n154) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p156 = "llvm.getelementptr"(%c, %n155) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v157 = "llvm.load"(%p66) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v158 = "llvm.load"(%p72) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v159 = "llvm.load"(%p78) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v160 = "llvm.load"(%p84) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v161 = "llvm.load"(%p90) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v162 = "llvm.load"(%p96) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v163 = "llvm.load"(%p102) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v164 = "llvm.load"(%p108) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v165 = "llvm.load"(%p114) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v166 = "llvm.load"(%p120) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v167 = "llvm.load"(%p126) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v168 = "llvm.load"(%p132) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v169 = "llvm.load"(%p138) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v170 = "llvm.load"(%p144) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v171 = "llvm.load"(%p150) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v172 = "llvm.load"(%p156) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %r190:16 = "scf.for"(%i1, %h8, %i2, %v157, %v158, %v159, %v160, %v161, %v162, %v163, %v164, %v165, %v166, %v167, %v168, %v169, %v170, %v171, %v172) ({
    ^bb0(%iv173: index, %a174: vector<16xf32>, %a175: vector<16xf32>, %a176: vector<16xf32>, %a177: vector<16xf32>, %a178: vector<16xf32>, %a179: vector<16xf32>, %a180: vector<16xf32>, %a181: vector<16xf32>, %a182: vector<16xf32>, %a183: vector<16xf32>, %a184: vector<16xf32>, %a185: vector<16xf32>, %a186: vector<16xf32>, %a187: vector<16xf32>, %a188: vector<16xf32>, %a189: vector<16xf32>):
      %x206 = arith.index_cast %iv173 : index to i64
      %n207 = "llvm.mul"(%x206, %ldb) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %p208 = "llvm.getelementptr"(%p60, %n207) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v209 = "llvm.load"(%p208) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c210 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
      %p211 = "llvm.getelementptr"(%p208, %c210) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v212 = "llvm.load"(%p211) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c213 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
      %p214 = "llvm.getelementptr"(%p208, %c213) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v215 = "llvm.load"(%p214) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c216 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
      %p217 = "llvm.getelementptr"(%p208, %c216) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v218 = "llvm.load"(%p217) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c219 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
      %n220 = "llvm.mul"(%c219, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %n221 = "llvm.add"(%n220, %x206) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %p222 = "llvm.getelementptr"(%at, %n221) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v223 = "llvm.load"(%p222) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
      %s224 = "vector.broadcast"(%v223) : (i32) -> vector<16xi32>
      %v225 = "llvm.call_intrinsic"(%a174, %s224, %v209) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v226 = "llvm.call_intrinsic"(%a175, %s224, %v212) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v227 = "llvm.call_intrinsic"(%a176, %s224, %v215) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v228 = "llvm.call_intrinsic"(%a177, %s224, %v218) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %c229 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
      %n230 = "llvm.mul"(%c229, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %n231 = "llvm.add"(%n230, %x206) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %p232 = "llvm.getelementptr"(%at, %n231) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v233 = "llvm.load"(%p232) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
      %s234 = "vector.broadcast"(%v233) : (i32) -> vector<16xi32>
      %v235 = "llvm.call_intrinsic"(%a178, %s234, %v209) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v236 = "llvm.call_intrinsic"(%a179, %s234, %v212) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v237 = "llvm.call_intrinsic"(%a180, %s234, %v215) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v238 = "llvm.call_intrinsic"(%a181, %s234, %v218) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %c239 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
      %n240 = "llvm.mul"(%c239, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %n241 = "llvm.add"(%n240, %x206) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %p242 = "llvm.getelementptr"(%at, %n241) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v243 = "llvm.load"(%p242) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
      %s244 = "vector.broadcast"(%v243) : (i32) -> vector<16xi32>
      %v245 = "llvm.call_intrinsic"(%a182, %s244, %v209) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v246 = "llvm.call_intrinsic"(%a183, %s244, %v212) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v247 = "llvm.call_intrinsic"(%a184, %s244, %v215) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v248 = "llvm.call_intrinsic"(%a185, %s244, %v218) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %c249 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
      %n250 = "llvm.mul"(%c249, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %n251 = "llvm.add"(%n250, %x206) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %p252 = "llvm.getelementptr"(%at, %n251) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v253 = "llvm.load"(%p252) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
      %s254 = "vector.broadcast"(%v253) : (i32) -> vector<16xi32>
      %v255 = "llvm.call_intrinsic"(%a186, %s254, %v209) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v256 = "llvm.call_intrinsic"(%a187, %s254, %v212) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v257 = "llvm.call_intrinsic"(%a188, %s254, %v215) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v258 = "llvm.call_intrinsic"(%a189, %s254, %v218) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      "scf.yield"(%v225, %v226, %v227, %v228, %v235, %v236, %v237, %v238, %v245, %v246, %v247, %v248, %v255, %v256, %v257, %v258) : (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> ()
    }) : (index, index, index, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>)
    "llvm.store"(%r190#0, %p66) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r190#1, %p72) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r190#2, %p78) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r190#3, %p84) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r190#4, %p90) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r190#5, %p96) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r190#6, %p102) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r190#7, %p108) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r190#8, %p114) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r190#9, %p120) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r190#10, %p126) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r190#11, %p132) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r190#12, %p138) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r190#13, %p144) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r190#14, %p150) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r190#15, %p156) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  "func.return"() : () -> ()
}

"epitome.kernel"() <{op = "matmul", element = f32, weights = "bf16",
    indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d2, d1)>,
                     affine_map<(d0, d1, d2) -> (d0, d1)>],
    iterator_types = ["parallel", "parallel", "reduction"],
    body = ["arith.mulf", "arith.addf"],
    tile = array<i64: 1, 64>, whole_rows, pack_b = 64, transpose_a,
    function = @__epitome_avx512_matmul_bf16_r1}> : () -> ()

func.func private @__epitome_avx512_matmul_bf16_r1(%c: !llvm.ptr, %ldc: i64, %a: !llvm.ptr, %lda: i64, %at: !llvm.ptr, %b: !llvm.ptr, %ldb: i64, %k: i64, %n: i64, %panel: i64) attributes {llvm.no_inline, llvm.passthrough = [["target-features", "+avx512f,+avx512bf16"]]} {
  %i1 = arith.constant 0 : index
  %i2 = arith.constant 1 : index
  %k3 = arith.index_cast %k : i64 to index
  %n4 = arith.index_cast %n : i64 to index
  %i5 = arith.constant 16 : index
  %i6 = arith.constant 64 : index
  %i7 = arith.constant 2 : index
  %h8 = arith.divui %k3, %i7 : index
  %c9 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
  %n10 = "llvm.lshr"(%k, %c9) : (i64, i64) -> i64
  %c11 = "llvm.mlir.constant"() <{value = 6 : i64}> : () -> i64
  "scf.for"(%i1, %k3, %i5) ({
  ^bb0(%iv12: index):
    %x13 = arith.index_cast %iv12 : index to i64
    %c14 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %n15 = "llvm.lshr"(%x13, %c14) : (i64, i64) -> i64
    %c16 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n17 = "llvm.mul"(%c16, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n18 = "llvm.add"(%n17, %x13) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p19 = "llvm.getelementptr"(%a, %n18) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v20 = "llvm.load"(%p19) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v21 = "llvm.call_intrinsic"(%v20) <{intrin = "llvm.epitome.x86.cvtneps2bf16.512"}> : (vector<16xf32>) -> vector<8xi32>
    %c22 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n23 = "llvm.mul"(%c22, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n24 = "llvm.add"(%n23, %n15) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p25 = "llvm.getelementptr"(%at, %n24) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%v21, %p25) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<8xi32>, !llvm.ptr) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  "scf.for"(%i1, %n4, %i6) ({
  ^bb0(%iv26: index):
    %x27 = arith.index_cast %iv26 : index to i64
    %n28 = "llvm.lshr"(%x27, %c11) : (i64, i64) -> i64
    %n29 = "llvm.mul"(%n28, %panel) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p30 = "llvm.getelementptr"(%b, %n29) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c31 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n32 = "llvm.mul"(%c31, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c33 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n34 = "llvm.add"(%x27, %c33) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n35 = "llvm.add"(%n32, %n34) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p36 = "llvm.getelementptr"(%c, %n35) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c37 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n38 = "llvm.mul"(%c37, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c39 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %n40 = "llvm.add"(%x27, %c39) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n41 = "llvm.add"(%n38, %n40) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p42 = "llvm.getelementptr"(%c, %n41) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c43 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n44 = "llvm.mul"(%c43, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c45 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %n46 = "llvm.add"(%x27, %c45) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n47 = "llvm.add"(%n44, %n46) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p48 = "llvm.getelementptr"(%c, %n47) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c49 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n50 = "llvm.mul"(%c49, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %c51 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %n52 = "llvm.add"(%x27, %c51) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n53 = "llvm.add"(%n50, %n52) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p54 = "llvm.getelementptr"(%c, %n53) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v55 = "llvm.load"(%p36) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v56 = "llvm.load"(%p42) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v57 = "llvm.load"(%p48) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v58 = "llvm.load"(%p54) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %r64:4 = "scf.for"(%i1, %h8, %i2, %v55, %v56, %v57, %v58) ({
    ^bb0(%iv59: index, %a60: vector<16xf32>, %a61: vector<16xf32>, %a62: vector<16xf32>, %a63: vector<16xf32>):
      %x68 = arith.index_cast %iv59 : index to i64
      %n69 = "llvm.mul"(%x68, %ldb) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %p70 = "llvm.getelementptr"(%p30, %n69) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v71 = "llvm.load"(%p70) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c72 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
      %p73 = "llvm.getelementptr"(%p70, %c72) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v74 = "llvm.load"(%p73) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c75 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
      %p76 = "llvm.getelementptr"(%p70, %c75) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v77 = "llvm.load"(%p76) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c78 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
      %p79 = "llvm.getelementptr"(%p70, %c78) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v80 = "llvm.load"(%p79) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c81 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
      %n82 = "llvm.mul"(%c81, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %n83 = "llvm.add"(%n82, %x68) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %p84 = "llvm.getelementptr"(%at, %n83) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v85 = "llvm.load"(%p84) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
      %s86 = "vector.broadcast"(%v85) : (i32) -> vector<16xi32>
      %v87 = "llvm.call_intrinsic"(%a60, %s86, %v71) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v88 = "llvm.call_intrinsic"(%a61, %s86, %v74) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v89 = "llvm.call_intrinsic"(%a62, %s86, %v77) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v90 = "llvm.call_intrinsic"(%a63, %s86, %v80) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      "scf.yield"(%v87, %v88, %v89, %v90) : (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> ()
    }) : (index, index, index, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>)
    "llvm.store"(%r64#0, %p36) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r64#1, %p42) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r64#2, %p48) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r64#3, %p54) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  "func.return"() : () -> ()
}
