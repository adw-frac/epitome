module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} {
  func.func private @exit(i32)
  arc.model @Fir io !hw.modty<input clock : !seq.clock, input reset : i1, input io_in : i8, input io_valid : i1, output io_out : i16> storageBytes 34 {
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
    %in_clock = arc.root_input "clock", %arg0 {offset = 24 : i32} : (!arc.storage) -> !arc.state<!seq.clock>
    %in_reset = arc.root_input "reset", %arg0 {offset = 25 : i32} : (!arc.storage) -> !arc.state<i1>
    %in_io_in = arc.root_input "io_in", %arg0 {offset = 26 : i32} : (!arc.storage) -> !arc.state<i8>
    %in_io_valid = arc.root_input "io_valid", %arg0 {offset = 27 : i32} : (!arc.storage) -> !arc.state<i1>
    %1 = arc.alloc_state %arg0 {offset = 28 : i32} : (!arc.storage) -> !arc.state<i1>
    %2 = arc.alloc_state %arg0 {offset = 29 : i32} : (!arc.storage) -> !arc.state<i8>
    %3 = arc.alloc_state %arg0 {offset = 30 : i32} : (!arc.storage) -> !arc.state<i8>
    %4 = arc.alloc_state %arg0 {offset = 31 : i32} : (!arc.storage) -> !arc.state<i8>
    %out_io_out = arc.root_output "io_out", %arg0 {offset = 32 : i32} : (!arc.storage) -> !arc.state<i16>
    %5 = arc.storage.get %arg0[24] : !arc.storage -> !arc.state<!seq.clock>
    %6 = arc.state_read %5 : <!seq.clock>
    %7 = seq.from_clock %6
    %8 = arc.storage.get %arg0[28] : !arc.storage -> !arc.state<i1>
    %9 = arc.state_read %8 : <i1>
    arc.state_write %8 = %7 : <i1>
    %10 = comb.xor %9, %7 : i1
    %11 = comb.and %10, %7 : i1
    scf.if %11 {
      %35 = arc.storage.get %arg0[25] : !arc.storage -> !arc.state<i1>
      %36 = arc.state_read %35 : <i1>
      scf.if %36 {
        %37 = arc.storage.get %arg0[29] : !arc.storage -> !arc.state<i8>
        arc.state_write %37 = %c0_i8 : <i8>
        %38 = arc.storage.get %arg0[30] : !arc.storage -> !arc.state<i8>
        arc.state_write %38 = %c0_i8 : <i8>
        %39 = arc.storage.get %arg0[31] : !arc.storage -> !arc.state<i8>
        arc.state_write %39 = %c0_i8 : <i8>
      } else {
        %37 = arc.storage.get %arg0[27] : !arc.storage -> !arc.state<i1>
        %38 = arc.state_read %37 : <i1>
        scf.if %38 {
          %39 = arc.storage.get %arg0[29] : !arc.storage -> !arc.state<i8>
          %40 = arc.state_read %39 : <i8>
          %41 = arc.storage.get %arg0[26] : !arc.storage -> !arc.state<i8>
          %42 = arc.state_read %41 : <i8>
          arc.state_write %39 = %42 : <i8>
          %43 = arc.storage.get %arg0[30] : !arc.storage -> !arc.state<i8>
          %44 = arc.state_read %43 : <i8>
          arc.state_write %43 = %40 : <i8>
          %45 = arc.storage.get %arg0[31] : !arc.storage -> !arc.state<i8>
          arc.state_write %45 = %44 : <i8>
        }
      }
    }
    %12 = arc.storage.get %arg0[31] : !arc.storage -> !arc.state<i8>
    %13 = arc.state_read %12 : <i8>
    %14 = arc.storage.get %arg0[30] : !arc.storage -> !arc.state<i8>
    %15 = arc.state_read %14 : <i8>
    %16 = arc.storage.get %arg0[29] : !arc.storage -> !arc.state<i8>
    %17 = arc.state_read %16 : <i8>
    %18 = arc.storage.get %arg0[26] : !arc.storage -> !arc.state<i8>
    %19 = arc.state_read %18 : <i8>
    %20 = comb.concat %c0_i5, %13 : i5, i8
    %21 = comb.concat %c0_i2, %15 : i2, i8
    %22 = comb.mul bin %21, %c3_i10 : i10
    %23 = comb.concat %c0_i2, %22 : i2, i10
    %24 = comb.concat %c0_i2, %17 : i2, i8
    %25 = comb.mul bin %24, %c3_i10 : i10
    %26 = comb.concat %false, %25 : i1, i10
    %27 = comb.concat %c0_i3, %19 : i3, i8
    %28 = comb.add bin %27, %26 : i11
    %29 = comb.concat %false, %28 : i1, i11
    %30 = comb.add bin %29, %23 : i12
    %31 = comb.concat %false, %30 : i1, i12
    %32 = comb.add bin %31, %20 : i13
    %33 = comb.concat %c0_i3, %32 : i3, i13
    %34 = arc.storage.get %arg0[32] : !arc.storage -> !arc.state<i16>
    arc.state_write %34 = %33 : <i16>
  }
}
