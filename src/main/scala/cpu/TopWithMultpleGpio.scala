package cpu

import chisel3._
import chisel3.util._
import common.Consts._
import uart.UartTx

class TopWithMultipleGpio(memoryPathGen: Int => String = i => f"../sw/bootrom_${i}.hex", suppressDebugMessage: Boolean = false, numberOfGpios: Int = 1) extends Module {
  val io = IO(new Bundle {
    val debug_pc = Output(UInt(WORD_LEN.W))
    val gpio_out = Output(UInt(32.W))
    val uart_tx = Output(Bool())
    val success = Output(Bool())
    val exit = Output(Bool())
  })
  val baseAddress = BigInt("00000000", 16)
  val memSize = 8192
  val core = Module(new Core(startAddress = baseAddress.U(WORD_LEN.W), suppressDebugMessage))
  val baseMemoryMap = Seq(
    (BigInt(0x00000000L), BigInt(memSize)), // メモリ
  )
  val gpioMemoryMap = (0 until numberOfGpios).map(i => (BigInt(0xA0000000L + i * 0x10), BigInt(16)))
  val decoder = Module(new DMemDecoder(baseMemoryMap ++ gpioMemoryMap))
  
  val memory = Module(new Memory(Some(memoryPathGen), baseAddress.U(WORD_LEN.W), memSize))
  val gpios = (0 until numberOfGpios).map(i => Module(new Gpio()))

  core.io.imem <> memory.io.imem
  core.io.dmem <> decoder.io.initiator  // CPUにデコーダを接続
  decoder.io.targets(0) <> memory.io.dmem // 0番ポートにメモリを接続
  for (i <- 0 until numberOfGpios) {
    decoder.io.targets(i + 1) <> gpios(i).io.mem
  }

  val uartTx = Module(new UartTx(27000000, 115200))
  io.uart_tx := uartTx.io.tx

  io.success := core.io.success
  io.exit := core.io.exit
  io.debug_pc := core.io.debug_pc
}