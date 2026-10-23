#loc = loc("./chisel/fir/Fir.after-arc-opt.mlir":28:97)
"builtin.module"() ({
  "func.func"() <{function_type = (i32) -> (), sym_name = "exit", sym_visibility = "private"}> ({
  }) : () -> ()
  "arc.define"() <{function_type = (i8) -> i8, sym_name = "Fir_arc"}> ({
  ^bb0(%arg8: i8):
    "arc.output"(%arg8) : (i8) -> ()
  }) : () -> ()
  "arc.define"() <{function_type = (i8, i8, i8, i8) -> i16, sym_name = "Fir_arc_2"}> ({
  ^bb0(%arg4: i8, %arg5: i8, %arg6: i8, %arg7: i8):
    %4 = "hw.constant"() <{value = 0 : i5}> : () -> i5
    %5 = "hw.constant"() <{value = 0 : i2}> : () -> i2
    %6 = "hw.constant"() <{value = 3 : i10}> : () -> i10
    %7 = "hw.constant"() <{value = false}> : () -> i1
    %8 = "hw.constant"() <{value = 0 : i3}> : () -> i3
    %9 = "comb.concat"(%4, %arg4) : (i5, i8) -> i13
    %10 = "comb.concat"(%5, %arg5) : (i2, i8) -> i10
    %11 = "comb.mul"(%10, %6) <{twoState}> : (i10, i10) -> i10
    %12 = "comb.concat"(%5, %11) : (i2, i10) -> i12
    %13 = "comb.concat"(%5, %arg6) : (i2, i8) -> i10
    %14 = "comb.mul"(%13, %6) <{twoState}> : (i10, i10) -> i10
    %15 = "comb.concat"(%7, %14) : (i1, i10) -> i11
    %16 = "comb.concat"(%8, %arg7) : (i3, i8) -> i11
    %17 = "comb.add"(%16, %15) <{twoState}> : (i11, i11) -> i11
    %18 = "comb.concat"(%7, %17) : (i1, i11) -> i12
    %19 = "comb.add"(%18, %12) <{twoState}> : (i12, i12) -> i12
    %20 = "comb.concat"(%7, %19) : (i1, i12) -> i13
    %21 = "comb.add"(%20, %9) <{twoState}> : (i13, i13) -> i13
    %22 = "comb.concat"(%8, %21) : (i3, i13) -> i16
    "arc.output"(%22) : (i16) -> ()
  }) : () -> ()
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_in : i8, input io_valid : i1, output io_out : i16>, parameters = [], result_locs = [#loc], sym_name = "Fir"}> ({
  ^bb0(%arg0: !seq.clock, %arg1: i1, %arg2: i8, %arg3: i1):
    %0 = "arc.state"(%arg0, %arg3, %arg1, %arg2) <{arc = @Fir_arc, latency = 1 : i32, operandSegmentSizes = array<i32: 1, 1, 1, 1, 0>}> : (!seq.clock, i1, i1, i8) -> i8
    %1 = "arc.state"(%arg0, %arg3, %arg1, %0) <{arc = @Fir_arc, latency = 1 : i32, operandSegmentSizes = array<i32: 1, 1, 1, 1, 0>}> : (!seq.clock, i1, i1, i8) -> i8
    %2 = "arc.state"(%arg0, %arg3, %arg1, %1) <{arc = @Fir_arc, latency = 1 : i32, operandSegmentSizes = array<i32: 1, 1, 1, 1, 0>}> : (!seq.clock, i1, i1, i8) -> i8
    %3 = "arc.call"(%2, %1, %0, %arg2) <{arc = @Fir_arc_2}> : (i8, i8, i8, i8) -> i16
    "hw.output"(%3) : (i16) -> ()
  }) : () -> ()
}) {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} : () -> ()

