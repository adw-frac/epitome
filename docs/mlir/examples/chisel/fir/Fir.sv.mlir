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
  hw.module @Fir(in %clock : i1, in %reset : i1, in %io_in : i8, in %io_valid : i1, out io_out : i16) attributes {emit.fragments = [@RANDOM_INIT_REG_FRAGMENT, @RANDOM_INIT_FRAGMENT]} {
    %c0_i0 = hw.constant 0 : i0
    %false = hw.constant false
    %c0_i5 = hw.constant 0 : i5
    %c3_i10 = hw.constant 3 : i10
    %c0_i3 = hw.constant 0 : i3
    %c0_i2 = hw.constant 0 : i2
    %c0_i8 = hw.constant 0 : i8
    %taps_1 = sv.reg : !hw.inout<i8> 
    %0 = sv.read_inout %taps_1 : !hw.inout<i8>
    %taps_2 = sv.reg : !hw.inout<i8> 
    %1 = sv.read_inout %taps_2 : !hw.inout<i8>
    %taps_3 = sv.reg : !hw.inout<i8> 
    %2 = sv.read_inout %taps_3 : !hw.inout<i8>
    %3 = comb.concat %c0_i2, %0 : i2, i8
    %4 = comb.mul bin %3, %c3_i10 {sv.namehint = "products_1"} : i10
    %5 = comb.concat %c0_i2, %1 : i2, i8
    %6 = comb.mul bin %5, %c3_i10 {sv.namehint = "products_2"} : i10
    %7 = comb.concat %c0_i3, %io_in : i3, i8
    %8 = comb.concat %false, %4 : i1, i10
    %9 = comb.add bin %7, %8 {sv.namehint = "_io_out_T"} : i11
    %10 = comb.concat %false, %9 : i1, i11
    %11 = comb.concat %c0_i2, %6 : i2, i10
    %12 = comb.add bin %10, %11 {sv.namehint = "_io_out_T_1"} : i12
    %13 = comb.concat %false, %12 : i1, i12
    %14 = comb.concat %c0_i5, %2 : i5, i8
    %15 = comb.add bin %13, %14 {sv.namehint = "_io_out_T_2"} : i13
    %16 = comb.concat %c0_i3, %15 {sv.namehint = "io_out"} : i3, i13
    sv.always posedge %clock {
      sv.if %reset {
        sv.passign %taps_1, %c0_i8 : i8
        sv.passign %taps_2, %c0_i8 : i8
        sv.passign %taps_3, %c0_i8 : i8
      } else {
        sv.if %io_valid {
          sv.passign %taps_1, %io_in : i8
          sv.passign %taps_2, %0 : i8
          sv.passign %taps_3, %1 : i8
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
            %17 = sv.array_index_inout %_RANDOM[%c0_i0] : !hw.inout<uarray<1xi32>>, i0
            sv.bpassign %17, %RANDOM : i32
            %18 = sv.read_inout %17 : !hw.inout<i32>
            %19 = comb.extract %18 from 0 : (i32) -> i8
            sv.bpassign %taps_1, %19 : i8
            %20 = comb.extract %18 from 8 : (i32) -> i8
            sv.bpassign %taps_2, %20 : i8
            %21 = comb.extract %18 from 16 : (i32) -> i8
            sv.bpassign %taps_3, %21 : i8
          }
        }
        sv.ifdef @FIRRTL_AFTER_INITIAL {
          sv.verbatim "`FIRRTL_AFTER_INITIAL"
        }
      }
    }
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
