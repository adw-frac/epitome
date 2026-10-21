module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} {
  func.func private @exit(i32)
  arc.define @Fir_arc(%arg0: i8) -> i8 {
    arc.output %arg0 : i8
  }
  arc.define @Fir_arc_2(%arg0: i8, %arg1: i8, %arg2: i8, %arg3: i8) -> i16 {
    %c0_i5 = hw.constant 0 : i5
    %c0_i2 = hw.constant 0 : i2
    %c3_i10 = hw.constant 3 : i10
    %false = hw.constant false
    %c0_i3 = hw.constant 0 : i3
    %0 = comb.concat %c0_i5, %arg0 : i5, i8
    %1 = comb.concat %c0_i2, %arg1 : i2, i8
    %2 = comb.mul bin %1, %c3_i10 : i10
    %3 = comb.concat %c0_i2, %2 : i2, i10
    %4 = comb.concat %c0_i2, %arg2 : i2, i8
    %5 = comb.mul bin %4, %c3_i10 : i10
    %6 = comb.concat %false, %5 : i1, i10
    %7 = comb.concat %c0_i3, %arg3 : i3, i8
    %8 = comb.add bin %7, %6 : i11
    %9 = comb.concat %false, %8 : i1, i11
    %10 = comb.add bin %9, %3 : i12
    %11 = comb.concat %false, %10 : i1, i12
    %12 = comb.add bin %11, %0 : i13
    %13 = comb.concat %c0_i3, %12 : i3, i13
    arc.output %13 : i16
  }
  hw.module @Fir(in %clock : !seq.clock, in %reset : i1, in %io_in : i8, in %io_valid : i1, out io_out : i16) {
    %0 = arc.state @Fir_arc(%io_in) clock %clock enable %io_valid reset %reset latency 1 : (i8) -> i8
    %1 = arc.state @Fir_arc(%0) clock %clock enable %io_valid reset %reset latency 1 : (i8) -> i8
    %2 = arc.state @Fir_arc(%1) clock %clock enable %io_valid reset %reset latency 1 : (i8) -> i8
    %3 = arc.call @Fir_arc_2(%2, %1, %0, %io_in) : (i8, i8, i8, i8) -> i16
    hw.output %3 : i16
  }
}
