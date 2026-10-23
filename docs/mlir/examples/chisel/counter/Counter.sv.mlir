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
  hw.module @Counter(in %clock : i1, in %reset : i1, in %io_en : i1, out io_count : i8) attributes {emit.fragments = [@RANDOM_INIT_REG_FRAGMENT, @RANDOM_INIT_FRAGMENT]} {
    %c0_i0 = hw.constant 0 : i0
    %c1_i8 = hw.constant 1 : i8
    %c0_i8 = hw.constant 0 : i8
    %reg = sv.reg {sv.namehint = "reg"} : !hw.inout<i8> 
    %0 = sv.read_inout %reg : !hw.inout<i8>
    %1 = comb.add bin %0, %c1_i8 {sv.namehint = "_reg_T"} : i8
    sv.always posedge %clock {
      sv.if %reset {
        sv.passign %reg, %c0_i8 : i8
      } else {
        sv.if %io_en {
          sv.passign %reg, %1 : i8
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
            %2 = sv.array_index_inout %_RANDOM[%c0_i0] : !hw.inout<uarray<1xi32>>, i0
            sv.bpassign %2, %RANDOM : i32
            %3 = sv.read_inout %2 : !hw.inout<i32>
            %4 = comb.extract %3 from 0 : (i32) -> i8
            sv.bpassign %reg, %4 : i8
          }
        }
        sv.ifdef @FIRRTL_AFTER_INITIAL {
          sv.verbatim "`FIRRTL_AFTER_INITIAL"
        }
      }
    }
    hw.output %0 : i8
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
