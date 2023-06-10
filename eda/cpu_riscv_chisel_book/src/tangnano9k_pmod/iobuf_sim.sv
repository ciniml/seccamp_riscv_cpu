/*
 * @file iobuf_sim.v
 * @brief IOBUF module for iverilog simulation.
 */
// Copyright 2019 Kenta IDA
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)


module IOBUF (
    output wire O,
    input wire I,
    inout wire IO,
    input wire OEN
);

assign O = IO;
assign IO = !OEN ? I : 1'bz;

endmodule