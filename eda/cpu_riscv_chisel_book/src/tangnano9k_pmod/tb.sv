/*
 * @file tb.sv
 * @brief Testbench for i2c_slave module
 */
// Copyright 2019 Kenta IDA
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)


`timescale 10ns/1ps

module tb ();
    localparam I2C_REG_ADDRESS_WIDTH = 8;
    localparam I2C_CLOCK_PERIOD = 1000;

    logic clock;
    logic reset;
    logic [7:0] row;
    logic [7:0] d;
    logic seven_seg;
    logic [5:0] led;
    logic lcd_rs;
    logic lcd_rw;
    logic lcd_e;
    logic [3:0] lcd_db;
    logic uart_tx;
    logic uart_rx;
    logic [5:0] debug_out;
    logic button_s2 = 1;

    initial begin
        forever begin
            clock = 1;
            #2;
            clock = 0;
            #2;
        end
    end

    assign uart_rx = 1;
    top dut (
        .*
    );


    initial begin
        $dumpfile("output.vcd");
        $dumpvars;

        reset <= 1;
        
        repeat(2) @(posedge clock);
        reset <= 0;
        @(posedge clock);
        
        repeat(10000) @(posedge clock);

        $finish;
    end
endmodule