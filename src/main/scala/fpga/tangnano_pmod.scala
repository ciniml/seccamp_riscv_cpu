// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2021.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

package fpga

import chisel3._
import chisel3.stage.ChiselStage
import cpu.TopWithSegmentLed

object Elaborate_TangNanoPmod_SegmentLed extends App {
  val directory = args(0)
  val filename = args(1)
  val memorySize = args(2).toInt
  (new ChiselStage).emitVerilog(new TopWithSegmentLed(memorySize = memorySize), Array(
    "-o", filename,
    "--target-dir", directory,
  ))
}
