package cpu

import chisel3._
import chisel3.util._
import common.Consts._
import uart._
import video.TestPatternGenerator
import video.VideoSignalGenerator
import video.VideoConfig
import video.SimpleTestPatternGenerator
import video.VideoController

class TopWithHDMI(memoryPathGen: Int => String = i => f"../sw/bootrom_${i}.hex", suppressDebugMessage: Boolean = false) extends Module {
  val io = IO(new Bundle {
    val debug_pc = Output(UInt(WORD_LEN.W))
    val gpio_out = Output(UInt(32.W))
    val uart_tx = Output(Bool())
    val uart_rx = Input(Bool())
    val success = Output(Bool())
    val exit = Output(Bool())

    val pixel_reset = Input(Bool())
    val pixel_clock = Input(Clock())
    val rgb_hs = Output(Bool())
    val rgb_vs = Output(Bool())
    val rgb_de = Output(Bool())
    val rgb_r = Output(UInt(8.W))
    val rgb_g = Output(UInt(8.W))
    val rgb_b = Output(UInt(8.W))
  })
  val baseAddress = BigInt("00000000", 16)
  val memSize = 8192
  val core = Module(new Core(startAddress = baseAddress.U(WORD_LEN.W), suppressDebugMessage))
  val decoder = Module(new DMemDecoder(Seq(
    (BigInt(0x00000000L), BigInt(memSize)), // メモリ
    (BigInt(0xA0000000L), BigInt(64)),      // GPIO
    (BigInt(0xB0000000L), BigInt(0x20000)), // VRAM
    (BigInt(0xB0020000L), BigInt(0x1000)),  // Video Controller
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

  // 640x480@60Hz CEA-861 timing
  // https://tomverbeure.github.io/video_timings_calculator
  val videoParams = video.VideoParams(24, 33, 480, 10, 2, 48, 640, 16, 96)
  //val videoParams = video.VideoParams(24, 30, 480, 9, 6, 60, 720, 16, 62)
  val videoController = Module(new VideoController(videoParams, 8, 8, 8, value => Cat(value(7, 6), Fill(6, value(6)), value(5, 3), Fill(5, value(3)), value(2, 0), Fill(5, value(0))) /* BGR233 to BGR888 */ ))
  decoder.io.targets(2) <> videoController.io.mem
  decoder.io.targets(3) <> videoController.io.reg
  videoController.io.videoClock := io.pixel_clock
  videoController.io.videoReset := io.pixel_reset

  val useTestPatternGenerator = false
  if( !useTestPatternGenerator ) {
    io.rgb_de := videoController.io.video.dataEnable
    io.rgb_hs := videoController.io.video.hSync
    io.rgb_vs := videoController.io.video.vSync
    io.rgb_r := videoController.io.video.pixelData(7, 0)
    io.rgb_g := videoController.io.video.pixelData(15, 8)
    io.rgb_b := videoController.io.video.pixelData(23, 16)
  } else {
    val tpg = Module(new SimpleTestPatternGenerator(videoParams))
    io.rgb_de := tpg.io.video.dataEnable
    io.rgb_hs := tpg.io.video.hSync
    io.rgb_vs := tpg.io.video.vSync
    io.rgb_r := tpg.io.video.pixelData(7, 0)
    io.rgb_g := tpg.io.video.pixelData(15, 8)
    io.rgb_b := tpg.io.video.pixelData(23, 16)
  }
}