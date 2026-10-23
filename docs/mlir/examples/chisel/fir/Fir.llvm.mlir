module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} {
  llvm.func @arcRuntimeIR_allocInstance(!llvm.ptr, !llvm.ptr) -> (!llvm.ptr {llvm.align = 16 : i64, llvm.noalias, llvm.nonnull, llvm.noundef})
  llvm.func @arcRuntimeIR_deleteInstance(!llvm.ptr)
  llvm.func @arcRuntimeIR_onEval(!llvm.ptr {llvm.noalias, llvm.nocapture, llvm.nofree})
  llvm.func @arcRuntimeIR_onInitialized(!llvm.ptr {llvm.noalias, llvm.nocapture, llvm.nofree})
  llvm.mlir.global internal constant @_arc_mod_name_Fir("Fir\00") {addr_space = 0 : i32}
  llvm.mlir.global external @arcRuntimeModel_Fir() {addr_space = 0 : i32} : !llvm.struct<(i64, i64, ptr, ptr)> {
    %0 = llvm.mlir.constant(1 : i64) : i64
    %1 = llvm.mlir.constant(34 : i64) : i64
    %2 = llvm.mlir.addressof @_arc_mod_name_Fir : !llvm.ptr
    %3 = llvm.mlir.zero : !llvm.ptr
    %4 = llvm.mlir.poison : !llvm.struct<(i64, i64, ptr, ptr)>
    %5 = llvm.insertvalue %0, %4[0] : !llvm.struct<(i64, i64, ptr, ptr)> 
    %6 = llvm.insertvalue %1, %5[1] : !llvm.struct<(i64, i64, ptr, ptr)> 
    %7 = llvm.insertvalue %2, %6[2] : !llvm.struct<(i64, i64, ptr, ptr)> 
    %8 = llvm.insertvalue %3, %7[3] : !llvm.struct<(i64, i64, ptr, ptr)> 
    llvm.return %8 : !llvm.struct<(i64, i64, ptr, ptr)>
  }
  llvm.func @exit(i32) attributes {sym_visibility = "private"}
  llvm.func @Fir_main() {
    %0 = llvm.mlir.constant(-1 : i64) : i64
    %1 = llvm.mlir.zero : !llvm.ptr
    %2 = llvm.mlir.addressof @arcRuntimeModel_Fir : !llvm.ptr
    %3 = llvm.call @arcRuntimeIR_allocInstance(%2, %1) : (!llvm.ptr, !llvm.ptr) -> !llvm.ptr
    llvm.call @arcRuntimeIR_onInitialized(%3) : (!llvm.ptr) -> ()
    %4 = llvm.getelementptr %3[16] : (!llvm.ptr) -> !llvm.ptr, i8
    %5 = llvm.load %4 : !llvm.ptr -> i64
    llvm.br ^bb1(%5 : i64)
  ^bb1(%6: i64):  // 2 preds: ^bb0, ^bb2
    %7 = llvm.icmp "ne" %6, %0 : i64
    llvm.cond_br %7, ^bb2(%6 : i64), ^bb3
  ^bb2(%8: i64):  // pred: ^bb1
    llvm.store %8, %3 : i64, !llvm.ptr
    llvm.call @arcRuntimeIR_onEval(%3) : (!llvm.ptr) -> ()
    llvm.call @Fir_eval(%3) : (!llvm.ptr) -> ()
    %9 = llvm.load %4 : !llvm.ptr -> i64
    llvm.br ^bb1(%9 : i64)
  ^bb3:  // pred: ^bb1
    llvm.call @arcRuntimeIR_deleteInstance(%3) : (!llvm.ptr) -> ()
    llvm.return
  }
  llvm.func @Fir_eval(%arg0: !llvm.ptr) {
    %0 = llvm.mlir.constant(3 : i10) : i10
    %1 = llvm.mlir.constant(0 : i8) : i8
    %2 = llvm.mlir.constant(-1 : i64) : i64
    %3 = llvm.getelementptr %arg0[16] : (!llvm.ptr) -> !llvm.ptr, i8
    llvm.store %2, %3 : i64, !llvm.ptr
    %4 = llvm.getelementptr %arg0[24] : (!llvm.ptr) -> !llvm.ptr, i8
    %5 = llvm.load %4 : !llvm.ptr -> i1
    %6 = llvm.getelementptr %arg0[28] : (!llvm.ptr) -> !llvm.ptr, i8
    %7 = llvm.load %6 : !llvm.ptr -> i1
    llvm.store %5, %6 : i1, !llvm.ptr
    %8 = llvm.xor %7, %5 : i1
    %9 = llvm.and %8, %5 : i1
    llvm.cond_br %9, ^bb1, ^bb7
  ^bb1:  // pred: ^bb0
    %10 = llvm.getelementptr %arg0[25] : (!llvm.ptr) -> !llvm.ptr, i8
    %11 = llvm.load %10 : !llvm.ptr -> i1
    llvm.cond_br %11, ^bb2, ^bb3
  ^bb2:  // pred: ^bb1
    %12 = llvm.getelementptr %arg0[29] : (!llvm.ptr) -> !llvm.ptr, i8
    llvm.store %1, %12 : i8, !llvm.ptr
    %13 = llvm.getelementptr %arg0[30] : (!llvm.ptr) -> !llvm.ptr, i8
    llvm.store %1, %13 : i8, !llvm.ptr
    %14 = llvm.getelementptr %arg0[31] : (!llvm.ptr) -> !llvm.ptr, i8
    llvm.store %1, %14 : i8, !llvm.ptr
    llvm.br ^bb6
  ^bb3:  // pred: ^bb1
    %15 = llvm.getelementptr %arg0[27] : (!llvm.ptr) -> !llvm.ptr, i8
    %16 = llvm.load %15 : !llvm.ptr -> i1
    llvm.cond_br %16, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %17 = llvm.getelementptr %arg0[29] : (!llvm.ptr) -> !llvm.ptr, i8
    %18 = llvm.load %17 : !llvm.ptr -> i8
    %19 = llvm.getelementptr %arg0[26] : (!llvm.ptr) -> !llvm.ptr, i8
    %20 = llvm.load %19 : !llvm.ptr -> i8
    llvm.store %20, %17 : i8, !llvm.ptr
    %21 = llvm.getelementptr %arg0[30] : (!llvm.ptr) -> !llvm.ptr, i8
    %22 = llvm.load %21 : !llvm.ptr -> i8
    llvm.store %18, %21 : i8, !llvm.ptr
    %23 = llvm.getelementptr %arg0[31] : (!llvm.ptr) -> !llvm.ptr, i8
    llvm.store %22, %23 : i8, !llvm.ptr
    llvm.br ^bb5
  ^bb5:  // 2 preds: ^bb3, ^bb4
    llvm.br ^bb6
  ^bb6:  // 2 preds: ^bb2, ^bb5
    llvm.br ^bb7
  ^bb7:  // 2 preds: ^bb0, ^bb6
    %24 = llvm.getelementptr %arg0[31] : (!llvm.ptr) -> !llvm.ptr, i8
    %25 = llvm.load %24 : !llvm.ptr -> i8
    %26 = llvm.getelementptr %arg0[30] : (!llvm.ptr) -> !llvm.ptr, i8
    %27 = llvm.load %26 : !llvm.ptr -> i8
    %28 = llvm.getelementptr %arg0[29] : (!llvm.ptr) -> !llvm.ptr, i8
    %29 = llvm.load %28 : !llvm.ptr -> i8
    %30 = llvm.getelementptr %arg0[26] : (!llvm.ptr) -> !llvm.ptr, i8
    %31 = llvm.load %30 : !llvm.ptr -> i8
    %32 = llvm.zext %25 : i8 to i13
    %33 = llvm.zext %27 : i8 to i10
    %34 = llvm.mul %33, %0 : i10
    %35 = llvm.zext %34 : i10 to i12
    %36 = llvm.zext %29 : i8 to i10
    %37 = llvm.mul %36, %0 : i10
    %38 = llvm.zext %37 : i10 to i11
    %39 = llvm.zext %31 : i8 to i11
    %40 = llvm.add %39, %38 : i11
    %41 = llvm.zext %40 : i11 to i12
    %42 = llvm.add %41, %35 : i12
    %43 = llvm.zext %42 : i12 to i13
    %44 = llvm.add %43, %32 : i13
    %45 = llvm.zext %44 : i13 to i16
    %46 = llvm.getelementptr %arg0[32] : (!llvm.ptr) -> !llvm.ptr, i8
    llvm.store %45, %46 : i16, !llvm.ptr
    llvm.return
  }
}
