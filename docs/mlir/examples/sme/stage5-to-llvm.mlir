"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (ptr, i64, ptr, i64, ptr, i64, i64, i64)>, linkage = #llvm.linkage<external>, sym_name = "__epitome_sme_matmul_f32", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  ^bb0(%arg0: !llvm.ptr, %arg1: i64, %arg2: !llvm.ptr, %arg3: i64, %arg4: !llvm.ptr, %arg5: i64, %arg6: i64, %arg7: i64):
    "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.start"}> : () -> ()
    "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.ptrue.p0.s"}> : () -> ()
    "llvm.call_intrinsic"(%arg7) <{intrin = "llvm.epitome.sme.whilelt.p1.s"}> : (i64) -> ()
    %0 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %1 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %2 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    "llvm.br"(%0)[^bb1] : (i64) -> ()
  ^bb1(%3: i64):
    %4 = "llvm.icmp"(%3, %2) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%4)[^bb2, ^bb3] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb2:
    %5 = "llvm.mul"(%3, %arg1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %6 = "llvm.getelementptr"(%arg0, %5) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %7 = "llvm.trunc"(%3) : (i64) -> i32
    "llvm.call_intrinsic"(%6, %7) <{intrin = "llvm.epitome.sme.ld1w.za0h.s"}> : (!llvm.ptr, i32) -> ()
    %8 = "llvm.add"(%3, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%8)[^bb1] : (i64) -> ()
  ^bb3:
    "llvm.br"(%0)[^bb4] : (i64) -> ()
  ^bb4(%9: i64):
    %10 = "llvm.icmp"(%9, %arg6) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%10)[^bb5, ^bb6] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb5:
    %11 = "llvm.mul"(%9, %arg3) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %12 = "llvm.getelementptr"(%arg2, %11) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %13 = "llvm.mul"(%9, %arg5) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %14 = "llvm.getelementptr"(%arg4, %13) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.call_intrinsic"(%12, %14) <{intrin = "llvm.epitome.sme.fmopa.za0.s"}> : (!llvm.ptr, !llvm.ptr) -> ()
    %15 = "llvm.add"(%9, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%15)[^bb4] : (i64) -> ()
  ^bb6:
    "llvm.br"(%0)[^bb7] : (i64) -> ()
  ^bb7(%16: i64):
    %17 = "llvm.icmp"(%16, %2) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%17)[^bb8, ^bb9] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb8:
    %18 = "llvm.mul"(%16, %arg1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %19 = "llvm.getelementptr"(%arg0, %18) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %20 = "llvm.trunc"(%16) : (i64) -> i32
    "llvm.call_intrinsic"(%19, %20) <{intrin = "llvm.epitome.sme.st1w.za0h.s"}> : (!llvm.ptr, i32) -> ()
    %21 = "llvm.add"(%16, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%21)[^bb7] : (i64) -> ()
  ^bb9:
    "llvm.call_intrinsic"() <{intrin = "llvm.epitome.sme.stop"}> : () -> ()
    "llvm.return"() : () -> ()
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (ptr, ptr, ptr)>, linkage = #llvm.linkage<external>, sym_name = "matmul", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  ^bb0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr):
    %0 = "llvm.mlir.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %1 = "llvm.mlir.constant"() <{value = 1280 : i64}> : () -> i64
    %2 = "llvm.call"(%1) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @malloc, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (i64) -> !llvm.ptr
    %3 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %4 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %5 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    "llvm.br"(%3)[^bb1] : (i64) -> ()
  ^bb1(%6: i64):
    %7 = "llvm.icmp"(%6, %4) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%7)[^bb2, ^bb6] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb2:
    %8 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %9 = "llvm.mlir.constant"() <{value = 20 : i64}> : () -> i64
    %10 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    "llvm.br"(%8)[^bb3] : (i64) -> ()
  ^bb3(%11: i64):
    %12 = "llvm.icmp"(%11, %9) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%12)[^bb4, ^bb5] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb4:
    %13 = "llvm.mlir.constant"() <{value = 20 : i64}> : () -> i64
    %14 = "llvm.mul"(%6, %13) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %15 = "llvm.add"(%14, %11) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %16 = "llvm.getelementptr"(%2, %15) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%0, %16) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %17 = "llvm.add"(%11, %10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%17)[^bb3] : (i64) -> ()
  ^bb5:
    %18 = "llvm.add"(%6, %5) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%18)[^bb1] : (i64) -> ()
  ^bb6:
    %19 = "llvm.mlir.constant"() <{value = 256 : i64}> : () -> i64
    %20 = "llvm.call"(%19) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @malloc, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (i64) -> !llvm.ptr
    %21 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %22 = "llvm.mlir.constant"() <{value = 4 : i64}> : () -> i64
    %23 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    "llvm.br"(%21)[^bb7] : (i64) -> ()
  ^bb7(%24: i64):
    %25 = "llvm.icmp"(%24, %22) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%25)[^bb8, ^bb12] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb8:
    %26 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %27 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %28 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    "llvm.br"(%26)[^bb9] : (i64) -> ()
  ^bb9(%29: i64):
    %30 = "llvm.icmp"(%29, %27) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%30)[^bb10, ^bb11] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb10:
    %31 = "llvm.mlir.constant"() <{value = 4 : i64}> : () -> i64
    %32 = "llvm.mul"(%29, %31) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %33 = "llvm.add"(%32, %24) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %34 = "llvm.getelementptr"(%arg0, %33) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %35 = "llvm.load"(%34) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %36 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %37 = "llvm.mul"(%24, %36) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %38 = "llvm.add"(%37, %29) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %39 = "llvm.getelementptr"(%20, %38) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%35, %39) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %40 = "llvm.add"(%29, %28) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%40)[^bb9] : (i64) -> ()
  ^bb11:
    %41 = "llvm.add"(%24, %23) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%41)[^bb7] : (i64) -> ()
  ^bb12:
    %42 = "llvm.ptrtoint"(%20) : (!llvm.ptr) -> i64
    %43 = "llvm.inttoptr"(%42) : (i64) -> !llvm.ptr
    %44 = "llvm.ptrtoint"(%arg1) : (!llvm.ptr) -> i64
    %45 = "llvm.inttoptr"(%44) : (i64) -> !llvm.ptr
    %46 = "llvm.ptrtoint"(%2) : (!llvm.ptr) -> i64
    %47 = "llvm.inttoptr"(%46) : (i64) -> !llvm.ptr
    %48 = "llvm.mlir.constant"() <{value = 20 : i64}> : () -> i64
    %49 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %50 = "llvm.mlir.constant"() <{value = 20 : i64}> : () -> i64
    %51 = "llvm.mlir.constant"() <{value = 4 : i64}> : () -> i64
    %52 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %53 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %54 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %55 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %56 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %57 = "llvm.mlir.constant"() <{value = 16 : i64}> : () -> i64
    %58 = "llvm.mlir.constant"() <{value = 20 : i64}> : () -> i64
    "llvm.br"(%54)[^bb13] : (i64) -> ()
  ^bb13(%59: i64):
    %60 = "llvm.icmp"(%59, %57) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%60)[^bb14, ^bb18] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb14:
    "llvm.br"(%54)[^bb15] : (i64) -> ()
  ^bb15(%61: i64):
    %62 = "llvm.icmp"(%61, %58) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%62)[^bb16, ^bb17] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb16:
    %63 = "llvm.sub"(%58, %61) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %64 = "llvm.icmp"(%63, %56) <{predicate = 2 : i64}> : (i64, i64) -> i1
    %65 = "llvm.select"(%64, %63, %56) <{fastmathFlags = #llvm.fastmath<none>}> : (i1, i64, i64) -> i64
    %66 = "llvm.mul"(%59, %48) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %67 = "llvm.add"(%66, %61) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %68 = "llvm.add"(%67, %53) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %69 = "llvm.getelementptr"(%47, %68) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %70 = "llvm.getelementptr"(%43, %59) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %71 = "llvm.add"(%61, %52) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %72 = "llvm.getelementptr"(%45, %71) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.call"(%69, %48, %70, %49, %72, %50, %51, %65) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @__epitome_sme_matmul_f32, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 8, 0>}> : (!llvm.ptr, i64, !llvm.ptr, i64, !llvm.ptr, i64, i64, i64) -> ()
    %73 = "llvm.add"(%61, %56) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%73)[^bb15] : (i64) -> ()
  ^bb17:
    %74 = "llvm.add"(%59, %55) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%74)[^bb13] : (i64) -> ()
  ^bb18:
    "llvm.call"(%20) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @free, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (!llvm.ptr) -> ()
    %75 = "llvm.mlir.constant"() <{value = 1280 : i64}> : () -> i64
    "llvm.intr.memcpy"(%arg2, %2, %75) <{isVolatile = false}> : (!llvm.ptr, !llvm.ptr, i64) -> ()
    "llvm.call"(%2) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @free, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (!llvm.ptr) -> ()
    "llvm.return"() : () -> ()
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<ptr (i64)>, linkage = #llvm.linkage<external>, sym_name = "malloc", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (ptr)>, linkage = #llvm.linkage<external>, sym_name = "free", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
}) : () -> ()
