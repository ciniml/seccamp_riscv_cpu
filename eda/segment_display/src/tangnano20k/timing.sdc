// timing.sdc
// Copyright 2022 Kenta IDA
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)


create_clock -name clock -period 37.037 -waveform {0 18.518} [get_ports {clock}]