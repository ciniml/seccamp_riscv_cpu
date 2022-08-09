package cpu

import chisel3._
import chisel3.util._
import common.Consts._
import uart.UartTx

class Top(memoryPathGen: Int => String = i => f"../sw/bootrom_${i}.hex") extends Module {
  val io = IO(new Bundle {
    val debug_pc = Output(UInt(WORD_LEN.W))
    val gpio_out = Output(UInt(32.W))
    val uart_tx = Output(Bool())
    val success = Output(Bool())
    val exit = Output(Bool())
  })
  val baseAddress = BigInt("00000000", 16)
  val memSize = 8192
  val core = Module(new Core(startAddress = baseAddress.U(WORD_LEN.W)))
  val decoder = Module(new DMemDecoder(Seq(
    (BigInt(0x00000000L), BigInt(memSize)), // メモリ
    (BigInt(0xA0000000L), BigInt(64)),      // GPIO
  )))
  
  val memory = Module(new Memory(Some(memoryPathGen), baseAddress.U(WORD_LEN.W), memSize))
  val gpio = Module(new Gpio)

  core.io.imem <> memory.io.imem
  core.io.dmem <> decoder.io.initiator  // CPUにデコーダを接続
  decoder.io.targets(0) <> memory.io.dmem // 0番ポートにメモリを接続
  decoder.io.targets(1) <> gpio.io.mem    // 1番ポートにGPIOを接続
  io.gpio_out := gpio.io.out  // GPIOの出力を外部ポートに接続
  //io.gpio_out := core.io.gpio_out  // GPIO CSRの出力を外部ポートに接続

  val uartTx = Module(new UartTx(27000000, 115200))
  io.uart_tx := uartTx.io.tx

  io.success := core.io.success
  io.exit := core.io.exit
  io.debug_pc := core.io.debug_pc
}