module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} {
  func.func private @exit(i32)
  arc.model @Counter io !hw.modty<input clock : !seq.clock, input reset : i1, input io_en : i1, output io_count : i8> storageBytes 30 {
  ^bb0(%arg0: !arc.storage):
    %c1_i8 = hw.constant 1 : i8
    %c0_i8 = hw.constant 0 : i8
    %c-1_i64 = hw.constant -1 : i64
    %0 = arc.as_context %arg0 : !arc.storage
    arc.set_next_wakeup %0, %c-1_i64
    %in_clock = arc.root_input "clock", %arg0 {offset = 24 : i32} : (!arc.storage) -> !arc.state<!seq.clock>
    %in_reset = arc.root_input "reset", %arg0 {offset = 25 : i32} : (!arc.storage) -> !arc.state<i1>
    %in_io_en = arc.root_input "io_en", %arg0 {offset = 26 : i32} : (!arc.storage) -> !arc.state<i1>
    %1 = arc.alloc_state %arg0 {offset = 27 : i32} : (!arc.storage) -> !arc.state<i1>
    %2 = arc.alloc_state %arg0 {offset = 28 : i32} : (!arc.storage) -> !arc.state<i8>
    %out_io_count = arc.root_output "io_count", %arg0 {offset = 29 : i32} : (!arc.storage) -> !arc.state<i8>
    %3 = arc.storage.get %arg0[24] : !arc.storage -> !arc.state<!seq.clock>
    %4 = arc.state_read %3 : <!seq.clock>
    %5 = seq.from_clock %4
    %6 = arc.storage.get %arg0[27] : !arc.storage -> !arc.state<i1>
    %7 = arc.state_read %6 : <i1>
    arc.state_write %6 = %5 : <i1>
    %8 = comb.xor %7, %5 : i1
    %9 = comb.and %8, %5 : i1
    scf.if %9 {
      %13 = arc.storage.get %arg0[25] : !arc.storage -> !arc.state<i1>
      %14 = arc.state_read %13 : <i1>
      scf.if %14 {
        %15 = arc.storage.get %arg0[28] : !arc.storage -> !arc.state<i8>
        arc.state_write %15 = %c0_i8 : <i8>
      } else {
        %15 = arc.storage.get %arg0[26] : !arc.storage -> !arc.state<i1>
        %16 = arc.state_read %15 : <i1>
        scf.if %16 {
          %17 = arc.storage.get %arg0[28] : !arc.storage -> !arc.state<i8>
          %18 = arc.state_read %17 : <i8>
          %19 = comb.add bin %18, %c1_i8 : i8
          arc.state_write %17 = %19 : <i8>
        }
      }
    }
    %10 = arc.storage.get %arg0[28] : !arc.storage -> !arc.state<i8>
    %11 = arc.state_read %10 : <i8>
    %12 = arc.storage.get %arg0[29] : !arc.storage -> !arc.state<i8>
    arc.state_write %12 = %11 : <i8>
  }
}
