// timing.sdc
// Copyright 2022 Kenta IDA
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)


create_clock -name clock -period 37.037 -waveform {0 18.518} [get_ports {clock}]
set_false_path -from [get_pins {reset_button_0_s1/Q}] -to [get_pins {reset_seq_ext/reset_seq*/SET}]
set_false_path -from [get_pins {reset_button_0_s1/Q}] -to [get_pins {reset_seq_ext/reset_seq*/D}]
set_false_path -from [get_pins {reset_seq_dvi/reset_seq_0_s0/Q}] -to [get_pins {oser_dvi_*/RESET}]
set_false_path -from [get_pins {core/videoController/hSync_s0/Q}] -to [get_pins {core/videoController/hSyncReg_1_s0/D}]
set_false_path -from [get_pins {core/videoController/vSync_s0/Q}] -to [get_pins {core/videoController/vSyncReg_1_s0/D}]
set_false_path -from [get_pins {core/videoController/dataEnableReg_1_s0_0/Q}] -to [get_pins {core/videoController/dataEnableReg_1_s0/D}]