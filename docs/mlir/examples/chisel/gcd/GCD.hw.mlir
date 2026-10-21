module {
  sv.macro.decl @layer$Verification$Assert$Temporal
  sv.macro.decl @layer$Verification$Assume$Temporal
  sv.macro.decl @layer$Verification$Cover$Temporal
  hw.module @GCD(in %clock : !seq.clock, in %reset : i1, in %io_value1 : i16, in %io_value2 : i16, in %io_loadingValues : i1, out io_outputGCD : i16, out io_outputValid : i1) {
    %c0_i16 = hw.constant 0 : i16
    %x = seq.firreg %5 clock %clock {firrtl.random_init_start = 0 : ui64, sv.namehint = "x"} : i16
    %y = seq.firreg %6 clock %clock {firrtl.random_init_start = 16 : ui64} : i16
    %0 = comb.icmp bin ugt %x, %y : i16
    %1 = comb.sub bin %x, %y {sv.namehint = "_x_T"} : i16
    %2 = comb.mux bin %0, %1, %x : i16
    %3 = comb.sub bin %y, %x {sv.namehint = "_y_T"} : i16
    %4 = comb.mux bin %0, %y, %3 : i16
    %5 = comb.mux bin %io_loadingValues, %io_value1, %2 : i16
    %6 = comb.mux bin %io_loadingValues, %io_value2, %4 : i16
    %7 = comb.icmp bin eq %y, %c0_i16 {sv.namehint = "io_outputValid"} : i16
    hw.output %x, %7 : i16, i1
  }
  sv.macro.decl @layers_GCD_Verification["layers_GCD_Verification"]
  emit.file "verification/layers-GCD-Verification.sv" {
    sv.ifdef @layers_GCD_Verification {
    } else {
      sv.macro.def @layers_GCD_Verification ""
    }
  }
  sv.macro.decl @layers_GCD_Verification_Assert["layers_GCD_Verification_Assert"]
  emit.file "verification/assert/layers-GCD-Verification-Assert.sv" {
    sv.ifdef @layers_GCD_Verification_Assert {
    } else {
      sv.macro.def @layers_GCD_Verification_Assert ""
      sv.include local "layers-GCD-Verification.sv"
    }
  }
  sv.macro.decl @layers_GCD_Verification_Assume["layers_GCD_Verification_Assume"]
  emit.file "verification/assume/layers-GCD-Verification-Assume.sv" {
    sv.ifdef @layers_GCD_Verification_Assume {
    } else {
      sv.macro.def @layers_GCD_Verification_Assume ""
      sv.include local "layers-GCD-Verification.sv"
    }
  }
  sv.macro.decl @layers_GCD_Verification_Cover["layers_GCD_Verification_Cover"]
  emit.file "verification/cover/layers-GCD-Verification-Cover.sv" {
    sv.ifdef @layers_GCD_Verification_Cover {
    } else {
      sv.macro.def @layers_GCD_Verification_Cover ""
      sv.include local "layers-GCD-Verification.sv"
    }
  }
  om.class @GCD_Class(%basepath: !om.basepath) {
    om.class.fields 
  }
}
