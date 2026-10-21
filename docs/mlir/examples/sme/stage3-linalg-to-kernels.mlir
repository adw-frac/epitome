"builtin.module"() ({
  "func.func"() <{function_type = (!llvm.ptr, i64, !llvm.ptr, i64, !llvm.ptr, i64, i64, i64) -> (), sym_name = "__epitome_sme_matmul_f32", sym_visibility = "private"}> ({
  ^bb0(%arg0: !llvm.ptr, %arg1: i64, %arg2: !llvm.ptr, %arg3: i64, %arg4: !llvm.ptr, %arg5: i64, %arg6: i64, %arg7: i64):
    "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.start"}> : () -> ()
    "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.ptrue.p0.s"}> : () -> ()
    "llvm.call_intrinsic"(%arg7) <{intrin = "llvm.epitome.sme.whilelt.p1.s"}> : (i64) -> ()
    %0 = "arith.constant"() <{value = 0 : index}> : () -> index
    %1 = "arith.constant"() <{value = 1 : index}> : () -> index
    %2 = "arith.constant"() <{value = 16 : index}> : () -> index
    "scf.for"(%0, %2, %1) ({
    ^bb0(%arg8: index):
      %3 = "arith.index_cast"(%arg8) : (index) -> i64
      %4 = "llvm.mul"(%3, %arg1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %5 = "llvm.getelementptr"(%arg0, %4) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %6 = "arith.trunci"(%3) : (i64) -> i32
      "llvm.call_intrinsic"(%5, %6) <{intrin = "llvm.epitome.sme.ld1w.za0h.s"}> : (!llvm.ptr, i32) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    %7 = "arith.index_cast"(%arg6) : (i64) -> index
    "scf.for"(%0, %7, %1) ({
    ^bb0(%arg9: index):
      %8 = "arith.index_cast"(%arg9) : (index) -> i64
      %9 = "llvm.mul"(%8, %arg3) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %10 = "llvm.getelementptr"(%arg2, %9) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %11 = "llvm.mul"(%8, %arg5) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %12 = "llvm.getelementptr"(%arg4, %11) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      "llvm.call_intrinsic"(%10, %12) <{intrin = "llvm.epitome.sme.fmopa.za0.s"}> : (!llvm.ptr, !llvm.ptr) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.for"(%0, %2, %1) ({
    ^bb0(%arg10: index):
      %13 = "arith.index_cast"(%arg10) : (index) -> i64
      %14 = "llvm.mul"(%13, %arg1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
      %15 = "llvm.getelementptr"(%arg0, %14) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
      %16 = "arith.trunci"(%13) : (i64) -> i32
      "llvm.call_intrinsic"(%15, %16) <{intrin = "llvm.epitome.sme.st1w.za0h.s"}> : (!llvm.ptr, i32) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.stop"}> : () -> ()
    "func.return"() : () -> ()
  }) : () -> ()
  "func.func"() <{function_type = (memref<16x4xf32>, memref<4x20xf32>, memref<16x20xf32>) -> (), sym_name = "matmul"}> ({
  ^bb0(%arg0: memref<16x4xf32>, %arg1: memref<4x20xf32>, %arg2: memref<16x20xf32>):
    %0 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %1 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<16x20xf32>
    "linalg.fill"(%0, %1) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg3: f32, %arg4: f32):
      "linalg.yield"(%arg3) : (f32) -> ()
    }) : (f32, memref<16x20xf32>) -> ()
    %2 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<4x16xf32>
    "linalg.generic"(%arg0, %2) <{indexing_maps = [affine_map<(d0, d1) -> (d1, d0)>, affine_map<(d0, d1) -> (d0, d1)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg5: f32, %arg6: f32):
      "linalg.yield"(%arg5) : (f32) -> ()
    }) : (memref<16x4xf32>, memref<4x16xf32>) -> ()
    %3 = "memref.extract_aligned_pointer_as_index"(%2) : (memref<4x16xf32>) -> index
    %4 = "arith.index_cast"(%3) : (index) -> i64
    %5 = "llvm.inttoptr"(%4) : (i64) -> !llvm.ptr
    %6 = "memref.extract_aligned_pointer_as_index"(%arg1) : (memref<4x20xf32>) -> index
    %7 = "arith.index_cast"(%6) : (index) -> i64
    %8 = "llvm.inttoptr"(%7) : (i64) -> !llvm.ptr
    %9 = "memref.extract_aligned_pointer_as_index"(%1) : (memref<16x20xf32>) -> index
    %10 = "arith.index_cast"(%9) : (index) -> i64
    %11 = "llvm.inttoptr"(%10) : (i64) -> !llvm.ptr
    %12 = "llvm.mlir.constant"() <{value = 20 : i64}> : () -> i64
    %13 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %14 = "llvm.mlir.constant"() <{value = 20 : i64}> : () -> i64
    %15 = "llvm.mlir.constant"() <{value = 4 : i64}> : () -> i64
    %16 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %17 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %18 = "arith.constant"() <{value = 0 : index}> : () -> index
    %19 = "arith.constant"() <{value = 16 : index}> : () -> index
    %20 = "arith.constant"() <{value = 16 : index}> : () -> index
    %21 = "arith.constant"() <{value = 16 : index}> : () -> index
    %22 = "arith.constant"() <{value = 20 : index}> : () -> index
    "scf.for"(%18, %21, %19) ({
    ^bb0(%arg7: index):
      "scf.for"(%18, %22, %20) ({
      ^bb0(%arg8: index):
        %23 = "arith.index_cast"(%arg7) : (index) -> i64
        %24 = "arith.index_cast"(%arg8) : (index) -> i64
        %25 = "arith.subi"(%22, %arg8) : (index, index) -> index
        %26 = "arith.minsi"(%25, %20) : (index, index) -> index
        %27 = "arith.index_cast"(%26) : (index) -> i64
        %28 = "llvm.mul"(%23, %12) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %29 = "llvm.add"(%28, %24) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %30 = "llvm.add"(%29, %17) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %31 = "llvm.getelementptr"(%11, %30) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
        %32 = "llvm.getelementptr"(%5, %23) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
        %33 = "llvm.add"(%24, %16) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %34 = "llvm.getelementptr"(%8, %33) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
        "func.call"(%31, %12, %32, %13, %34, %14, %15, %27) <{callee = @__epitome_sme_matmul_f32}> : (!llvm.ptr, i64, !llvm.ptr, i64, !llvm.ptr, i64, i64, i64) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "memref.dealloc"(%2) : (memref<4x16xf32>) -> ()
    "memref.copy"(%1, %arg2) : (memref<16x20xf32>, memref<16x20xf32>) -> ()
    "memref.dealloc"(%1) : (memref<16x20xf32>) -> ()
    "func.return"() : () -> ()
  }) : () -> ()
}) : () -> ()
