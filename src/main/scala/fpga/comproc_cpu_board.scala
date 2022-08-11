// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2021.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

package fpga

import chisel3._
import chisel3.stage.ChiselStage
import cpu.Top
import cpu.TopWithHDMI

object Elaborate_ComProcCpuBoard extends App {
  (new ChiselStage).emitVerilog(new Top, Array(
    "-o", "riscv.v",
    "--target-dir", "rtl/comproc_cpu_board",
  ))
}

object Elaborate_ComProcCpuBoard_RustBootrom extends App {
  (new ChiselStage).emitVerilog(new Top(i =>  f"../sw-rs/bootrom-rs_${i}.hex"), Array(
    "-o", "riscv.v",
    "--target-dir", "rtl/comproc_cpu_board",
  ))
}

object Elaborate_ComProcCpuBoard_HDMI extends App {
  (new ChiselStage).emitVerilog(new TopWithHDMI, Array(
    "-o", "riscv.v",
    "--target-dir", "rtl/comproc_cpu_board_hdmi",
  ))
}