module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} {
  func.func private @exit(i32)
  arc.model @GCD io !hw.modty<input clock : !seq.clock, input reset : i1, input io_value1 : i16, input io_value2 : i16, input io_loadingValues : i1, output io_outputGCD : i16, output io_outputValid : i1> {
  ^bb0(%arg0: !arc.storage):
    %c0_i16 = hw.constant 0 : i16
    %c-1_i64 = hw.constant -1 : i64
    %0 = arc.as_context %arg0 : !arc.storage
    arc.set_next_wakeup %0, %c-1_i64
    %in_clock = arc.root_input "clock", %arg0 : (!arc.storage) -> !arc.state<!seq.clock>
    %in_reset = arc.root_input "reset", %arg0 : (!arc.storage) -> !arc.state<i1>
    %in_io_value1 = arc.root_input "io_value1", %arg0 : (!arc.storage) -> !arc.state<i16>
    %in_io_value2 = arc.root_input "io_value2", %arg0 : (!arc.storage) -> !arc.state<i16>
    %in_io_loadingValues = arc.root_input "io_loadingValues", %arg0 : (!arc.storage) -> !arc.state<i1>
    %1 = arc.alloc_state %arg0 : (!arc.storage) -> !arc.state<i16>
    %2 = arc.alloc_state %arg0 : (!arc.storage) -> !arc.state<i16>
    %3 = arc.alloc_state %arg0 : (!arc.storage) -> !arc.state<i1>
    %out_io_outputGCD = arc.root_output "io_outputGCD", %arg0 : (!arc.storage) -> !arc.state<i16>
    %out_io_outputValid = arc.root_output "io_outputValid", %arg0 : (!arc.storage) -> !arc.state<i1>
    %4 = arc.state_read %in_clock : <!seq.clock>
    %5 = seq.from_clock %4
    %6 = arc.state_read %3 : <i1>
    arc.state_write %3 = %5 : <i1>
    %7 = comb.xor %6, %5 : i1
    %8 = comb.and %7, %5 : i1
    scf.if %8 {
      %12 = arc.state_read %1 : <i16>
      %13 = arc.state_read %2 : <i16>
      %14 = comb.icmp bin ugt %12, %13 : i16
      %15 = arc.state_read %in_io_loadingValues : <i1>
      %16 = arc.state_read %in_io_value1 : <i16>
      %17 = comb.sub bin %12, %13 : i16
      %18 = comb.mux bin %14, %17, %12 : i16
      %19 = comb.mux bin %15, %16, %18 : i16
      arc.state_write %1 = %19 : <i16>
      %20 = arc.state_read %2 : <i16>
      %21 = arc.state_read %in_io_loadingValues : <i1>
      %22 = arc.state_read %in_io_value2 : <i16>
      %23 = comb.sub bin %20, %12 : i16
      %24 = comb.mux bin %14, %20, %23 : i16
      %25 = comb.mux bin %21, %22, %24 : i16
      arc.state_write %2 = %25 : <i16>
    }
    %9 = arc.state_read %1 : <i16>
    arc.state_write %out_io_outputGCD = %9 : <i16>
    %10 = arc.state_read %2 : <i16>
    %11 = comb.icmp bin eq %10, %c0_i16 : i16
    arc.state_write %out_io_outputValid = %11 : <i1>
  }
}
