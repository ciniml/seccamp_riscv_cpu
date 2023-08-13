// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2021.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

package fpga

import chisel3._
import cpu.TopWithSegmentLed
import chisel3.stage.ChiselStage

object Elaborate_TangNanoPmod_SegmentLed extends App {
  val directory = args(0)
  val memorySize = args(1).toInt
  val bootromDir = args(2)
  (new ChiselStage).emitVerilog(new TopWithSegmentLed(memoryPathGen = i => f"${bootromDir}/bootrom_${i}.hex", memorySize = memorySize, forSimulation = false, enableProbe = false, useTargetPrimitive = true), Array(
    "--target-dir", directory,
  ))
}
