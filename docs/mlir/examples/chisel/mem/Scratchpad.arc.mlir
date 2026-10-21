module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} {
  func.func private @exit(i32)
  arc.model @Scratchpad io !hw.modty<input clock : !seq.clock, input reset : i1, input io_raddr : i4, output io_rdata : i32, input io_wen : i1, input io_waddr : i4, input io_wdata : i32> storageBytes 120 {
  ^bb0(%arg0: !arc.storage):
    %c0_i32 = hw.constant 0 : i32
    %true = hw.constant true
    %c-1_i64 = hw.constant -1 : i64
    %0 = arc.as_context %arg0 : !arc.storage
    arc.set_next_wakeup %0, %c-1_i64
    %in_clock = arc.root_input "clock", %arg0 {offset = 24 : i32} : (!arc.storage) -> !arc.state<!seq.clock>
    %in_reset = arc.root_input "reset", %arg0 {offset = 25 : i32} : (!arc.storage) -> !arc.state<i1>
    %in_io_raddr = arc.root_input "io_raddr", %arg0 {offset = 26 : i32} : (!arc.storage) -> !arc.state<i4>
    %in_io_wen = arc.root_input "io_wen", %arg0 {offset = 27 : i32} : (!arc.storage) -> !arc.state<i1>
    %in_io_waddr = arc.root_input "io_waddr", %arg0 {offset = 28 : i32} : (!arc.storage) -> !arc.state<i4>
    %in_io_wdata = arc.root_input "io_wdata", %arg0 {offset = 32 : i32} : (!arc.storage) -> !arc.state<i32>
    %1 = arc.alloc_memory %arg0 {offset = 48 : i32, stride = 4 : i32} : (!arc.storage) -> !arc.memory<16 x i32, i4>
    %2 = arc.alloc_state %arg0 {offset = 112 : i32} : (!arc.storage) -> !arc.state<i4>
    %3 = arc.alloc_state %arg0 {offset = 113 : i32} : (!arc.storage) -> !arc.state<i1>
    %4 = arc.alloc_state %arg0 {offset = 114 : i32} : (!arc.storage) -> !arc.state<i1>
    %out_io_rdata = arc.root_output "io_rdata", %arg0 {offset = 116 : i32} : (!arc.storage) -> !arc.state<i32>
    %5 = arc.storage.get %arg0[24] : !arc.storage -> !arc.state<!seq.clock>
    %6 = arc.state_read %5 : <!seq.clock>
    %7 = seq.from_clock %6
    %8 = arc.storage.get %arg0[113] : !arc.storage -> !arc.state<i1>
    %9 = arc.state_read %8 : <i1>
    arc.state_write %8 = %7 : <i1>
    %10 = comb.xor %9, %7 : i1
    %11 = comb.and %10, %7 : i1
    scf.if %11 {
      %20 = arc.storage.get %arg0[27] : !arc.storage -> !arc.state<i1>
      %21 = arc.state_read %20 : <i1>
      scf.if %21 {
        %26 = arc.storage.get %arg0[28] : !arc.storage -> !arc.state<i4>
        %27 = arc.state_read %26 : <i4>
        %28 = arc.storage.get %arg0[32] : !arc.storage -> !arc.state<i32>
        %29 = arc.state_read %28 : <i32>
        %30 = arc.storage.get %arg0[48] : !arc.storage -> !arc.memory<16 x i32, i4>
        arc.memory_write %30[%27], %29 : <16 x i32, i4>
      }
      %22 = arc.storage.get %arg0[26] : !arc.storage -> !arc.state<i4>
      %23 = arc.state_read %22 : <i4>
      %24 = arc.storage.get %arg0[112] : !arc.storage -> !arc.state<i4>
      arc.state_write %24 = %23 : <i4>
      %25 = arc.storage.get %arg0[114] : !arc.storage -> !arc.state<i1>
      arc.state_write %25 = %true : <i1>
    }
    %12 = arc.storage.get %arg0[114] : !arc.storage -> !arc.state<i1>
    %13 = arc.state_read %12 : <i1>
    %14 = arc.storage.get %arg0[112] : !arc.storage -> !arc.state<i4>
    %15 = arc.state_read %14 : <i4>
    %16 = arc.storage.get %arg0[48] : !arc.storage -> !arc.memory<16 x i32, i4>
    %17 = arc.memory_read %16[%15] : <16 x i32, i4>
    %18 = comb.mux %13, %17, %c0_i32 : i32
    %19 = arc.storage.get %arg0[116] : !arc.storage -> !arc.state<i32>
    arc.state_write %19 = %18 : <i32>
  }
}
