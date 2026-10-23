module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} {
  llvm.func @arcRuntimeIR_allocInstance(!llvm.ptr, !llvm.ptr) -> (!llvm.ptr {llvm.align = 16 : i64, llvm.noalias, llvm.nonnull, llvm.noundef})
  llvm.func @arcRuntimeIR_deleteInstance(!llvm.ptr)
  llvm.func @arcRuntimeIR_onEval(!llvm.ptr {llvm.noalias, llvm.nocapture, llvm.nofree})
  llvm.func @arcRuntimeIR_onInitialized(!llvm.ptr {llvm.noalias, llvm.nocapture, llvm.nofree})
  llvm.mlir.global internal constant @_arc_mod_name_GCD("GCD\00") {addr_space = 0 : i32}
  llvm.mlir.global external @arcRuntimeModel_GCD() {addr_space = 0 : i32} : !llvm.struct<(i64, i64, ptr, ptr)> {
    %0 = llvm.mlir.constant(1 : i64) : i64
    %1 = llvm.mlir.constant(41 : i64) : i64
    %2 = llvm.mlir.addressof @_arc_mod_name_GCD : !llvm.ptr
    %3 = llvm.mlir.zero : !llvm.ptr
    %4 = llvm.mlir.poison : !llvm.struct<(i64, i64, ptr, ptr)>
    %5 = llvm.insertvalue %0, %4[0] : !llvm.struct<(i64, i64, ptr, ptr)> 
    %6 = llvm.insertvalue %1, %5[1] : !llvm.struct<(i64, i64, ptr, ptr)> 
    %7 = llvm.insertvalue %2, %6[2] : !llvm.struct<(i64, i64, ptr, ptr)> 
    %8 = llvm.insertvalue %3, %7[3] : !llvm.struct<(i64, i64, ptr, ptr)> 
    llvm.return %8 : !llvm.struct<(i64, i64, ptr, ptr)>
  }
  llvm.func @exit(i32) attributes {sym_visibility = "private"}
  llvm.func @GCD_main() {
    %0 = llvm.mlir.constant(-1 : i64) : i64
    %1 = llvm.mlir.zero : !llvm.ptr
    %2 = llvm.mlir.addressof @arcRuntimeModel_GCD : !llvm.ptr
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
    llvm.call @GCD_eval(%3) : (!llvm.ptr) -> ()
    %9 = llvm.load %4 : !llvm.ptr -> i64
    llvm.br ^bb1(%9 : i64)
  ^bb3:  // pred: ^bb1
    llvm.call @arcRuntimeIR_deleteInstance(%3) : (!llvm.ptr) -> ()
    llvm.return
  }
  llvm.func @GCD_eval(%arg0: !llvm.ptr) {
    %0 = llvm.mlir.constant(0 : i16) : i16
    %1 = llvm.mlir.constant(-1 : i64) : i64
    %2 = llvm.getelementptr %arg0[16] : (!llvm.ptr) -> !llvm.ptr, i8
    llvm.store %1, %2 : i64, !llvm.ptr
    %3 = llvm.getelementptr %arg0[24] : (!llvm.ptr) -> !llvm.ptr, i8
    %4 = llvm.load %3 : !llvm.ptr -> i1
    %5 = llvm.getelementptr %arg0[36] : (!llvm.ptr) -> !llvm.ptr, i8
    %6 = llvm.load %5 : !llvm.ptr -> i1
    llvm.store %4, %5 : i1, !llvm.ptr
    %7 = llvm.xor %6, %4 : i1
    %8 = llvm.and %7, %4 : i1
    llvm.cond_br %8, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %9 = llvm.getelementptr %arg0[32] : (!llvm.ptr) -> !llvm.ptr, i8
    %10 = llvm.load %9 : !llvm.ptr -> i16
    %11 = llvm.getelementptr %arg0[34] : (!llvm.ptr) -> !llvm.ptr, i8
    %12 = llvm.load %11 : !llvm.ptr -> i16
    %13 = llvm.icmp "ugt" %10, %12 : i16
    %14 = llvm.getelementptr %arg0[30] : (!llvm.ptr) -> !llvm.ptr, i8
    %15 = llvm.load %14 : !llvm.ptr -> i1
    %16 = llvm.getelementptr %arg0[26] : (!llvm.ptr) -> !llvm.ptr, i8
    %17 = llvm.load %16 : !llvm.ptr -> i16
    %18 = llvm.sub %10, %12 : i16
    %19 = llvm.select %13, %18, %10 : i1, i16
    %20 = llvm.select %15, %17, %19 : i1, i16
    llvm.store %20, %9 : i16, !llvm.ptr
    %21 = llvm.load %11 : !llvm.ptr -> i16
    %22 = llvm.load %14 : !llvm.ptr -> i1
    %23 = llvm.getelementptr %arg0[28] : (!llvm.ptr) -> !llvm.ptr, i8
    %24 = llvm.load %23 : !llvm.ptr -> i16
    %25 = llvm.sub %21, %10 : i16
    %26 = llvm.select %13, %21, %25 : i1, i16
    %27 = llvm.select %22, %24, %26 : i1, i16
    llvm.store %27, %11 : i16, !llvm.ptr
    llvm.br ^bb2
  ^bb2:  // 2 preds: ^bb0, ^bb1
    %28 = llvm.getelementptr %arg0[32] : (!llvm.ptr) -> !llvm.ptr, i8
    %29 = llvm.load %28 : !llvm.ptr -> i16
    %30 = llvm.getelementptr %arg0[38] : (!llvm.ptr) -> !llvm.ptr, i8
    llvm.store %29, %30 : i16, !llvm.ptr
    %31 = llvm.getelementptr %arg0[34] : (!llvm.ptr) -> !llvm.ptr, i8
    %32 = llvm.load %31 : !llvm.ptr -> i16
    %33 = llvm.icmp "eq" %32, %0 : i16
    %34 = llvm.getelementptr %arg0[40] : (!llvm.ptr) -> !llvm.ptr, i8
    llvm.store %33, %34 : i1, !llvm.ptr
    llvm.return
  }
}
