// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2023.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

package diag

import chisel3._
import chisel3.util._
import chisel3.experimental.ChiselEnum

/**
  * Probe configuration
  *
  * @param bufferDepth Number of entries the probe buffer can hold.
  * @param triggerPosition Position in the buffer at which the trigger is placed.
  */
case class ProbeConfig(val bufferDepth: Int = 1024, val triggerPosition: Int = 512)

/**
  * Probe output signal
  *
  * @param width Width of the output signal.
  */
class ProbeOutput(width: Int) extends Bundle {
    val data = UInt(width.W)
    val last = Bool()
}
object ProbeOutput {
    def apply(width: Int): ProbeOutput = {
        new ProbeOutput(width)
    }
}

/**
  * Embedded logic probe module which stores signals in the buffer.
  *
  * @param config configuration of the probe.
  * @param width number of bits of the input signal.
  */
class Probe(val config: ProbeConfig, val width: Int) extends Module {
    val io = IO(new Bundle{
        val in = Input(UInt(width.W))
        val out = Decoupled(ProbeOutput(width))
        val trigger = Input(Bool())
        val triggered = Output(Bool())
    })

    object State extends ChiselEnum {
        val Reset, FillPreTrigger, AwaitingTrigger, FillPostTrigger, Output = Value
    }

    assert(isPow2(config.bufferDepth), "Probe buffer depth must be a power of 2")

    val state = RegInit(State.Reset)
    val flushBuffer = WireDefault(state === State.Reset)

    val in = Wire(Decoupled(UInt(width.W)))
    in.valid := false.B
    in.bits := io.in

    val buffer = Queue(in, config.bufferDepth, useSyncReadMem = true, flush = Some(flushBuffer))
    val triggerPosition = WireDefault(config.triggerPosition.U(config.bufferDepth.W))
    val triggerCount = RegInit(0.U(log2Ceil(config.bufferDepth).W))
    
    val bufferReady = WireDefault(false.B)
    buffer.ready := bufferReady
    val outValid = RegInit(false.B)
    val outData = RegInit(0.U(width.W))
    val outLast = WireDefault(false.B)

    io.out.valid := outValid
    io.out.bits.data := outData
    io.out.bits.last := outLast

    val triggered = WireDefault(false.B)
    io.triggered := triggered

    val hasTriggered = RegInit(false.B)
    when( io.trigger ) {
        hasTriggered := true.B
    }

    switch(state) {
        is(State.Reset) {
            triggerCount := 0.U
            outValid := false.B
            outLast := false.B
            
            when( triggerPosition === 0.U ) {
                // If no pre-trigger data is required, go directly to awaiting trigger state.
                state := State.AwaitingTrigger
            } .otherwise {
                // Fill the buffer with pre-trigger data.
                state := State.FillPreTrigger
            }
        }
        is( State.FillPreTrigger) {
            in.valid := true.B
            triggerCount := triggerCount + 1.U
            when(triggerCount === triggerPosition - 1.U) {
                state := State.AwaitingTrigger
            }
        }
        is( State.AwaitingTrigger ) {
            in.valid := true.B
            when( io.trigger || hasTriggered ) {    // Trigger condition has been met.
                triggered := true.B
                state := State.FillPostTrigger
            } .otherwise {
                bufferReady := true.B   // Discard the oldest data.
            }
        }
        is( State.FillPostTrigger ) {
            in.valid := true.B
            when( !in.ready ) {
                // Buffer is filled.
                state := State.Output
            }
        }
        is( State.Output ) {
            // Clear triggered flag
            hasTriggered := false.B
            // Connect the internal buffer to output stream
            outLast := !buffer.valid
            when( !outValid || io.out.ready ) {
                outValid := buffer.valid
                outData := buffer.bits
                bufferReady := true.B
            }
            when( outValid && io.out.ready && outLast ) {
                state := State.Reset
            }
        }
    }
}

/**
  * Probe output width converter for the probe output via 8bit stream.
  * The input signal is split into 7bit chunks and padded with 0s from LSb to MSb (LSb first)
  * @param width width of the input signal.
  */
class ProbeOutWidthConverter(val width: Int) extends Module {
    val io = IO(new Bundle {
        val in = Flipped(Decoupled(ProbeOutput(width)))
        val out = Decoupled(ProbeOutput(8))
    })

    val numberOfPhases = (width + 6) / 7
    val inputWidthWithPadding = numberOfPhases * 7
    val paddingWidth = inputWidthWithPadding - width

    if( numberOfPhases == 1 ) {
        io.out.valid <> io.in.valid 
        io.out.ready <> io.in.ready
        io.out.bits.data <> io.in.bits.data
        io.out.bits.last <> io.in.bits.last
    } else {
        val phaseCounter = RegInit(0.U(log2Ceil(numberOfPhases + 1).W))
        val inData = RegInit(0.U(inputWidthWithPadding.W))
        val inLast = RegInit(false.B)
        val outValid = RegInit(false.B)
        val outData = RegInit(0.U(7.W))
        val outLast = RegInit(false.B)
        
        io.in.ready := phaseCounter === 0.U
        io.out.valid := outValid
        io.out.bits.data := Cat(0.U(1.W), outData)
        io.out.bits.last := outLast

        when(outValid && io.out.ready) {
            outValid := false.B
        }
        when(io.in.valid && io.in.ready) {
            //printf(p"WC: in=${Hexadecimal(io.in.bits.data)} last=${io.in.bits.last}\n")
            inData := io.in.bits.data
            inLast := io.in.bits.last
            phaseCounter := numberOfPhases.U
        }
        when( phaseCounter > 0.U && (!outValid || io.out.ready)) {
            phaseCounter := phaseCounter - 1.U
            outValid := true.B
            for(phase <- 1 to numberOfPhases) {
                when(phaseCounter === phase.U) {
                    //printf(p"WC: out(${phaseCounter})=${Hexadecimal(inData(phase * 7 - 1, (phase - 1) * 7))}\n")
                    outData := inData((numberOfPhases - phase + 1) * 7 - 1, (numberOfPhases - phase) * 7)
                }
            }
            outLast := phaseCounter === 1.U && inLast
        }
        //printf(p"valid=${io.out.valid} ready=${io.out.ready} data=${Hexadecimal(io.out.bits.data)} last=${io.out.bits.last}\n")
    }
}

/**
  * Probe frame adapter for the probe output via 8bit stream.
  * The input signal from the probe is encapsulated into a frame, which consists of a SOF marker, the data and an EOF marker.
  * @param width
  */
class ProbeFrameAdapter(val width: Int) extends Module {
    val START_OF_FRAME = 0x80
    val END_OF_FRAME = 0x81
    
    val io = IO(new Bundle {
        val in = Flipped(Decoupled(ProbeOutput(width)))
        val out = Decoupled(UInt(8.W))
    })

    object State extends ChiselEnum {
        val Idle, InFrame, EndOfFrame = Value
    }

    val widthConverter = Module(new ProbeOutWidthConverter(width))
    widthConverter.io.in <> io.in
    val inReady = WireDefault(false.B)
    widthConverter.io.out.ready := inReady
    
    val outValid = RegInit(false.B)
    val outData = RegInit(0.U(8.W))
    io.out.valid := outValid
    io.out.bits := outData

    val state = RegInit(State.Idle)

    when(outValid && io.out.ready) {
        outValid := false.B
    }

    switch(state) {
        is(State.Idle) {
            when(widthConverter.io.out.valid && (!outValid || io.out.ready)) {
                // Put SOF marker
                outValid := true.B
                outData := START_OF_FRAME.U
                state := State.InFrame
                //printf(p"SOF\n")
            }
        }
        is(State.InFrame) {
            inReady := !outValid || io.out.ready
            when(widthConverter.io.out.valid && inReady ) {
                outValid := true.B
                outData := widthConverter.io.out.bits.data
                //printf(p"DATA: ${Hexadecimal(widthConverter.io.out.bits.data)}, LAST: ${widthConverter.io.out.bits.last}}\n")
                when(widthConverter.io.out.bits.last) {
                    state := State.EndOfFrame
                }
            }
        }
        is(State.EndOfFrame) {
            when( !outValid || io.out.ready ) {
                // Put EOF marker
                //printf(p"EOF\n")
                outValid := true.B
                outData := END_OF_FRAME.U
                state := State.Idle
            }
        }
    }
}