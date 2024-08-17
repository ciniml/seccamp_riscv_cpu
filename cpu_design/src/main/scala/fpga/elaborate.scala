// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2021-2024.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

package fpga

import chisel3._
import cpu.{Top, TopWithHDMI, TopWithSegmentLed, TopWithStepper}
import _root_.circt.stage.ChiselStage
import cpu.TopWithEthernet

object Elaborate_Minimal extends App {
  val directory = args(0)
  val memorySize = args(1).toInt
  val bootromDir = args(2)
  ChiselStage.emitSystemVerilogFile(
    new Top(memoryPathGen = i => f"${bootromDir}/bootrom_${i}.hex"), 
    Array("--target-dir", directory),
    Array("--lowering-options=disallowLocalVariables")
  )
}

object Elaborate_HDMI extends App {
  val directory = args(0)
  val memorySize = args(1).toInt
  val bootromDir = args(2)
  ChiselStage.emitSystemVerilogFile(
    new TopWithHDMI(memoryPathGen = i => f"${bootromDir}/bootrom_${i}.hex"), 
    Array("--target-dir", directory),
    Array("--lowering-options=disallowLocalVariables")
  )
}

object Elaborate_SegmentLed extends App {
  val directory = args(0)
  val memorySize = args(1).toInt
  val bootromDir = args(2)
  ChiselStage.emitSystemVerilogFile(
    new TopWithSegmentLed(memoryPathGen = i => f"${bootromDir}/bootrom_${i}.hex", memorySize = memorySize, forSimulation = false, enableProbe = true, useTargetPrimitive = false), 
    Array("--target-dir", directory),
    Array("--lowering-options=disallowLocalVariables")
  )
}

object Elaborate_Ethernet extends App {
  val directory = args(0)
  val memorySize = args(1).toInt
  val bootromDir = args(2)
  ChiselStage.emitSystemVerilogFile(
    new TopWithEthernet(memoryPathGen = i => f"${bootromDir}/bootrom_${i}.hex", memorySize = memorySize, forSimulation = false, enableProbe = true, useTargetPrimitive = false), 
    Array("--target-dir", directory),
    Array("--lowering-options=disallowLocalVariables")
  )
}

object Elaborate_Stepper extends App {
  val directory = args(0)
  val memorySize = args(1).toInt
  val bootromDir = args(2)
  ChiselStage.emitSystemVerilogFile(
    new TopWithStepper(memoryPathGen = i => f"${bootromDir}/bootrom_${i}.hex", memorySize = memorySize, forSimulation = false, enableProbe = false, useTargetPrimitive = true), 
    Array("--target-dir", directory),
    Array("--lowering-options=disallowLocalVariables")
  )
}
