module {
  firrtl.circuit "Counter" {
    firrtl.layer @Verification bind attributes {output_file = #hw.output_file<"verification/">} {
      firrtl.layer @Assert bind attributes {output_file = #hw.output_file<"verification/assert/">} {
        firrtl.layer @Temporal inline {
        }
      }
      firrtl.layer @Assume bind attributes {output_file = #hw.output_file<"verification/assume/">} {
        firrtl.layer @Temporal inline {
        }
      }
      firrtl.layer @Cover bind attributes {output_file = #hw.output_file<"verification/cover/">} {
        firrtl.layer @Temporal inline {
        }
      }
    }
    firrtl.module @Counter(in %clock: !firrtl.clock, in %reset: !firrtl.uint<1>, out %io: !firrtl.bundle<en flip: uint<1>, count: uint<8>>) attributes {annotations = [{class = "firrtl.transforms.DedupGroupAnnotation", group = "Counter"}], convention = #firrtl<convention scalarized>} {
      %0 = firrtl.subfield %io[count] : !firrtl.bundle<en flip: uint<1>, count: uint<8>>
      %1 = firrtl.subfield %io[en] : !firrtl.bundle<en flip: uint<1>, count: uint<8>>
      %c0_ui8 = firrtl.constant 0 : !firrtl.const.uint<8>
      %reg = firrtl.regreset interesting_name %clock, %reset, %c0_ui8 : !firrtl.clock, !firrtl.uint<1>, !firrtl.const.uint<8>, !firrtl.uint<8>
      %c1_ui1 = firrtl.constant 1 : !firrtl.const.uint<1>
      firrtl.when %1 : !firrtl.uint<1> {
        %2 = firrtl.add %reg, %c1_ui1 : (!firrtl.uint<8>, !firrtl.const.uint<1>) -> !firrtl.uint<9>
        %_reg_T = firrtl.node interesting_name %2 : !firrtl.uint<9>
        %3 = firrtl.tail %_reg_T, 1 : (!firrtl.uint<9>) -> !firrtl.uint<8>
        %_reg_T_1 = firrtl.node interesting_name %3 : !firrtl.uint<8>
        firrtl.matchingconnect %reg, %_reg_T_1 : !firrtl.uint<8>
      }
      firrtl.matchingconnect %0, %reg : !firrtl.uint<8>
    }
  }
}
