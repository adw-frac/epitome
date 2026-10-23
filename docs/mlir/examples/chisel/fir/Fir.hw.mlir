module {
  sv.macro.decl @layer$Verification$Assert$Temporal
  sv.macro.decl @layer$Verification$Assume$Temporal
  sv.macro.decl @layer$Verification$Cover$Temporal
  hw.module @Fir(in %clock : !seq.clock, in %reset : i1, in %io_in : i8, in %io_valid : i1, out io_out : i16) {
    %c0_i5 = hw.constant 0 : i5
    %c3_i10 = hw.constant 3 : i10
    %c0_i3 = hw.constant 0 : i3
    %c0_i2 = hw.constant 0 : i2
    %false = hw.constant false
    %c0_i8 = hw.constant 0 : i8
    %taps_1 = seq.firreg %0 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 0 : ui64} : i8
    %taps_2 = seq.firreg %1 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 8 : ui64} : i8
    %taps_3 = seq.firreg %2 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 16 : ui64} : i8
    %0 = comb.mux bin %io_valid, %io_in, %taps_1 : i8
    %1 = comb.mux bin %io_valid, %taps_1, %taps_2 : i8
    %2 = comb.mux bin %io_valid, %taps_2, %taps_3 : i8
    %3 = comb.concat %c0_i2, %taps_1 : i2, i8
    %4 = comb.mul bin %3, %c3_i10 {sv.namehint = "products_1"} : i10
    %5 = comb.concat %c0_i2, %taps_2 : i2, i8
    %6 = comb.mul bin %5, %c3_i10 {sv.namehint = "products_2"} : i10
    %7 = comb.concat %c0_i3, %io_in : i3, i8
    %8 = comb.concat %false, %4 : i1, i10
    %9 = comb.add bin %7, %8 {sv.namehint = "_io_out_T"} : i11
    %10 = comb.concat %false, %9 : i1, i11
    %11 = comb.concat %c0_i2, %6 : i2, i10
    %12 = comb.add bin %10, %11 {sv.namehint = "_io_out_T_1"} : i12
    %13 = comb.concat %false, %12 : i1, i12
    %14 = comb.concat %c0_i5, %taps_3 : i5, i8
    %15 = comb.add bin %13, %14 {sv.namehint = "_io_out_T_2"} : i13
    %16 = comb.concat %c0_i3, %15 {sv.namehint = "io_out"} : i3, i13
    hw.output %16 : i16
  }
  sv.macro.decl @layers_Fir_Verification["layers_Fir_Verification"]
  emit.file "verification/layers-Fir-Verification.sv" {
    sv.ifdef @layers_Fir_Verification {
    } else {
      sv.macro.def @layers_Fir_Verification ""
    }
  }
  sv.macro.decl @layers_Fir_Verification_Assert["layers_Fir_Verification_Assert"]
  emit.file "verification/assert/layers-Fir-Verification-Assert.sv" {
    sv.ifdef @layers_Fir_Verification_Assert {
    } else {
      sv.macro.def @layers_Fir_Verification_Assert ""
      sv.include local "layers-Fir-Verification.sv"
    }
  }
  sv.macro.decl @layers_Fir_Verification_Assume["layers_Fir_Verification_Assume"]
  emit.file "verification/assume/layers-Fir-Verification-Assume.sv" {
    sv.ifdef @layers_Fir_Verification_Assume {
    } else {
      sv.macro.def @layers_Fir_Verification_Assume ""
      sv.include local "layers-Fir-Verification.sv"
    }
  }
  sv.macro.decl @layers_Fir_Verification_Cover["layers_Fir_Verification_Cover"]
  emit.file "verification/cover/layers-Fir-Verification-Cover.sv" {
    sv.ifdef @layers_Fir_Verification_Cover {
    } else {
      sv.macro.def @layers_Fir_Verification_Cover ""
      sv.include local "layers-Fir-Verification.sv"
    }
  }
  om.class @Fir_Class(%basepath: !om.basepath) {
    om.class.fields 
  }
}
