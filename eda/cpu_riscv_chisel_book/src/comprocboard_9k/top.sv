/**
 * @file top.sv
 * @brief Top module for RISC-V Chisel Book CPU core
 */
// Copyright 2022 Kenta IDA
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

`default_nettype none
module top(
    input wire clock,

    // Input button
    input wire button_s2,

    // LED matrix + 7+1 seg LED
    output logic [7:0] row,
    output logic [7:0] d,
    output logic seven_seg,

    // Tang Nano On Board LEDs
    output logic [5:0] led,

    // Character LCD
    output logic lcd_rs,
    output logic lcd_rw,
    output logic lcd_e,
    inout wire [3:0] lcd_db,

    // UART
    output logic uart_tx,
    input wire uart_rx,

    // Debug
    output logic [5:0] debug_out
);

assign row = '1;
//assign d = 8'b0000_1111;
assign seven_seg = 0;
assign lcd_rs = 0;
assign lcd_rw = 0;
assign lcd_e = 0;
assign lcd_db = 0;
assign uart_tx = 0;
assign debug_out = 0;

// Reset sequencer.
logic [15:0] reset_seq;
initial begin
  reset_seq = '1;
end
always_ff @(posedge clock) begin
  if(!button_s2) begin
    reset_seq = '1;
  end
  else begin
    reset_seq <= reset_seq >> 1;
  end
end
logic reset;
assign reset = reset_seq[0];

logic [31:0] io_debug_pc;
logic [31:0] io_gpio_out;
logic io_success;
logic io_exit;

assign d = io_debug_pc[9:2];

logic cpu_halt = 0;
always_ff @(posedge clock) begin
  if( reset ) begin
    cpu_halt <= 0;
  end
  else begin
    if( io_exit ) begin
      cpu_halt <= 1;
    end
  end
end

assign led = ~io_gpio_out[5:0]; //~{3'b000, reset, io_success, io_exit};

Top core(
  .clock(clock && !cpu_halt),
  .*
);

endmodule
`default_nettype wire