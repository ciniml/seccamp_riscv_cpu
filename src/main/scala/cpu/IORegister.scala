package cpu

import chisel3._
import chisel3.util._
import common.Consts._
import chisel3.stage.ChiselStage

class IORegister(masks: Seq[(BigInt, BigInt)]) extends Module {
  val io = IO(new Bundle {
    val mem = new DmemPortIo
    val in = Vec(masks.length, Flipped(Decoupled(UInt(32.W))))
    val out = Vec(masks.length, Valid(UInt(32.W)))
  })

  val ADDRESS_RANGE_PER_GPIO = 4
  val ADDRESS_RANGE = BigInt(masks.length * ADDRESS_RANGE_PER_GPIO)
  val ADDRESS_BITS = log2Ceil(ADDRESS_RANGE)
  
  val inSignals = MuxLookup(io.mem.addr(ADDRESS_BITS - 1, 2), Cat(false.B, "xDEADBEEF".U), masks.zipWithIndex.flatMap { 
    case (m, i) => Seq(
      i.U -> Cat(io.in(i).valid, (io.in(i).bits & m._1.U)),
    ) 
  })
  io.mem.rvalid := inSignals(32)
  io.mem.rdata := inSignals(31, 0)

  val mask = Cat((0 to 3).map(i => Mux(io.mem.wstrb(i), 0xff.U(8.W), 0x00.U(8.W))).reverse)

  for( gpioIndex <- 0 until masks.length) {
    io.out(gpioIndex).valid := false.B
    io.in(gpioIndex).ready := false.B
    io.out(gpioIndex).bits := (io.mem.wdata & mask) & masks(gpioIndex)._2.U
    when(io.mem.addr(ADDRESS_BITS, 2) === gpioIndex.U) {
      io.out(gpioIndex).valid := io.mem.wen
      io.in(gpioIndex).ready := io.mem.ren
    }
  }
}