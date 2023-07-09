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
  (new ChiselStage).emitVerilog(new TopWithSegmentLed, Array(
    "-o", "riscv.v",
    "--target-dir", "rtl/tangnano_pmod_segment_led",
  ))
}
