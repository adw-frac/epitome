module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} {
  func.func private @exit(i32)
  arc.model @Fir64 io !hw.modty<input clock : !seq.clock, input reset : i1, input io_in : i8, input io_valid : i1, output io_out : i16> storageBytes 94 {
  ^bb0(%arg0: !arc.storage):
    %c11_i12 = hw.constant 11 : i12
    %c48_i14 = hw.constant 48 : i14
    %c85_i15 = hw.constant 85 : i15
    %c122_i15 = hw.constant 122 : i15
    %c159_i16 = hw.constant 159 : i16
    %c196_i16 = hw.constant 196 : i16
    %c233_i16 = hw.constant 233 : i16
    %c19_i13 = hw.constant 19 : i13
    %c56_i14 = hw.constant 56 : i14
    %c93_i15 = hw.constant 93 : i15
    %c130_i16 = hw.constant 130 : i16
    %c167_i16 = hw.constant 167 : i16
    %c204_i16 = hw.constant 204 : i16
    %c241_i16 = hw.constant 241 : i16
    %c27_i13 = hw.constant 27 : i13
    %c101_i15 = hw.constant 101 : i15
    %c138_i16 = hw.constant 138 : i16
    %c175_i16 = hw.constant 175 : i16
    %c212_i16 = hw.constant 212 : i16
    %c249_i16 = hw.constant 249 : i16
    %c35_i14 = hw.constant 35 : i14
    %c72_i15 = hw.constant 72 : i15
    %c109_i15 = hw.constant 109 : i15
    %c146_i16 = hw.constant 146 : i16
    %c183_i16 = hw.constant 183 : i16
    %c220_i16 = hw.constant 220 : i16
    %c6_i11 = hw.constant 6 : i11
    %c43_i14 = hw.constant 43 : i14
    %c80_i15 = hw.constant 80 : i15
    %c117_i15 = hw.constant 117 : i15
    %c154_i16 = hw.constant 154 : i16
    %c191_i16 = hw.constant 191 : i16
    %c228_i16 = hw.constant 228 : i16
    %c14_i12 = hw.constant 14 : i12
    %c51_i14 = hw.constant 51 : i14
    %c88_i15 = hw.constant 88 : i15
    %c125_i15 = hw.constant 125 : i15
    %c162_i16 = hw.constant 162 : i16
    %c199_i16 = hw.constant 199 : i16
    %c236_i16 = hw.constant 236 : i16
    %c22_i13 = hw.constant 22 : i13
    %c59_i14 = hw.constant 59 : i14
    %c96_i15 = hw.constant 96 : i15
    %c133_i16 = hw.constant 133 : i16
    %c170_i16 = hw.constant 170 : i16
    %c207_i16 = hw.constant 207 : i16
    %c244_i16 = hw.constant 244 : i16
    %c0_i3 = hw.constant 0 : i3
    %c30_i13 = hw.constant 30 : i13
    %c0_i5 = hw.constant 0 : i5
    %c67_i15 = hw.constant 67 : i15
    %c104_i15 = hw.constant 104 : i15
    %c141_i16 = hw.constant 141 : i16
    %c178_i16 = hw.constant 178 : i16
    %c215_i16 = hw.constant 215 : i16
    %c38_i14 = hw.constant 38 : i14
    %c75_i15 = hw.constant 75 : i15
    %c112_i15 = hw.constant 112 : i15
    %c149_i16 = hw.constant 149 : i16
    %c186_i16 = hw.constant 186 : i16
    %c223_i16 = hw.constant 223 : i16
    %c9_i12 = hw.constant 9 : i12
    %c0_i4 = hw.constant 0 : i4
    %c0_i2 = hw.constant 0 : i2
    %c46_i14 = hw.constant 46 : i14
    %c0_i6 = hw.constant 0 : i6
    %false = hw.constant false
    %c83_i15 = hw.constant 83 : i15
    %c0_i7 = hw.constant 0 : i7
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
    %5 = arc.alloc_state %arg0 {offset = 32 : i32} : (!arc.storage) -> !arc.state<i8>
    %6 = arc.alloc_state %arg0 {offset = 33 : i32} : (!arc.storage) -> !arc.state<i8>
    %7 = arc.alloc_state %arg0 {offset = 34 : i32} : (!arc.storage) -> !arc.state<i8>
    %8 = arc.alloc_state %arg0 {offset = 35 : i32} : (!arc.storage) -> !arc.state<i8>
    %9 = arc.alloc_state %arg0 {offset = 36 : i32} : (!arc.storage) -> !arc.state<i8>
    %10 = arc.alloc_state %arg0 {offset = 37 : i32} : (!arc.storage) -> !arc.state<i8>
    %11 = arc.alloc_state %arg0 {offset = 38 : i32} : (!arc.storage) -> !arc.state<i8>
    %12 = arc.alloc_state %arg0 {offset = 39 : i32} : (!arc.storage) -> !arc.state<i8>
    %13 = arc.alloc_state %arg0 {offset = 40 : i32} : (!arc.storage) -> !arc.state<i8>
    %14 = arc.alloc_state %arg0 {offset = 41 : i32} : (!arc.storage) -> !arc.state<i8>
    %15 = arc.alloc_state %arg0 {offset = 42 : i32} : (!arc.storage) -> !arc.state<i8>
    %16 = arc.alloc_state %arg0 {offset = 43 : i32} : (!arc.storage) -> !arc.state<i8>
    %17 = arc.alloc_state %arg0 {offset = 44 : i32} : (!arc.storage) -> !arc.state<i8>
    %18 = arc.alloc_state %arg0 {offset = 45 : i32} : (!arc.storage) -> !arc.state<i8>
    %19 = arc.alloc_state %arg0 {offset = 46 : i32} : (!arc.storage) -> !arc.state<i8>
    %20 = arc.alloc_state %arg0 {offset = 47 : i32} : (!arc.storage) -> !arc.state<i8>
    %21 = arc.alloc_state %arg0 {offset = 48 : i32} : (!arc.storage) -> !arc.state<i8>
    %22 = arc.alloc_state %arg0 {offset = 49 : i32} : (!arc.storage) -> !arc.state<i8>
    %23 = arc.alloc_state %arg0 {offset = 50 : i32} : (!arc.storage) -> !arc.state<i8>
    %24 = arc.alloc_state %arg0 {offset = 51 : i32} : (!arc.storage) -> !arc.state<i8>
    %25 = arc.alloc_state %arg0 {offset = 52 : i32} : (!arc.storage) -> !arc.state<i8>
    %26 = arc.alloc_state %arg0 {offset = 53 : i32} : (!arc.storage) -> !arc.state<i8>
    %27 = arc.alloc_state %arg0 {offset = 54 : i32} : (!arc.storage) -> !arc.state<i8>
    %28 = arc.alloc_state %arg0 {offset = 55 : i32} : (!arc.storage) -> !arc.state<i8>
    %29 = arc.alloc_state %arg0 {offset = 56 : i32} : (!arc.storage) -> !arc.state<i8>
    %30 = arc.alloc_state %arg0 {offset = 57 : i32} : (!arc.storage) -> !arc.state<i8>
    %31 = arc.alloc_state %arg0 {offset = 58 : i32} : (!arc.storage) -> !arc.state<i8>
    %32 = arc.alloc_state %arg0 {offset = 59 : i32} : (!arc.storage) -> !arc.state<i8>
    %33 = arc.alloc_state %arg0 {offset = 60 : i32} : (!arc.storage) -> !arc.state<i8>
    %34 = arc.alloc_state %arg0 {offset = 61 : i32} : (!arc.storage) -> !arc.state<i8>
    %35 = arc.alloc_state %arg0 {offset = 62 : i32} : (!arc.storage) -> !arc.state<i8>
    %36 = arc.alloc_state %arg0 {offset = 63 : i32} : (!arc.storage) -> !arc.state<i8>
    %37 = arc.alloc_state %arg0 {offset = 64 : i32} : (!arc.storage) -> !arc.state<i8>
    %38 = arc.alloc_state %arg0 {offset = 65 : i32} : (!arc.storage) -> !arc.state<i8>
    %39 = arc.alloc_state %arg0 {offset = 66 : i32} : (!arc.storage) -> !arc.state<i8>
    %40 = arc.alloc_state %arg0 {offset = 67 : i32} : (!arc.storage) -> !arc.state<i8>
    %41 = arc.alloc_state %arg0 {offset = 68 : i32} : (!arc.storage) -> !arc.state<i8>
    %42 = arc.alloc_state %arg0 {offset = 69 : i32} : (!arc.storage) -> !arc.state<i8>
    %43 = arc.alloc_state %arg0 {offset = 70 : i32} : (!arc.storage) -> !arc.state<i8>
    %44 = arc.alloc_state %arg0 {offset = 71 : i32} : (!arc.storage) -> !arc.state<i8>
    %45 = arc.alloc_state %arg0 {offset = 72 : i32} : (!arc.storage) -> !arc.state<i8>
    %46 = arc.alloc_state %arg0 {offset = 73 : i32} : (!arc.storage) -> !arc.state<i8>
    %47 = arc.alloc_state %arg0 {offset = 74 : i32} : (!arc.storage) -> !arc.state<i8>
    %48 = arc.alloc_state %arg0 {offset = 75 : i32} : (!arc.storage) -> !arc.state<i8>
    %49 = arc.alloc_state %arg0 {offset = 76 : i32} : (!arc.storage) -> !arc.state<i8>
    %50 = arc.alloc_state %arg0 {offset = 77 : i32} : (!arc.storage) -> !arc.state<i8>
    %51 = arc.alloc_state %arg0 {offset = 78 : i32} : (!arc.storage) -> !arc.state<i8>
    %52 = arc.alloc_state %arg0 {offset = 79 : i32} : (!arc.storage) -> !arc.state<i8>
    %53 = arc.alloc_state %arg0 {offset = 80 : i32} : (!arc.storage) -> !arc.state<i8>
    %54 = arc.alloc_state %arg0 {offset = 81 : i32} : (!arc.storage) -> !arc.state<i8>
    %55 = arc.alloc_state %arg0 {offset = 82 : i32} : (!arc.storage) -> !arc.state<i8>
    %56 = arc.alloc_state %arg0 {offset = 83 : i32} : (!arc.storage) -> !arc.state<i8>
    %57 = arc.alloc_state %arg0 {offset = 84 : i32} : (!arc.storage) -> !arc.state<i8>
    %58 = arc.alloc_state %arg0 {offset = 85 : i32} : (!arc.storage) -> !arc.state<i8>
    %59 = arc.alloc_state %arg0 {offset = 86 : i32} : (!arc.storage) -> !arc.state<i8>
    %60 = arc.alloc_state %arg0 {offset = 87 : i32} : (!arc.storage) -> !arc.state<i8>
    %61 = arc.alloc_state %arg0 {offset = 88 : i32} : (!arc.storage) -> !arc.state<i8>
    %62 = arc.alloc_state %arg0 {offset = 89 : i32} : (!arc.storage) -> !arc.state<i8>
    %63 = arc.alloc_state %arg0 {offset = 90 : i32} : (!arc.storage) -> !arc.state<i8>
    %64 = arc.alloc_state %arg0 {offset = 91 : i32} : (!arc.storage) -> !arc.state<i8>
    %out_io_out = arc.root_output "io_out", %arg0 {offset = 92 : i32} : (!arc.storage) -> !arc.state<i16>
    %65 = arc.storage.get %arg0[24] : !arc.storage -> !arc.state<!seq.clock>
    %66 = arc.state_read %65 : <!seq.clock>
    %67 = seq.from_clock %66
    %68 = arc.storage.get %arg0[28] : !arc.storage -> !arc.state<i1>
    %69 = arc.state_read %68 : <i1>
    arc.state_write %68 = %67 : <i1>
    %70 = comb.xor %69, %67 : i1
    %71 = comb.and %70, %67 : i1
    scf.if %71 {
      %362 = arc.storage.get %arg0[25] : !arc.storage -> !arc.state<i1>
      %363 = arc.state_read %362 : <i1>
      scf.if %363 {
        %364 = arc.storage.get %arg0[29] : !arc.storage -> !arc.state<i8>
        arc.state_write %364 = %c0_i8 : <i8>
        %365 = arc.storage.get %arg0[30] : !arc.storage -> !arc.state<i8>
        arc.state_write %365 = %c0_i8 : <i8>
        %366 = arc.storage.get %arg0[31] : !arc.storage -> !arc.state<i8>
        arc.state_write %366 = %c0_i8 : <i8>
        %367 = arc.storage.get %arg0[32] : !arc.storage -> !arc.state<i8>
        arc.state_write %367 = %c0_i8 : <i8>
        %368 = arc.storage.get %arg0[33] : !arc.storage -> !arc.state<i8>
        arc.state_write %368 = %c0_i8 : <i8>
        %369 = arc.storage.get %arg0[34] : !arc.storage -> !arc.state<i8>
        arc.state_write %369 = %c0_i8 : <i8>
        %370 = arc.storage.get %arg0[35] : !arc.storage -> !arc.state<i8>
        arc.state_write %370 = %c0_i8 : <i8>
        %371 = arc.storage.get %arg0[36] : !arc.storage -> !arc.state<i8>
        arc.state_write %371 = %c0_i8 : <i8>
        %372 = arc.storage.get %arg0[37] : !arc.storage -> !arc.state<i8>
        arc.state_write %372 = %c0_i8 : <i8>
        %373 = arc.storage.get %arg0[38] : !arc.storage -> !arc.state<i8>
        arc.state_write %373 = %c0_i8 : <i8>
        %374 = arc.storage.get %arg0[39] : !arc.storage -> !arc.state<i8>
        arc.state_write %374 = %c0_i8 : <i8>
        %375 = arc.storage.get %arg0[40] : !arc.storage -> !arc.state<i8>
        arc.state_write %375 = %c0_i8 : <i8>
        %376 = arc.storage.get %arg0[41] : !arc.storage -> !arc.state<i8>
        arc.state_write %376 = %c0_i8 : <i8>
        %377 = arc.storage.get %arg0[42] : !arc.storage -> !arc.state<i8>
        arc.state_write %377 = %c0_i8 : <i8>
        %378 = arc.storage.get %arg0[43] : !arc.storage -> !arc.state<i8>
        arc.state_write %378 = %c0_i8 : <i8>
        %379 = arc.storage.get %arg0[44] : !arc.storage -> !arc.state<i8>
        arc.state_write %379 = %c0_i8 : <i8>
        %380 = arc.storage.get %arg0[45] : !arc.storage -> !arc.state<i8>
        arc.state_write %380 = %c0_i8 : <i8>
        %381 = arc.storage.get %arg0[46] : !arc.storage -> !arc.state<i8>
        arc.state_write %381 = %c0_i8 : <i8>
        %382 = arc.storage.get %arg0[47] : !arc.storage -> !arc.state<i8>
        arc.state_write %382 = %c0_i8 : <i8>
        %383 = arc.storage.get %arg0[48] : !arc.storage -> !arc.state<i8>
        arc.state_write %383 = %c0_i8 : <i8>
        %384 = arc.storage.get %arg0[49] : !arc.storage -> !arc.state<i8>
        arc.state_write %384 = %c0_i8 : <i8>
        %385 = arc.storage.get %arg0[50] : !arc.storage -> !arc.state<i8>
        arc.state_write %385 = %c0_i8 : <i8>
        %386 = arc.storage.get %arg0[51] : !arc.storage -> !arc.state<i8>
        arc.state_write %386 = %c0_i8 : <i8>
        %387 = arc.storage.get %arg0[52] : !arc.storage -> !arc.state<i8>
        arc.state_write %387 = %c0_i8 : <i8>
        %388 = arc.storage.get %arg0[53] : !arc.storage -> !arc.state<i8>
        arc.state_write %388 = %c0_i8 : <i8>
        %389 = arc.storage.get %arg0[54] : !arc.storage -> !arc.state<i8>
        arc.state_write %389 = %c0_i8 : <i8>
        %390 = arc.storage.get %arg0[55] : !arc.storage -> !arc.state<i8>
        arc.state_write %390 = %c0_i8 : <i8>
        %391 = arc.storage.get %arg0[56] : !arc.storage -> !arc.state<i8>
        arc.state_write %391 = %c0_i8 : <i8>
        %392 = arc.storage.get %arg0[57] : !arc.storage -> !arc.state<i8>
        arc.state_write %392 = %c0_i8 : <i8>
        %393 = arc.storage.get %arg0[58] : !arc.storage -> !arc.state<i8>
        arc.state_write %393 = %c0_i8 : <i8>
        %394 = arc.storage.get %arg0[59] : !arc.storage -> !arc.state<i8>
        arc.state_write %394 = %c0_i8 : <i8>
        %395 = arc.storage.get %arg0[60] : !arc.storage -> !arc.state<i8>
        arc.state_write %395 = %c0_i8 : <i8>
        %396 = arc.storage.get %arg0[61] : !arc.storage -> !arc.state<i8>
        arc.state_write %396 = %c0_i8 : <i8>
        %397 = arc.storage.get %arg0[62] : !arc.storage -> !arc.state<i8>
        arc.state_write %397 = %c0_i8 : <i8>
        %398 = arc.storage.get %arg0[63] : !arc.storage -> !arc.state<i8>
        arc.state_write %398 = %c0_i8 : <i8>
        %399 = arc.storage.get %arg0[64] : !arc.storage -> !arc.state<i8>
        arc.state_write %399 = %c0_i8 : <i8>
        %400 = arc.storage.get %arg0[65] : !arc.storage -> !arc.state<i8>
        arc.state_write %400 = %c0_i8 : <i8>
        %401 = arc.storage.get %arg0[66] : !arc.storage -> !arc.state<i8>
        arc.state_write %401 = %c0_i8 : <i8>
        %402 = arc.storage.get %arg0[67] : !arc.storage -> !arc.state<i8>
        arc.state_write %402 = %c0_i8 : <i8>
        %403 = arc.storage.get %arg0[68] : !arc.storage -> !arc.state<i8>
        arc.state_write %403 = %c0_i8 : <i8>
        %404 = arc.storage.get %arg0[69] : !arc.storage -> !arc.state<i8>
        arc.state_write %404 = %c0_i8 : <i8>
        %405 = arc.storage.get %arg0[70] : !arc.storage -> !arc.state<i8>
        arc.state_write %405 = %c0_i8 : <i8>
        %406 = arc.storage.get %arg0[71] : !arc.storage -> !arc.state<i8>
        arc.state_write %406 = %c0_i8 : <i8>
        %407 = arc.storage.get %arg0[72] : !arc.storage -> !arc.state<i8>
        arc.state_write %407 = %c0_i8 : <i8>
        %408 = arc.storage.get %arg0[73] : !arc.storage -> !arc.state<i8>
        arc.state_write %408 = %c0_i8 : <i8>
        %409 = arc.storage.get %arg0[74] : !arc.storage -> !arc.state<i8>
        arc.state_write %409 = %c0_i8 : <i8>
        %410 = arc.storage.get %arg0[75] : !arc.storage -> !arc.state<i8>
        arc.state_write %410 = %c0_i8 : <i8>
        %411 = arc.storage.get %arg0[76] : !arc.storage -> !arc.state<i8>
        arc.state_write %411 = %c0_i8 : <i8>
        %412 = arc.storage.get %arg0[77] : !arc.storage -> !arc.state<i8>
        arc.state_write %412 = %c0_i8 : <i8>
        %413 = arc.storage.get %arg0[78] : !arc.storage -> !arc.state<i8>
        arc.state_write %413 = %c0_i8 : <i8>
        %414 = arc.storage.get %arg0[79] : !arc.storage -> !arc.state<i8>
        arc.state_write %414 = %c0_i8 : <i8>
        %415 = arc.storage.get %arg0[80] : !arc.storage -> !arc.state<i8>
        arc.state_write %415 = %c0_i8 : <i8>
        %416 = arc.storage.get %arg0[81] : !arc.storage -> !arc.state<i8>
        arc.state_write %416 = %c0_i8 : <i8>
        %417 = arc.storage.get %arg0[82] : !arc.storage -> !arc.state<i8>
        arc.state_write %417 = %c0_i8 : <i8>
        %418 = arc.storage.get %arg0[83] : !arc.storage -> !arc.state<i8>
        arc.state_write %418 = %c0_i8 : <i8>
        %419 = arc.storage.get %arg0[84] : !arc.storage -> !arc.state<i8>
        arc.state_write %419 = %c0_i8 : <i8>
        %420 = arc.storage.get %arg0[85] : !arc.storage -> !arc.state<i8>
        arc.state_write %420 = %c0_i8 : <i8>
        %421 = arc.storage.get %arg0[86] : !arc.storage -> !arc.state<i8>
        arc.state_write %421 = %c0_i8 : <i8>
        %422 = arc.storage.get %arg0[87] : !arc.storage -> !arc.state<i8>
        arc.state_write %422 = %c0_i8 : <i8>
        %423 = arc.storage.get %arg0[88] : !arc.storage -> !arc.state<i8>
        arc.state_write %423 = %c0_i8 : <i8>
        %424 = arc.storage.get %arg0[89] : !arc.storage -> !arc.state<i8>
        arc.state_write %424 = %c0_i8 : <i8>
        %425 = arc.storage.get %arg0[90] : !arc.storage -> !arc.state<i8>
        arc.state_write %425 = %c0_i8 : <i8>
        %426 = arc.storage.get %arg0[91] : !arc.storage -> !arc.state<i8>
        arc.state_write %426 = %c0_i8 : <i8>
      } else {
        %364 = arc.storage.get %arg0[27] : !arc.storage -> !arc.state<i1>
        %365 = arc.state_read %364 : <i1>
        scf.if %365 {
          %366 = arc.storage.get %arg0[29] : !arc.storage -> !arc.state<i8>
          %367 = arc.state_read %366 : <i8>
          %368 = arc.storage.get %arg0[26] : !arc.storage -> !arc.state<i8>
          %369 = arc.state_read %368 : <i8>
          arc.state_write %366 = %369 : <i8>
          %370 = arc.storage.get %arg0[30] : !arc.storage -> !arc.state<i8>
          %371 = arc.state_read %370 : <i8>
          arc.state_write %370 = %367 : <i8>
          %372 = arc.storage.get %arg0[31] : !arc.storage -> !arc.state<i8>
          %373 = arc.state_read %372 : <i8>
          arc.state_write %372 = %371 : <i8>
          %374 = arc.storage.get %arg0[32] : !arc.storage -> !arc.state<i8>
          %375 = arc.state_read %374 : <i8>
          arc.state_write %374 = %373 : <i8>
          %376 = arc.storage.get %arg0[33] : !arc.storage -> !arc.state<i8>
          %377 = arc.state_read %376 : <i8>
          arc.state_write %376 = %375 : <i8>
          %378 = arc.storage.get %arg0[34] : !arc.storage -> !arc.state<i8>
          %379 = arc.state_read %378 : <i8>
          arc.state_write %378 = %377 : <i8>
          %380 = arc.storage.get %arg0[35] : !arc.storage -> !arc.state<i8>
          %381 = arc.state_read %380 : <i8>
          arc.state_write %380 = %379 : <i8>
          %382 = arc.storage.get %arg0[36] : !arc.storage -> !arc.state<i8>
          %383 = arc.state_read %382 : <i8>
          arc.state_write %382 = %381 : <i8>
          %384 = arc.storage.get %arg0[37] : !arc.storage -> !arc.state<i8>
          %385 = arc.state_read %384 : <i8>
          arc.state_write %384 = %383 : <i8>
          %386 = arc.storage.get %arg0[38] : !arc.storage -> !arc.state<i8>
          %387 = arc.state_read %386 : <i8>
          arc.state_write %386 = %385 : <i8>
          %388 = arc.storage.get %arg0[39] : !arc.storage -> !arc.state<i8>
          %389 = arc.state_read %388 : <i8>
          arc.state_write %388 = %387 : <i8>
          %390 = arc.storage.get %arg0[40] : !arc.storage -> !arc.state<i8>
          %391 = arc.state_read %390 : <i8>
          arc.state_write %390 = %389 : <i8>
          %392 = arc.storage.get %arg0[41] : !arc.storage -> !arc.state<i8>
          %393 = arc.state_read %392 : <i8>
          arc.state_write %392 = %391 : <i8>
          %394 = arc.storage.get %arg0[42] : !arc.storage -> !arc.state<i8>
          %395 = arc.state_read %394 : <i8>
          arc.state_write %394 = %393 : <i8>
          %396 = arc.storage.get %arg0[43] : !arc.storage -> !arc.state<i8>
          %397 = arc.state_read %396 : <i8>
          arc.state_write %396 = %395 : <i8>
          %398 = arc.storage.get %arg0[44] : !arc.storage -> !arc.state<i8>
          %399 = arc.state_read %398 : <i8>
          arc.state_write %398 = %397 : <i8>
          %400 = arc.storage.get %arg0[45] : !arc.storage -> !arc.state<i8>
          %401 = arc.state_read %400 : <i8>
          arc.state_write %400 = %399 : <i8>
          %402 = arc.storage.get %arg0[46] : !arc.storage -> !arc.state<i8>
          %403 = arc.state_read %402 : <i8>
          arc.state_write %402 = %401 : <i8>
          %404 = arc.storage.get %arg0[47] : !arc.storage -> !arc.state<i8>
          %405 = arc.state_read %404 : <i8>
          arc.state_write %404 = %403 : <i8>
          %406 = arc.storage.get %arg0[48] : !arc.storage -> !arc.state<i8>
          %407 = arc.state_read %406 : <i8>
          arc.state_write %406 = %405 : <i8>
          %408 = arc.storage.get %arg0[49] : !arc.storage -> !arc.state<i8>
          %409 = arc.state_read %408 : <i8>
          arc.state_write %408 = %407 : <i8>
          %410 = arc.storage.get %arg0[50] : !arc.storage -> !arc.state<i8>
          %411 = arc.state_read %410 : <i8>
          arc.state_write %410 = %409 : <i8>
          %412 = arc.storage.get %arg0[51] : !arc.storage -> !arc.state<i8>
          %413 = arc.state_read %412 : <i8>
          arc.state_write %412 = %411 : <i8>
          %414 = arc.storage.get %arg0[52] : !arc.storage -> !arc.state<i8>
          %415 = arc.state_read %414 : <i8>
          arc.state_write %414 = %413 : <i8>
          %416 = arc.storage.get %arg0[53] : !arc.storage -> !arc.state<i8>
          %417 = arc.state_read %416 : <i8>
          arc.state_write %416 = %415 : <i8>
          %418 = arc.storage.get %arg0[54] : !arc.storage -> !arc.state<i8>
          %419 = arc.state_read %418 : <i8>
          arc.state_write %418 = %417 : <i8>
          %420 = arc.storage.get %arg0[55] : !arc.storage -> !arc.state<i8>
          %421 = arc.state_read %420 : <i8>
          arc.state_write %420 = %419 : <i8>
          %422 = arc.storage.get %arg0[56] : !arc.storage -> !arc.state<i8>
          %423 = arc.state_read %422 : <i8>
          arc.state_write %422 = %421 : <i8>
          %424 = arc.storage.get %arg0[57] : !arc.storage -> !arc.state<i8>
          %425 = arc.state_read %424 : <i8>
          arc.state_write %424 = %423 : <i8>
          %426 = arc.storage.get %arg0[58] : !arc.storage -> !arc.state<i8>
          %427 = arc.state_read %426 : <i8>
          arc.state_write %426 = %425 : <i8>
          %428 = arc.storage.get %arg0[59] : !arc.storage -> !arc.state<i8>
          %429 = arc.state_read %428 : <i8>
          arc.state_write %428 = %427 : <i8>
          %430 = arc.storage.get %arg0[60] : !arc.storage -> !arc.state<i8>
          %431 = arc.state_read %430 : <i8>
          arc.state_write %430 = %429 : <i8>
          %432 = arc.storage.get %arg0[61] : !arc.storage -> !arc.state<i8>
          %433 = arc.state_read %432 : <i8>
          arc.state_write %432 = %431 : <i8>
          %434 = arc.storage.get %arg0[62] : !arc.storage -> !arc.state<i8>
          %435 = arc.state_read %434 : <i8>
          arc.state_write %434 = %433 : <i8>
          %436 = arc.storage.get %arg0[63] : !arc.storage -> !arc.state<i8>
          %437 = arc.state_read %436 : <i8>
          arc.state_write %436 = %435 : <i8>
          %438 = arc.storage.get %arg0[64] : !arc.storage -> !arc.state<i8>
          %439 = arc.state_read %438 : <i8>
          arc.state_write %438 = %437 : <i8>
          %440 = arc.storage.get %arg0[65] : !arc.storage -> !arc.state<i8>
          %441 = arc.state_read %440 : <i8>
          arc.state_write %440 = %439 : <i8>
          %442 = arc.storage.get %arg0[66] : !arc.storage -> !arc.state<i8>
          %443 = arc.state_read %442 : <i8>
          arc.state_write %442 = %441 : <i8>
          %444 = arc.storage.get %arg0[67] : !arc.storage -> !arc.state<i8>
          %445 = arc.state_read %444 : <i8>
          arc.state_write %444 = %443 : <i8>
          %446 = arc.storage.get %arg0[68] : !arc.storage -> !arc.state<i8>
          %447 = arc.state_read %446 : <i8>
          arc.state_write %446 = %445 : <i8>
          %448 = arc.storage.get %arg0[69] : !arc.storage -> !arc.state<i8>
          %449 = arc.state_read %448 : <i8>
          arc.state_write %448 = %447 : <i8>
          %450 = arc.storage.get %arg0[70] : !arc.storage -> !arc.state<i8>
          %451 = arc.state_read %450 : <i8>
          arc.state_write %450 = %449 : <i8>
          %452 = arc.storage.get %arg0[71] : !arc.storage -> !arc.state<i8>
          %453 = arc.state_read %452 : <i8>
          arc.state_write %452 = %451 : <i8>
          %454 = arc.storage.get %arg0[72] : !arc.storage -> !arc.state<i8>
          %455 = arc.state_read %454 : <i8>
          arc.state_write %454 = %453 : <i8>
          %456 = arc.storage.get %arg0[73] : !arc.storage -> !arc.state<i8>
          %457 = arc.state_read %456 : <i8>
          arc.state_write %456 = %455 : <i8>
          %458 = arc.storage.get %arg0[74] : !arc.storage -> !arc.state<i8>
          %459 = arc.state_read %458 : <i8>
          arc.state_write %458 = %457 : <i8>
          %460 = arc.storage.get %arg0[75] : !arc.storage -> !arc.state<i8>
          %461 = arc.state_read %460 : <i8>
          arc.state_write %460 = %459 : <i8>
          %462 = arc.storage.get %arg0[76] : !arc.storage -> !arc.state<i8>
          %463 = arc.state_read %462 : <i8>
          arc.state_write %462 = %461 : <i8>
          %464 = arc.storage.get %arg0[77] : !arc.storage -> !arc.state<i8>
          %465 = arc.state_read %464 : <i8>
          arc.state_write %464 = %463 : <i8>
          %466 = arc.storage.get %arg0[78] : !arc.storage -> !arc.state<i8>
          %467 = arc.state_read %466 : <i8>
          arc.state_write %466 = %465 : <i8>
          %468 = arc.storage.get %arg0[79] : !arc.storage -> !arc.state<i8>
          %469 = arc.state_read %468 : <i8>
          arc.state_write %468 = %467 : <i8>
          %470 = arc.storage.get %arg0[80] : !arc.storage -> !arc.state<i8>
          %471 = arc.state_read %470 : <i8>
          arc.state_write %470 = %469 : <i8>
          %472 = arc.storage.get %arg0[81] : !arc.storage -> !arc.state<i8>
          %473 = arc.state_read %472 : <i8>
          arc.state_write %472 = %471 : <i8>
          %474 = arc.storage.get %arg0[82] : !arc.storage -> !arc.state<i8>
          %475 = arc.state_read %474 : <i8>
          arc.state_write %474 = %473 : <i8>
          %476 = arc.storage.get %arg0[83] : !arc.storage -> !arc.state<i8>
          %477 = arc.state_read %476 : <i8>
          arc.state_write %476 = %475 : <i8>
          %478 = arc.storage.get %arg0[84] : !arc.storage -> !arc.state<i8>
          %479 = arc.state_read %478 : <i8>
          arc.state_write %478 = %477 : <i8>
          %480 = arc.storage.get %arg0[85] : !arc.storage -> !arc.state<i8>
          %481 = arc.state_read %480 : <i8>
          arc.state_write %480 = %479 : <i8>
          %482 = arc.storage.get %arg0[86] : !arc.storage -> !arc.state<i8>
          %483 = arc.state_read %482 : <i8>
          arc.state_write %482 = %481 : <i8>
          %484 = arc.storage.get %arg0[87] : !arc.storage -> !arc.state<i8>
          %485 = arc.state_read %484 : <i8>
          arc.state_write %484 = %483 : <i8>
          %486 = arc.storage.get %arg0[88] : !arc.storage -> !arc.state<i8>
          %487 = arc.state_read %486 : <i8>
          arc.state_write %486 = %485 : <i8>
          %488 = arc.storage.get %arg0[89] : !arc.storage -> !arc.state<i8>
          %489 = arc.state_read %488 : <i8>
          arc.state_write %488 = %487 : <i8>
          %490 = arc.storage.get %arg0[90] : !arc.storage -> !arc.state<i8>
          %491 = arc.state_read %490 : <i8>
          arc.state_write %490 = %489 : <i8>
          %492 = arc.storage.get %arg0[91] : !arc.storage -> !arc.state<i8>
          arc.state_write %492 = %491 : <i8>
        }
      }
    }
    %72 = arc.storage.get %arg0[91] : !arc.storage -> !arc.state<i8>
    %73 = arc.state_read %72 : <i8>
    %74 = arc.storage.get %arg0[90] : !arc.storage -> !arc.state<i8>
    %75 = arc.state_read %74 : <i8>
    %76 = arc.storage.get %arg0[89] : !arc.storage -> !arc.state<i8>
    %77 = arc.state_read %76 : <i8>
    %78 = arc.storage.get %arg0[88] : !arc.storage -> !arc.state<i8>
    %79 = arc.state_read %78 : <i8>
    %80 = arc.storage.get %arg0[87] : !arc.storage -> !arc.state<i8>
    %81 = arc.state_read %80 : <i8>
    %82 = arc.storage.get %arg0[86] : !arc.storage -> !arc.state<i8>
    %83 = arc.state_read %82 : <i8>
    %84 = arc.storage.get %arg0[85] : !arc.storage -> !arc.state<i8>
    %85 = arc.state_read %84 : <i8>
    %86 = arc.storage.get %arg0[84] : !arc.storage -> !arc.state<i8>
    %87 = arc.state_read %86 : <i8>
    %88 = arc.storage.get %arg0[83] : !arc.storage -> !arc.state<i8>
    %89 = arc.state_read %88 : <i8>
    %90 = arc.storage.get %arg0[82] : !arc.storage -> !arc.state<i8>
    %91 = arc.state_read %90 : <i8>
    %92 = arc.storage.get %arg0[81] : !arc.storage -> !arc.state<i8>
    %93 = arc.state_read %92 : <i8>
    %94 = arc.storage.get %arg0[80] : !arc.storage -> !arc.state<i8>
    %95 = arc.state_read %94 : <i8>
    %96 = arc.storage.get %arg0[79] : !arc.storage -> !arc.state<i8>
    %97 = arc.state_read %96 : <i8>
    %98 = arc.storage.get %arg0[78] : !arc.storage -> !arc.state<i8>
    %99 = arc.state_read %98 : <i8>
    %100 = arc.storage.get %arg0[77] : !arc.storage -> !arc.state<i8>
    %101 = arc.state_read %100 : <i8>
    %102 = arc.storage.get %arg0[76] : !arc.storage -> !arc.state<i8>
    %103 = arc.state_read %102 : <i8>
    %104 = arc.storage.get %arg0[75] : !arc.storage -> !arc.state<i8>
    %105 = arc.state_read %104 : <i8>
    %106 = arc.storage.get %arg0[74] : !arc.storage -> !arc.state<i8>
    %107 = arc.state_read %106 : <i8>
    %108 = arc.storage.get %arg0[73] : !arc.storage -> !arc.state<i8>
    %109 = arc.state_read %108 : <i8>
    %110 = arc.storage.get %arg0[72] : !arc.storage -> !arc.state<i8>
    %111 = arc.state_read %110 : <i8>
    %112 = arc.storage.get %arg0[71] : !arc.storage -> !arc.state<i8>
    %113 = arc.state_read %112 : <i8>
    %114 = arc.storage.get %arg0[70] : !arc.storage -> !arc.state<i8>
    %115 = arc.state_read %114 : <i8>
    %116 = arc.storage.get %arg0[69] : !arc.storage -> !arc.state<i8>
    %117 = arc.state_read %116 : <i8>
    %118 = arc.storage.get %arg0[68] : !arc.storage -> !arc.state<i8>
    %119 = arc.state_read %118 : <i8>
    %120 = arc.storage.get %arg0[67] : !arc.storage -> !arc.state<i8>
    %121 = arc.state_read %120 : <i8>
    %122 = arc.storage.get %arg0[66] : !arc.storage -> !arc.state<i8>
    %123 = arc.state_read %122 : <i8>
    %124 = arc.storage.get %arg0[65] : !arc.storage -> !arc.state<i8>
    %125 = arc.state_read %124 : <i8>
    %126 = arc.storage.get %arg0[64] : !arc.storage -> !arc.state<i8>
    %127 = arc.state_read %126 : <i8>
    %128 = arc.storage.get %arg0[63] : !arc.storage -> !arc.state<i8>
    %129 = arc.state_read %128 : <i8>
    %130 = arc.storage.get %arg0[62] : !arc.storage -> !arc.state<i8>
    %131 = arc.state_read %130 : <i8>
    %132 = arc.storage.get %arg0[61] : !arc.storage -> !arc.state<i8>
    %133 = arc.state_read %132 : <i8>
    %134 = arc.storage.get %arg0[60] : !arc.storage -> !arc.state<i8>
    %135 = arc.state_read %134 : <i8>
    %136 = arc.storage.get %arg0[59] : !arc.storage -> !arc.state<i8>
    %137 = arc.state_read %136 : <i8>
    %138 = arc.storage.get %arg0[58] : !arc.storage -> !arc.state<i8>
    %139 = arc.state_read %138 : <i8>
    %140 = arc.storage.get %arg0[57] : !arc.storage -> !arc.state<i8>
    %141 = arc.state_read %140 : <i8>
    %142 = arc.storage.get %arg0[56] : !arc.storage -> !arc.state<i8>
    %143 = arc.state_read %142 : <i8>
    %144 = arc.storage.get %arg0[55] : !arc.storage -> !arc.state<i8>
    %145 = arc.state_read %144 : <i8>
    %146 = arc.storage.get %arg0[54] : !arc.storage -> !arc.state<i8>
    %147 = arc.state_read %146 : <i8>
    %148 = arc.storage.get %arg0[53] : !arc.storage -> !arc.state<i8>
    %149 = arc.state_read %148 : <i8>
    %150 = arc.storage.get %arg0[52] : !arc.storage -> !arc.state<i8>
    %151 = arc.state_read %150 : <i8>
    %152 = arc.storage.get %arg0[51] : !arc.storage -> !arc.state<i8>
    %153 = arc.state_read %152 : <i8>
    %154 = arc.storage.get %arg0[50] : !arc.storage -> !arc.state<i8>
    %155 = arc.state_read %154 : <i8>
    %156 = arc.storage.get %arg0[49] : !arc.storage -> !arc.state<i8>
    %157 = arc.state_read %156 : <i8>
    %158 = arc.storage.get %arg0[48] : !arc.storage -> !arc.state<i8>
    %159 = arc.state_read %158 : <i8>
    %160 = arc.storage.get %arg0[47] : !arc.storage -> !arc.state<i8>
    %161 = arc.state_read %160 : <i8>
    %162 = arc.storage.get %arg0[46] : !arc.storage -> !arc.state<i8>
    %163 = arc.state_read %162 : <i8>
    %164 = arc.storage.get %arg0[45] : !arc.storage -> !arc.state<i8>
    %165 = arc.state_read %164 : <i8>
    %166 = arc.storage.get %arg0[44] : !arc.storage -> !arc.state<i8>
    %167 = arc.state_read %166 : <i8>
    %168 = arc.storage.get %arg0[43] : !arc.storage -> !arc.state<i8>
    %169 = arc.state_read %168 : <i8>
    %170 = arc.storage.get %arg0[42] : !arc.storage -> !arc.state<i8>
    %171 = arc.state_read %170 : <i8>
    %172 = arc.storage.get %arg0[41] : !arc.storage -> !arc.state<i8>
    %173 = arc.state_read %172 : <i8>
    %174 = arc.storage.get %arg0[40] : !arc.storage -> !arc.state<i8>
    %175 = arc.state_read %174 : <i8>
    %176 = arc.storage.get %arg0[39] : !arc.storage -> !arc.state<i8>
    %177 = arc.state_read %176 : <i8>
    %178 = arc.storage.get %arg0[38] : !arc.storage -> !arc.state<i8>
    %179 = arc.state_read %178 : <i8>
    %180 = arc.storage.get %arg0[37] : !arc.storage -> !arc.state<i8>
    %181 = arc.state_read %180 : <i8>
    %182 = arc.storage.get %arg0[36] : !arc.storage -> !arc.state<i8>
    %183 = arc.state_read %182 : <i8>
    %184 = arc.storage.get %arg0[35] : !arc.storage -> !arc.state<i8>
    %185 = arc.state_read %184 : <i8>
    %186 = arc.storage.get %arg0[34] : !arc.storage -> !arc.state<i8>
    %187 = arc.state_read %186 : <i8>
    %188 = arc.storage.get %arg0[33] : !arc.storage -> !arc.state<i8>
    %189 = arc.state_read %188 : <i8>
    %190 = arc.storage.get %arg0[32] : !arc.storage -> !arc.state<i8>
    %191 = arc.state_read %190 : <i8>
    %192 = arc.storage.get %arg0[31] : !arc.storage -> !arc.state<i8>
    %193 = arc.state_read %192 : <i8>
    %194 = arc.storage.get %arg0[30] : !arc.storage -> !arc.state<i8>
    %195 = arc.state_read %194 : <i8>
    %196 = arc.storage.get %arg0[29] : !arc.storage -> !arc.state<i8>
    %197 = arc.state_read %196 : <i8>
    %198 = arc.storage.get %arg0[26] : !arc.storage -> !arc.state<i8>
    %199 = arc.state_read %198 : <i8>
    %200 = comb.concat %c0_i7, %73 : i7, i8
    %201 = comb.mul bin %200, %c83_i15 : i15
    %202 = comb.concat %false, %201 : i1, i15
    %203 = comb.concat %c0_i6, %75 : i6, i8
    %204 = comb.mul bin %203, %c46_i14 : i14
    %205 = comb.concat %c0_i2, %204 : i2, i14
    %206 = comb.concat %c0_i4, %77 : i4, i8
    %207 = comb.mul bin %206, %c9_i12 : i12
    %208 = comb.concat %c0_i4, %207 : i4, i12
    %209 = comb.concat %c0_i8, %79 : i8, i8
    %210 = comb.mul bin %209, %c223_i16 : i16
    %211 = comb.concat %c0_i8, %81 : i8, i8
    %212 = comb.mul bin %211, %c186_i16 : i16
    %213 = comb.concat %c0_i8, %83 : i8, i8
    %214 = comb.mul bin %213, %c149_i16 : i16
    %215 = comb.concat %c0_i7, %85 : i7, i8
    %216 = comb.mul bin %215, %c112_i15 : i15
    %217 = comb.concat %false, %216 : i1, i15
    %218 = comb.concat %c0_i7, %87 : i7, i8
    %219 = comb.mul bin %218, %c75_i15 : i15
    %220 = comb.concat %false, %219 : i1, i15
    %221 = comb.concat %c0_i6, %89 : i6, i8
    %222 = comb.mul bin %221, %c38_i14 : i14
    %223 = comb.concat %c0_i2, %222 : i2, i14
    %224 = comb.concat %c0_i8, %91 : i8, i8
    %225 = comb.concat %c0_i8, %93 : i8, i8
    %226 = comb.mul bin %225, %c215_i16 : i16
    %227 = comb.concat %c0_i8, %95 : i8, i8
    %228 = comb.mul bin %227, %c178_i16 : i16
    %229 = comb.concat %c0_i8, %97 : i8, i8
    %230 = comb.mul bin %229, %c141_i16 : i16
    %231 = comb.concat %c0_i7, %99 : i7, i8
    %232 = comb.mul bin %231, %c104_i15 : i15
    %233 = comb.concat %false, %232 : i1, i15
    %234 = comb.concat %c0_i7, %101 : i7, i8
    %235 = comb.mul bin %234, %c67_i15 : i15
    %236 = comb.concat %false, %235 : i1, i15
    %237 = comb.concat %c0_i5, %103 : i5, i8
    %238 = comb.mul bin %237, %c30_i13 : i13
    %239 = comb.concat %c0_i3, %238 : i3, i13
    %240 = comb.concat %c0_i8, %105 : i8, i8
    %241 = comb.mul bin %240, %c244_i16 : i16
    %242 = comb.concat %c0_i8, %107 : i8, i8
    %243 = comb.mul bin %242, %c207_i16 : i16
    %244 = comb.concat %c0_i8, %109 : i8, i8
    %245 = comb.mul bin %244, %c170_i16 : i16
    %246 = comb.concat %c0_i8, %111 : i8, i8
    %247 = comb.mul bin %246, %c133_i16 : i16
    %248 = comb.concat %c0_i7, %113 : i7, i8
    %249 = comb.mul bin %248, %c96_i15 : i15
    %250 = comb.concat %false, %249 : i1, i15
    %251 = comb.concat %c0_i6, %115 : i6, i8
    %252 = comb.mul bin %251, %c59_i14 : i14
    %253 = comb.concat %c0_i2, %252 : i2, i14
    %254 = comb.concat %c0_i5, %117 : i5, i8
    %255 = comb.mul bin %254, %c22_i13 : i13
    %256 = comb.concat %c0_i3, %255 : i3, i13
    %257 = comb.concat %c0_i8, %119 : i8, i8
    %258 = comb.mul bin %257, %c236_i16 : i16
    %259 = comb.concat %c0_i8, %121 : i8, i8
    %260 = comb.mul bin %259, %c199_i16 : i16
    %261 = comb.concat %c0_i8, %123 : i8, i8
    %262 = comb.mul bin %261, %c162_i16 : i16
    %263 = comb.concat %c0_i7, %125 : i7, i8
    %264 = comb.mul bin %263, %c125_i15 : i15
    %265 = comb.concat %false, %264 : i1, i15
    %266 = comb.concat %c0_i7, %127 : i7, i8
    %267 = comb.mul bin %266, %c88_i15 : i15
    %268 = comb.concat %false, %267 : i1, i15
    %269 = comb.concat %c0_i6, %129 : i6, i8
    %270 = comb.mul bin %269, %c51_i14 : i14
    %271 = comb.concat %c0_i2, %270 : i2, i14
    %272 = comb.concat %c0_i4, %131 : i4, i8
    %273 = comb.mul bin %272, %c14_i12 : i12
    %274 = comb.concat %c0_i4, %273 : i4, i12
    %275 = comb.concat %c0_i8, %133 : i8, i8
    %276 = comb.mul bin %275, %c228_i16 : i16
    %277 = comb.concat %c0_i8, %135 : i8, i8
    %278 = comb.mul bin %277, %c191_i16 : i16
    %279 = comb.concat %c0_i8, %137 : i8, i8
    %280 = comb.mul bin %279, %c154_i16 : i16
    %281 = comb.concat %c0_i7, %139 : i7, i8
    %282 = comb.mul bin %281, %c117_i15 : i15
    %283 = comb.concat %false, %282 : i1, i15
    %284 = comb.concat %c0_i7, %141 : i7, i8
    %285 = comb.mul bin %284, %c80_i15 : i15
    %286 = comb.concat %false, %285 : i1, i15
    %287 = comb.concat %c0_i6, %143 : i6, i8
    %288 = comb.mul bin %287, %c43_i14 : i14
    %289 = comb.concat %c0_i2, %288 : i2, i14
    %290 = comb.concat %c0_i3, %145 : i3, i8
    %291 = comb.mul bin %290, %c6_i11 : i11
    %292 = comb.concat %c0_i5, %291 : i5, i11
    %293 = comb.concat %c0_i8, %147 : i8, i8
    %294 = comb.mul bin %293, %c220_i16 : i16
    %295 = comb.concat %c0_i8, %149 : i8, i8
    %296 = comb.mul bin %295, %c183_i16 : i16
    %297 = comb.concat %c0_i8, %151 : i8, i8
    %298 = comb.mul bin %297, %c146_i16 : i16
    %299 = comb.concat %c0_i7, %153 : i7, i8
    %300 = comb.mul bin %299, %c109_i15 : i15
    %301 = comb.concat %false, %300 : i1, i15
    %302 = comb.concat %c0_i7, %155 : i7, i8
    %303 = comb.mul bin %302, %c72_i15 : i15
    %304 = comb.concat %false, %303 : i1, i15
    %305 = comb.concat %c0_i6, %157 : i6, i8
    %306 = comb.mul bin %305, %c35_i14 : i14
    %307 = comb.concat %c0_i2, %306 : i2, i14
    %308 = comb.concat %c0_i8, %159 : i8, i8
    %309 = comb.mul bin %308, %c249_i16 : i16
    %310 = comb.concat %c0_i8, %161 : i8, i8
    %311 = comb.mul bin %310, %c212_i16 : i16
    %312 = comb.concat %c0_i8, %163 : i8, i8
    %313 = comb.mul bin %312, %c175_i16 : i16
    %314 = comb.concat %c0_i8, %165 : i8, i8
    %315 = comb.mul bin %314, %c138_i16 : i16
    %316 = comb.concat %c0_i7, %167 : i7, i8
    %317 = comb.mul bin %316, %c101_i15 : i15
    %318 = comb.concat %false, %317 : i1, i15
    %319 = comb.concat %c0_i2, %169, %c0_i6 : i2, i8, i6
    %320 = comb.concat %c0_i5, %171 : i5, i8
    %321 = comb.mul bin %320, %c27_i13 : i13
    %322 = comb.concat %c0_i3, %321 : i3, i13
    %323 = comb.concat %c0_i8, %173 : i8, i8
    %324 = comb.mul bin %323, %c241_i16 : i16
    %325 = comb.concat %c0_i8, %175 : i8, i8
    %326 = comb.mul bin %325, %c204_i16 : i16
    %327 = comb.concat %c0_i8, %177 : i8, i8
    %328 = comb.mul bin %327, %c167_i16 : i16
    %329 = comb.concat %c0_i8, %179 : i8, i8
    %330 = comb.mul bin %329, %c130_i16 : i16
    %331 = comb.concat %c0_i7, %181 : i7, i8
    %332 = comb.mul bin %331, %c93_i15 : i15
    %333 = comb.concat %false, %332 : i1, i15
    %334 = comb.concat %c0_i6, %183 : i6, i8
    %335 = comb.mul bin %334, %c56_i14 : i14
    %336 = comb.concat %c0_i2, %335 : i2, i14
    %337 = comb.concat %c0_i5, %185 : i5, i8
    %338 = comb.mul bin %337, %c19_i13 : i13
    %339 = comb.concat %c0_i3, %338 : i3, i13
    %340 = comb.concat %c0_i8, %187 : i8, i8
    %341 = comb.mul bin %340, %c233_i16 : i16
    %342 = comb.concat %c0_i8, %189 : i8, i8
    %343 = comb.mul bin %342, %c196_i16 : i16
    %344 = comb.concat %c0_i8, %191 : i8, i8
    %345 = comb.mul bin %344, %c159_i16 : i16
    %346 = comb.concat %c0_i7, %193 : i7, i8
    %347 = comb.mul bin %346, %c122_i15 : i15
    %348 = comb.concat %false, %347 : i1, i15
    %349 = comb.concat %c0_i7, %195 : i7, i8
    %350 = comb.mul bin %349, %c85_i15 : i15
    %351 = comb.concat %false, %350 : i1, i15
    %352 = comb.concat %c0_i6, %197 : i6, i8
    %353 = comb.mul bin %352, %c48_i14 : i14
    %354 = comb.concat %false, %353 : i1, i14
    %355 = comb.concat %c0_i4, %199 : i4, i8
    %356 = comb.mul bin %355, %c11_i12 : i12
    %357 = comb.concat %c0_i3, %356 : i3, i12
    %358 = comb.add bin %357, %354 : i15
    %359 = comb.concat %false, %358 : i1, i15
    %360 = comb.add bin %359, %351, %348, %345, %343, %341, %339, %336, %333, %330, %328, %326, %324, %322, %319, %318, %315, %313, %311, %309, %307, %304, %301, %298, %296, %294, %292, %289, %286, %283, %280, %278, %276, %274, %271, %268, %265, %262, %260, %258, %256, %253, %250, %247, %245, %243, %241, %239, %236, %233, %230, %228, %226, %224, %223, %220, %217, %214, %212, %210, %208, %205, %202 : i16
    %361 = arc.storage.get %arg0[92] : !arc.storage -> !arc.state<i16>
    arc.state_write %361 = %360 : <i16>
  }
}
