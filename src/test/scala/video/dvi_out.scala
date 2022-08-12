package video

import chisel3._
import chisel3.util._
import chiseltest._
import scala.util.control.Breaks
import org.scalatest.flatspec.AnyFlatSpec

class DviOutTest extends AnyFlatSpec with ChiselScalatestTester {
    it must "runs DviOut" in { 
    test(new DviOut)
            .withAnnotations(Seq(VerilatorBackendAnnotation, WriteFstAnnotation)) 
        { c =>
            val totalCycles = 10000
            c.reset.poke(true.B)
            c.clock.step(4)
            c.reset.poke(false.B)
            c.clock.setTimeout(totalCycles + 10)
            c.clock.step(10)
            c.io.video.hSync.poke(true.B)
            c.clock.step(3)
            c.io.video.hSync.poke(false.B)
            c.io.video.vSync.poke(true.B)
            c.clock.step(3)
            c.io.video.vSync.poke(false.B)
            c.clock.step(1)
            c.io.video.dataEnable.poke(true.B)
            for(i <- 0 to 999) {
                c.io.video.pixelData.poke(i.U)
                c.clock.step(1)
            }
            c.io.video.dataEnable.poke(false.B)
            c.clock.step(totalCycles - 20 - 1000)
        } 
    }
  
}
