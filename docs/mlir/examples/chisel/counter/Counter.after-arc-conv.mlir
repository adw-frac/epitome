module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} {
  func.func private @exit(i32)
  arc.define @Counter_arc(%arg0: i8, %arg1: i1) -> i8 {
    %c1_i8 = hw.constant 1 : i8
    %0 = comb.add bin %arg0, %c1_i8 : i8
    %1 = comb.mux bin %arg1, %0, %arg0 : i8
    arc.output %1 : i8
  }
  hw.module @Counter(in %clock : !seq.clock, in %reset : i1, in %io_en : i1, out io_count : i8) {
    %0 = arc.state @Counter_arc(%0, %io_en) clock %clock reset %reset latency 1 : (i8, i1) -> i8
    hw.output %0 : i8
  }
}
