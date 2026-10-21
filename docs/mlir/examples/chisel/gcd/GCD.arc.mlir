module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} {
  func.func private @exit(i32)
  arc.model @GCD io !hw.modty<input clock : !seq.clock, input reset : i1, input io_value1 : i16, input io_value2 : i16, input io_loadingValues : i1, output io_outputGCD : i16, output io_outputValid : i1> storageBytes 41 {
  ^bb0(%arg0: !arc.storage):
    %c0_i16 = hw.constant 0 : i16
    %c-1_i64 = hw.constant -1 : i64
    %0 = arc.as_context %arg0 : !arc.storage
    arc.set_next_wakeup %0, %c-1_i64
    %in_clock = arc.root_input "clock", %arg0 {offset = 24 : i32} : (!arc.storage) -> !arc.state<!seq.clock>
    %in_reset = arc.root_input "reset", %arg0 {offset = 25 : i32} : (!arc.storage) -> !arc.state<i1>
    %in_io_value1 = arc.root_input "io_value1", %arg0 {offset = 26 : i32} : (!arc.storage) -> !arc.state<i16>
    %in_io_value2 = arc.root_input "io_value2", %arg0 {offset = 28 : i32} : (!arc.storage) -> !arc.state<i16>
    %in_io_loadingValues = arc.root_input "io_loadingValues", %arg0 {offset = 30 : i32} : (!arc.storage) -> !arc.state<i1>
    %1 = arc.alloc_state %arg0 {offset = 32 : i32} : (!arc.storage) -> !arc.state<i16>
    %2 = arc.alloc_state %arg0 {offset = 34 : i32} : (!arc.storage) -> !arc.state<i16>
    %3 = arc.alloc_state %arg0 {offset = 36 : i32} : (!arc.storage) -> !arc.state<i1>
    %out_io_outputGCD = arc.root_output "io_outputGCD", %arg0 {offset = 38 : i32} : (!arc.storage) -> !arc.state<i16>
    %out_io_outputValid = arc.root_output "io_outputValid", %arg0 {offset = 40 : i32} : (!arc.storage) -> !arc.state<i1>
    %4 = arc.storage.get %arg0[24] : !arc.storage -> !arc.state<!seq.clock>
    %5 = arc.state_read %4 : <!seq.clock>
    %6 = seq.from_clock %5
    %7 = arc.storage.get %arg0[36] : !arc.storage -> !arc.state<i1>
    %8 = arc.state_read %7 : <i1>
    arc.state_write %7 = %6 : <i1>
    %9 = comb.xor %8, %6 : i1
    %10 = comb.and %9, %6 : i1
    scf.if %10 {
      %18 = arc.storage.get %arg0[32] : !arc.storage -> !arc.state<i16>
      %19 = arc.state_read %18 : <i16>
      %20 = arc.storage.get %arg0[34] : !arc.storage -> !arc.state<i16>
      %21 = arc.state_read %20 : <i16>
      %22 = comb.icmp bin ugt %19, %21 : i16
      %23 = arc.storage.get %arg0[30] : !arc.storage -> !arc.state<i1>
      %24 = arc.state_read %23 : <i1>
      %25 = arc.storage.get %arg0[26] : !arc.storage -> !arc.state<i16>
      %26 = arc.state_read %25 : <i16>
      %27 = comb.sub bin %19, %21 : i16
      %28 = comb.mux bin %22, %27, %19 : i16
      %29 = comb.mux bin %24, %26, %28 : i16
      arc.state_write %18 = %29 : <i16>
      %30 = arc.state_read %20 : <i16>
      %31 = arc.state_read %23 : <i1>
      %32 = arc.storage.get %arg0[28] : !arc.storage -> !arc.state<i16>
      %33 = arc.state_read %32 : <i16>
      %34 = comb.sub bin %30, %19 : i16
      %35 = comb.mux bin %22, %30, %34 : i16
      %36 = comb.mux bin %31, %33, %35 : i16
      arc.state_write %20 = %36 : <i16>
    }
    %11 = arc.storage.get %arg0[32] : !arc.storage -> !arc.state<i16>
    %12 = arc.state_read %11 : <i16>
    %13 = arc.storage.get %arg0[38] : !arc.storage -> !arc.state<i16>
    arc.state_write %13 = %12 : <i16>
    %14 = arc.storage.get %arg0[34] : !arc.storage -> !arc.state<i16>
    %15 = arc.state_read %14 : <i16>
    %16 = comb.icmp bin eq %15, %c0_i16 : i16
    %17 = arc.storage.get %arg0[40] : !arc.storage -> !arc.state<i1>
    arc.state_write %17 = %16 : <i1>
  }
}
