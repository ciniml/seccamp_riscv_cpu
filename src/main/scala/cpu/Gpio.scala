package cpu

import chisel3._
import chisel3.util._
import common.Consts._
import chisel3.stage.ChiselStage

class Gpio() extends Module {
  val io = IO(new Bundle {
    val mem = new DmemPortIo
    val out = Output(UInt(32.W))
  })

  val out = RegInit(0.U(32.W))
  
  io.out := out
  
  io.mem.rdata := "xdeadbeef".U
  io.mem.rvalid := true.B
  io.mem.rdata := MuxLookup(io.mem.addr(3, 2), "xDEADBEEF".U, Seq(
      0.U -> out, // Output
  ))
  when(io.mem.wen) {
    val mask = Cat((0 to 3).map(i => Mux(io.mem.wstrb(i), 0xff.U(8.W), 0x00.U(8.W))).reverse)
    switch(io.mem.addr(3,2)) {
        // Output
        is(0.U) {
          out := (out & ~mask) | (io.mem.wdata & mask)
        }
    }
  }
}

class GpioArray(masks: Seq[BigInt]) extends Module {
  val io = IO(new Bundle {
    val mem = new DmemPortIo
    val in = Input(Vec(masks.length, UInt(32.W)))
    val out = Output(Vec(masks.length, UInt(32.W)))
  })

  val REGISTERS_PER_GPIO = 4  // Currently GPIO array implemnets OUT register only per one GPIO port, but in the future, it will implement some registers like IN and DIR registers.
  val ADDRESS_RANGE_PER_GPIO = REGISTERS_PER_GPIO * 4
  val ADDRESS_RANGE = BigInt(masks.length * ADDRESS_RANGE_PER_GPIO)
  val ADDRESS_BITS = log2Ceil(ADDRESS_RANGE)
  val outReg = RegInit(VecInit(masks.map(_ => 0.U(32.W))))
  val inReg = RegInit(VecInit(masks.map(_ => 0.U(32.W))))
  
  io.mem.rvalid := true.B
  io.mem.rdata := MuxLookup(io.mem.addr(ADDRESS_BITS - 1, 2), "xDEADBEEF".U, masks.zipWithIndex.flatMap { 
    case (m, i) => Seq(
      (i * REGISTERS_PER_GPIO + 0).U -> (outReg(i) & m.U),
      (i * REGISTERS_PER_GPIO + 1).U -> (inReg(i) & m.U),
    ) 
  })
  val mask = Cat((0 to 3).map(i => Mux(io.mem.wstrb(i), 0xff.U(8.W), 0x00.U(8.W))).reverse)

  for( gpioIndex <- 0 until masks.length) {
    inReg(gpioIndex) := io.in(gpioIndex)
    io.out(gpioIndex) := outReg(gpioIndex)
    when(io.mem.wen) {
      when(io.mem.addr(ADDRESS_BITS, 2) === (gpioIndex * REGISTERS_PER_GPIO).U) {
        // Output register
        outReg(gpioIndex) := ((outReg(gpioIndex) & ~mask) | (io.mem.wdata & mask)) & masks(gpioIndex).U
      }
    }
  }
}