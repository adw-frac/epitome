module {
  sv.macro.decl @layer$Verification$Assert$Temporal
  sv.macro.decl @layer$Verification$Assume$Temporal
  sv.macro.decl @layer$Verification$Cover$Temporal
  hw.module @Counter(in %clock : !seq.clock, in %reset : i1, in %io_en : i1, out io_count : i8) {
    %c1_i8 = hw.constant 1 : i8
    %c0_i8 = hw.constant 0 : i8
    %reg = seq.firreg %1 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 0 : ui64, sv.namehint = "reg"} : i8
    %0 = comb.add bin %reg, %c1_i8 {sv.namehint = "_reg_T"} : i8
    %1 = comb.mux bin %io_en, %0, %reg : i8
    hw.output %reg : i8
  }
  sv.macro.decl @layers_Counter_Verification["layers_Counter_Verification"]
  emit.file "verification/layers-Counter-Verification.sv" {
    sv.ifdef @layers_Counter_Verification {
    } else {
      sv.macro.def @layers_Counter_Verification ""
    }
  }
  sv.macro.decl @layers_Counter_Verification_Assert["layers_Counter_Verification_Assert"]
  emit.file "verification/assert/layers-Counter-Verification-Assert.sv" {
    sv.ifdef @layers_Counter_Verification_Assert {
    } else {
      sv.macro.def @layers_Counter_Verification_Assert ""
      sv.include local "layers-Counter-Verification.sv"
    }
  }
  sv.macro.decl @layers_Counter_Verification_Assume["layers_Counter_Verification_Assume"]
  emit.file "verification/assume/layers-Counter-Verification-Assume.sv" {
    sv.ifdef @layers_Counter_Verification_Assume {
    } else {
      sv.macro.def @layers_Counter_Verification_Assume ""
      sv.include local "layers-Counter-Verification.sv"
    }
  }
  sv.macro.decl @layers_Counter_Verification_Cover["layers_Counter_Verification_Cover"]
  emit.file "verification/cover/layers-Counter-Verification-Cover.sv" {
    sv.ifdef @layers_Counter_Verification_Cover {
    } else {
      sv.macro.def @layers_Counter_Verification_Cover ""
      sv.include local "layers-Counter-Verification.sv"
    }
  }
  om.class @Counter_Class(%basepath: !om.basepath) {
    om.class.fields 
  }
}
