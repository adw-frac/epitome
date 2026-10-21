module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} {
  func.func private @exit(i32)
  arc.model @Fir io !hw.modty<input clock : !seq.clock, input reset : i1, input io_in : i8, input io_valid : i1, output io_out : i16> {
  ^bb0(%arg0: !arc.storage):
    %c0_i3 = hw.constant 0 : i3
    %false = hw.constant false
    %c3_i10 = hw.constant 3 : i10
    %c0_i2 = hw.constant 0 : i2
    %c0_i5 = hw.constant 0 : i5
    %c0_i8 = hw.constant 0 : i8
    %c-1_i64 = hw.constant -1 : i64
    %0 = arc.as_context %arg0 : !arc.storage
    arc.set_next_wakeup %0, %c-1_i64
    %in_clock = arc.root_input "clock", %arg0 : (!arc.storage) -> !arc.state<!seq.clock>
    %in_reset = arc.root_input "reset", %arg0 : (!arc.storage) -> !arc.state<i1>
    %in_io_in = arc.root_input "io_in", %arg0 : (!arc.storage) -> !arc.state<i8>
    %in_io_valid = arc.root_input "io_valid", %arg0 : (!arc.storage) -> !arc.state<i1>
    %1 = arc.alloc_state %arg0 : (!arc.storage) -> !arc.state<i1>
    %2 = arc.alloc_state %arg0 : (!arc.storage) -> !arc.state<i8>
    %3 = arc.alloc_state %arg0 : (!arc.storage) -> !arc.state<i8>
    %4 = arc.alloc_state %arg0 : (!arc.storage) -> !arc.state<i8>
    %out_io_out = arc.root_output "io_out", %arg0 : (!arc.storage) -> !arc.state<i16>
    %5 = arc.state_read %in_clock : <!seq.clock>
    %6 = seq.from_clock %5
    %7 = arc.state_read %1 : <i1>
    arc.state_write %1 = %6 : <i1>
    %8 = comb.xor %7, %6 : i1
    %9 = comb.and %8, %6 : i1
    scf.if %9 {
      %28 = arc.state_read %in_reset : <i1>
      scf.if %28 {
        arc.state_write %2 = %c0_i8 : <i8>
        arc.state_write %3 = %c0_i8 : <i8>
        arc.state_write %4 = %c0_i8 : <i8>
      } else {
        %29 = arc.state_read %in_io_valid : <i1>
        scf.if %29 {
          %30 = arc.state_read %2 : <i8>
          %31 = arc.state_read %in_io_in : <i8>
          arc.state_write %2 = %31 : <i8>
          %32 = arc.state_read %3 : <i8>
          arc.state_write %3 = %30 : <i8>
          arc.state_write %4 = %32 : <i8>
        }
      }
    }
    %10 = arc.state_read %4 : <i8>
    %11 = arc.state_read %3 : <i8>
    %12 = arc.state_read %2 : <i8>
    %13 = arc.state_read %in_io_in : <i8>
    %14 = comb.concat %c0_i5, %10 : i5, i8
    %15 = comb.concat %c0_i2, %11 : i2, i8
    %16 = comb.mul bin %15, %c3_i10 : i10
    %17 = comb.concat %c0_i2, %16 : i2, i10
    %18 = comb.concat %c0_i2, %12 : i2, i8
    %19 = comb.mul bin %18, %c3_i10 : i10
    %20 = comb.concat %false, %19 : i1, i10
    %21 = comb.concat %c0_i3, %13 : i3, i8
    %22 = comb.add bin %21, %20 : i11
    %23 = comb.concat %false, %22 : i1, i11
    %24 = comb.add bin %23, %17 : i12
    %25 = comb.concat %false, %24 : i1, i12
    %26 = comb.add bin %25, %14 : i13
    %27 = comb.concat %c0_i3, %26 : i3, i13
    arc.state_write %out_io_out = %27 : <i16>
  }
}
