// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2022-2023.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

package uart

import chisel3._
import chisel3.util._

class UartTx(numberOfBits: Int, baudDivider: Int) extends Module {
    val io = IO(new Bundle{
        val in = Flipped(Decoupled(UInt(numberOfBits.W)))
        val tx = Output(Bool())
    })

    val rateCounter = RegInit(0.U(log2Ceil(baudDivider).W))
    val bitCounter = RegInit(0.U(log2Ceil(numberOfBits + 2).W))
    val bits = Reg(Vec(numberOfBits + 2, Bool()))

    io.tx := bitCounter === 0.U || bits(0)
    io.in.ready := bitCounter === 0.U
    
    when(io.in.valid && io.in.ready) {
        bits := Cat(1.U, io.in.bits, 0.U).asBools   // STOP(1), DATA, START(0)
        bitCounter := (numberOfBits + 2).U
        rateCounter := (baudDivider - 1).U
    }

    when( bitCounter > 0.U ) {
        when(rateCounter === 0.U) {
            // Shift out from LSB
            (0 to numberOfBits).foreach(i => bits(i) := bits(i + 1))
            bitCounter := bitCounter - 1.U
            rateCounter := (baudDivider - 1).U
        } .otherwise {
            rateCounter := rateCounter - 1.U
        }
    }
}