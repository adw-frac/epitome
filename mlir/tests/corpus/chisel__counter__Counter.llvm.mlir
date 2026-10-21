"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<ptr (ptr, ptr)>, linkage = #llvm.linkage<external>, res_attrs = [{llvm.align = 16 : i64, llvm.noalias, llvm.nonnull, llvm.noundef}], sym_name = "arcRuntimeIR_allocInstance", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (ptr)>, linkage = #llvm.linkage<external>, sym_name = "arcRuntimeIR_deleteInstance", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, arg_attrs = [{llvm.noalias, llvm.nocapture, llvm.nofree}], function_type = !llvm.func<void (ptr)>, linkage = #llvm.linkage<external>, sym_name = "arcRuntimeIR_onEval", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, arg_attrs = [{llvm.noalias, llvm.nocapture, llvm.nofree}], function_type = !llvm.func<void (ptr)>, linkage = #llvm.linkage<external>, sym_name = "arcRuntimeIR_onInitialized", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.mlir.global"() <{addr_space = 0 : i32, constant, global_type = !llvm.array<8 x i8>, linkage = #llvm.linkage<internal>, sym_name = "_arc_mod_name_Counter", tls_mode = 0 : i64, unnamed_addr = 0 : i64, value = "Counter\00", visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.mlir.global"() <{addr_space = 0 : i32, global_type = !llvm.struct<(i64, i64, ptr, ptr)>, linkage = #llvm.linkage<external>, sym_name = "arcRuntimeModel_Counter", tls_mode = 0 : i64, unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
    %31 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %32 = "llvm.mlir.constant"() <{value = 30 : i64}> : () -> i64
    %33 = "llvm.mlir.addressof"() <{global_name = @_arc_mod_name_Counter}> : () -> !llvm.ptr
    %34 = "llvm.mlir.zero"() : () -> !llvm.ptr
    %35 = "llvm.mlir.poison"() : () -> !llvm.struct<(i64, i64, ptr, ptr)>
    %36 = "llvm.insertvalue"(%35, %31) <{position = array<i64: 0>}> : (!llvm.struct<(i64, i64, ptr, ptr)>, i64) -> !llvm.struct<(i64, i64, ptr, ptr)>
    %37 = "llvm.insertvalue"(%36, %32) <{position = array<i64: 1>}> : (!llvm.struct<(i64, i64, ptr, ptr)>, i64) -> !llvm.struct<(i64, i64, ptr, ptr)>
    %38 = "llvm.insertvalue"(%37, %33) <{position = array<i64: 2>}> : (!llvm.struct<(i64, i64, ptr, ptr)>, !llvm.ptr) -> !llvm.struct<(i64, i64, ptr, ptr)>
    %39 = "llvm.insertvalue"(%38, %34) <{position = array<i64: 3>}> : (!llvm.struct<(i64, i64, ptr, ptr)>, !llvm.ptr) -> !llvm.struct<(i64, i64, ptr, ptr)>
    "llvm.return"(%39) : (!llvm.struct<(i64, i64, ptr, ptr)>) -> ()
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (i32)>, linkage = #llvm.linkage<external>, sym_name = "exit", sym_visibility = "private", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void ()>, linkage = #llvm.linkage<external>, sym_name = "Counter_main", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
    %21 = "llvm.mlir.constant"() <{value = -1 : i64}> : () -> i64
    %22 = "llvm.mlir.zero"() : () -> !llvm.ptr
    %23 = "llvm.mlir.addressof"() <{global_name = @arcRuntimeModel_Counter}> : () -> !llvm.ptr
    %24 = "llvm.call"(%23, %22) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @arcRuntimeIR_allocInstance, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 2, 0>}> : (!llvm.ptr, !llvm.ptr) -> !llvm.ptr
    "llvm.call"(%24) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @arcRuntimeIR_onInitialized, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (!llvm.ptr) -> ()
    %25 = "llvm.getelementptr"(%24) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 16>}> : (!llvm.ptr) -> !llvm.ptr
    %26 = "llvm.load"(%25) <{ordering = 0 : i64}> : (!llvm.ptr) -> i64
    "llvm.br"(%26)[^bb1] : (i64) -> ()
  ^bb1(%27: i64):  // 2 preds: ^bb0, ^bb2
    %28 = "llvm.icmp"(%27, %21) <{predicate = 1 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%28, %27)[^bb2, ^bb3] <{operandSegmentSizes = array<i32: 1, 1, 0>}> : (i1, i64) -> ()
  ^bb2(%29: i64):  // pred: ^bb1
    "llvm.store"(%29, %24) <{ordering = 0 : i64}> : (i64, !llvm.ptr) -> ()
    "llvm.call"(%24) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @arcRuntimeIR_onEval, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (!llvm.ptr) -> ()
    "llvm.call"(%24) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @Counter_eval, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (!llvm.ptr) -> ()
    %30 = "llvm.load"(%25) <{ordering = 0 : i64}> : (!llvm.ptr) -> i64
    "llvm.br"(%30)[^bb1] : (i64) -> ()
  ^bb3:  // pred: ^bb1
    "llvm.call"(%24) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @arcRuntimeIR_deleteInstance, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (!llvm.ptr) -> ()
    "llvm.return"() : () -> ()
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (ptr)>, linkage = #llvm.linkage<external>, sym_name = "Counter_eval", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  ^bb0(%arg0: !llvm.ptr):
    %0 = "llvm.mlir.constant"() <{value = 1 : i8}> : () -> i8
    %1 = "llvm.mlir.constant"() <{value = 0 : i8}> : () -> i8
    %2 = "llvm.mlir.constant"() <{value = -1 : i64}> : () -> i64
    %3 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 16>}> : (!llvm.ptr) -> !llvm.ptr
    "llvm.store"(%2, %3) <{ordering = 0 : i64}> : (i64, !llvm.ptr) -> ()
    %4 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 24>}> : (!llvm.ptr) -> !llvm.ptr
    %5 = "llvm.load"(%4) <{ordering = 0 : i64}> : (!llvm.ptr) -> i1
    %6 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 27>}> : (!llvm.ptr) -> !llvm.ptr
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
    %12 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 28>}> : (!llvm.ptr) -> !llvm.ptr
    "llvm.store"(%1, %12) <{ordering = 0 : i64}> : (i8, !llvm.ptr) -> ()
    "llvm.br"()[^bb6] : () -> ()
  ^bb3:  // pred: ^bb1
    %13 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 26>}> : (!llvm.ptr) -> !llvm.ptr
    %14 = "llvm.load"(%13) <{ordering = 0 : i64}> : (!llvm.ptr) -> i1
    "llvm.cond_br"(%14)[^bb4, ^bb5] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb4:  // pred: ^bb3
    %15 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 28>}> : (!llvm.ptr) -> !llvm.ptr
    %16 = "llvm.load"(%15) <{ordering = 0 : i64}> : (!llvm.ptr) -> i8
    %17 = "llvm.add"(%16, %0) <{overflowFlags = 0 : i32}> : (i8, i8) -> i8
    "llvm.store"(%17, %15) <{ordering = 0 : i64}> : (i8, !llvm.ptr) -> ()
    "llvm.br"()[^bb5] : () -> ()
  ^bb5:  // 2 preds: ^bb3, ^bb4
    "llvm.br"()[^bb6] : () -> ()
  ^bb6:  // 2 preds: ^bb2, ^bb5
    "llvm.br"()[^bb7] : () -> ()
  ^bb7:  // 2 preds: ^bb0, ^bb6
    %18 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 28>}> : (!llvm.ptr) -> !llvm.ptr
    %19 = "llvm.load"(%18) <{ordering = 0 : i64}> : (!llvm.ptr) -> i8
    %20 = "llvm.getelementptr"(%arg0) <{elem_type = i8, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: 29>}> : (!llvm.ptr) -> !llvm.ptr
    "llvm.store"(%19, %20) <{ordering = 0 : i64}> : (i8, !llvm.ptr) -> ()
    "llvm.return"() : () -> ()
  }) : () -> ()
}) {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} : () -> ()

