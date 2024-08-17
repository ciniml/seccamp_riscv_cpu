package cpu

import chisel3._
import chisel3.util._
import common.Consts._
import uart.UartTx
import segled.SegmentLedWithShiftRegs
import segled.ShiftRegisterPort
import display.MatrixLed
import display.MatrixLedConfig
import uart.UartRx
import _root_.util.AsyncFIFO
import _root_.util.Flushable
import _root_.util.PacketQueue


class TopWithEthernet(memoryPathGen: Int => String = i => f"../sw/bootrom_${i}.hex", suppressDebugMessage: Boolean = false, memorySize: Int = 8192, enableProbe: Boolean = false, forSimulation: Boolean = false, useTargetPrimitive: Boolean = false) extends Module {
  val io = IO(new Bundle {
    val debug_pc = Output(UInt(WORD_LEN.W))
    val uartTx = Output(Bool())
    val uartRx = Input(Bool())
    val success = Output(Bool())
    val segmentOut = ShiftRegisterPort()
    val digitSelector = ShiftRegisterPort()
    val ledOut = Output(UInt(32.W))
    val switchIn = Input(UInt(32.W))
    val matrixColumnOut = Output(UInt(8.W))
    val matrixRowOut = Output(UInt(8.W))

    // Ethernet IF
    val rmiiClock = Input(Clock())
    val rmiiReset = Input(Bool())
    val macInData = Input(UInt(8.W))
    val macInValid = Input(Bool())
    val macInReady = Output(Bool())
    val macInLast = Input(Bool())
    val macOutData = Output(UInt(8.W))
    val macOutValid = Output(Bool())
    val macOutReady = Input(Bool())
    val macOutLast = Output(Bool())

    val probeOut = Output(Bool())
    val exit = Output(Bool())
  })

  val clockFreqHz = 27000000
  val baseAddress = BigInt("00000000", 16)
  val core = Module(new Core(startAddress = baseAddress.U(WORD_LEN.W), suppressDebugMessage))

  val memory = Module(new Memory(Some(memoryPathGen), baseAddress.U(WORD_LEN.W), memorySize, forSimulation, useTargetPrimitive = useTargetPrimitive))
  val gpios = Module(new GpioArray((0 until 6).map(_ => BigInt("ffffffff", 16)))) // GPIO Array (6ポート)
  val uartRegs = Module(new IORegister(Seq((0x100ff, 0xff), (0x03, 0x00))))       // UART IOレジスタ
  val ethernetRegs = Module(new IORegister(Seq((0x3ff, 0x1ff), (0x1, 0x0))))      // ETHERNET IOレジスタ

  val decoder = Module(new DMemDecoder(Seq(
    (BigInt(0x00000000L), BigInt(memorySize)),         // メモリ
    (BigInt(0xA0000000L), gpios.ADDRESS_RANGE),     // GPIO Array (5ポート)
    (BigInt(0xA0001000L), uartRegs.ADDRESS_RANGE),  // UART IO
    (BigInt(0xA0002000L), ethernetRegs.ADDRESS_RANGE),  // ETHERNET IO
  )))
  core.io.imem <> memory.io.imem
  core.io.dmem <> decoder.io.initiator  // CPUにデコーダを接続

  decoder.io.targets(0) <> memory.io.dmem   // 0番ポートにメモリを接続
  decoder.io.targets(1) <> gpios.io.mem     // 1番ポートにGPIOを接続
  decoder.io.targets(2) <> uartRegs.io.mem  // 2番ポートにUART IOを接続
  decoder.io.targets(3) <> ethernetRegs.io.mem  // 3番ポートにETHERNET IOを接続

  // GPIO port 0, 1 に8セグメント6桁LED用のドライバを接続
  val segmentLeds = Module(new SegmentLedWithShiftRegs(8, 6, 2, 2700, true, true))
  io.segmentOut <> segmentLeds.io.segmentOut
  io.digitSelector <> segmentLeds.io.digitSelector
  segmentLeds.io.digits := VecInit((0 to 3).map(i => gpios.io.out(0)(8 * i + 7, 8 * i)) ++ (0 to 1).map(i => gpios.io.out(1)(8 * i + 7, 8 * i)))
  gpios.io.in(0) := 0.U
  gpios.io.in(1) := 0.U

  // GPIO port 2, 3 にLEDマトリクス用のドライバを接続
  val matrixLed = Module(new MatrixLed(new MatrixLedConfig(rows = 8, columns = 8, clockFreq = clockFreqHz, refreshInterval = 2700, refreshGuardInterval = 10)))
  matrixLed.io.matrix := VecInit((0 to 3).map(i => gpios.io.out(2)(8 * i + 7, 8 * i)) ++ (0 to 3).map(i => gpios.io.out(3)(8 * i + 7, 8 * i)))
  io.matrixColumnOut := matrixLed.io.column
  io.matrixRowOut := matrixLed.io.row
  gpios.io.in(2) := 0.U
  gpios.io.in(3) := 0.U

  // GPIO port 4にLED用のドライバを接続
  io.ledOut := gpios.io.out(4)
  gpios.io.in(4) := 0.U

  // GPIO port 5にピン入力のドライバを接続
  io.switchIn <> gpios.io.in(5)

  val uartTx = Module(new UartTx(8, clockFreqHz / 115200))
  val uartRx = Module(new UartRx(8, clockFreqHz / 115200, 2))
  val uartTxValidReady = Wire(new DecoupledIO(UInt(8.W)))
  val uartTxQueue = Queue(uartTxValidReady, 16)
  val uartRxQueue = Queue(uartRx.io.out, 16)

  io.uartTx <> uartTx.io.tx
  uartTx.io.in <> uartTxQueue
  uartTxValidReady.valid := uartRegs.io.out(0).valid
  uartTxValidReady.bits := uartRegs.io.out(0).bits
  uartRegs.io.in(1).bits := Cat(0.U(30.W), uartRxQueue.valid, uartTxValidReady.ready)
  uartRegs.io.in(1).valid := true.B
  core.io.interrupt_in := uartRxQueue.valid

  io.uartRx <> uartRx.io.rx
  uartRegs.io.in(0).bits := Cat(0.U(15.W), uartRxQueue.valid, 0.U(8.W), uartRxQueue.bits)
  uartRegs.io.in(0).valid := true.B
  uartRxQueue.ready := uartRegs.io.in(0).ready

  io.success := core.io.success
  io.exit := core.io.exit
  io.debug_pc := core.io.debug_pc

  // Ethernet IF
  val ethernetFifoRx = Module(new AsyncFIFO(Flushable(UInt(8.W)), 11))
  val ethernetFifoTx = Module(new AsyncFIFO(Flushable(UInt(8.W)), 2))
  ethernetFifoRx.io.readClock := clock
  ethernetFifoRx.io.readReset := reset
  ethernetFifoRx.io.writeClock := io.rmiiClock
  ethernetFifoRx.io.writeReset := io.rmiiReset
  ethernetFifoTx.io.readClock := io.rmiiClock
  ethernetFifoTx.io.readReset := io.rmiiReset
  ethernetFifoTx.io.writeClock := clock
  ethernetFifoTx.io.writeReset := reset

  // Ethernet registers
  // 0x0: read: {RX valid, RX last, RX data} write: {TX last, TX data}
  // 0x4: read: {TX ready} write: {}
  ethernetRegs.io.in(0).valid := true.B
  ethernetRegs.io.in(0).bits := Cat(ethernetFifoRx.io.read.valid, ethernetFifoRx.io.read.bits.last, ethernetFifoRx.io.read.bits.data)
  ethernetFifoRx.io.read.ready := ethernetRegs.io.in(0).ready

  ethernetFifoTx.io.write.valid := ethernetRegs.io.out(0).valid
  ethernetFifoTx.io.write.bits.data := ethernetRegs.io.out(0).bits(7, 0)
  ethernetFifoTx.io.write.bits.last := ethernetRegs.io.out(0).bits(8)
  ethernetRegs.io.in(1).valid := true.B
  ethernetRegs.io.in(1).bits := ethernetFifoTx.io.write.ready

  // Ethernet MAC clock domain (RMII REFCLK 50MHz)
  withClockAndReset(io.rmiiClock, io.rmiiReset) {
    // Connect async FIFO to Ethernet MAC interface
    ethernetFifoRx.io.write.valid := io.macInValid
    io.macInReady := ethernetFifoRx.io.write.ready
    ethernetFifoRx.io.write.bits.data := io.macInData
    ethernetFifoRx.io.write.bits.last := io.macInLast

    // Connect TX packet FIFO and TX async FIFO
    val txPacketFifo = Module(new PacketQueue(Flushable(UInt(8.W)), 1536))
    txPacketFifo.io.write <> ethernetFifoTx.io.read

    // Connect TX packet FIFO
    io.macOutValid := txPacketFifo.io.read.valid
    io.macOutData := txPacketFifo.io.read.bits.data
    io.macOutLast := txPacketFifo.io.read.bits.last
    txPacketFifo.io.read.ready := io.macOutReady
  }

  // 信号観測用プローブを構築
  if( enableProbe ) {
    val probe = Module(new diag.Probe(new diag.ProbeConfig(bufferDepth = 512, triggerPosition = 16), 11))
    // probe.io.in := Cat( core.io.imem.valid, core.io.debug_if_inst, core.io.debug_pc )
    // val noActivityCounter = RegInit(0.U(log2Ceil(256).W))
    // when( gpios.io.mem.wen ) {
    //   noActivityCounter := 0.U
    // } .otherwise {
    //   noActivityCounter := noActivityCounter + 1.U
    // }
    // probe.io.trigger := (noActivityCounter === 255.U) | !io.switchIn(0)
    probe.io.in := Cat(ethernetRegs.io.out(0).valid, ethernetFifoTx.io.write.ready, ethernetRegs.io.out(0).bits(8), ethernetRegs.io.out(0).bits(7, 0))
    probe.io.trigger := ethernetRegs.io.out(0).valid
    val probeFrameAdapter = Module(new diag.ProbeFrameAdapter(probe.width))
    probeFrameAdapter.io.in <> probe.io.out
    val probeUartTx = Module(new UartTx(numberOfBits = 8, baudDivider = clockFreqHz / 115200))
    probeUartTx.io.in <> probeFrameAdapter.io.out
    io.probeOut := probeUartTx.io.tx
  } else {
    io.probeOut := true.B
  }
}