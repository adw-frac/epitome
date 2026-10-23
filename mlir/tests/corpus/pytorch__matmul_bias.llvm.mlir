"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<ptr (i64)>, linkage = #llvm.linkage<external>, sym_name = "malloc", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> (ptr, ptr, i64, i64, i64, i64, i64, ptr, ptr, i64, i64, i64, i64, i64, ptr, ptr, i64, i64, i64)>, linkage = #llvm.linkage<external>, sym_name = "matmul_bias", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  ^bb0(%arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: i64, %arg10: i64, %arg11: !llvm.ptr, %arg12: !llvm.ptr, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: i64, %arg17: i64, %arg18: !llvm.ptr, %arg19: !llvm.ptr, %arg20: i64, %arg21: i64, %arg22: i64):
    %23 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %24 = "llvm.insertvalue"(%23, %arg18) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %25 = "llvm.insertvalue"(%24, %arg19) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %26 = "llvm.insertvalue"(%25, %arg20) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %27 = "llvm.insertvalue"(%26, %arg21) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %28 = "llvm.insertvalue"(%27, %arg22) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %29 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %30 = "llvm.insertvalue"(%29, %arg11) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %31 = "llvm.insertvalue"(%30, %arg12) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %32 = "llvm.insertvalue"(%31, %arg13) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %33 = "llvm.insertvalue"(%32, %arg14) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %34 = "llvm.insertvalue"(%33, %arg16) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %35 = "llvm.insertvalue"(%34, %arg15) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %36 = "llvm.insertvalue"(%35, %arg17) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %37 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %38 = "llvm.insertvalue"(%37, %arg4) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %39 = "llvm.insertvalue"(%38, %arg5) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %40 = "llvm.insertvalue"(%39, %arg6) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %41 = "llvm.insertvalue"(%40, %arg7) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %42 = "llvm.insertvalue"(%41, %arg9) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %43 = "llvm.insertvalue"(%42, %arg8) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %44 = "llvm.insertvalue"(%43, %arg10) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %45 = "llvm.mlir.constant"() <{value = 3 : index}> : () -> i64
    %46 = "llvm.mlir.constant"() <{value = 4 : index}> : () -> i64
    %47 = "llvm.mlir.constant"() <{value = 1 : index}> : () -> i64
    %48 = "llvm.mlir.constant"() <{value = 2 : index}> : () -> i64
    %49 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %50 = "llvm.mlir.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %51 = "llvm.mlir.constant"() <{value = 2 : index}> : () -> i64
    %52 = "llvm.mlir.constant"() <{value = 4 : index}> : () -> i64
    %53 = "llvm.mlir.constant"() <{value = 1 : index}> : () -> i64
    %54 = "llvm.mlir.constant"() <{value = 8 : index}> : () -> i64
    %55 = "llvm.mlir.zero"() : () -> !llvm.ptr
    %56 = "llvm.getelementptr"(%55, %54) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %57 = "llvm.ptrtoint"(%56) : (!llvm.ptr) -> i64
    %58 = "llvm.mlir.constant"() <{value = 64 : index}> : () -> i64
    %59 = "llvm.add"(%57, %58) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %60 = "llvm.call"(%59) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @malloc, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 1, 0>}> : (i64) -> !llvm.ptr
    %61 = "llvm.ptrtoint"(%60) : (!llvm.ptr) -> i64
    %62 = "llvm.mlir.constant"() <{value = 1 : index}> : () -> i64
    %63 = "llvm.sub"(%58, %62) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %64 = "llvm.add"(%61, %63) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %65 = "llvm.urem"(%64, %58) : (i64, i64) -> i64
    %66 = "llvm.sub"(%64, %65) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %67 = "llvm.inttoptr"(%66) : (i64) -> !llvm.ptr
    %68 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %69 = "llvm.insertvalue"(%68, %60) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %70 = "llvm.insertvalue"(%69, %67) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %71 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %72 = "llvm.insertvalue"(%70, %71) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %73 = "llvm.insertvalue"(%72, %51) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %74 = "llvm.insertvalue"(%73, %52) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %75 = "llvm.insertvalue"(%74, %52) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %76 = "llvm.insertvalue"(%75, %53) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    "llvm.br"(%49)[^bb1] : (i64) -> ()
  ^bb1(%77: i64):  // 2 preds: ^bb0, ^bb5
    %78 = "llvm.icmp"(%77, %48) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%78)[^bb2, ^bb6] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb2:  // pred: ^bb1
    "llvm.br"(%49)[^bb3] : (i64) -> ()
  ^bb3(%79: i64):  // 2 preds: ^bb2, ^bb4
    %80 = "llvm.icmp"(%79, %46) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%80)[^bb4, ^bb5] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb4:  // pred: ^bb3
    %81 = "llvm.extractvalue"(%76) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> !llvm.ptr
    %82 = "llvm.mlir.constant"() <{value = 4 : index}> : () -> i64
    %83 = "llvm.mul"(%77, %82) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %84 = "llvm.add"(%83, %79) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %85 = "llvm.getelementptr"(%81, %84) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%50, %85) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %86 = "llvm.add"(%79, %47) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%86)[^bb3] : (i64) -> ()
  ^bb5:  // pred: ^bb3
    %87 = "llvm.add"(%77, %47) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%87)[^bb1] : (i64) -> ()
  ^bb6:  // pred: ^bb1
    "llvm.br"(%49)[^bb7] : (i64) -> ()
  ^bb7(%88: i64):  // 2 preds: ^bb6, ^bb14
    %89 = "llvm.icmp"(%88, %48) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%89)[^bb8, ^bb15] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb8:  // pred: ^bb7
    "llvm.br"(%49)[^bb9] : (i64) -> ()
  ^bb9(%90: i64):  // 2 preds: ^bb8, ^bb13
    %91 = "llvm.icmp"(%90, %46) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%91)[^bb10, ^bb14] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb10:  // pred: ^bb9
    "llvm.br"(%49)[^bb11] : (i64) -> ()
  ^bb11(%92: i64):  // 2 preds: ^bb10, ^bb12
    %93 = "llvm.icmp"(%92, %45) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%93)[^bb12, ^bb13] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb12:  // pred: ^bb11
    %94 = "llvm.extractvalue"(%44) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> !llvm.ptr
    %95 = "llvm.mlir.constant"() <{value = 3 : index}> : () -> i64
    %96 = "llvm.mul"(%88, %95) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %97 = "llvm.add"(%96, %92) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %98 = "llvm.getelementptr"(%94, %97) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %99 = "llvm.load"(%98) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %100 = "llvm.extractvalue"(%36) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> !llvm.ptr
    %101 = "llvm.mlir.constant"() <{value = 4 : index}> : () -> i64
    %102 = "llvm.mul"(%92, %101) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %103 = "llvm.add"(%102, %90) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %104 = "llvm.getelementptr"(%100, %103) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %105 = "llvm.load"(%104) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %106 = "llvm.extractvalue"(%76) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> !llvm.ptr
    %107 = "llvm.mlir.constant"() <{value = 4 : index}> : () -> i64
    %108 = "llvm.mul"(%88, %107) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %109 = "llvm.add"(%108, %90) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %110 = "llvm.getelementptr"(%106, %109) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %111 = "llvm.load"(%110) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %112 = "llvm.fmul"(%99, %105) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %113 = "llvm.fadd"(%111, %112) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %114 = "llvm.extractvalue"(%76) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> !llvm.ptr
    %115 = "llvm.mlir.constant"() <{value = 4 : index}> : () -> i64
    %116 = "llvm.mul"(%88, %115) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %117 = "llvm.add"(%116, %90) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %118 = "llvm.getelementptr"(%114, %117) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%113, %118) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %119 = "llvm.add"(%92, %47) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%119)[^bb11] : (i64) -> ()
  ^bb13:  // pred: ^bb11
    %120 = "llvm.add"(%90, %47) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%120)[^bb9] : (i64) -> ()
  ^bb14:  // pred: ^bb9
    %121 = "llvm.add"(%88, %47) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%121)[^bb7] : (i64) -> ()
  ^bb15:  // pred: ^bb7
    "llvm.br"(%49)[^bb16] : (i64) -> ()
  ^bb16(%122: i64):  // 2 preds: ^bb15, ^bb20
    %123 = "llvm.icmp"(%122, %48) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%123)[^bb17, ^bb21] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb17:  // pred: ^bb16
    "llvm.br"(%49)[^bb18] : (i64) -> ()
  ^bb18(%124: i64):  // 2 preds: ^bb17, ^bb19
    %125 = "llvm.icmp"(%124, %46) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%125)[^bb19, ^bb20] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb19:  // pred: ^bb18
    %126 = "llvm.extractvalue"(%76) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> !llvm.ptr
    %127 = "llvm.mlir.constant"() <{value = 4 : index}> : () -> i64
    %128 = "llvm.mul"(%122, %127) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %129 = "llvm.add"(%128, %124) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %130 = "llvm.getelementptr"(%126, %129) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %131 = "llvm.load"(%130) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %132 = "llvm.extractvalue"(%28) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> !llvm.ptr
    %133 = "llvm.getelementptr"(%132, %124) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %134 = "llvm.load"(%133) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %135 = "llvm.fadd"(%131, %134) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %136 = "llvm.extractvalue"(%76) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> !llvm.ptr
    %137 = "llvm.mlir.constant"() <{value = 4 : index}> : () -> i64
    %138 = "llvm.mul"(%122, %137) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %139 = "llvm.add"(%138, %124) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %140 = "llvm.getelementptr"(%136, %139) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%135, %140) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %141 = "llvm.add"(%124, %47) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%141)[^bb18] : (i64) -> ()
  ^bb20:  // pred: ^bb18
    %142 = "llvm.add"(%122, %47) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%142)[^bb16] : (i64) -> ()
  ^bb21:  // pred: ^bb16
    "llvm.return"(%76) : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> ()
  }) {llvm.emit_c_interface} : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (ptr, ptr, ptr, ptr)>, linkage = #llvm.linkage<external>, sym_name = "_mlir_ciface_matmul_bias", unnamed_addr = 0 : i64, visibility_ = 0 : i64}> ({
  ^bb0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr):
    %0 = "llvm.load"(%arg1) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = "llvm.extractvalue"(%0) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> !llvm.ptr
    %2 = "llvm.extractvalue"(%0) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> !llvm.ptr
    %3 = "llvm.extractvalue"(%0) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %4 = "llvm.extractvalue"(%0) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %5 = "llvm.extractvalue"(%0) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %6 = "llvm.extractvalue"(%0) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %7 = "llvm.extractvalue"(%0) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %8 = "llvm.load"(%arg2) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = "llvm.extractvalue"(%8) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> !llvm.ptr
    %10 = "llvm.extractvalue"(%8) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> !llvm.ptr
    %11 = "llvm.extractvalue"(%8) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %12 = "llvm.extractvalue"(%8) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %13 = "llvm.extractvalue"(%8) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %14 = "llvm.extractvalue"(%8) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %15 = "llvm.extractvalue"(%8) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %16 = "llvm.load"(%arg3) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %17 = "llvm.extractvalue"(%16) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> !llvm.ptr
    %18 = "llvm.extractvalue"(%16) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> !llvm.ptr
    %19 = "llvm.extractvalue"(%16) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> i64
    %20 = "llvm.extractvalue"(%16) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> i64
    %21 = "llvm.extractvalue"(%16) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> i64
    %22 = "llvm.call"(%1, %2, %3, %4, %5, %6, %7, %9, %10, %11, %12, %13, %14, %15, %17, %18, %19, %20, %21) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @matmul_bias, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 19, 0>}> : (!llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    "llvm.store"(%22, %arg0) <{ordering = 0 : i64}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr) -> ()
    "llvm.return"() : () -> ()
  }) {llvm.emit_c_interface} : () -> ()
}) : () -> ()
