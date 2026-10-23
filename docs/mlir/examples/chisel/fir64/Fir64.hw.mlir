module {
  sv.macro.decl @layer$Verification$Assert$Temporal
  sv.macro.decl @layer$Verification$Assume$Temporal
  sv.macro.decl @layer$Verification$Cover$Temporal
  hw.module @Fir64(in %clock : !seq.clock, in %reset : i1, in %io_in : i8, in %io_valid : i1, out io_out : i16) {
    %c0_i2 = hw.constant 0 : i2
    %c83_i15 = hw.constant 83 : i15
    %c46_i14 = hw.constant 46 : i14
    %c9_i12 = hw.constant 9 : i12
    %c223_i16 = hw.constant 223 : i16
    %c186_i16 = hw.constant 186 : i16
    %c149_i16 = hw.constant 149 : i16
    %c112_i15 = hw.constant 112 : i15
    %c75_i15 = hw.constant 75 : i15
    %c38_i14 = hw.constant 38 : i14
    %c215_i16 = hw.constant 215 : i16
    %c178_i16 = hw.constant 178 : i16
    %c141_i16 = hw.constant 141 : i16
    %c104_i15 = hw.constant 104 : i15
    %c67_i15 = hw.constant 67 : i15
    %c30_i13 = hw.constant 30 : i13
    %c244_i16 = hw.constant 244 : i16
    %c207_i16 = hw.constant 207 : i16
    %c170_i16 = hw.constant 170 : i16
    %c133_i16 = hw.constant 133 : i16
    %c96_i15 = hw.constant 96 : i15
    %c59_i14 = hw.constant 59 : i14
    %c22_i13 = hw.constant 22 : i13
    %c236_i16 = hw.constant 236 : i16
    %c199_i16 = hw.constant 199 : i16
    %c162_i16 = hw.constant 162 : i16
    %c125_i15 = hw.constant 125 : i15
    %c88_i15 = hw.constant 88 : i15
    %c51_i14 = hw.constant 51 : i14
    %c14_i12 = hw.constant 14 : i12
    %c228_i16 = hw.constant 228 : i16
    %c191_i16 = hw.constant 191 : i16
    %c154_i16 = hw.constant 154 : i16
    %c117_i15 = hw.constant 117 : i15
    %c80_i15 = hw.constant 80 : i15
    %c43_i14 = hw.constant 43 : i14
    %c6_i11 = hw.constant 6 : i11
    %c220_i16 = hw.constant 220 : i16
    %c183_i16 = hw.constant 183 : i16
    %c146_i16 = hw.constant 146 : i16
    %c109_i15 = hw.constant 109 : i15
    %c72_i15 = hw.constant 72 : i15
    %c35_i14 = hw.constant 35 : i14
    %c249_i16 = hw.constant 249 : i16
    %c212_i16 = hw.constant 212 : i16
    %c175_i16 = hw.constant 175 : i16
    %c138_i16 = hw.constant 138 : i16
    %c101_i15 = hw.constant 101 : i15
    %c27_i13 = hw.constant 27 : i13
    %c241_i16 = hw.constant 241 : i16
    %c204_i16 = hw.constant 204 : i16
    %c167_i16 = hw.constant 167 : i16
    %c130_i16 = hw.constant 130 : i16
    %c93_i15 = hw.constant 93 : i15
    %c56_i14 = hw.constant 56 : i14
    %c19_i13 = hw.constant 19 : i13
    %c233_i16 = hw.constant 233 : i16
    %c196_i16 = hw.constant 196 : i16
    %c159_i16 = hw.constant 159 : i16
    %c122_i15 = hw.constant 122 : i15
    %c85_i15 = hw.constant 85 : i15
    %c48_i14 = hw.constant 48 : i14
    %c11_i12 = hw.constant 11 : i12
    %false = hw.constant false
    %c0_i3 = hw.constant 0 : i3
    %c0_i5 = hw.constant 0 : i5
    %c0_i7 = hw.constant 0 : i7
    %c0_i6 = hw.constant 0 : i6
    %c0_i4 = hw.constant 0 : i4
    %c0_i8 = hw.constant 0 : i8
    %taps_1 = seq.firreg %0 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 0 : ui64} : i8
    %taps_2 = seq.firreg %1 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 8 : ui64} : i8
    %taps_3 = seq.firreg %2 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 16 : ui64} : i8
    %taps_4 = seq.firreg %3 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 24 : ui64} : i8
    %taps_5 = seq.firreg %4 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 32 : ui64} : i8
    %taps_6 = seq.firreg %5 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 40 : ui64} : i8
    %taps_7 = seq.firreg %6 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 48 : ui64} : i8
    %taps_8 = seq.firreg %7 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 56 : ui64} : i8
    %taps_9 = seq.firreg %8 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 64 : ui64} : i8
    %taps_10 = seq.firreg %9 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 72 : ui64} : i8
    %taps_11 = seq.firreg %10 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 80 : ui64} : i8
    %taps_12 = seq.firreg %11 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 88 : ui64} : i8
    %taps_13 = seq.firreg %12 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 96 : ui64} : i8
    %taps_14 = seq.firreg %13 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 104 : ui64} : i8
    %taps_15 = seq.firreg %14 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 112 : ui64} : i8
    %taps_16 = seq.firreg %15 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 120 : ui64} : i8
    %taps_17 = seq.firreg %16 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 128 : ui64} : i8
    %taps_18 = seq.firreg %17 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 136 : ui64} : i8
    %taps_19 = seq.firreg %18 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 144 : ui64} : i8
    %taps_20 = seq.firreg %19 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 152 : ui64} : i8
    %taps_21 = seq.firreg %20 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 160 : ui64} : i8
    %taps_22 = seq.firreg %21 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 168 : ui64} : i8
    %taps_23 = seq.firreg %22 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 176 : ui64} : i8
    %taps_24 = seq.firreg %23 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 184 : ui64} : i8
    %taps_25 = seq.firreg %24 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 192 : ui64} : i8
    %taps_26 = seq.firreg %25 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 200 : ui64} : i8
    %taps_27 = seq.firreg %26 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 208 : ui64} : i8
    %taps_28 = seq.firreg %27 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 216 : ui64} : i8
    %taps_29 = seq.firreg %28 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 224 : ui64} : i8
    %taps_30 = seq.firreg %29 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 232 : ui64} : i8
    %taps_31 = seq.firreg %30 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 240 : ui64} : i8
    %taps_32 = seq.firreg %31 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 248 : ui64} : i8
    %taps_33 = seq.firreg %32 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 256 : ui64} : i8
    %taps_34 = seq.firreg %33 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 264 : ui64} : i8
    %taps_35 = seq.firreg %34 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 272 : ui64} : i8
    %taps_36 = seq.firreg %35 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 280 : ui64} : i8
    %taps_37 = seq.firreg %36 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 288 : ui64} : i8
    %taps_38 = seq.firreg %37 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 296 : ui64} : i8
    %taps_39 = seq.firreg %38 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 304 : ui64} : i8
    %taps_40 = seq.firreg %39 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 312 : ui64} : i8
    %taps_41 = seq.firreg %40 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 320 : ui64} : i8
    %taps_42 = seq.firreg %41 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 328 : ui64} : i8
    %taps_43 = seq.firreg %42 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 336 : ui64} : i8
    %taps_44 = seq.firreg %43 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 344 : ui64} : i8
    %taps_45 = seq.firreg %44 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 352 : ui64} : i8
    %taps_46 = seq.firreg %45 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 360 : ui64} : i8
    %taps_47 = seq.firreg %46 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 368 : ui64} : i8
    %taps_48 = seq.firreg %47 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 376 : ui64} : i8
    %taps_49 = seq.firreg %48 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 384 : ui64} : i8
    %taps_50 = seq.firreg %49 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 392 : ui64} : i8
    %taps_51 = seq.firreg %50 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 400 : ui64} : i8
    %taps_52 = seq.firreg %51 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 408 : ui64} : i8
    %taps_53 = seq.firreg %52 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 416 : ui64} : i8
    %taps_54 = seq.firreg %53 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 424 : ui64} : i8
    %taps_55 = seq.firreg %54 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 432 : ui64} : i8
    %taps_56 = seq.firreg %55 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 440 : ui64} : i8
    %taps_57 = seq.firreg %56 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 448 : ui64} : i8
    %taps_58 = seq.firreg %57 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 456 : ui64} : i8
    %taps_59 = seq.firreg %58 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 464 : ui64} : i8
    %taps_60 = seq.firreg %59 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 472 : ui64} : i8
    %taps_61 = seq.firreg %60 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 480 : ui64} : i8
    %taps_62 = seq.firreg %61 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 488 : ui64} : i8
    %taps_63 = seq.firreg %62 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 496 : ui64} : i8
    %0 = comb.mux bin %io_valid, %io_in, %taps_1 : i8
    %1 = comb.mux bin %io_valid, %taps_1, %taps_2 : i8
    %2 = comb.mux bin %io_valid, %taps_2, %taps_3 : i8
    %3 = comb.mux bin %io_valid, %taps_3, %taps_4 : i8
    %4 = comb.mux bin %io_valid, %taps_4, %taps_5 : i8
    %5 = comb.mux bin %io_valid, %taps_5, %taps_6 : i8
    %6 = comb.mux bin %io_valid, %taps_6, %taps_7 : i8
    %7 = comb.mux bin %io_valid, %taps_7, %taps_8 : i8
    %8 = comb.mux bin %io_valid, %taps_8, %taps_9 : i8
    %9 = comb.mux bin %io_valid, %taps_9, %taps_10 : i8
    %10 = comb.mux bin %io_valid, %taps_10, %taps_11 : i8
    %11 = comb.mux bin %io_valid, %taps_11, %taps_12 : i8
    %12 = comb.mux bin %io_valid, %taps_12, %taps_13 : i8
    %13 = comb.mux bin %io_valid, %taps_13, %taps_14 : i8
    %14 = comb.mux bin %io_valid, %taps_14, %taps_15 : i8
    %15 = comb.mux bin %io_valid, %taps_15, %taps_16 : i8
    %16 = comb.mux bin %io_valid, %taps_16, %taps_17 : i8
    %17 = comb.mux bin %io_valid, %taps_17, %taps_18 : i8
    %18 = comb.mux bin %io_valid, %taps_18, %taps_19 : i8
    %19 = comb.mux bin %io_valid, %taps_19, %taps_20 : i8
    %20 = comb.mux bin %io_valid, %taps_20, %taps_21 : i8
    %21 = comb.mux bin %io_valid, %taps_21, %taps_22 : i8
    %22 = comb.mux bin %io_valid, %taps_22, %taps_23 : i8
    %23 = comb.mux bin %io_valid, %taps_23, %taps_24 : i8
    %24 = comb.mux bin %io_valid, %taps_24, %taps_25 : i8
    %25 = comb.mux bin %io_valid, %taps_25, %taps_26 : i8
    %26 = comb.mux bin %io_valid, %taps_26, %taps_27 : i8
    %27 = comb.mux bin %io_valid, %taps_27, %taps_28 : i8
    %28 = comb.mux bin %io_valid, %taps_28, %taps_29 : i8
    %29 = comb.mux bin %io_valid, %taps_29, %taps_30 : i8
    %30 = comb.mux bin %io_valid, %taps_30, %taps_31 : i8
    %31 = comb.mux bin %io_valid, %taps_31, %taps_32 : i8
    %32 = comb.mux bin %io_valid, %taps_32, %taps_33 : i8
    %33 = comb.mux bin %io_valid, %taps_33, %taps_34 : i8
    %34 = comb.mux bin %io_valid, %taps_34, %taps_35 : i8
    %35 = comb.mux bin %io_valid, %taps_35, %taps_36 : i8
    %36 = comb.mux bin %io_valid, %taps_36, %taps_37 : i8
    %37 = comb.mux bin %io_valid, %taps_37, %taps_38 : i8
    %38 = comb.mux bin %io_valid, %taps_38, %taps_39 : i8
    %39 = comb.mux bin %io_valid, %taps_39, %taps_40 : i8
    %40 = comb.mux bin %io_valid, %taps_40, %taps_41 : i8
    %41 = comb.mux bin %io_valid, %taps_41, %taps_42 : i8
    %42 = comb.mux bin %io_valid, %taps_42, %taps_43 : i8
    %43 = comb.mux bin %io_valid, %taps_43, %taps_44 : i8
    %44 = comb.mux bin %io_valid, %taps_44, %taps_45 : i8
    %45 = comb.mux bin %io_valid, %taps_45, %taps_46 : i8
    %46 = comb.mux bin %io_valid, %taps_46, %taps_47 : i8
    %47 = comb.mux bin %io_valid, %taps_47, %taps_48 : i8
    %48 = comb.mux bin %io_valid, %taps_48, %taps_49 : i8
    %49 = comb.mux bin %io_valid, %taps_49, %taps_50 : i8
    %50 = comb.mux bin %io_valid, %taps_50, %taps_51 : i8
    %51 = comb.mux bin %io_valid, %taps_51, %taps_52 : i8
    %52 = comb.mux bin %io_valid, %taps_52, %taps_53 : i8
    %53 = comb.mux bin %io_valid, %taps_53, %taps_54 : i8
    %54 = comb.mux bin %io_valid, %taps_54, %taps_55 : i8
    %55 = comb.mux bin %io_valid, %taps_55, %taps_56 : i8
    %56 = comb.mux bin %io_valid, %taps_56, %taps_57 : i8
    %57 = comb.mux bin %io_valid, %taps_57, %taps_58 : i8
    %58 = comb.mux bin %io_valid, %taps_58, %taps_59 : i8
    %59 = comb.mux bin %io_valid, %taps_59, %taps_60 : i8
    %60 = comb.mux bin %io_valid, %taps_60, %taps_61 : i8
    %61 = comb.mux bin %io_valid, %taps_61, %taps_62 : i8
    %62 = comb.mux bin %io_valid, %taps_62, %taps_63 : i8
    %63 = comb.concat %c0_i4, %io_in : i4, i8
    %64 = comb.mul bin %63, %c11_i12 {sv.namehint = "products_0"} : i12
    %65 = comb.concat %c0_i6, %taps_1 : i6, i8
    %66 = comb.mul bin %65, %c48_i14 {sv.namehint = "products_1"} : i14
    %67 = comb.concat %c0_i7, %taps_2 : i7, i8
    %68 = comb.mul bin %67, %c85_i15 {sv.namehint = "products_2"} : i15
    %69 = comb.concat %c0_i7, %taps_3 : i7, i8
    %70 = comb.mul bin %69, %c122_i15 {sv.namehint = "products_3"} : i15
    %71 = comb.concat %c0_i8, %taps_4 : i8, i8
    %72 = comb.mul bin %71, %c159_i16 {sv.namehint = "products_4"} : i16
    %73 = comb.concat %c0_i8, %taps_5 : i8, i8
    %74 = comb.mul bin %73, %c196_i16 {sv.namehint = "products_5"} : i16
    %75 = comb.concat %c0_i8, %taps_6 : i8, i8
    %76 = comb.mul bin %75, %c233_i16 {sv.namehint = "products_6"} : i16
    %77 = comb.concat %c0_i5, %taps_7 : i5, i8
    %78 = comb.mul bin %77, %c19_i13 {sv.namehint = "products_7"} : i13
    %79 = comb.concat %c0_i6, %taps_8 : i6, i8
    %80 = comb.mul bin %79, %c56_i14 {sv.namehint = "products_8"} : i14
    %81 = comb.concat %c0_i7, %taps_9 : i7, i8
    %82 = comb.mul bin %81, %c93_i15 {sv.namehint = "products_9"} : i15
    %83 = comb.concat %c0_i8, %taps_10 : i8, i8
    %84 = comb.mul bin %83, %c130_i16 {sv.namehint = "products_10"} : i16
    %85 = comb.concat %c0_i8, %taps_11 : i8, i8
    %86 = comb.mul bin %85, %c167_i16 {sv.namehint = "products_11"} : i16
    %87 = comb.concat %c0_i8, %taps_12 : i8, i8
    %88 = comb.mul bin %87, %c204_i16 {sv.namehint = "products_12"} : i16
    %89 = comb.concat %c0_i8, %taps_13 : i8, i8
    %90 = comb.mul bin %89, %c241_i16 {sv.namehint = "products_13"} : i16
    %91 = comb.concat %c0_i5, %taps_14 : i5, i8
    %92 = comb.mul bin %91, %c27_i13 {sv.namehint = "products_14"} : i13
    %93 = comb.concat %c0_i7, %taps_16 : i7, i8
    %94 = comb.mul bin %93, %c101_i15 {sv.namehint = "products_16"} : i15
    %95 = comb.concat %c0_i8, %taps_17 : i8, i8
    %96 = comb.mul bin %95, %c138_i16 {sv.namehint = "products_17"} : i16
    %97 = comb.concat %c0_i8, %taps_18 : i8, i8
    %98 = comb.mul bin %97, %c175_i16 {sv.namehint = "products_18"} : i16
    %99 = comb.concat %c0_i8, %taps_19 : i8, i8
    %100 = comb.mul bin %99, %c212_i16 {sv.namehint = "products_19"} : i16
    %101 = comb.concat %c0_i8, %taps_20 : i8, i8
    %102 = comb.mul bin %101, %c249_i16 {sv.namehint = "products_20"} : i16
    %103 = comb.concat %c0_i6, %taps_21 : i6, i8
    %104 = comb.mul bin %103, %c35_i14 {sv.namehint = "products_21"} : i14
    %105 = comb.concat %c0_i7, %taps_22 : i7, i8
    %106 = comb.mul bin %105, %c72_i15 {sv.namehint = "products_22"} : i15
    %107 = comb.concat %c0_i7, %taps_23 : i7, i8
    %108 = comb.mul bin %107, %c109_i15 {sv.namehint = "products_23"} : i15
    %109 = comb.concat %c0_i8, %taps_24 : i8, i8
    %110 = comb.mul bin %109, %c146_i16 {sv.namehint = "products_24"} : i16
    %111 = comb.concat %c0_i8, %taps_25 : i8, i8
    %112 = comb.mul bin %111, %c183_i16 {sv.namehint = "products_25"} : i16
    %113 = comb.concat %c0_i8, %taps_26 : i8, i8
    %114 = comb.mul bin %113, %c220_i16 {sv.namehint = "products_26"} : i16
    %115 = comb.concat %c0_i3, %taps_27 : i3, i8
    %116 = comb.mul bin %115, %c6_i11 {sv.namehint = "products_27"} : i11
    %117 = comb.concat %c0_i6, %taps_28 : i6, i8
    %118 = comb.mul bin %117, %c43_i14 {sv.namehint = "products_28"} : i14
    %119 = comb.concat %c0_i7, %taps_29 : i7, i8
    %120 = comb.mul bin %119, %c80_i15 {sv.namehint = "products_29"} : i15
    %121 = comb.concat %c0_i7, %taps_30 : i7, i8
    %122 = comb.mul bin %121, %c117_i15 {sv.namehint = "products_30"} : i15
    %123 = comb.concat %c0_i8, %taps_31 : i8, i8
    %124 = comb.mul bin %123, %c154_i16 {sv.namehint = "products_31"} : i16
    %125 = comb.concat %c0_i8, %taps_32 : i8, i8
    %126 = comb.mul bin %125, %c191_i16 {sv.namehint = "products_32"} : i16
    %127 = comb.concat %c0_i8, %taps_33 : i8, i8
    %128 = comb.mul bin %127, %c228_i16 {sv.namehint = "products_33"} : i16
    %129 = comb.concat %c0_i4, %taps_34 : i4, i8
    %130 = comb.mul bin %129, %c14_i12 {sv.namehint = "products_34"} : i12
    %131 = comb.concat %c0_i6, %taps_35 : i6, i8
    %132 = comb.mul bin %131, %c51_i14 {sv.namehint = "products_35"} : i14
    %133 = comb.concat %c0_i7, %taps_36 : i7, i8
    %134 = comb.mul bin %133, %c88_i15 {sv.namehint = "products_36"} : i15
    %135 = comb.concat %c0_i7, %taps_37 : i7, i8
    %136 = comb.mul bin %135, %c125_i15 {sv.namehint = "products_37"} : i15
    %137 = comb.concat %c0_i8, %taps_38 : i8, i8
    %138 = comb.mul bin %137, %c162_i16 {sv.namehint = "products_38"} : i16
    %139 = comb.concat %c0_i8, %taps_39 : i8, i8
    %140 = comb.mul bin %139, %c199_i16 {sv.namehint = "products_39"} : i16
    %141 = comb.concat %c0_i8, %taps_40 : i8, i8
    %142 = comb.mul bin %141, %c236_i16 {sv.namehint = "products_40"} : i16
    %143 = comb.concat %c0_i5, %taps_41 : i5, i8
    %144 = comb.mul bin %143, %c22_i13 {sv.namehint = "products_41"} : i13
    %145 = comb.concat %c0_i6, %taps_42 : i6, i8
    %146 = comb.mul bin %145, %c59_i14 {sv.namehint = "products_42"} : i14
    %147 = comb.concat %c0_i7, %taps_43 : i7, i8
    %148 = comb.mul bin %147, %c96_i15 {sv.namehint = "products_43"} : i15
    %149 = comb.concat %c0_i8, %taps_44 : i8, i8
    %150 = comb.mul bin %149, %c133_i16 {sv.namehint = "products_44"} : i16
    %151 = comb.concat %c0_i8, %taps_45 : i8, i8
    %152 = comb.mul bin %151, %c170_i16 {sv.namehint = "products_45"} : i16
    %153 = comb.concat %c0_i8, %taps_46 : i8, i8
    %154 = comb.mul bin %153, %c207_i16 {sv.namehint = "products_46"} : i16
    %155 = comb.concat %c0_i8, %taps_47 : i8, i8
    %156 = comb.mul bin %155, %c244_i16 {sv.namehint = "products_47"} : i16
    %157 = comb.concat %c0_i5, %taps_48 : i5, i8
    %158 = comb.mul bin %157, %c30_i13 {sv.namehint = "products_48"} : i13
    %159 = comb.concat %c0_i7, %taps_49 : i7, i8
    %160 = comb.mul bin %159, %c67_i15 {sv.namehint = "products_49"} : i15
    %161 = comb.concat %c0_i7, %taps_50 : i7, i8
    %162 = comb.mul bin %161, %c104_i15 {sv.namehint = "products_50"} : i15
    %163 = comb.concat %c0_i8, %taps_51 : i8, i8
    %164 = comb.mul bin %163, %c141_i16 {sv.namehint = "products_51"} : i16
    %165 = comb.concat %c0_i8, %taps_52 : i8, i8
    %166 = comb.mul bin %165, %c178_i16 {sv.namehint = "products_52"} : i16
    %167 = comb.concat %c0_i8, %taps_53 : i8, i8
    %168 = comb.mul bin %167, %c215_i16 {sv.namehint = "products_53"} : i16
    %169 = comb.concat %c0_i6, %taps_55 : i6, i8
    %170 = comb.mul bin %169, %c38_i14 {sv.namehint = "products_55"} : i14
    %171 = comb.concat %c0_i7, %taps_56 : i7, i8
    %172 = comb.mul bin %171, %c75_i15 {sv.namehint = "products_56"} : i15
    %173 = comb.concat %c0_i7, %taps_57 : i7, i8
    %174 = comb.mul bin %173, %c112_i15 {sv.namehint = "products_57"} : i15
    %175 = comb.concat %c0_i8, %taps_58 : i8, i8
    %176 = comb.mul bin %175, %c149_i16 {sv.namehint = "products_58"} : i16
    %177 = comb.concat %c0_i8, %taps_59 : i8, i8
    %178 = comb.mul bin %177, %c186_i16 {sv.namehint = "products_59"} : i16
    %179 = comb.concat %c0_i8, %taps_60 : i8, i8
    %180 = comb.mul bin %179, %c223_i16 {sv.namehint = "products_60"} : i16
    %181 = comb.concat %c0_i4, %taps_61 : i4, i8
    %182 = comb.mul bin %181, %c9_i12 {sv.namehint = "products_61"} : i12
    %183 = comb.concat %c0_i6, %taps_62 : i6, i8
    %184 = comb.mul bin %183, %c46_i14 {sv.namehint = "products_62"} : i14
    %185 = comb.concat %c0_i7, %taps_63 : i7, i8
    %186 = comb.mul bin %185, %c83_i15 {sv.namehint = "products_63"} : i15
    %187 = comb.concat %c0_i3, %64 : i3, i12
    %188 = comb.concat %false, %66 : i1, i14
    %189 = comb.add bin %187, %188 {sv.namehint = "_io_out_T"} : i15
    %190 = comb.concat %false, %189 : i1, i15
    %191 = comb.concat %false, %68 : i1, i15
    %192 = comb.concat %false, %70 : i1, i15
    %193 = comb.concat %c0_i3, %78 : i3, i13
    %194 = comb.concat %c0_i2, %80 : i2, i14
    %195 = comb.concat %false, %82 : i1, i15
    %196 = comb.concat %c0_i3, %92 : i3, i13
    %197 = comb.concat %c0_i2, %taps_15, %c0_i6 : i2, i8, i6
    %198 = comb.concat %false, %94 : i1, i15
    %199 = comb.concat %c0_i2, %104 : i2, i14
    %200 = comb.concat %false, %106 : i1, i15
    %201 = comb.concat %false, %108 : i1, i15
    %202 = comb.concat %c0_i5, %116 : i5, i11
    %203 = comb.concat %c0_i2, %118 : i2, i14
    %204 = comb.concat %false, %120 : i1, i15
    %205 = comb.concat %false, %122 : i1, i15
    %206 = comb.concat %c0_i4, %130 : i4, i12
    %207 = comb.concat %c0_i2, %132 : i2, i14
    %208 = comb.concat %false, %134 : i1, i15
    %209 = comb.concat %false, %136 : i1, i15
    %210 = comb.concat %c0_i3, %144 : i3, i13
    %211 = comb.concat %c0_i2, %146 : i2, i14
    %212 = comb.concat %false, %148 : i1, i15
    %213 = comb.concat %c0_i3, %158 : i3, i13
    %214 = comb.concat %false, %160 : i1, i15
    %215 = comb.concat %false, %162 : i1, i15
    %216 = comb.concat %c0_i8, %taps_54 : i8, i8
    %217 = comb.concat %c0_i2, %170 : i2, i14
    %218 = comb.concat %false, %172 : i1, i15
    %219 = comb.concat %false, %174 : i1, i15
    %220 = comb.concat %c0_i4, %182 : i4, i12
    %221 = comb.concat %c0_i2, %184 : i2, i14
    %222 = comb.concat %false, %186 : i1, i15
    %223 = comb.add bin %190, %191, %192, %72, %74, %76, %193, %194, %195, %84, %86, %88, %90, %196, %197, %198, %96, %98, %100, %102, %199, %200, %201, %110, %112, %114, %202, %203, %204, %205, %124, %126, %128, %206, %207, %208, %209, %138, %140, %142, %210, %211, %212, %150, %152, %154, %156, %213, %214, %215, %164, %166, %168, %216, %217, %218, %219, %176, %178, %180, %220, %221, %222 {sv.namehint = "_io_out_T_62"} : i16
    hw.output %223 : i16
  }
  sv.macro.decl @layers_Fir64_Verification["layers_Fir64_Verification"]
  emit.file "verification/layers-Fir64-Verification.sv" {
    sv.ifdef @layers_Fir64_Verification {
    } else {
      sv.macro.def @layers_Fir64_Verification ""
    }
  }
  sv.macro.decl @layers_Fir64_Verification_Assert["layers_Fir64_Verification_Assert"]
  emit.file "verification/assert/layers-Fir64-Verification-Assert.sv" {
    sv.ifdef @layers_Fir64_Verification_Assert {
    } else {
      sv.macro.def @layers_Fir64_Verification_Assert ""
      sv.include local "layers-Fir64-Verification.sv"
    }
  }
  sv.macro.decl @layers_Fir64_Verification_Assume["layers_Fir64_Verification_Assume"]
  emit.file "verification/assume/layers-Fir64-Verification-Assume.sv" {
    sv.ifdef @layers_Fir64_Verification_Assume {
    } else {
      sv.macro.def @layers_Fir64_Verification_Assume ""
      sv.include local "layers-Fir64-Verification.sv"
    }
  }
  sv.macro.decl @layers_Fir64_Verification_Cover["layers_Fir64_Verification_Cover"]
  emit.file "verification/cover/layers-Fir64-Verification-Cover.sv" {
    sv.ifdef @layers_Fir64_Verification_Cover {
    } else {
      sv.macro.def @layers_Fir64_Verification_Cover ""
      sv.include local "layers-Fir64-Verification.sv"
    }
  }
  om.class @Fir64_Class(%basepath: !om.basepath) {
    om.class.fields 
  }
}
