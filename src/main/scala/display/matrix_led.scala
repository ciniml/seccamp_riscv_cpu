// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2022.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

package display

import chisel3._
import chisel3.util._

case class MatrixLedConfig(rows: Int = 8, columns: Int = 8, val clockFreq: Int, refreshInterval: Int, refreshGuardInterval: Int)

class MatrixLed(val config: MatrixLedConfig) extends Module {
    val io = IO(new Bundle {
        val row = Output(UInt(config.rows.W))
        val column = Output(UInt(config.columns.W))
        val matrix = Input(Vec(config.rows, UInt(config.columns.W)))
    })

    val refreshCounter = RegInit(0.U(log2Ceil(config.refreshInterval).W))
    val rowReg = RegInit(1.U(config.rows.W))
    val rowEnable = WireDefault(true.B)
    
    io.row := Mux(rowEnable, rowReg, 0.U(config.columns.W))
    io.column := MuxCase(0.U, (0 to config.rows - 1).map(i => ((rowReg === (1.U << i), io.matrix(i)))))

    refreshCounter := refreshCounter + 1.U
    when( refreshCounter < (config.refreshInterval - config.refreshGuardInterval*2 - 1).U ) {
    } .elsewhen( refreshCounter === (config.refreshInterval - config.refreshGuardInterval - 1).U ) {
      rowEnable := false.B
      rowReg := (rowReg << 1) | rowReg(config.rows - 1)
    } .elsewhen( refreshCounter < (config.refreshInterval - 1).U ) {
      rowEnable := false.B
    } .elsewhen( refreshCounter === (config.refreshInterval - 1).U ) {
      refreshCounter := 0.U
    }
}
