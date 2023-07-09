package diag

import chiseltest._
import scala.util.control.Breaks
import org.scalatest.flatspec.AnyFlatSpec
import chisel3._
import chisel3.util._
import chisel3.experimental.BundleLiterals._
import scala.util.Random

class ProbeTestSystem extends Module {
  val io = IO(new Bundle{
    val in = Input(UInt(8.W))
    val out = Decoupled(ProbeOutput(8))
    val trigger = Input(Bool())
  })

  val config = new ProbeConfig(bufferDepth = 8, triggerPosition = 4)
  val dut = Module(new Probe(config, 8))
  io.in <> dut.io.in
  io.out <> dut.io.out
  dut.io.trigger <> io.trigger
}

class ProbeTest extends AnyFlatSpec with ChiselScalatestTester {
  it must "fill buffer full and then trigger" in { test(new ProbeTestSystem).withAnnotations(Seq(VerilatorBackendAnnotation, WriteFstAnnotation)) { c =>
    c.io.out.initSink().setSinkClock(c.clock)
    c.reset.poke(true.B)
    c.clock.step(1)
    c.reset.poke(false.B)
    c.clock.step(1)

    fork {  // input task
      for(i <- 0 to 11) {
        c.io.trigger.poke((i == 8).B) // trigger at input `8` (9th clock). 
        c.io.in.poke(i.U)
        c.clock.step(1)
      }
    }
    fork {  // output check task
      // The probe buffer must contain 4 to 11 inclusive.
      for(i <- 4 to 11) {
        c.io.out.expectDequeue(ProbeOutput(8).Lit(_.data -> i.U, _.last -> (i == 11).B))
      }
      c.io.out.valid.expect(false.B)
      c.clock.step(1)
      c.io.out.valid.expect(false.B)
      c.clock.step(1)
    }.join()
  } }
  it must "trigger at first cycle" in { test(new ProbeTestSystem).withAnnotations(Seq(VerilatorBackendAnnotation, WriteFstAnnotation)) { c =>
    c.io.out.initSink().setSinkClock(c.clock)
    c.reset.poke(true.B)
    c.clock.step(1)
    c.reset.poke(false.B)
    c.clock.step(1)

    fork {  // input task
      for(i <- 0 to 11) {
        c.io.trigger.poke((i == 0).B) // trigger at input `8` (9th clock). 
        c.io.in.poke(i.U)
        c.clock.step(1)
      }
    }
    fork {  // output check task
      // The probe buffer must contain 4 to 11 inclusive.
      for(i <- 0 to 7) {
        c.io.out.expectDequeue(ProbeOutput(8).Lit(_.data -> i.U, _.last -> (i == 7).B))
      }
      c.io.out.valid.expect(false.B)
      c.clock.step(1)
      c.io.out.valid.expect(false.B)
      c.clock.step(1)
    }.join()
  } }
}


class ProbeFrameAdapterTest extends AnyFlatSpec with ChiselScalatestTester {
  def testSequence(c: ProbeFrameAdapter, datas: Seq[Seq[BigInt]]) = {
    val probeOutputType = ProbeOutput(c.width)
    c.io.in.initSource().setSourceClock(c.clock)
    c.io.out.initSink().setSinkClock(c.clock)
    c.reset.poke(true.B)
    c.clock.step(1)
    c.reset.poke(false.B)
    c.clock.step(1)

    fork {  // input task
      for(data <- datas) {
        for((v, i) <- data.zipWithIndex) {
          c.io.in.enqueue(probeOutputType.Lit(_.data -> v.U, _.last -> (i == data.length - 1).B))
          c.clock.step(Random.nextInt(3))
        }
      }
    }
    fork {  // output check task
      for(data <- datas) {
        c.io.out.expectDequeue(0x80.U)
        c.clock.step(Random.nextInt(3))
        for((v, i) <- data.zipWithIndex) {
          val numberOfOctets = (c.width + 6)/7
          // LSb first.
          for(octetIndex <- 0 until numberOfOctets) {
            val lower = octetIndex * 7
            val octet = (v >> lower) & 0x7f
            c.io.out.expectDequeue(octet.U)
            c.clock.step(Random.nextInt(3))
          }
        }
        c.io.out.expectDequeue(0x81.U)
      }
      c.io.out.valid.expect(false.B)
      c.clock.step(1)
      c.io.out.valid.expect(false.B)
      c.clock.step(1)
    }.join
  }
  
  it must "1bit" in { test(new ProbeFrameAdapter(1)).withAnnotations(Seq(VerilatorBackendAnnotation, WriteFstAnnotation)) { c =>
    testSequence(c, Seq((1 to 13).map(i => BigInt(i & 1))))
  } }

  it must "4bit" in { test(new ProbeFrameAdapter(4)).withAnnotations(Seq(VerilatorBackendAnnotation, WriteFstAnnotation)) { c =>
    testSequence(c, Seq((1 to 13).map(i => BigInt(i))))
  } }

  it must "7bit" in { test(new ProbeFrameAdapter(7)).withAnnotations(Seq(VerilatorBackendAnnotation, WriteFstAnnotation)) { c =>
    testSequence(c, Seq((1 to 127).map(i => BigInt(i))))
  } }

  it must "8bit" in { test(new ProbeFrameAdapter(8)).withAnnotations(Seq(VerilatorBackendAnnotation, WriteFstAnnotation)) { c =>
    testSequence(c, Seq((1 to 128).map(i => BigInt(i))))
  } }

  it must "14bit" in { test(new ProbeFrameAdapter(14)).withAnnotations(Seq(VerilatorBackendAnnotation, WriteFstAnnotation)) { c =>
    testSequence(c, Seq((1 to 15).map(i => BigInt(i * 0x400))))
  } }
  it must "16bit" in { test(new ProbeFrameAdapter(16)).withAnnotations(Seq(VerilatorBackendAnnotation, WriteFstAnnotation)) { c =>
    testSequence(c, Seq((1 to 15).map(i => BigInt(i * 0x1000))))
  } }

}
