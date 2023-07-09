package cpu

import chiseltest._
import scala.util.control.Breaks
import org.scalatest.flatspec.AnyFlatSpec
import chisel3._
import chisel3.util._
import uart.UartTx
import scala.util.Random

class TopTestSystem extends Module {
  val io = IO(new Bundle{
    val success = Output(Bool())
    val exit = Output(Bool())
  })

  val top = Module(new Top(i => f"eda/cpu_riscv_chisel_book/src/sw/bootrom_${i}.hex", true))
  io.success := top.io.success
  io.exit := top.io.exit
  // top.io.uart_rx := true.B
  // top.io.pixel_clock := top.clock
  // top.io.pixel_reset := top.reset
}

class TopWithHDMITestSystem extends Module {
  val io = IO(new Bundle{
    val success = Output(Bool())
    val exit = Output(Bool())
  })

  val top = Module(new TopWithHDMI(i => f"eda/cpu_riscv_chisel_book/src/sw/bootrom_${i}.hex", true))
  io.success := top.io.success
  io.exit := top.io.exit
  top.io.uart_rx := true.B
  top.io.pixel_clock := top.clock
  top.io.pixel_reset := top.reset
}

class TopWithSegmentLedTestSystem extends Module {
  val io = IO(new Bundle{
    val uartTx = Flipped(Decoupled(UInt(8.W)))
    val success = Output(Bool())
    val exit = Output(Bool())
  })

  val top = Module(new TopWithSegmentLed(i => f"eda/segment_display/src/sw/bootrom_${i}.hex", true))
  io.success := top.io.success
  io.exit := top.io.exit
  top.io.switchIn := 0.U

  val uartTestTx = Module(new UartTx(8, top.clockFreqHz / 115200))
  top.io.uartRx <> uartTestTx.io.tx;
  uartTestTx.io.in <> io.uartTx;
}

class TopTest extends AnyFlatSpec with ChiselScalatestTester {
      it must "runs Top" in { test(new TopTestSystem).withAnnotations(Seq(VerilatorBackendAnnotation, WriteFstAnnotation)) { c =>
        c.reset.poke(true.B)
        c.clock.step(4)
        c.reset.poke(false.B)
        c.clock.setTimeout(100010)
        c.clock.step(100000)
      } }
  
}

class TopWithSegmentLedTest extends AnyFlatSpec with ChiselScalatestTester {
      it must "runs TopWithSegmentLed" in { test(new TopWithSegmentLedTestSystem).withAnnotations(Seq(VerilatorBackendAnnotation, WriteFstAnnotation)) { c =>
        c.io.uartTx.initSource().setSourceClock(c.clock)
        c.reset.poke(true.B)
        c.clock.step(4)
        c.reset.poke(false.B)
        c.clock.setTimeout(1000010)
        //c.clock.step(1000000)
        for( i <- 0 to 1000000) {
          c.io.uartTx.enqueue((i % 256).U)
          c.clock.step(Random.nextInt(10000) + (c.top.clockFreqHz / 115200))
        }
      } }
  
}
