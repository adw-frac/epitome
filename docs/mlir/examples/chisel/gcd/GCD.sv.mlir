module {
  sv.macro.decl @SYNTHESIS
  sv.macro.decl @VERILATOR
  emit.fragment @RANDOM_INIT_FRAGMENT {
    sv.verbatim "// Standard header to adapt well known macros for register randomization."
    sv.verbatim "\0A// RANDOM may be set to an expression that produces a 32-bit random unsigned value."
    sv.ifdef @RANDOM {
    } else {
      sv.macro.def @RANDOM "$random"
    }
    sv.verbatim "\0A// Users can define INIT_RANDOM as general code that gets injected into the\0A// initializer block for modules with registers."
    sv.ifdef @INIT_RANDOM {
    } else {
      sv.macro.def @INIT_RANDOM ""
    }
    sv.verbatim "\0A// If using random initialization, you can also define RANDOMIZE_DELAY to\0A// customize the delay used, otherwise 0.002 is used."
    sv.ifdef @RANDOMIZE_DELAY {
    } else {
      sv.macro.def @RANDOMIZE_DELAY "0.002"
    }
    sv.verbatim "\0A// Define INIT_RANDOM_PROLOG_ for use in our modules below."
    sv.ifdef @INIT_RANDOM_PROLOG_ {
    } else {
      sv.ifdef @RANDOMIZE {
        sv.ifdef @VERILATOR {
          sv.macro.def @INIT_RANDOM_PROLOG_ "`INIT_RANDOM"
        } else {
          sv.macro.def @INIT_RANDOM_PROLOG_ "`INIT_RANDOM #`RANDOMIZE_DELAY begin end"
        }
      } else {
        sv.macro.def @INIT_RANDOM_PROLOG_ ""
      }
    }
  }
  emit.fragment @RANDOM_INIT_REG_FRAGMENT {
    sv.verbatim "\0A// Include register initializers in init blocks unless synthesis is set"
    sv.ifdef @RANDOMIZE {
    } else {
      sv.ifdef @RANDOMIZE_REG_INIT {
        sv.macro.def @RANDOMIZE ""
      }
    }
    sv.ifdef @SYNTHESIS {
    } else {
      sv.ifdef @ENABLE_INITIAL_REG_ {
      } else {
        sv.macro.def @ENABLE_INITIAL_REG_ ""
      }
    }
    sv.verbatim ""
  }
  sv.macro.decl @ENABLE_INITIAL_REG_
  sv.macro.decl @ENABLE_INITIAL_MEM_
  sv.macro.decl @FIRRTL_BEFORE_INITIAL
  sv.macro.decl @FIRRTL_AFTER_INITIAL
  sv.macro.decl @RANDOMIZE_REG_INIT
  sv.macro.decl @RANDOMIZE
  sv.macro.decl @RANDOMIZE_DELAY
  sv.macro.decl @RANDOM
  sv.macro.decl @INIT_RANDOM
  sv.macro.decl @INIT_RANDOM_PROLOG_
  sv.macro.decl @layer$Verification$Assert$Temporal
  sv.macro.decl @layer$Verification$Assume$Temporal
  sv.macro.decl @layer$Verification$Cover$Temporal
  hw.module @GCD(in %clock : i1, in %reset : i1, in %io_value1 : i16, in %io_value2 : i16, in %io_loadingValues : i1, out io_outputGCD : i16, out io_outputValid : i1) attributes {emit.fragments = [@RANDOM_INIT_REG_FRAGMENT, @RANDOM_INIT_FRAGMENT]} {
    %c0_i0 = hw.constant 0 : i0
    %c0_i16 = hw.constant 0 : i16
    %x = sv.reg {sv.namehint = "x"} : !hw.inout<i16> 
    %0 = sv.read_inout %x : !hw.inout<i16>
    %y = sv.reg : !hw.inout<i16> 
    %1 = sv.read_inout %y : !hw.inout<i16>
    %2 = comb.icmp bin ugt %0, %1 : i16
    %3 = comb.sub bin %0, %1 {sv.namehint = "_x_T"} : i16
    %4 = comb.sub bin %1, %0 {sv.namehint = "_y_T"} : i16
    %5 = comb.icmp bin eq %1, %c0_i16 {sv.namehint = "io_outputValid"} : i16
    sv.always posedge %clock {
      sv.if %io_loadingValues {
        sv.passign %x, %io_value1 : i16
        sv.passign %y, %io_value2 : i16
      } else {
        sv.if %2 {
          sv.passign %x, %3 : i16
        } else {
          sv.passign %y, %4 : i16
        }
      }
    }
    sv.ifdef @ENABLE_INITIAL_REG_ {
      sv.ordered {
        sv.ifdef @FIRRTL_BEFORE_INITIAL {
          sv.verbatim "`FIRRTL_BEFORE_INITIAL"
        }
        sv.initial {
          sv.ifdef.procedural @INIT_RANDOM_PROLOG_ {
            sv.verbatim "`INIT_RANDOM_PROLOG_"
          }
          sv.ifdef.procedural @RANDOMIZE_REG_INIT {
            %_RANDOM = sv.logic : !hw.inout<uarray<1xi32>>
            %RANDOM = sv.macro.ref.expr.se @RANDOM() : () -> i32
            %6 = sv.array_index_inout %_RANDOM[%c0_i0] : !hw.inout<uarray<1xi32>>, i0
            sv.bpassign %6, %RANDOM : i32
            %7 = sv.read_inout %6 : !hw.inout<i32>
            %8 = comb.extract %7 from 0 : (i32) -> i16
            sv.bpassign %x, %8 : i16
            %9 = comb.extract %7 from 16 : (i32) -> i16
            sv.bpassign %y, %9 : i16
          }
        }
        sv.ifdef @FIRRTL_AFTER_INITIAL {
          sv.verbatim "`FIRRTL_AFTER_INITIAL"
        }
      }
    }
    hw.output %0, %5 : i16, i1
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
