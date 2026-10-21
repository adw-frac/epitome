#loc = loc("./chisel/gcd/GCD.after-arc-conv.mlir":24:131)
#loc1 = loc("./chisel/gcd/GCD.after-arc-conv.mlir":24:155)
"builtin.module"() ({
  "func.func"() <{function_type = (i32) -> (), sym_name = "exit", sym_visibility = "private"}> ({
  }) : () -> ()
  "arc.define"() <{function_type = (i16, i16, i1, i1, i16) -> i16, sym_name = "GCD_arc"}> ({
  ^bb0(%arg13: i16, %arg14: i16, %arg15: i1, %arg16: i1, %arg17: i16):
    %10 = "comb.sub"(%arg13, %arg14) <{twoState}> : (i16, i16) -> i16
    %11 = "comb.mux"(%arg15, %10, %arg13) <{twoState}> : (i1, i16, i16) -> i16
    %12 = "comb.mux"(%arg16, %arg17, %11) <{twoState}> : (i1, i16, i16) -> i16
    "arc.output"(%12) : (i16) -> ()
  }) : () -> ()
  "arc.define"() <{function_type = (i16, i16, i1, i1, i16) -> i16, sym_name = "GCD_arc_0"}> ({
  ^bb0(%arg8: i16, %arg9: i16, %arg10: i1, %arg11: i1, %arg12: i16):
    %7 = "comb.sub"(%arg8, %arg9) <{twoState}> : (i16, i16) -> i16
    %8 = "comb.mux"(%arg10, %arg8, %7) <{twoState}> : (i1, i16, i16) -> i16
    %9 = "comb.mux"(%arg11, %arg12, %8) <{twoState}> : (i1, i16, i16) -> i16
    "arc.output"(%9) : (i16) -> ()
  }) : () -> ()
  "arc.define"() <{function_type = (i16, i16) -> i1, sym_name = "GCD_arc_1"}> ({
  ^bb0(%arg6: i16, %arg7: i16):
    %6 = "comb.icmp"(%arg6, %arg7) <{predicate = 8 : i64, twoState}> : (i16, i16) -> i1
    "arc.output"(%6) : (i1) -> ()
  }) : () -> ()
  "arc.define"() <{function_type = (i16) -> i1, sym_name = "GCD_arc_2"}> ({
  ^bb0(%arg5: i16):
    %4 = "hw.constant"() <{value = 0 : i16}> : () -> i16
    %5 = "comb.icmp"(%arg5, %4) <{predicate = 0 : i64, twoState}> : (i16, i16) -> i1
    "arc.output"(%5) : (i1) -> ()
  }) : () -> ()
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_value1 : i16, input io_value2 : i16, input io_loadingValues : i1, output io_outputGCD : i16, output io_outputValid : i1>, parameters = [], result_locs = [#loc, #loc1], sym_name = "GCD"}> ({
  ^bb0(%arg0: !seq.clock, %arg1: i1, %arg2: i16, %arg3: i16, %arg4: i1):
    %0 = "arc.state"(%arg0, %0, %1, %2, %arg4, %arg2) <{arc = @GCD_arc, latency = 1 : i32, operandSegmentSizes = array<i32: 1, 0, 0, 5, 0>}> : (!seq.clock, i16, i16, i1, i1, i16) -> i16
    %1 = "arc.state"(%arg0, %1, %0, %2, %arg4, %arg3) <{arc = @GCD_arc_0, latency = 1 : i32, operandSegmentSizes = array<i32: 1, 0, 0, 5, 0>}> : (!seq.clock, i16, i16, i1, i1, i16) -> i16
    %2 = "arc.call"(%0, %1) <{arc = @GCD_arc_1}> : (i16, i16) -> i1
    %3 = "arc.call"(%1) <{arc = @GCD_arc_2}> : (i16) -> i1
    "hw.output"(%0, %3) : (i16, i1) -> ()
  }) : () -> ()
}) {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} : () -> ()

