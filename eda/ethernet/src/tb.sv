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
    logic [5:0] led_out;
    logic [7:0] switch_in;
    logic [7:0] anode;
    logic [7:0] cathode;
    logic uart_rx;
    logic uart_tx;
    logic       rmii_txclk;
    logic [1:0] rmii_rxd;
    logic       rmii_crs_dv;
    logic [1:0] rmii_txd;
    logic       rmii_txen;
    logic       rmii_mdio;
    logic       rmii_mdc;
    logic       rmii_rstn;
    logic       probe_out;

    initial begin
        forever begin
            clock = 1;
            #5;
            clock = 0;
            #5;
        end
    end
    initial begin
        forever begin
            rmii_txclk = 1;
            #2;
            rmii_txclk = 0;
            #2;
        end
    end
    assign switch_in = 0;
    assign uart_rx = 1;
    top dut (
        .*
    );


    localparam int RECEIVE_DATA_LEN = 8 + 6 + 6 + 2 + 4;
    bit [7:0] RECEIVE_DATA[0:RECEIVE_DATA_LEN - 1] = '{
        8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'hd5,
        8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff,
        8'h00, 8'h11, 8'h22, 8'h33, 8'h44, 8'h55,
        8'h08, 8'h06,
        8'h00, 8'h00, 8'h00, 8'h00 // FCS
    };
    int receive_counter;

    initial begin
        receive_counter = 0;
    end
    always @(negedge rmii_txclk) begin
        rmii_crs_dv <= 0;
        if( !rmii_rstn ) begin
            receive_counter <= 0;
        end
        else begin
            if( receive_counter < RECEIVE_DATA_LEN*4 ) begin
                rmii_crs_dv <= 1;
                rmii_rxd <= RECEIVE_DATA[receive_counter >> 2] >> (2 * ((receive_counter & 3)));
            end
            if( receive_counter < RECEIVE_DATA_LEN*4 + 20 ) begin
                receive_counter <= receive_counter + 1;
            end
            else begin
                receive_counter <= 0;
            end
        end
    end

    initial begin
        $dumpfile("output.vcd");
        $dumpvars;

        reset = 1;
        
        repeat(2) @(posedge clock);
        reset = 0;
        @(posedge clock);
        
        repeat(10000) @(posedge clock);

        $finish;
    end
endmodule