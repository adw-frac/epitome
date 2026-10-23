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
    %2 = "arith.constant"() <{value = 0 : index}> : () -> index
    %3 = "arith.constant"() <{value = 16 : index}> : () -> index
    %4 = "arith.constant"() <{value = 1 : index}> : () -> index
    "scf.for"(%2, %3, %4) ({
    ^bb0(%arg3: index):
      %5 = "arith.constant"() <{value = 0 : index}> : () -> index
      %6 = "arith.constant"() <{value = 20 : index}> : () -> index
      %7 = "arith.constant"() <{value = 1 : index}> : () -> index
      "scf.for"(%5, %6, %7) ({
      ^bb0(%arg4: index):
        "memref.store"(%0, %1, %arg3, %arg4) : (f32, memref<16x20xf32>, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    %8 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<4x16xf32>
    %9 = "arith.constant"() <{value = 0 : index}> : () -> index
    %10 = "arith.constant"() <{value = 4 : index}> : () -> index
    %11 = "arith.constant"() <{value = 1 : index}> : () -> index
    "scf.for"(%9, %10, %11) ({
    ^bb0(%arg5: index):
      %12 = "arith.constant"() <{value = 0 : index}> : () -> index
      %13 = "arith.constant"() <{value = 16 : index}> : () -> index
      %14 = "arith.constant"() <{value = 1 : index}> : () -> index
      "scf.for"(%12, %13, %14) ({
      ^bb0(%arg6: index):
        %15 = "memref.load"(%arg0, %arg6, %arg5) : (memref<16x4xf32>, index, index) -> f32
        "memref.store"(%15, %8, %arg5, %arg6) : (f32, memref<4x16xf32>, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    %16 = "memref.extract_aligned_pointer_as_index"(%8) : (memref<4x16xf32>) -> index
    %17 = "arith.index_cast"(%16) : (index) -> i64
    %18 = "llvm.inttoptr"(%17) : (i64) -> !llvm.ptr
    %19 = "memref.extract_aligned_pointer_as_index"(%arg1) : (memref<4x20xf32>) -> index
    %20 = "arith.index_cast"(%19) : (index) -> i64
    %21 = "llvm.inttoptr"(%20) : (i64) -> !llvm.ptr
    %22 = "memref.extract_aligned_pointer_as_index"(%1) : (memref<16x20xf32>) -> index
    %23 = "arith.index_cast"(%22) : (index) -> i64
    %24 = "llvm.inttoptr"(%23) : (i64) -> !llvm.ptr
    %25 = "llvm.mlir.constant"() <{value = 20 : i64}> : () -> i64
    %26 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %27 = "llvm.mlir.constant"() <{value = 20 : i64}> : () -> i64
    %28 = "llvm.mlir.constant"() <{value = 4 : i64}> : () -> i64
    %29 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %30 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %31 = "arith.constant"() <{value = 0 : index}> : () -> index
    %32 = "arith.constant"() <{value = 16 : index}> : () -> index
    %33 = "arith.constant"() <{value = 16 : index}> : () -> index
    %34 = "arith.constant"() <{value = 16 : index}> : () -> index
    %35 = "arith.constant"() <{value = 20 : index}> : () -> index
    "scf.for"(%31, %34, %32) ({
    ^bb0(%arg7: index):
      "scf.for"(%31, %35, %33) ({
      ^bb0(%arg8: index):
        %36 = "arith.index_cast"(%arg7) : (index) -> i64
        %37 = "arith.index_cast"(%arg8) : (index) -> i64
        %38 = "arith.subi"(%35, %arg8) : (index, index) -> index
        %39 = "arith.minsi"(%38, %33) : (index, index) -> index
        %40 = "arith.index_cast"(%39) : (index) -> i64
        %41 = "llvm.mul"(%36, %25) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %42 = "llvm.add"(%41, %37) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %43 = "llvm.add"(%42, %30) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %44 = "llvm.getelementptr"(%24, %43) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
        %45 = "llvm.getelementptr"(%18, %36) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
        %46 = "llvm.add"(%37, %29) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
        %47 = "llvm.getelementptr"(%21, %46) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
        "func.call"(%44, %25, %45, %26, %47, %27, %28, %40) <{callee = @__epitome_sme_matmul_f32}> : (!llvm.ptr, i64, !llvm.ptr, i64, !llvm.ptr, i64, i64, i64) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "memref.dealloc"(%8) : (memref<4x16xf32>) -> ()
    "memref.copy"(%1, %arg2) : (memref<16x20xf32>, memref<16x20xf32>) -> ()
    "memref.dealloc"(%1) : (memref<16x20xf32>) -> ()
    "func.return"() : () -> ()
  }) : () -> ()
}) : () -> ()
