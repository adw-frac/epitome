"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<ptr (ptr, ptr)>, linkage = #llvm.linkage<external>, res_attrs = [{llvm.align = 16 : i64, llvm.noalias, llvm.nonnull, llvm.noundef}], sym_name = "arcRuntimeIR_allocInstance", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (ptr)>, linkage = #llvm.linkage<external>, sym_name = "arcRuntimeIR_deleteInstance", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, arg_attrs = [{llvm.noalias, llvm.nocapture, llvm.nofree}], function_type = !llvm.func<void (ptr)>, linkage = #llvm.linkage<external>, sym_name = "arcRuntimeIR_onEval", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, arg_attrs = [{llvm.noalias, llvm.nocapture, llvm.nofree}], function_type = !llvm.func<void (ptr)>, linkage = #llvm.linkage<external>, sym_name = "arcRuntimeIR_onInitialized", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.mlir.global"() <{addr_space = 0 : i32, constant, global_type = !llvm.array<4 x i8>, linkage = #llvm.linkage<internal>, sym_name = "_arc_mod_name_Fir", tls_mode = 0 : i64, unnamed_addr = 0 : i64, value = "Fir\00", visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.mlir.global"() <{addr_space = 0 : i32, global_type = !llvm.struct<(i64, i64, ptr, ptr)>, linkage = #llvm.linkage<external>, sym_name = "arcRuntimeModel_Fir", tls_mode = 0 : i64, unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
    %57 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %58 = "llvm.mlir.constant"() <{value = 34 : i64}> : () -> i64
    %59 = "llvm.mlir.addressof"() <{global_name = @_arc_mod_name_Fir}> : () -> !llvm.ptr
    %60 = "llvm.mlir.zero"() : () -> !llvm.ptr
    %61 = "llvm.mlir.poison"() : () -> !llvm.struct<(i64, i64, ptr, ptr)>
    %62 = "llvm.insertvalue"(%61, %57) <{position = array<i64: 0>}> : (!llvm.struct<(i64, i64, ptr, ptr)>, i64) -> !llvm.struct<(i64, i64, ptr, ptr)>
    %63 = "llvm.insertvalue"(%62, %58) <{position = array<i64: 1>}> : (!llvm.struct<(i64, i64, ptr, ptr)>, i64) -> !llvm.struct<(i64, i64, ptr, ptr)>
    %64 = "llvm.insertvalue"(%63, %59) <{position = array<i64: 2>}> : (!llvm.struct<(i64, i64, ptr, ptr)>, !llvm.ptr) -> !llvm.struct<(i64, i64, ptr, ptr)>
    %65 = "llvm.insertvalue"(%64, %60) <{position = array<i64: 3>}> : (!llvm.struct<(i64, i64, ptr, ptr)>, !llvm.ptr) -> !llvm.struct<(i64, i64, ptr, ptr)>
    "llvm.return"(%65) : (!llvm.struct<(i64, i64, ptr, ptr)>) -> ()
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (i32)>, linkage = #llvm.linkage<external>, sym_name = "exit", sym_visibility = "private", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void ()>, linkage = #llvm.linkage<external>, sym_name = "Fir_main", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
    %47 = "llvm.mlir.constant"() <{value = -1 : i64}> : () -> i64
    %48 = "llvm.mlir.zero"() : () -> !llvm.ptr
    %49 = "llvm.mlir.addressof"() <{global_name = @arcRuntimeModel_Fir}> : () -> !llvm.ptr
    %50 = "llvm.call"(%49, %48) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @arcRuntimeIR_allocInstance, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 2, 0>}> : (!llvm.ptr, !llvm.ptr) -> !llvm.ptr
    "llvm.call"(%50) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @arcRuntimeIR_onInitialized, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (!llvm.ptr) -> ()
    %51 = "llvm.getelementptr"(%50) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 16>}> : (!llvm.ptr) -> !llvm.ptr
    %52 = "llvm.load"(%51) <{ordering = 0 : i64}> : (!llvm.ptr) -> i64
    "llvm.br"(%52)[^bb1] : (i64) -> ()
  ^bb1(%53: i64):  // 2 preds: ^bb0, ^bb2
    %54 = "llvm.icmp"(%53, %47) <{predicate = 1 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%54, %53)[^bb2, ^bb3] <{operandSegmentSizes = array<i32: 1, 1, 0>}> : (i1, i64) -> ()
  ^bb2(%55: i64):  // pred: ^bb1
    "llvm.store"(%55, %50) <{ordering = 0 : i64}> : (i64, !llvm.ptr) -> ()
    "llvm.call"(%50) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @arcRuntimeIR_onEval, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (!llvm.ptr) -> ()
    "llvm.call"(%50) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @Fir_eval, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (!llvm.ptr) -> ()
    %56 = "llvm.load"(%51) <{ordering = 0 : i64}> : (!llvm.ptr) -> i64
    "llvm.br"(%56)[^bb1] : (i64) -> ()
  ^bb3:  // pred: ^bb1
    "llvm.call"(%50) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @arcRuntimeIR_deleteInstance, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (!llvm.ptr) -> ()
    "llvm.return"() : () -> ()
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (ptr)>, linkage = #llvm.linkage<external>, sym_name = "Fir_eval", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  ^bb0(%arg0: !llvm.ptr):
    %0 = "llvm.mlir.constant"() <{value = 3 : i10}> : () -> i10
    %1 = "llvm.mlir.constant"() <{value = 0 : i8}> : () -> i8
    %2 = "llvm.mlir.constant"() <{value = -1 : i64}> : () -> i64
    %3 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 16>}> : (!llvm.ptr) -> !llvm.ptr
    "llvm.store"(%2, %3) <{ordering = 0 : i64}> : (i64, !llvm.ptr) -> ()
    %4 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 24>}> : (!llvm.ptr) -> !llvm.ptr
    %5 = "llvm.load"(%4) <{ordering = 0 : i64}> : (!llvm.ptr) -> i1
    %6 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 28>}> : (!llvm.ptr) -> !llvm.ptr
    %7 = "llvm.load"(%6) <{ordering = 0 : i64}> : (!llvm.ptr) -> i1
    "llvm.store"(%5, %6) <{ordering = 0 : i64}> : (i1, !llvm.ptr) -> ()
    %8 = "llvm.xor"(%7, %5) : (i1, i1) -> i1
    %9 = "llvm.and"(%8, %5) : (i1, i1) -> i1
    "llvm.cond_br"(%9)[^bb1, ^bb7] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb1:  // pred: ^bb0
    %10 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 25>}> : (!llvm.ptr) -> !llvm.ptr
    %11 = "llvm.load"(%10) <{ordering = 0 : i64}> : (!llvm.ptr) -> i1
    "llvm.cond_br"(%11)[^bb2, ^bb3] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb2:  // pred: ^bb1
    %12 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 29>}> : (!llvm.ptr) -> !llvm.ptr
    "llvm.store"(%1, %12) <{ordering = 0 : i64}> : (i8, !llvm.ptr) -> ()
    %13 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 30>}> : (!llvm.ptr) -> !llvm.ptr
    "llvm.store"(%1, %13) <{ordering = 0 : i64}> : (i8, !llvm.ptr) -> ()
    %14 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 31>}> : (!llvm.ptr) -> !llvm.ptr
    "llvm.store"(%1, %14) <{ordering = 0 : i64}> : (i8, !llvm.ptr) -> ()
    "llvm.br"()[^bb6] : () -> ()
  ^bb3:  // pred: ^bb1
    %15 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 27>}> : (!llvm.ptr) -> !llvm.ptr
    %16 = "llvm.load"(%15) <{ordering = 0 : i64}> : (!llvm.ptr) -> i1
    "llvm.cond_br"(%16)[^bb4, ^bb5] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb4:  // pred: ^bb3
    %17 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 29>}> : (!llvm.ptr) -> !llvm.ptr
    %18 = "llvm.load"(%17) <{ordering = 0 : i64}> : (!llvm.ptr) -> i8
    %19 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 26>}> : (!llvm.ptr) -> !llvm.ptr
    %20 = "llvm.load"(%19) <{ordering = 0 : i64}> : (!llvm.ptr) -> i8
    "llvm.store"(%20, %17) <{ordering = 0 : i64}> : (i8, !llvm.ptr) -> ()
    %21 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 30>}> : (!llvm.ptr) -> !llvm.ptr
    %22 = "llvm.load"(%21) <{ordering = 0 : i64}> : (!llvm.ptr) -> i8
    "llvm.store"(%18, %21) <{ordering = 0 : i64}> : (i8, !llvm.ptr) -> ()
    %23 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 31>}> : (!llvm.ptr) -> !llvm.ptr
    "llvm.store"(%22, %23) <{ordering = 0 : i64}> : (i8, !llvm.ptr) -> ()
    "llvm.br"()[^bb5] : () -> ()
  ^bb5:  // 2 preds: ^bb3, ^bb4
    "llvm.br"()[^bb6] : () -> ()
  ^bb6:  // 2 preds: ^bb2, ^bb5
    "llvm.br"()[^bb7] : () -> ()
  ^bb7:  // 2 preds: ^bb0, ^bb6
    %24 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 31>}> : (!llvm.ptr) -> !llvm.ptr
    %25 = "llvm.load"(%24) <{ordering = 0 : i64}> : (!llvm.ptr) -> i8
    %26 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 30>}> : (!llvm.ptr) -> !llvm.ptr
    %27 = "llvm.load"(%26) <{ordering = 0 : i64}> : (!llvm.ptr) -> i8
    %28 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 29>}> : (!llvm.ptr) -> !llvm.ptr
    %29 = "llvm.load"(%28) <{ordering = 0 : i64}> : (!llvm.ptr) -> i8
    %30 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 26>}> : (!llvm.ptr) -> !llvm.ptr
    %31 = "llvm.load"(%30) <{ordering = 0 : i64}> : (!llvm.ptr) -> i8
    %32 = "llvm.zext"(%25) : (i8) -> i13
    %33 = "llvm.zext"(%27) : (i8) -> i10
    %34 = "llvm.mul"(%33, %0) <{overflowFlags = 0 : i32}> : (i10, i10) -> i10
    %35 = "llvm.zext"(%34) : (i10) -> i12
    %36 = "llvm.zext"(%29) : (i8) -> i10
    %37 = "llvm.mul"(%36, %0) <{overflowFlags = 0 : i32}> : (i10, i10) -> i10
    %38 = "llvm.zext"(%37) : (i10) -> i11
    %39 = "llvm.zext"(%31) : (i8) -> i11
    %40 = "llvm.add"(%39, %38) <{overflowFlags = 0 : i32}> : (i11, i11) -> i11
    %41 = "llvm.zext"(%40) : (i11) -> i12
    %42 = "llvm.add"(%41, %35) <{overflowFlags = 0 : i32}> : (i12, i12) -> i12
    %43 = "llvm.zext"(%42) : (i12) -> i13
    %44 = "llvm.add"(%43, %32) <{overflowFlags = 0 : i32}> : (i13, i13) -> i13
    %45 = "llvm.zext"(%44) : (i13) -> i16
    %46 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 32>}> : (!llvm.ptr) -> !llvm.ptr
    "llvm.store"(%45, %46) <{ordering = 0 : i64}> : (i16, !llvm.ptr) -> ()
    "llvm.return"() : () -> ()
  }) : () -> ()
}) {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} : () -> ()

