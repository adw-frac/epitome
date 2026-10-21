//> using scala 2.13.18
//> using dep org.chipsalliance::chisel:7.16.0
//> using plugin org.chipsalliance:::chisel-plugin:7.16.0
//> using options -deprecation -feature -Xcheckinit -Ymacro-annotations -language:reflectiveCalls

import chisel3._
import circt.stage.ChiselStage

/** A 16 x 32-bit memory with one synchronous read port and one write port. */
class Scratchpad extends Module {
  val io = IO(new Bundle {
    val raddr = Input(UInt(4.W))
    val rdata = Output(UInt(32.W))
    val wen   = Input(Bool())
    val waddr = Input(UInt(4.W))
    val wdata = Input(UInt(32.W))
  })
  val mem = SyncReadMem(16, UInt(32.W))
  io.rdata := mem.read(io.raddr)
  when(io.wen) { mem.write(io.waddr, io.wdata) }
}

object Main extends App {
  print(ChiselStage.emitCHIRRTL(new Scratchpad))
}
