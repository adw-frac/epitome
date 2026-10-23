module {
  sv.macro.decl @layer$Verification$Assert$Temporal
  sv.macro.decl @layer$Verification$Assume$Temporal
  sv.macro.decl @layer$Verification$Cover$Temporal
  hw.module @Scratchpad(in %clock : !seq.clock, in %reset : i1, in %io_raddr : i4, out io_rdata : i32, in %io_wen : i1, in %io_waddr : i4, in %io_wdata : i32) {
    %mem = seq.firmem 1, 1, undefined, port_order : <16 x 32>
    seq.firmem.write_port %mem[%io_waddr] = %io_wdata, clock %clock enable %io_wen : <16 x 32>
    %0 = seq.firmem.read_port %mem[%io_raddr], clock %clock {sv.namehint = "io_rdata"} : <16 x 32>
    hw.output %0 : i32
  }
  sv.macro.decl @layers_Scratchpad_Verification["layers_Scratchpad_Verification"]
  emit.file "verification/layers-Scratchpad-Verification.sv" {
    sv.ifdef @layers_Scratchpad_Verification {
    } else {
      sv.macro.def @layers_Scratchpad_Verification ""
    }
  }
  sv.macro.decl @layers_Scratchpad_Verification_Assert["layers_Scratchpad_Verification_Assert"]
  emit.file "verification/assert/layers-Scratchpad-Verification-Assert.sv" {
    sv.ifdef @layers_Scratchpad_Verification_Assert {
    } else {
      sv.macro.def @layers_Scratchpad_Verification_Assert ""
      sv.include local "layers-Scratchpad-Verification.sv"
    }
  }
  sv.macro.decl @layers_Scratchpad_Verification_Assume["layers_Scratchpad_Verification_Assume"]
  emit.file "verification/assume/layers-Scratchpad-Verification-Assume.sv" {
    sv.ifdef @layers_Scratchpad_Verification_Assume {
    } else {
      sv.macro.def @layers_Scratchpad_Verification_Assume ""
      sv.include local "layers-Scratchpad-Verification.sv"
    }
  }
  sv.macro.decl @layers_Scratchpad_Verification_Cover["layers_Scratchpad_Verification_Cover"]
  emit.file "verification/cover/layers-Scratchpad-Verification-Cover.sv" {
    sv.ifdef @layers_Scratchpad_Verification_Cover {
    } else {
      sv.macro.def @layers_Scratchpad_Verification_Cover ""
      sv.include local "layers-Scratchpad-Verification.sv"
    }
  }
  om.class @Scratchpad_Class(%basepath: !om.basepath) {
    om.class.fields 
  }
}
