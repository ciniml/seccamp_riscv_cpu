package cpu

import chisel3._
import chisel3.util._
import common.Consts._
import chisel3.util.experimental.loadMemoryFromFile

class SimTop(memoryPath: Int => String) extends Module {
  val io = IO(new Bundle {
    val success = Output(Bool())
    val exit = Output(Bool())
  })
  val core = Module(new Core())
  val memory = Module(new Memory(Some(memoryPath)))

  core.io.imem <> memory.io.imem
  core.io.dmem <> memory.io.dmem
  io.success := core.io.success
  io.exit := core.io.exit
}