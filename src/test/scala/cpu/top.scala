package cpu

import chiseltest._
import scala.util.control.Breaks
import org.scalatest.flatspec.AnyFlatSpec
import chisel3._
import chisel3.util._

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

class TopTest extends AnyFlatSpec with ChiselScalatestTester {
      it must "runs Top" in { test(new TopTestSystem).withAnnotations(Seq(VerilatorBackendAnnotation, WriteFstAnnotation)) { c =>
        c.reset.poke(true.B)
        c.clock.step(4)
        c.reset.poke(false.B)
        c.clock.setTimeout(100010)
        c.clock.step(100000)
      } }
  
}
