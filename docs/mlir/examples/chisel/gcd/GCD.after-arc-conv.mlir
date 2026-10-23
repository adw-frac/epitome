module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} {
  func.func private @exit(i32)
  arc.define @GCD_arc(%arg0: i16, %arg1: i16, %arg2: i1, %arg3: i1, %arg4: i16) -> i16 {
    %0 = comb.sub bin %arg0, %arg1 : i16
    %1 = comb.mux bin %arg2, %0, %arg0 : i16
    %2 = comb.mux bin %arg3, %arg4, %1 : i16
    arc.output %2 : i16
  }
  arc.define @GCD_arc_0(%arg0: i16, %arg1: i16, %arg2: i1, %arg3: i1, %arg4: i16) -> i16 {
    %0 = comb.sub bin %arg0, %arg1 : i16
    %1 = comb.mux bin %arg2, %arg0, %0 : i16
    %2 = comb.mux bin %arg3, %arg4, %1 : i16
    arc.output %2 : i16
  }
  arc.define @GCD_arc_1(%arg0: i16, %arg1: i16) -> i1 {
    %0 = comb.icmp bin ugt %arg0, %arg1 : i16
    arc.output %0 : i1
  }
  arc.define @GCD_arc_2(%arg0: i16) -> i1 {
    %c0_i16 = hw.constant 0 : i16
    %0 = comb.icmp bin eq %arg0, %c0_i16 : i16
    arc.output %0 : i1
  }
  hw.module @GCD(in %clock : !seq.clock, in %reset : i1, in %io_value1 : i16, in %io_value2 : i16, in %io_loadingValues : i1, out io_outputGCD : i16, out io_outputValid : i1) {
    %0 = arc.state @GCD_arc(%0, %1, %2, %io_loadingValues, %io_value1) clock %clock latency 1 : (i16, i16, i1, i1, i16) -> i16
    %1 = arc.state @GCD_arc_0(%1, %0, %2, %io_loadingValues, %io_value2) clock %clock latency 1 : (i16, i16, i1, i1, i16) -> i16
    %2 = arc.call @GCD_arc_1(%0, %1) : (i16, i16) -> i1
    %3 = arc.call @GCD_arc_2(%1) : (i16) -> i1
    hw.output %0, %3 : i16, i1
  }
}
