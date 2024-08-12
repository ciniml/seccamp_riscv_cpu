// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2021-2024.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

package fpga

import chisel3._
import _root_.circt.stage.ChiselStage
import cpu.Top

object Elaborate_Minimal extends App {
  ChiselStage.emitSystemVerilogFile(
    new Top, 
    Array(
      "--target-dir", "rtl/chisel_output",
    ),
    Array("--lowering-options=disallowLocalVariables")
  )
}

