// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2021.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

package segled

import chisel3._
import chisel3.util._
import chisel3.experimental.ChiselEnum

class ShiftRegisterPort extends Bundle {
    val outputEnable = Output(Bool())
    val shiftClock = Output(Bool())
    val latch = Output(Bool())
    val data = Output(Bool())
}

object ShiftRegisterPort {
    def apply() = new ShiftRegisterPort
}

class SegmentLedWithShiftRegs(numberOfSegments: Int, numberOfDigits: Int, shiftClockDivider: Int, segmentUpdateDivider: Int, cathodeCommon: Boolean, isOEActiveLow: Boolean) extends Module {
    val io = IO(new Bundle {
        val segmentOut = ShiftRegisterPort()
        val digitSelector = ShiftRegisterPort()
        val digits = Input(Vec(numberOfDigits, UInt(numberOfSegments.W)))
    })

    val SEGMENT_UPDATE_COUNTER_BITS = log2Ceil(segmentUpdateDivider)
    val segmentUpdateCounter = RegInit(0.U(SEGMENT_UPDATE_COUNTER_BITS.W))
    val segmentLogic1 = cathodeCommon.B     // Segment output logic 1 level (cathode common: active high, anode common: active low)
    val digitLogic1 = (!cathodeCommon).B    // Digit selector output logic 1 level (cathode common: active low, anode common: active high)
    val outputEnableLogic1 = !isOEActiveLow.B   // Output enable output logic 1 level

    object State extends ChiselEnum {
        val Reset, SetupDigit, ShiftDigit, SetupSegment, ShiftSegment, OutputDigit, HoldDigit = Value
    }
    val state = RegInit(State.Reset)
    val digitIndex = RegInit(0.U(log2Ceil(numberOfDigits).W))
    val segmentCounter = RegInit(0.U(log2Ceil(numberOfSegments).W))
    val shiftClockCounter = RegInit(0.U(log2Ceil(shiftClockDivider + 1).W))
    val segmentShiftReg = RegInit(0.U(numberOfSegments.W))

    val segmentOutputEnable = RegInit(!outputEnableLogic1)
    val segmentShiftClock = RegInit(false.B)
    val segmentLatch = RegInit(false.B)
    val segmentData = RegInit(!segmentLogic1)
    val digitOutputEnable = RegInit(!outputEnableLogic1)
    val digitShiftClock = RegInit(false.B)
    val digitLatch = RegInit(false.B)
    val digitData = RegInit(!segmentLogic1)
    
    io.segmentOut.outputEnable := segmentOutputEnable
    io.segmentOut.shiftClock := segmentShiftClock
    io.segmentOut.latch := segmentLatch
    io.segmentOut.data := segmentData
    io.digitSelector.outputEnable := digitOutputEnable
    io.digitSelector.shiftClock := digitShiftClock
    io.digitSelector.latch := digitLatch
    io.digitSelector.data := digitData
    
    switch(state) {
        is(State.Reset) {
            digitIndex := 0.U
            segmentCounter := 0.U
            shiftClockCounter := 0.U
            segmentLatch := false.B
            digitLatch := false.B
            digitOutputEnable := !outputEnableLogic1
            segmentOutputEnable := !outputEnableLogic1
            state := State.SetupDigit
        }
        is( State.SetupDigit ) {
            // output low to latch signals to output positive edge in OutputDigit state.
            digitLatch := false.B
            segmentLatch := false.B
            
            // Setup the digit selector output
            digitData := Mux(digitIndex === 0.U, digitLogic1, !digitLogic1) // shift in logic 1 if this is the first digit. otherwise just shift the register.
            digitShiftClock := false.B
            shiftClockCounter := shiftClockDivider.U
            segmentShiftReg := io.digits(digitIndex)
            segmentCounter := (numberOfSegments - 1).U
            state := State.ShiftDigit

            // update digit index to next digit
            digitIndex := Mux(digitIndex === (numberOfDigits - 1).U, 0.U, digitIndex + 1.U)
        }
        is( State.ShiftDigit ) {
            when( shiftClockCounter === 0.U ) {
                digitShiftClock := !digitShiftClock
                shiftClockCounter := shiftClockDivider.U
                when( digitShiftClock ) {
                    state := State.SetupSegment
                }
            } .otherwise {
                shiftClockCounter := shiftClockCounter - 1.U
            }
        }
        is( State.SetupSegment ) {
            segmentData := Mux(segmentShiftReg(numberOfSegments - 1), segmentLogic1, !segmentLogic1)
            segmentShiftReg := Cat(segmentShiftReg(numberOfSegments - 2, 0), 0.U(1.W))
            segmentShiftClock := false.B
            shiftClockCounter := shiftClockDivider.U
            state := State.ShiftSegment
        }
        is( State.ShiftSegment ) {
            when( shiftClockCounter === 0.U ) {
                segmentShiftClock := !segmentShiftClock
                shiftClockCounter := shiftClockDivider.U
                when( segmentShiftClock ) {
                    when( segmentCounter === 0.U ) {
                        state := State.OutputDigit
                    } .otherwise {
                        segmentCounter := segmentCounter - 1.U
                        state := State.SetupSegment
                    }
                }
            } .otherwise {
                shiftClockCounter := shiftClockCounter - 1.U
            }
        }
        is( State.OutputDigit ) {
            // Latches both the digit selector and segment output and then enable these outputs.
            digitLatch := true.B
            segmentLatch := true.B
            digitOutputEnable := outputEnableLogic1
            segmentOutputEnable := outputEnableLogic1
            segmentUpdateCounter := segmentUpdateDivider.U
            state := State.HoldDigit
        }
        is( State.HoldDigit ) {
            // Wait until the segment update counter reaches 0.
            when ( segmentUpdateCounter === 0.U ) {
                state := State.SetupDigit
            } .otherwise {
                segmentUpdateCounter := segmentUpdateCounter - 1.U
            }
        }
    }
}