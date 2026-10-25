// Kernels for x86-64 with AVX-512 and AVX512-BF16: data for
// `mlir/src/linalg_kernels.rs` (`--pass=linalg-to-kernels=x86-avx512`).
// Written by gen_x86_avx512.py; do not edit. See aarch64-sme.mlir for what
// an `epitome.kernel` says and the arguments its function takes.
//
// Matrix products in BF16 ("weights = bf16"), for B a constant, packed
// as for aarch64-sme.mlir's BF16 kernel: each 64-column panel k/2 rows of
// 64 words, a word two rows of a column (row 2i in the bottom half). A
// block of rows of A is rounded to BF16 into at (vcvtneps2bf16), each row
// k/2 pairs, then interleaved, each step's pairs of the rows together; vdpbf16ps adds both products of a pair of A, broadcast, and
// of a word of B into each f32 lane of C. The kernels are the same but for
// how many rows of C they keep in registers: four (16 vectors of the 32),
// then one for the rows left over. The functions alone use AVX-512
// ("target-features"), so the rest of a program needs only AVX2. Each has
// a twin for C that starts zeroed (`zeroed`): its sums start at zero
// rather than at C, which is then not read.

"epitome.kernel"() <{op = "matmul", element = f32, weights = "bf16",
    indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d2, d1)>,
                     affine_map<(d0, d1, d2) -> (d0, d1)>],
    iterator_types = ["parallel", "parallel", "reduction"],
    body = ["arith.mulf", "arith.addf"],
    tile = array<i64: 4, 64>, whole_rows, pack_b = 64, transpose_a,
    function = @__epitome_avx512_matmul_bf16_r4, zeroed = @__epitome_avx512_matmul_bf16_r4_z}> : () -> ()

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
  %c56 = "llvm.mlir.constant"() <{value = 4 : i64}> : () -> i64
  %n57 = "llvm.mul"(%c56, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p58 = "llvm.getelementptr"(%at, %n57) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  "scf.for"(%i1, %h8, %i2) ({
  ^bb0(%iv59: index):
    %x60 = arith.index_cast %iv59 : index to i64
    %c61 = "llvm.mlir.constant"() <{value = 4 : i64}> : () -> i64
    %n62 = "llvm.mul"(%x60, %c61) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p63 = "llvm.getelementptr"(%p58, %n62) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c64 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n65 = "llvm.mul"(%c64, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n66 = "llvm.add"(%n65, %x60) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p67 = "llvm.getelementptr"(%at, %n66) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v68 = "llvm.load"(%p67) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
    "llvm.store"(%v68, %p63) <{alignment = 4 : i64, ordering = 0 : i64}> : (i32, !llvm.ptr) -> ()
    %c69 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %n70 = "llvm.mul"(%c69, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n71 = "llvm.add"(%n70, %x60) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p72 = "llvm.getelementptr"(%at, %n71) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v73 = "llvm.load"(%p72) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
    %c74 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %p75 = "llvm.getelementptr"(%p63, %c74) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%v73, %p75) <{alignment = 4 : i64, ordering = 0 : i64}> : (i32, !llvm.ptr) -> ()
    %c76 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
    %n77 = "llvm.mul"(%c76, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n78 = "llvm.add"(%n77, %x60) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p79 = "llvm.getelementptr"(%at, %n78) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v80 = "llvm.load"(%p79) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
    %c81 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
    %p82 = "llvm.getelementptr"(%p63, %c81) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%v80, %p82) <{alignment = 4 : i64, ordering = 0 : i64}> : (i32, !llvm.ptr) -> ()
    %c83 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
    %n84 = "llvm.mul"(%c83, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n85 = "llvm.add"(%n84, %x60) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p86 = "llvm.getelementptr"(%at, %n85) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v87 = "llvm.load"(%p86) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
    %c88 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
    %p89 = "llvm.getelementptr"(%p63, %c88) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%v87, %p89) <{alignment = 4 : i64, ordering = 0 : i64}> : (i32, !llvm.ptr) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  %c90 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
  %n91 = "llvm.mul"(%c90, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p92 = "llvm.getelementptr"(%c, %n91) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  %c93 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
  %n94 = "llvm.mul"(%c93, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p95 = "llvm.getelementptr"(%c, %n94) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  %c96 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
  %n97 = "llvm.mul"(%c96, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p98 = "llvm.getelementptr"(%c, %n97) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  "scf.for"(%i1, %n4, %i6) ({
  ^bb0(%iv99: index):
    %x100 = arith.index_cast %iv99 : index to i64
    %n101 = "llvm.lshr"(%x100, %c11) : (i64, i64) -> i64
    %n102 = "llvm.mul"(%n101, %panel) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p103 = "llvm.getelementptr"(%b, %n102) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p104 = "llvm.getelementptr"(%c, %x100) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p105 = "llvm.getelementptr"(%p92, %x100) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p106 = "llvm.getelementptr"(%p95, %x100) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p107 = "llvm.getelementptr"(%p98, %x100) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c108 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p109 = "llvm.getelementptr"(%p104, %c108) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c110 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p111 = "llvm.getelementptr"(%p104, %c110) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c112 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p113 = "llvm.getelementptr"(%p104, %c112) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c114 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p115 = "llvm.getelementptr"(%p105, %c114) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c116 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p117 = "llvm.getelementptr"(%p105, %c116) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c118 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p119 = "llvm.getelementptr"(%p105, %c118) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c120 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p121 = "llvm.getelementptr"(%p106, %c120) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c122 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p123 = "llvm.getelementptr"(%p106, %c122) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c124 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p125 = "llvm.getelementptr"(%p106, %c124) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c126 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p127 = "llvm.getelementptr"(%p107, %c126) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c128 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p129 = "llvm.getelementptr"(%p107, %c128) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c130 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p131 = "llvm.getelementptr"(%p107, %c130) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v132 = "llvm.load"(%p104) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v133 = "llvm.load"(%p109) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v134 = "llvm.load"(%p111) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v135 = "llvm.load"(%p113) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v136 = "llvm.load"(%p105) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v137 = "llvm.load"(%p115) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v138 = "llvm.load"(%p117) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v139 = "llvm.load"(%p119) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v140 = "llvm.load"(%p106) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v141 = "llvm.load"(%p121) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v142 = "llvm.load"(%p123) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v143 = "llvm.load"(%p125) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v144 = "llvm.load"(%p107) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v145 = "llvm.load"(%p127) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v146 = "llvm.load"(%p129) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v147 = "llvm.load"(%p131) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %r165:16 = "scf.for"(%i1, %h8, %i2, %v132, %v133, %v134, %v135, %v136, %v137, %v138, %v139, %v140, %v141, %v142, %v143, %v144, %v145, %v146, %v147) ({
    ^bb0(%iv148: index, %a149: vector<16xf32>, %a150: vector<16xf32>, %a151: vector<16xf32>, %a152: vector<16xf32>, %a153: vector<16xf32>, %a154: vector<16xf32>, %a155: vector<16xf32>, %a156: vector<16xf32>, %a157: vector<16xf32>, %a158: vector<16xf32>, %a159: vector<16xf32>, %a160: vector<16xf32>, %a161: vector<16xf32>, %a162: vector<16xf32>, %a163: vector<16xf32>, %a164: vector<16xf32>):
      %x181 = arith.index_cast %iv148 : index to i64
      %n182 = "llvm.shl"(%x181, %c11) : (i64, i64) -> i64
      %p183 = "llvm.getelementptr"(%p103, %n182) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v184 = "llvm.load"(%p183) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c185 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
      %p186 = "llvm.getelementptr"(%p183, %c185) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v187 = "llvm.load"(%p186) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c188 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
      %p189 = "llvm.getelementptr"(%p183, %c188) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v190 = "llvm.load"(%p189) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c191 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
      %p192 = "llvm.getelementptr"(%p183, %c191) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v193 = "llvm.load"(%p192) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c194 = "llvm.mlir.constant"() <{value = 4 : i64}> : () -> i64
      %n195 = "llvm.mul"(%x181, %c194) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %p196 = "llvm.getelementptr"(%p58, %n195) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v197 = "llvm.load"(%p196) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
      %s198 = "vector.broadcast"(%v197) : (i32) -> vector<16xi32>
      %v199 = "llvm.call_intrinsic"(%a149, %s198, %v184) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v200 = "llvm.call_intrinsic"(%a150, %s198, %v187) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v201 = "llvm.call_intrinsic"(%a151, %s198, %v190) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v202 = "llvm.call_intrinsic"(%a152, %s198, %v193) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %c203 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
      %p204 = "llvm.getelementptr"(%p196, %c203) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v205 = "llvm.load"(%p204) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
      %s206 = "vector.broadcast"(%v205) : (i32) -> vector<16xi32>
      %v207 = "llvm.call_intrinsic"(%a153, %s206, %v184) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v208 = "llvm.call_intrinsic"(%a154, %s206, %v187) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v209 = "llvm.call_intrinsic"(%a155, %s206, %v190) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v210 = "llvm.call_intrinsic"(%a156, %s206, %v193) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %c211 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
      %p212 = "llvm.getelementptr"(%p196, %c211) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v213 = "llvm.load"(%p212) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
      %s214 = "vector.broadcast"(%v213) : (i32) -> vector<16xi32>
      %v215 = "llvm.call_intrinsic"(%a157, %s214, %v184) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v216 = "llvm.call_intrinsic"(%a158, %s214, %v187) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v217 = "llvm.call_intrinsic"(%a159, %s214, %v190) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v218 = "llvm.call_intrinsic"(%a160, %s214, %v193) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %c219 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
      %p220 = "llvm.getelementptr"(%p196, %c219) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v221 = "llvm.load"(%p220) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
      %s222 = "vector.broadcast"(%v221) : (i32) -> vector<16xi32>
      %v223 = "llvm.call_intrinsic"(%a161, %s222, %v184) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v224 = "llvm.call_intrinsic"(%a162, %s222, %v187) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v225 = "llvm.call_intrinsic"(%a163, %s222, %v190) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v226 = "llvm.call_intrinsic"(%a164, %s222, %v193) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      "scf.yield"(%v199, %v200, %v201, %v202, %v207, %v208, %v209, %v210, %v215, %v216, %v217, %v218, %v223, %v224, %v225, %v226) : (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> ()
    }) : (index, index, index, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>)
    %p227 = "llvm.getelementptr"(%c, %x100) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p228 = "llvm.getelementptr"(%p92, %x100) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p229 = "llvm.getelementptr"(%p95, %x100) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p230 = "llvm.getelementptr"(%p98, %x100) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c231 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p232 = "llvm.getelementptr"(%p227, %c231) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c233 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p234 = "llvm.getelementptr"(%p227, %c233) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c235 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p236 = "llvm.getelementptr"(%p227, %c235) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c237 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p238 = "llvm.getelementptr"(%p228, %c237) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c239 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p240 = "llvm.getelementptr"(%p228, %c239) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c241 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p242 = "llvm.getelementptr"(%p228, %c241) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c243 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p244 = "llvm.getelementptr"(%p229, %c243) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c245 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p246 = "llvm.getelementptr"(%p229, %c245) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c247 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p248 = "llvm.getelementptr"(%p229, %c247) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c249 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p250 = "llvm.getelementptr"(%p230, %c249) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c251 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p252 = "llvm.getelementptr"(%p230, %c251) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c253 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p254 = "llvm.getelementptr"(%p230, %c253) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%r165#0, %p227) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r165#1, %p232) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r165#2, %p234) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r165#3, %p236) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r165#4, %p228) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r165#5, %p238) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r165#6, %p240) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r165#7, %p242) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r165#8, %p229) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r165#9, %p244) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r165#10, %p246) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r165#11, %p248) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r165#12, %p230) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r165#13, %p250) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r165#14, %p252) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r165#15, %p254) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  "func.return"() : () -> ()
}

func.func private @__epitome_avx512_matmul_bf16_r4_z(%c: !llvm.ptr, %ldc: i64, %a: !llvm.ptr, %lda: i64, %at: !llvm.ptr, %b: !llvm.ptr, %ldb: i64, %k: i64, %n: i64, %panel: i64) attributes {llvm.no_inline, llvm.passthrough = [["target-features", "+avx512f,+avx512bf16"]]} {
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
  %c56 = "llvm.mlir.constant"() <{value = 4 : i64}> : () -> i64
  %n57 = "llvm.mul"(%c56, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p58 = "llvm.getelementptr"(%at, %n57) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  "scf.for"(%i1, %h8, %i2) ({
  ^bb0(%iv59: index):
    %x60 = arith.index_cast %iv59 : index to i64
    %c61 = "llvm.mlir.constant"() <{value = 4 : i64}> : () -> i64
    %n62 = "llvm.mul"(%x60, %c61) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p63 = "llvm.getelementptr"(%p58, %n62) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c64 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %n65 = "llvm.mul"(%c64, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n66 = "llvm.add"(%n65, %x60) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p67 = "llvm.getelementptr"(%at, %n66) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v68 = "llvm.load"(%p67) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
    "llvm.store"(%v68, %p63) <{alignment = 4 : i64, ordering = 0 : i64}> : (i32, !llvm.ptr) -> ()
    %c69 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %n70 = "llvm.mul"(%c69, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n71 = "llvm.add"(%n70, %x60) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p72 = "llvm.getelementptr"(%at, %n71) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v73 = "llvm.load"(%p72) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
    %c74 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %p75 = "llvm.getelementptr"(%p63, %c74) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%v73, %p75) <{alignment = 4 : i64, ordering = 0 : i64}> : (i32, !llvm.ptr) -> ()
    %c76 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
    %n77 = "llvm.mul"(%c76, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n78 = "llvm.add"(%n77, %x60) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p79 = "llvm.getelementptr"(%at, %n78) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v80 = "llvm.load"(%p79) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
    %c81 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
    %p82 = "llvm.getelementptr"(%p63, %c81) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%v80, %p82) <{alignment = 4 : i64, ordering = 0 : i64}> : (i32, !llvm.ptr) -> ()
    %c83 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
    %n84 = "llvm.mul"(%c83, %n10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %n85 = "llvm.add"(%n84, %x60) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p86 = "llvm.getelementptr"(%at, %n85) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v87 = "llvm.load"(%p86) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
    %c88 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
    %p89 = "llvm.getelementptr"(%p63, %c88) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%v87, %p89) <{alignment = 4 : i64, ordering = 0 : i64}> : (i32, !llvm.ptr) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  %c90 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
  %n91 = "llvm.mul"(%c90, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p92 = "llvm.getelementptr"(%c, %n91) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  %c93 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
  %n94 = "llvm.mul"(%c93, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p95 = "llvm.getelementptr"(%c, %n94) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  %c96 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
  %n97 = "llvm.mul"(%c96, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p98 = "llvm.getelementptr"(%c, %n97) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  "scf.for"(%i1, %n4, %i6) ({
  ^bb0(%iv99: index):
    %x100 = arith.index_cast %iv99 : index to i64
    %n101 = "llvm.lshr"(%x100, %c11) : (i64, i64) -> i64
    %n102 = "llvm.mul"(%n101, %panel) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %p103 = "llvm.getelementptr"(%b, %n102) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %z104 = arith.constant dense<0.000000e+00> : vector<16xf32>
    %r122:16 = "scf.for"(%i1, %h8, %i2, %z104, %z104, %z104, %z104, %z104, %z104, %z104, %z104, %z104, %z104, %z104, %z104, %z104, %z104, %z104, %z104) ({
    ^bb0(%iv105: index, %a106: vector<16xf32>, %a107: vector<16xf32>, %a108: vector<16xf32>, %a109: vector<16xf32>, %a110: vector<16xf32>, %a111: vector<16xf32>, %a112: vector<16xf32>, %a113: vector<16xf32>, %a114: vector<16xf32>, %a115: vector<16xf32>, %a116: vector<16xf32>, %a117: vector<16xf32>, %a118: vector<16xf32>, %a119: vector<16xf32>, %a120: vector<16xf32>, %a121: vector<16xf32>):
      %x138 = arith.index_cast %iv105 : index to i64
      %n139 = "llvm.shl"(%x138, %c11) : (i64, i64) -> i64
      %p140 = "llvm.getelementptr"(%p103, %n139) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v141 = "llvm.load"(%p140) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c142 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
      %p143 = "llvm.getelementptr"(%p140, %c142) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v144 = "llvm.load"(%p143) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c145 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
      %p146 = "llvm.getelementptr"(%p140, %c145) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v147 = "llvm.load"(%p146) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c148 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
      %p149 = "llvm.getelementptr"(%p140, %c148) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v150 = "llvm.load"(%p149) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c151 = "llvm.mlir.constant"() <{value = 4 : i64}> : () -> i64
      %n152 = "llvm.mul"(%x138, %c151) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %p153 = "llvm.getelementptr"(%p58, %n152) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v154 = "llvm.load"(%p153) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
      %s155 = "vector.broadcast"(%v154) : (i32) -> vector<16xi32>
      %v156 = "llvm.call_intrinsic"(%a106, %s155, %v141) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v157 = "llvm.call_intrinsic"(%a107, %s155, %v144) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v158 = "llvm.call_intrinsic"(%a108, %s155, %v147) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v159 = "llvm.call_intrinsic"(%a109, %s155, %v150) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %c160 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
      %p161 = "llvm.getelementptr"(%p153, %c160) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v162 = "llvm.load"(%p161) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
      %s163 = "vector.broadcast"(%v162) : (i32) -> vector<16xi32>
      %v164 = "llvm.call_intrinsic"(%a110, %s163, %v141) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v165 = "llvm.call_intrinsic"(%a111, %s163, %v144) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v166 = "llvm.call_intrinsic"(%a112, %s163, %v147) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v167 = "llvm.call_intrinsic"(%a113, %s163, %v150) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %c168 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
      %p169 = "llvm.getelementptr"(%p153, %c168) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v170 = "llvm.load"(%p169) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
      %s171 = "vector.broadcast"(%v170) : (i32) -> vector<16xi32>
      %v172 = "llvm.call_intrinsic"(%a114, %s171, %v141) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v173 = "llvm.call_intrinsic"(%a115, %s171, %v144) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v174 = "llvm.call_intrinsic"(%a116, %s171, %v147) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v175 = "llvm.call_intrinsic"(%a117, %s171, %v150) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %c176 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
      %p177 = "llvm.getelementptr"(%p153, %c176) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v178 = "llvm.load"(%p177) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
      %s179 = "vector.broadcast"(%v178) : (i32) -> vector<16xi32>
      %v180 = "llvm.call_intrinsic"(%a118, %s179, %v141) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v181 = "llvm.call_intrinsic"(%a119, %s179, %v144) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v182 = "llvm.call_intrinsic"(%a120, %s179, %v147) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v183 = "llvm.call_intrinsic"(%a121, %s179, %v150) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      "scf.yield"(%v156, %v157, %v158, %v159, %v164, %v165, %v166, %v167, %v172, %v173, %v174, %v175, %v180, %v181, %v182, %v183) : (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> ()
    }) : (index, index, index, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>)
    %p184 = "llvm.getelementptr"(%c, %x100) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p185 = "llvm.getelementptr"(%p92, %x100) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p186 = "llvm.getelementptr"(%p95, %x100) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p187 = "llvm.getelementptr"(%p98, %x100) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c188 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p189 = "llvm.getelementptr"(%p184, %c188) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c190 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p191 = "llvm.getelementptr"(%p184, %c190) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c192 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p193 = "llvm.getelementptr"(%p184, %c192) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c194 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p195 = "llvm.getelementptr"(%p185, %c194) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c196 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p197 = "llvm.getelementptr"(%p185, %c196) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c198 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p199 = "llvm.getelementptr"(%p185, %c198) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c200 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p201 = "llvm.getelementptr"(%p186, %c200) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c202 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p203 = "llvm.getelementptr"(%p186, %c202) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c204 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p205 = "llvm.getelementptr"(%p186, %c204) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c206 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p207 = "llvm.getelementptr"(%p187, %c206) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c208 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p209 = "llvm.getelementptr"(%p187, %c208) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c210 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p211 = "llvm.getelementptr"(%p187, %c210) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%r122#0, %p184) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r122#1, %p189) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r122#2, %p191) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r122#3, %p193) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r122#4, %p185) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r122#5, %p195) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r122#6, %p197) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r122#7, %p199) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r122#8, %p186) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r122#9, %p201) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r122#10, %p203) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r122#11, %p205) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r122#12, %p187) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r122#13, %p207) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r122#14, %p209) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r122#15, %p211) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
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
    function = @__epitome_avx512_matmul_bf16_r1, zeroed = @__epitome_avx512_matmul_bf16_r1_z}> : () -> ()

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
    %p31 = "llvm.getelementptr"(%c, %x27) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c32 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p33 = "llvm.getelementptr"(%p31, %c32) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c34 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p35 = "llvm.getelementptr"(%p31, %c34) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c36 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p37 = "llvm.getelementptr"(%p31, %c36) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v38 = "llvm.load"(%p31) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v39 = "llvm.load"(%p33) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v40 = "llvm.load"(%p35) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v41 = "llvm.load"(%p37) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %r47:4 = "scf.for"(%i1, %h8, %i2, %v38, %v39, %v40, %v41) ({
    ^bb0(%iv42: index, %a43: vector<16xf32>, %a44: vector<16xf32>, %a45: vector<16xf32>, %a46: vector<16xf32>):
      %x51 = arith.index_cast %iv42 : index to i64
      %n52 = "llvm.shl"(%x51, %c11) : (i64, i64) -> i64
      %p53 = "llvm.getelementptr"(%p30, %n52) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v54 = "llvm.load"(%p53) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c55 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
      %p56 = "llvm.getelementptr"(%p53, %c55) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v57 = "llvm.load"(%p56) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c58 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
      %p59 = "llvm.getelementptr"(%p53, %c58) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v60 = "llvm.load"(%p59) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c61 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
      %p62 = "llvm.getelementptr"(%p53, %c61) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v63 = "llvm.load"(%p62) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c64 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
      %n65 = "llvm.mul"(%x51, %c64) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %p66 = "llvm.getelementptr"(%at, %n65) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v67 = "llvm.load"(%p66) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
      %s68 = "vector.broadcast"(%v67) : (i32) -> vector<16xi32>
      %v69 = "llvm.call_intrinsic"(%a43, %s68, %v54) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v70 = "llvm.call_intrinsic"(%a44, %s68, %v57) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v71 = "llvm.call_intrinsic"(%a45, %s68, %v60) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v72 = "llvm.call_intrinsic"(%a46, %s68, %v63) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      "scf.yield"(%v69, %v70, %v71, %v72) : (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> ()
    }) : (index, index, index, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>)
    %p73 = "llvm.getelementptr"(%c, %x27) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c74 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p75 = "llvm.getelementptr"(%p73, %c74) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c76 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p77 = "llvm.getelementptr"(%p73, %c76) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c78 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p79 = "llvm.getelementptr"(%p73, %c78) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%r47#0, %p73) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r47#1, %p75) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r47#2, %p77) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r47#3, %p79) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  "func.return"() : () -> ()
}

func.func private @__epitome_avx512_matmul_bf16_r1_z(%c: !llvm.ptr, %ldc: i64, %a: !llvm.ptr, %lda: i64, %at: !llvm.ptr, %b: !llvm.ptr, %ldb: i64, %k: i64, %n: i64, %panel: i64) attributes {llvm.no_inline, llvm.passthrough = [["target-features", "+avx512f,+avx512bf16"]]} {
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
    %z31 = arith.constant dense<0.000000e+00> : vector<16xf32>
    %r37:4 = "scf.for"(%i1, %h8, %i2, %z31, %z31, %z31, %z31) ({
    ^bb0(%iv32: index, %a33: vector<16xf32>, %a34: vector<16xf32>, %a35: vector<16xf32>, %a36: vector<16xf32>):
      %x41 = arith.index_cast %iv32 : index to i64
      %n42 = "llvm.shl"(%x41, %c11) : (i64, i64) -> i64
      %p43 = "llvm.getelementptr"(%p30, %n42) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v44 = "llvm.load"(%p43) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c45 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
      %p46 = "llvm.getelementptr"(%p43, %c45) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v47 = "llvm.load"(%p46) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c48 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
      %p49 = "llvm.getelementptr"(%p43, %c48) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v50 = "llvm.load"(%p49) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c51 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
      %p52 = "llvm.getelementptr"(%p43, %c51) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v53 = "llvm.load"(%p52) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xi32>
      %c54 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
      %n55 = "llvm.mul"(%x41, %c54) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %p56 = "llvm.getelementptr"(%at, %n55) <{elem_type = i32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v57 = "llvm.load"(%p56) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> i32
      %s58 = "vector.broadcast"(%v57) : (i32) -> vector<16xi32>
      %v59 = "llvm.call_intrinsic"(%a33, %s58, %v44) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v60 = "llvm.call_intrinsic"(%a34, %s58, %v47) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v61 = "llvm.call_intrinsic"(%a35, %s58, %v50) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      %v62 = "llvm.call_intrinsic"(%a36, %s58, %v53) <{intrin = "llvm.epitome.x86.dpbf16ps.512"}> : (vector<16xf32>, vector<16xi32>, vector<16xi32>) -> vector<16xf32>
      "scf.yield"(%v59, %v60, %v61, %v62) : (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> ()
    }) : (index, index, index, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>)
    %p63 = "llvm.getelementptr"(%c, %x27) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c64 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p65 = "llvm.getelementptr"(%p63, %c64) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c66 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p67 = "llvm.getelementptr"(%p63, %c66) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c68 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p69 = "llvm.getelementptr"(%p63, %c68) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%r37#0, %p63) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r37#1, %p65) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r37#2, %p67) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r37#3, %p69) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  "func.return"() : () -> ()
}

// Matrix products in f32 of B that is not a constant (attention's), n
// a multiple of 64: see matmul_f32 in gen_x86_avx512.py.

"epitome.kernel"() <{op = "matmul", element = f32,
    indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d2, d1)>, affine_map<(d0, d1, d2) -> (d0, d1)>],
    iterator_types = ["parallel", "parallel", "reduction"],
    body = ["arith.mulf", "arith.addf"],
    tile = array<i64: 4, 64>, whole_rows, transpose_a, col_multiple = 64,
    function = @__epitome_avx512_matmul_f32_r4, zeroed = @__epitome_avx512_matmul_f32_r4_z}> : () -> ()

"epitome.kernel"() <{op = "batch_matmul", element = f32,
    indexing_maps = [affine_map<(d0, d1, d2, d3) -> (d0, d1, d3)>, affine_map<(d0, d1, d2, d3) -> (d0, d3, d2)>, affine_map<(d0, d1, d2, d3) -> (d0, d1, d2)>],
    iterator_types = ["parallel", "parallel", "parallel", "reduction"],
    body = ["arith.mulf", "arith.addf"],
    tile = array<i64: 4, 64>, whole_rows, transpose_a, col_multiple = 64,
    function = @__epitome_avx512_matmul_f32_r4, zeroed = @__epitome_avx512_matmul_f32_r4_z}> : () -> ()

func.func private @__epitome_avx512_matmul_f32_r4(%c: !llvm.ptr, %ldc: i64, %a: !llvm.ptr, %lda: i64, %at: !llvm.ptr, %b: !llvm.ptr, %ldb: i64, %k: i64, %n: i64) attributes {llvm.no_inline, llvm.passthrough = [["target-features", "+avx512f,+avx512bf16"]]} {
  %i1 = arith.constant 0 : index
  %i2 = arith.constant 1 : index
  %k3 = arith.index_cast %k : i64 to index
  %n4 = arith.index_cast %n : i64 to index
  %i5 = arith.constant 64 : index
  %c6 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
  %n7 = "llvm.mul"(%c6, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p8 = "llvm.getelementptr"(%a, %n7) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  %c9 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
  %n10 = "llvm.mul"(%c9, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p11 = "llvm.getelementptr"(%a, %n10) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  %c12 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
  %n13 = "llvm.mul"(%c12, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p14 = "llvm.getelementptr"(%a, %n13) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  %c15 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
  %n16 = "llvm.mul"(%c15, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p17 = "llvm.getelementptr"(%c, %n16) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  %c18 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
  %n19 = "llvm.mul"(%c18, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p20 = "llvm.getelementptr"(%c, %n19) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  %c21 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
  %n22 = "llvm.mul"(%c21, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p23 = "llvm.getelementptr"(%c, %n22) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  "scf.for"(%i1, %n4, %i5) ({
  ^bb0(%iv24: index):
    %x25 = arith.index_cast %iv24 : index to i64
    %p26 = "llvm.getelementptr"(%c, %x25) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p27 = "llvm.getelementptr"(%p17, %x25) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p28 = "llvm.getelementptr"(%p20, %x25) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p29 = "llvm.getelementptr"(%p23, %x25) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c30 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p31 = "llvm.getelementptr"(%p26, %c30) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c32 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p33 = "llvm.getelementptr"(%p26, %c32) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c34 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p35 = "llvm.getelementptr"(%p26, %c34) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c36 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p37 = "llvm.getelementptr"(%p27, %c36) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c38 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p39 = "llvm.getelementptr"(%p27, %c38) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c40 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p41 = "llvm.getelementptr"(%p27, %c40) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c42 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p43 = "llvm.getelementptr"(%p28, %c42) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c44 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p45 = "llvm.getelementptr"(%p28, %c44) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c46 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p47 = "llvm.getelementptr"(%p28, %c46) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c48 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p49 = "llvm.getelementptr"(%p29, %c48) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c50 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p51 = "llvm.getelementptr"(%p29, %c50) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c52 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p53 = "llvm.getelementptr"(%p29, %c52) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %v54 = "llvm.load"(%p26) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v55 = "llvm.load"(%p31) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v56 = "llvm.load"(%p33) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v57 = "llvm.load"(%p35) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v58 = "llvm.load"(%p27) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v59 = "llvm.load"(%p37) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v60 = "llvm.load"(%p39) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v61 = "llvm.load"(%p41) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v62 = "llvm.load"(%p28) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v63 = "llvm.load"(%p43) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v64 = "llvm.load"(%p45) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v65 = "llvm.load"(%p47) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v66 = "llvm.load"(%p29) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v67 = "llvm.load"(%p49) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v68 = "llvm.load"(%p51) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %v69 = "llvm.load"(%p53) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
    %p70 = "llvm.getelementptr"(%b, %x25) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %r88:16 = "scf.for"(%i1, %k3, %i2, %v54, %v55, %v56, %v57, %v58, %v59, %v60, %v61, %v62, %v63, %v64, %v65, %v66, %v67, %v68, %v69) ({
    ^bb0(%iv71: index, %a72: vector<16xf32>, %a73: vector<16xf32>, %a74: vector<16xf32>, %a75: vector<16xf32>, %a76: vector<16xf32>, %a77: vector<16xf32>, %a78: vector<16xf32>, %a79: vector<16xf32>, %a80: vector<16xf32>, %a81: vector<16xf32>, %a82: vector<16xf32>, %a83: vector<16xf32>, %a84: vector<16xf32>, %a85: vector<16xf32>, %a86: vector<16xf32>, %a87: vector<16xf32>):
      %x104 = arith.index_cast %iv71 : index to i64
      %n105 = "llvm.mul"(%x104, %ldb) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %p106 = "llvm.getelementptr"(%p70, %n105) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v107 = "llvm.load"(%p106) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
      %c108 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
      %p109 = "llvm.getelementptr"(%p106, %c108) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v110 = "llvm.load"(%p109) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
      %c111 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
      %p112 = "llvm.getelementptr"(%p106, %c111) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v113 = "llvm.load"(%p112) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
      %c114 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
      %p115 = "llvm.getelementptr"(%p106, %c114) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v116 = "llvm.load"(%p115) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
      %p117 = "llvm.getelementptr"(%a, %x104) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v118 = "llvm.load"(%p117) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> f32
      %s119 = "vector.broadcast"(%v118) : (f32) -> vector<16xf32>
      %v120 = "math.fma"(%s119, %v107, %a72) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v121 = "math.fma"(%s119, %v110, %a73) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v122 = "math.fma"(%s119, %v113, %a74) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v123 = "math.fma"(%s119, %v116, %a75) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %p124 = "llvm.getelementptr"(%p8, %x104) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v125 = "llvm.load"(%p124) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> f32
      %s126 = "vector.broadcast"(%v125) : (f32) -> vector<16xf32>
      %v127 = "math.fma"(%s126, %v107, %a76) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v128 = "math.fma"(%s126, %v110, %a77) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v129 = "math.fma"(%s126, %v113, %a78) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v130 = "math.fma"(%s126, %v116, %a79) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %p131 = "llvm.getelementptr"(%p11, %x104) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v132 = "llvm.load"(%p131) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> f32
      %s133 = "vector.broadcast"(%v132) : (f32) -> vector<16xf32>
      %v134 = "math.fma"(%s133, %v107, %a80) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v135 = "math.fma"(%s133, %v110, %a81) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v136 = "math.fma"(%s133, %v113, %a82) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v137 = "math.fma"(%s133, %v116, %a83) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %p138 = "llvm.getelementptr"(%p14, %x104) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v139 = "llvm.load"(%p138) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> f32
      %s140 = "vector.broadcast"(%v139) : (f32) -> vector<16xf32>
      %v141 = "math.fma"(%s140, %v107, %a84) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v142 = "math.fma"(%s140, %v110, %a85) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v143 = "math.fma"(%s140, %v113, %a86) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v144 = "math.fma"(%s140, %v116, %a87) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      "scf.yield"(%v120, %v121, %v122, %v123, %v127, %v128, %v129, %v130, %v134, %v135, %v136, %v137, %v141, %v142, %v143, %v144) : (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> ()
    }) : (index, index, index, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>)
    %p145 = "llvm.getelementptr"(%c, %x25) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p146 = "llvm.getelementptr"(%p17, %x25) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p147 = "llvm.getelementptr"(%p20, %x25) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p148 = "llvm.getelementptr"(%p23, %x25) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c149 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p150 = "llvm.getelementptr"(%p145, %c149) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c151 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p152 = "llvm.getelementptr"(%p145, %c151) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c153 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p154 = "llvm.getelementptr"(%p145, %c153) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c155 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p156 = "llvm.getelementptr"(%p146, %c155) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c157 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p158 = "llvm.getelementptr"(%p146, %c157) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c159 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p160 = "llvm.getelementptr"(%p146, %c159) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c161 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p162 = "llvm.getelementptr"(%p147, %c161) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c163 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p164 = "llvm.getelementptr"(%p147, %c163) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c165 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p166 = "llvm.getelementptr"(%p147, %c165) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c167 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p168 = "llvm.getelementptr"(%p148, %c167) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c169 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p170 = "llvm.getelementptr"(%p148, %c169) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c171 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p172 = "llvm.getelementptr"(%p148, %c171) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%r88#0, %p145) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r88#1, %p150) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r88#2, %p152) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r88#3, %p154) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r88#4, %p146) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r88#5, %p156) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r88#6, %p158) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r88#7, %p160) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r88#8, %p147) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r88#9, %p162) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r88#10, %p164) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r88#11, %p166) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r88#12, %p148) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r88#13, %p168) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r88#14, %p170) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r88#15, %p172) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  "func.return"() : () -> ()
}

func.func private @__epitome_avx512_matmul_f32_r4_z(%c: !llvm.ptr, %ldc: i64, %a: !llvm.ptr, %lda: i64, %at: !llvm.ptr, %b: !llvm.ptr, %ldb: i64, %k: i64, %n: i64) attributes {llvm.no_inline, llvm.passthrough = [["target-features", "+avx512f,+avx512bf16"]]} {
  %i1 = arith.constant 0 : index
  %i2 = arith.constant 1 : index
  %k3 = arith.index_cast %k : i64 to index
  %n4 = arith.index_cast %n : i64 to index
  %i5 = arith.constant 64 : index
  %c6 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
  %n7 = "llvm.mul"(%c6, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p8 = "llvm.getelementptr"(%a, %n7) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  %c9 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
  %n10 = "llvm.mul"(%c9, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p11 = "llvm.getelementptr"(%a, %n10) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  %c12 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
  %n13 = "llvm.mul"(%c12, %lda) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p14 = "llvm.getelementptr"(%a, %n13) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  %c15 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
  %n16 = "llvm.mul"(%c15, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p17 = "llvm.getelementptr"(%c, %n16) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  %c18 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
  %n19 = "llvm.mul"(%c18, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p20 = "llvm.getelementptr"(%c, %n19) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  %c21 = "llvm.mlir.constant"() <{value = 3 : i64}> : () -> i64
  %n22 = "llvm.mul"(%c21, %ldc) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
  %p23 = "llvm.getelementptr"(%c, %n22) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
  "scf.for"(%i1, %n4, %i5) ({
  ^bb0(%iv24: index):
    %x25 = arith.index_cast %iv24 : index to i64
    %z26 = arith.constant dense<0.000000e+00> : vector<16xf32>
    %p27 = "llvm.getelementptr"(%b, %x25) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %r45:16 = "scf.for"(%i1, %k3, %i2, %z26, %z26, %z26, %z26, %z26, %z26, %z26, %z26, %z26, %z26, %z26, %z26, %z26, %z26, %z26, %z26) ({
    ^bb0(%iv28: index, %a29: vector<16xf32>, %a30: vector<16xf32>, %a31: vector<16xf32>, %a32: vector<16xf32>, %a33: vector<16xf32>, %a34: vector<16xf32>, %a35: vector<16xf32>, %a36: vector<16xf32>, %a37: vector<16xf32>, %a38: vector<16xf32>, %a39: vector<16xf32>, %a40: vector<16xf32>, %a41: vector<16xf32>, %a42: vector<16xf32>, %a43: vector<16xf32>, %a44: vector<16xf32>):
      %x61 = arith.index_cast %iv28 : index to i64
      %n62 = "llvm.mul"(%x61, %ldb) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %p63 = "llvm.getelementptr"(%p27, %n62) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v64 = "llvm.load"(%p63) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
      %c65 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
      %p66 = "llvm.getelementptr"(%p63, %c65) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v67 = "llvm.load"(%p66) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
      %c68 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
      %p69 = "llvm.getelementptr"(%p63, %c68) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v70 = "llvm.load"(%p69) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
      %c71 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
      %p72 = "llvm.getelementptr"(%p63, %c71) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v73 = "llvm.load"(%p72) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> vector<16xf32>
      %p74 = "llvm.getelementptr"(%a, %x61) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v75 = "llvm.load"(%p74) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> f32
      %s76 = "vector.broadcast"(%v75) : (f32) -> vector<16xf32>
      %v77 = "math.fma"(%s76, %v64, %a29) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v78 = "math.fma"(%s76, %v67, %a30) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v79 = "math.fma"(%s76, %v70, %a31) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v80 = "math.fma"(%s76, %v73, %a32) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %p81 = "llvm.getelementptr"(%p8, %x61) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v82 = "llvm.load"(%p81) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> f32
      %s83 = "vector.broadcast"(%v82) : (f32) -> vector<16xf32>
      %v84 = "math.fma"(%s83, %v64, %a33) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v85 = "math.fma"(%s83, %v67, %a34) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v86 = "math.fma"(%s83, %v70, %a35) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v87 = "math.fma"(%s83, %v73, %a36) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %p88 = "llvm.getelementptr"(%p11, %x61) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v89 = "llvm.load"(%p88) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> f32
      %s90 = "vector.broadcast"(%v89) : (f32) -> vector<16xf32>
      %v91 = "math.fma"(%s90, %v64, %a37) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v92 = "math.fma"(%s90, %v67, %a38) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v93 = "math.fma"(%s90, %v70, %a39) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v94 = "math.fma"(%s90, %v73, %a40) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %p95 = "llvm.getelementptr"(%p14, %x61) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %v96 = "llvm.load"(%p95) <{alignment = 4 : i64, ordering = 0 : i64}> : (!llvm.ptr) -> f32
      %s97 = "vector.broadcast"(%v96) : (f32) -> vector<16xf32>
      %v98 = "math.fma"(%s97, %v64, %a41) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v99 = "math.fma"(%s97, %v67, %a42) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v100 = "math.fma"(%s97, %v70, %a43) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      %v101 = "math.fma"(%s97, %v73, %a44) <{fastmath = #arith.fastmath<none>}> : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
      "scf.yield"(%v77, %v78, %v79, %v80, %v84, %v85, %v86, %v87, %v91, %v92, %v93, %v94, %v98, %v99, %v100, %v101) : (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> ()
    }) : (index, index, index, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>) -> (vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>, vector<16xf32>)
    %p102 = "llvm.getelementptr"(%c, %x25) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p103 = "llvm.getelementptr"(%p17, %x25) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p104 = "llvm.getelementptr"(%p20, %x25) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %p105 = "llvm.getelementptr"(%p23, %x25) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c106 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p107 = "llvm.getelementptr"(%p102, %c106) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c108 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p109 = "llvm.getelementptr"(%p102, %c108) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c110 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p111 = "llvm.getelementptr"(%p102, %c110) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c112 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p113 = "llvm.getelementptr"(%p103, %c112) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c114 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p115 = "llvm.getelementptr"(%p103, %c114) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c116 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p117 = "llvm.getelementptr"(%p103, %c116) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c118 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p119 = "llvm.getelementptr"(%p104, %c118) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c120 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p121 = "llvm.getelementptr"(%p104, %c120) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c122 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p123 = "llvm.getelementptr"(%p104, %c122) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c124 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %p125 = "llvm.getelementptr"(%p105, %c124) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c126 = "llvm.mlir.constant"() <{value = 32 : i64}> : () -> i64
    %p127 = "llvm.getelementptr"(%p105, %c126) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %c128 = "llvm.mlir.constant"() <{value = 48 : i64}> : () -> i64
    %p129 = "llvm.getelementptr"(%p105, %c128) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%r45#0, %p102) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r45#1, %p107) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r45#2, %p109) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r45#3, %p111) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r45#4, %p103) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r45#5, %p113) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r45#6, %p115) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r45#7, %p117) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r45#8, %p104) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r45#9, %p119) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r45#10, %p121) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r45#11, %p123) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r45#12, %p105) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r45#13, %p125) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r45#14, %p127) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "llvm.store"(%r45#15, %p129) <{alignment = 4 : i64, ordering = 0 : i64}> : (vector<16xf32>, !llvm.ptr) -> ()
    "scf.yield"() : () -> ()
  }) : (index, index, index) -> ()
  "func.return"() : () -> ()
}
