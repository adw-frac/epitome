module {
  firrtl.circuit "Scratchpad" {
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
    firrtl.module @Scratchpad(in %clock: !firrtl.clock, in %reset: !firrtl.uint<1>, in %io_raddr: !firrtl.uint<4>, out %io_rdata: !firrtl.uint<32>, in %io_wen: !firrtl.uint<1>, in %io_waddr: !firrtl.uint<4>, in %io_wdata: !firrtl.uint<32>) attributes {convention = #firrtl<convention scalarized>} {
      %c1_ui1 = firrtl.constant 1 : !firrtl.uint<1>
      %io_rdata_0 = firrtl.wire {name = "io_rdata"} : !firrtl.uint<32>
      firrtl.matchingconnect %io_rdata, %io_rdata_0 : !firrtl.uint<32>
      %mem_MPORT, %mem_io_rdata_MPORT = firrtl.mem Undefined {depth = 16 : i64, name = "mem", portNames = ["MPORT", "io_rdata_MPORT"], readLatency = 1 : i32, writeLatency = 1 : i32} : !firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data: uint<32>, mask: uint<1>>, !firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data flip: uint<32>>
      %0 = firrtl.subfield %mem_MPORT[addr] : !firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data: uint<32>, mask: uint<1>>
      %1 = firrtl.subfield %mem_MPORT[en] : !firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data: uint<32>, mask: uint<1>>
      %2 = firrtl.subfield %mem_MPORT[clk] : !firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data: uint<32>, mask: uint<1>>
      %3 = firrtl.subfield %mem_MPORT[data] : !firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data: uint<32>, mask: uint<1>>
      %4 = firrtl.subfield %mem_MPORT[mask] : !firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data: uint<32>, mask: uint<1>>
      %5 = firrtl.subfield %mem_io_rdata_MPORT[addr] : !firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data flip: uint<32>>
      %6 = firrtl.subfield %mem_io_rdata_MPORT[en] : !firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data flip: uint<32>>
      %7 = firrtl.subfield %mem_io_rdata_MPORT[clk] : !firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data flip: uint<32>>
      %8 = firrtl.subfield %mem_io_rdata_MPORT[data] : !firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data flip: uint<32>>
      firrtl.matchingconnect %6, %c1_ui1 : !firrtl.uint<1>
      firrtl.matchingconnect %5, %io_raddr : !firrtl.uint<4>
      firrtl.matchingconnect %7, %clock : !firrtl.clock
      firrtl.matchingconnect %io_rdata_0, %8 : !firrtl.uint<32>
      firrtl.matchingconnect %0, %io_waddr : !firrtl.uint<4>
      firrtl.matchingconnect %1, %io_wen : !firrtl.uint<1>
      firrtl.matchingconnect %2, %clock : !firrtl.clock
      firrtl.matchingconnect %4, %c1_ui1 : !firrtl.uint<1>
      firrtl.matchingconnect %3, %io_wdata : !firrtl.uint<32>
    }
  }
}
