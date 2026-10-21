module {
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.func @matmul_bias(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> attributes {llvm.emit_c_interface} {
    %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %1 = llvm.insertvalue %arg14, %0[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %2 = llvm.insertvalue %arg15, %1[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %3 = llvm.insertvalue %arg16, %2[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %4 = llvm.insertvalue %arg17, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %5 = llvm.insertvalue %arg18, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %6 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %7 = llvm.insertvalue %arg7, %6[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.insertvalue %arg8, %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %9 = llvm.insertvalue %arg9, %8[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %arg10, %9[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %arg12, %10[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %arg11, %11[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.insertvalue %arg13, %12[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %15 = llvm.insertvalue %arg0, %14[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.insertvalue %arg1, %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %17 = llvm.insertvalue %arg2, %16[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %18 = llvm.insertvalue %arg3, %17[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.insertvalue %arg5, %18[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.insertvalue %arg4, %19[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.insertvalue %arg6, %20[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.mlir.constant(3 : index) : i64
    %23 = llvm.mlir.constant(4 : index) : i64
    %24 = llvm.mlir.constant(1 : index) : i64
    %25 = llvm.mlir.constant(2 : index) : i64
    %26 = llvm.mlir.constant(0 : index) : i64
    %27 = llvm.mlir.constant(0.000000e+00 : f32) : f32
    %28 = llvm.mlir.constant(2 : index) : i64
    %29 = llvm.mlir.constant(4 : index) : i64
    %30 = llvm.mlir.constant(1 : index) : i64
    %31 = llvm.mlir.constant(8 : index) : i64
    %32 = llvm.mlir.zero : !llvm.ptr
    %33 = llvm.getelementptr %32[%31] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %34 = llvm.ptrtoint %33 : !llvm.ptr to i64
    %35 = llvm.mlir.constant(64 : index) : i64
    %36 = llvm.add %34, %35 : i64
    %37 = llvm.call @malloc(%36) : (i64) -> !llvm.ptr
    %38 = llvm.ptrtoint %37 : !llvm.ptr to i64
    %39 = llvm.mlir.constant(1 : index) : i64
    %40 = llvm.sub %35, %39 : i64
    %41 = llvm.add %38, %40 : i64
    %42 = llvm.urem %41, %35 : i64
    %43 = llvm.sub %41, %42 : i64
    %44 = llvm.inttoptr %43 : i64 to !llvm.ptr
    %45 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %46 = llvm.insertvalue %37, %45[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %47 = llvm.insertvalue %44, %46[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %48 = llvm.mlir.constant(0 : index) : i64
    %49 = llvm.insertvalue %48, %47[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %50 = llvm.insertvalue %28, %49[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %51 = llvm.insertvalue %29, %50[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %52 = llvm.insertvalue %29, %51[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %53 = llvm.insertvalue %30, %52[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb1(%26 : i64)
  ^bb1(%54: i64):  // 2 preds: ^bb0, ^bb5
    %55 = llvm.icmp "slt" %54, %25 : i64
    llvm.cond_br %55, ^bb2, ^bb6
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%26 : i64)
  ^bb3(%56: i64):  // 2 preds: ^bb2, ^bb4
    %57 = llvm.icmp "slt" %56, %23 : i64
    llvm.cond_br %57, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %58 = llvm.extractvalue %53[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %59 = llvm.mlir.constant(4 : index) : i64
    %60 = llvm.mul %54, %59 overflow<nsw, nuw> : i64
    %61 = llvm.add %60, %56 overflow<nsw, nuw> : i64
    %62 = llvm.getelementptr inbounds|nuw %58[%61] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %27, %62 : f32, !llvm.ptr
    %63 = llvm.add %56, %24 : i64
    llvm.br ^bb3(%63 : i64)
  ^bb5:  // pred: ^bb3
    %64 = llvm.add %54, %24 : i64
    llvm.br ^bb1(%64 : i64)
  ^bb6:  // pred: ^bb1
    llvm.br ^bb7(%26 : i64)
  ^bb7(%65: i64):  // 2 preds: ^bb6, ^bb14
    %66 = llvm.icmp "slt" %65, %25 : i64
    llvm.cond_br %66, ^bb8, ^bb15
  ^bb8:  // pred: ^bb7
    llvm.br ^bb9(%26 : i64)
  ^bb9(%67: i64):  // 2 preds: ^bb8, ^bb13
    %68 = llvm.icmp "slt" %67, %23 : i64
    llvm.cond_br %68, ^bb10, ^bb14
  ^bb10:  // pred: ^bb9
    llvm.br ^bb11(%26 : i64)
  ^bb11(%69: i64):  // 2 preds: ^bb10, ^bb12
    %70 = llvm.icmp "slt" %69, %22 : i64
    llvm.cond_br %70, ^bb12, ^bb13
  ^bb12:  // pred: ^bb11
    %71 = llvm.extractvalue %21[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %72 = llvm.mlir.constant(3 : index) : i64
    %73 = llvm.mul %65, %72 overflow<nsw, nuw> : i64
    %74 = llvm.add %73, %69 overflow<nsw, nuw> : i64
    %75 = llvm.getelementptr inbounds|nuw %71[%74] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %76 = llvm.load %75 : !llvm.ptr -> f32
    %77 = llvm.extractvalue %13[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %78 = llvm.mlir.constant(4 : index) : i64
    %79 = llvm.mul %69, %78 overflow<nsw, nuw> : i64
    %80 = llvm.add %79, %67 overflow<nsw, nuw> : i64
    %81 = llvm.getelementptr inbounds|nuw %77[%80] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %82 = llvm.load %81 : !llvm.ptr -> f32
    %83 = llvm.extractvalue %53[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %84 = llvm.mlir.constant(4 : index) : i64
    %85 = llvm.mul %65, %84 overflow<nsw, nuw> : i64
    %86 = llvm.add %85, %67 overflow<nsw, nuw> : i64
    %87 = llvm.getelementptr inbounds|nuw %83[%86] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %88 = llvm.load %87 : !llvm.ptr -> f32
    %89 = llvm.fmul %76, %82 : f32
    %90 = llvm.fadd %88, %89 : f32
    %91 = llvm.extractvalue %53[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %92 = llvm.mlir.constant(4 : index) : i64
    %93 = llvm.mul %65, %92 overflow<nsw, nuw> : i64
    %94 = llvm.add %93, %67 overflow<nsw, nuw> : i64
    %95 = llvm.getelementptr inbounds|nuw %91[%94] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %90, %95 : f32, !llvm.ptr
    %96 = llvm.add %69, %24 : i64
    llvm.br ^bb11(%96 : i64)
  ^bb13:  // pred: ^bb11
    %97 = llvm.add %67, %24 : i64
    llvm.br ^bb9(%97 : i64)
  ^bb14:  // pred: ^bb9
    %98 = llvm.add %65, %24 : i64
    llvm.br ^bb7(%98 : i64)
  ^bb15:  // pred: ^bb7
    llvm.br ^bb16(%26 : i64)
  ^bb16(%99: i64):  // 2 preds: ^bb15, ^bb20
    %100 = llvm.icmp "slt" %99, %25 : i64
    llvm.cond_br %100, ^bb17, ^bb21
  ^bb17:  // pred: ^bb16
    llvm.br ^bb18(%26 : i64)
  ^bb18(%101: i64):  // 2 preds: ^bb17, ^bb19
    %102 = llvm.icmp "slt" %101, %23 : i64
    llvm.cond_br %102, ^bb19, ^bb20
  ^bb19:  // pred: ^bb18
    %103 = llvm.extractvalue %53[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %104 = llvm.mlir.constant(4 : index) : i64
    %105 = llvm.mul %99, %104 overflow<nsw, nuw> : i64
    %106 = llvm.add %105, %101 overflow<nsw, nuw> : i64
    %107 = llvm.getelementptr inbounds|nuw %103[%106] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %108 = llvm.load %107 : !llvm.ptr -> f32
    %109 = llvm.extractvalue %5[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %110 = llvm.getelementptr inbounds|nuw %109[%101] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %111 = llvm.load %110 : !llvm.ptr -> f32
    %112 = llvm.fadd %108, %111 : f32
    %113 = llvm.extractvalue %53[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %114 = llvm.mlir.constant(4 : index) : i64
    %115 = llvm.mul %99, %114 overflow<nsw, nuw> : i64
    %116 = llvm.add %115, %101 overflow<nsw, nuw> : i64
    %117 = llvm.getelementptr inbounds|nuw %113[%116] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %112, %117 : f32, !llvm.ptr
    %118 = llvm.add %101, %24 : i64
    llvm.br ^bb18(%118 : i64)
  ^bb20:  // pred: ^bb18
    %119 = llvm.add %99, %24 : i64
    llvm.br ^bb16(%119 : i64)
  ^bb21:  // pred: ^bb16
    llvm.return %53 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
  }
  llvm.func @_mlir_ciface_matmul_bias(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr) attributes {llvm.emit_c_interface} {
    %0 = llvm.load %arg1 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.extractvalue %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.extractvalue %0[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.extractvalue %0[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.extractvalue %0[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.extractvalue %0[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.extractvalue %0[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.extractvalue %0[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.load %arg2 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = llvm.extractvalue %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.extractvalue %8[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.extractvalue %8[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.extractvalue %8[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.extractvalue %8[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.extractvalue %8[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.extractvalue %8[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.load %arg3 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %18 = llvm.extractvalue %16[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %19 = llvm.extractvalue %16[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %20 = llvm.extractvalue %16[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %21 = llvm.extractvalue %16[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %22 = llvm.call @matmul_bias(%1, %2, %3, %4, %5, %6, %7, %9, %10, %11, %12, %13, %14, %15, %17, %18, %19, %20, %21) : (!llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    llvm.store %22, %arg0 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr
    llvm.return
  }
}
