"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<ptr (ptr, ptr)>, linkage = #llvm.linkage<external>, res_attrs = [{llvm.align = 16 : i64, llvm.noalias, llvm.nonnull, llvm.noundef}], sym_name = "arcRuntimeIR_allocInstance", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (ptr)>, linkage = #llvm.linkage<external>, sym_name = "arcRuntimeIR_deleteInstance", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, arg_attrs = [{llvm.noalias, llvm.nocapture, llvm.nofree}], function_type = !llvm.func<void (ptr)>, linkage = #llvm.linkage<external>, sym_name = "arcRuntimeIR_onEval", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, arg_attrs = [{llvm.noalias, llvm.nocapture, llvm.nofree}], function_type = !llvm.func<void (ptr)>, linkage = #llvm.linkage<external>, sym_name = "arcRuntimeIR_onInitialized", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.mlir.global"() <{addr_space = 0 : i32, constant, global_type = !llvm.array<4 x i8>, linkage = #llvm.linkage<internal>, sym_name = "_arc_mod_name_GCD", tls_mode = 0 : i64, unnamed_addr = 0 : i64, value = "GCD\00", visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.mlir.global"() <{addr_space = 0 : i32, global_type = !llvm.struct<(i64, i64, ptr, ptr)>, linkage = #llvm.linkage<external>, sym_name = "arcRuntimeModel_GCD", tls_mode = 0 : i64, unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
    %45 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %46 = "llvm.mlir.constant"() <{value = 41 : i64}> : () -> i64
    %47 = "llvm.mlir.addressof"() <{global_name = @_arc_mod_name_GCD}> : () -> !llvm.ptr
    %48 = "llvm.mlir.zero"() : () -> !llvm.ptr
    %49 = "llvm.mlir.poison"() : () -> !llvm.struct<(i64, i64, ptr, ptr)>
    %50 = "llvm.insertvalue"(%49, %45) <{position = array<i64: 0>}> : (!llvm.struct<(i64, i64, ptr, ptr)>, i64) -> !llvm.struct<(i64, i64, ptr, ptr)>
    %51 = "llvm.insertvalue"(%50, %46) <{position = array<i64: 1>}> : (!llvm.struct<(i64, i64, ptr, ptr)>, i64) -> !llvm.struct<(i64, i64, ptr, ptr)>
    %52 = "llvm.insertvalue"(%51, %47) <{position = array<i64: 2>}> : (!llvm.struct<(i64, i64, ptr, ptr)>, !llvm.ptr) -> !llvm.struct<(i64, i64, ptr, ptr)>
    %53 = "llvm.insertvalue"(%52, %48) <{position = array<i64: 3>}> : (!llvm.struct<(i64, i64, ptr, ptr)>, !llvm.ptr) -> !llvm.struct<(i64, i64, ptr, ptr)>
    "llvm.return"(%53) : (!llvm.struct<(i64, i64, ptr, ptr)>) -> ()
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (i32)>, linkage = #llvm.linkage<external>, sym_name = "exit", sym_visibility = "private", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void ()>, linkage = #llvm.linkage<external>, sym_name = "GCD_main", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
    %35 = "llvm.mlir.constant"() <{value = -1 : i64}> : () -> i64
    %36 = "llvm.mlir.zero"() : () -> !llvm.ptr
    %37 = "llvm.mlir.addressof"() <{global_name = @arcRuntimeModel_GCD}> : () -> !llvm.ptr
    %38 = "llvm.call"(%37, %36) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @arcRuntimeIR_allocInstance, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 2, 0>}> : (!llvm.ptr, !llvm.ptr) -> !llvm.ptr
    "llvm.call"(%38) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @arcRuntimeIR_onInitialized, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (!llvm.ptr) -> ()
    %39 = "llvm.getelementptr"(%38) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 16>}> : (!llvm.ptr) -> !llvm.ptr
    %40 = "llvm.load"(%39) <{ordering = 0 : i64}> : (!llvm.ptr) -> i64
    "llvm.br"(%40)[^bb1] : (i64) -> ()
  ^bb1(%41: i64):  // 2 preds: ^bb0, ^bb2
    %42 = "llvm.icmp"(%41, %35) <{predicate = 1 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%42, %41)[^bb2, ^bb3] <{operandSegmentSizes = array<i32: 1, 1, 0>}> : (i1, i64) -> ()
  ^bb2(%43: i64):  // pred: ^bb1
    "llvm.store"(%43, %38) <{ordering = 0 : i64}> : (i64, !llvm.ptr) -> ()
    "llvm.call"(%38) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @arcRuntimeIR_onEval, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (!llvm.ptr) -> ()
    "llvm.call"(%38) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @GCD_eval, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (!llvm.ptr) -> ()
    %44 = "llvm.load"(%39) <{ordering = 0 : i64}> : (!llvm.ptr) -> i64
    "llvm.br"(%44)[^bb1] : (i64) -> ()
  ^bb3:  // pred: ^bb1
    "llvm.call"(%38) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @arcRuntimeIR_deleteInstance, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (!llvm.ptr) -> ()
    "llvm.return"() : () -> ()
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (ptr)>, linkage = #llvm.linkage<external>, sym_name = "GCD_eval", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  ^bb0(%arg0: !llvm.ptr):
    %0 = "llvm.mlir.constant"() <{value = 0 : i16}> : () -> i16
    %1 = "llvm.mlir.constant"() <{value = -1 : i64}> : () -> i64
    %2 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 16>}> : (!llvm.ptr) -> !llvm.ptr
    "llvm.store"(%1, %2) <{ordering = 0 : i64}> : (i64, !llvm.ptr) -> ()
    %3 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 24>}> : (!llvm.ptr) -> !llvm.ptr
    %4 = "llvm.load"(%3) <{ordering = 0 : i64}> : (!llvm.ptr) -> i1
    %5 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 36>}> : (!llvm.ptr) -> !llvm.ptr
    %6 = "llvm.load"(%5) <{ordering = 0 : i64}> : (!llvm.ptr) -> i1
    "llvm.store"(%4, %5) <{ordering = 0 : i64}> : (i1, !llvm.ptr) -> ()
    %7 = "llvm.xor"(%6, %4) : (i1, i1) -> i1
    %8 = "llvm.and"(%7, %4) : (i1, i1) -> i1
    "llvm.cond_br"(%8)[^bb1, ^bb2] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb1:  // pred: ^bb0
    %9 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 32>}> : (!llvm.ptr) -> !llvm.ptr
    %10 = "llvm.load"(%9) <{ordering = 0 : i64}> : (!llvm.ptr) -> i16
    %11 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 34>}> : (!llvm.ptr) -> !llvm.ptr
    %12 = "llvm.load"(%11) <{ordering = 0 : i64}> : (!llvm.ptr) -> i16
    %13 = "llvm.icmp"(%10, %12) <{predicate = 8 : i64}> : (i16, i16) -> i1
    %14 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 30>}> : (!llvm.ptr) -> !llvm.ptr
    %15 = "llvm.load"(%14) <{ordering = 0 : i64}> : (!llvm.ptr) -> i1
    %16 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 26>}> : (!llvm.ptr) -> !llvm.ptr
    %17 = "llvm.load"(%16) <{ordering = 0 : i64}> : (!llvm.ptr) -> i16
    %18 = "llvm.sub"(%10, %12) <{overflowFlags = 0 : i32}> : (i16, i16) -> i16
    %19 = "llvm.select"(%13, %18, %10) <{fastmathFlags = #llvm.fastmath<none>}> : (i1, i16, i16) -> i16
    %20 = "llvm.select"(%15, %17, %19) <{fastmathFlags = #llvm.fastmath<none>}> : (i1, i16, i16) -> i16
    "llvm.store"(%20, %9) <{ordering = 0 : i64}> : (i16, !llvm.ptr) -> ()
    %21 = "llvm.load"(%11) <{ordering = 0 : i64}> : (!llvm.ptr) -> i16
    %22 = "llvm.load"(%14) <{ordering = 0 : i64}> : (!llvm.ptr) -> i1
    %23 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 28>}> : (!llvm.ptr) -> !llvm.ptr
    %24 = "llvm.load"(%23) <{ordering = 0 : i64}> : (!llvm.ptr) -> i16
    %25 = "llvm.sub"(%21, %10) <{overflowFlags = 0 : i32}> : (i16, i16) -> i16
    %26 = "llvm.select"(%13, %21, %25) <{fastmathFlags = #llvm.fastmath<none>}> : (i1, i16, i16) -> i16
    %27 = "llvm.select"(%22, %24, %26) <{fastmathFlags = #llvm.fastmath<none>}> : (i1, i16, i16) -> i16
    "llvm.store"(%27, %11) <{ordering = 0 : i64}> : (i16, !llvm.ptr) -> ()
    "llvm.br"()[^bb2] : () -> ()
  ^bb2:  // 2 preds: ^bb0, ^bb1
    %28 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 32>}> : (!llvm.ptr) -> !llvm.ptr
    %29 = "llvm.load"(%28) <{ordering = 0 : i64}> : (!llvm.ptr) -> i16
    %30 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 38>}> : (!llvm.ptr) -> !llvm.ptr
    "llvm.store"(%29, %30) <{ordering = 0 : i64}> : (i16, !llvm.ptr) -> ()
    %31 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 34>}> : (!llvm.ptr) -> !llvm.ptr
    %32 = "llvm.load"(%31) <{ordering = 0 : i64}> : (!llvm.ptr) -> i16
    %33 = "llvm.icmp"(%32, %0) <{predicate = 0 : i64}> : (i16, i16) -> i1
    %34 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 40>}> : (!llvm.ptr) -> !llvm.ptr
    "llvm.store"(%33, %34) <{ordering = 0 : i64}> : (i1, !llvm.ptr) -> ()
    "llvm.return"() : () -> ()
  }) : () -> ()
}) {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} : () -> ()

