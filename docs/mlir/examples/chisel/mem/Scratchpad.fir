FIRRTL version 7.0.0
circuit Scratchpad :%[[
  {
    "class":"firrtl.transforms.DedupGroupAnnotation",
    "target":"~|Scratchpad",
    "group":"Scratchpad"
  }
]]
  layer Verification, bind, "verification" :
    layer Assert, bind, "verification/assert" :
      layer Temporal, inline :
    layer Assume, bind, "verification/assume" :
      layer Temporal, inline :
    layer Cover, bind, "verification/cover" :
      layer Temporal, inline :

  public module Scratchpad : @[Scratchpad.scala 10:7]
    input clock : Clock @[Scratchpad.scala 10:7]
    input reset : UInt<1> @[Scratchpad.scala 10:7]
    output io : { flip raddr : UInt<4>, rdata : UInt<32>, flip wen : UInt<1>, flip waddr : UInt<4>, flip wdata : UInt<32>} @[Scratchpad.scala 11:14]

    smem mem : UInt<32>[16] @[Scratchpad.scala 18:24]
    wire _io_rdata_WIRE : UInt<4> @[Scratchpad.scala 19:23]
    invalidate _io_rdata_WIRE @[Scratchpad.scala 19:23]
    when UInt<1>(0h1) : @[Scratchpad.scala 19:23]
      connect _io_rdata_WIRE, io.raddr @[Scratchpad.scala 19:23]
      read mport io_rdata_MPORT = mem[_io_rdata_WIRE], clock @[Scratchpad.scala 19:23]
    connect io.rdata, io_rdata_MPORT @[Scratchpad.scala 19:12]
    when io.wen : @[Scratchpad.scala 20:16]
      write mport MPORT = mem[io.waddr], clock @[Scratchpad.scala 20:27]
      connect MPORT, io.wdata @[Scratchpad.scala 20:27]

