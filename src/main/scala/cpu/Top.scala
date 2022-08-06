package cpu

import chisel3._
import chisel3.util._
import common.Consts._

class Top extends Module {
  val io = IO(new Bundle {
    val debug_pc = Output(UInt(WORD_LEN.W))
    val success = Output(Bool())
    val exit = Output(Bool())
  })
  val base_address = "x00000000".U(WORD_LEN.W)
  val core = Module(new Core(startAddress = base_address))
  val memory = Module(new Memory(Some(i => f"../sw/bootrom_${i}.hex"), base_address, 8192))
  core.io.imem <> memory.io.imem
  core.io.dmem <> memory.io.dmem
  io.success := core.io.success
  io.exit := core.io.exit
  io.debug_pc := core.io.debug_pc
}