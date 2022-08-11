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

    // // LED matrix + 7+1 seg LED
    // output logic [7:0] row,
    // output logic [7:0] d,
    // output logic seven_seg,

    // Tang Nano On Board LEDs
    output logic [5:0] led,

    // // Character LCD
    // output logic lcd_rs,
    // output logic lcd_rw,
    // output logic lcd_e,
    // inout wire [3:0] lcd_db,

    // UART
    output logic uart_tx,
    input wire uart_rx,

    // DVI
    output logic tmds_clk_p,
    output logic tmds_clk_n,
    output logic [2:0] tmds_data_p,
    output logic [2:0] tmds_data_n,

    // Debug
    output logic [5:0] debug_out
);

assign debug_out = 0;

logic clock_dvi;
logic pll_lock;

logic [2:0] reset_button = '1;
always_ff @(posedge clock) begin
  reset_button <= {!button_s2, reset_button[2:1]};
end

logic reset;
reset_seq reset_seq_int(
  .clock(clock),
  .reset_in(reset_button[0]),
  .reset_out(reset)
);

logic reset_ext;
reset_seq reset_seq_ext(
  .clock(clock_dvi),
  .reset_in(reset_button[0] || !pll_lock),
  .reset_out(reset_ext)
);

Gowin_rPLL rpll_main(
    .clkout(clock_dvi), //output clkout
    .lock(pll_lock), //output lock
    .clkin(clock) //input clkin
);

logic reset_dvi;
reset_seq #( .RESET_DELAY_CYCLES(4) ) reset_seq_dvi(
  .clock(clock_dvi),
  .reset_in(reset_ext),
  .reset_out(reset_dvi)
);

logic [31:0] io_debug_pc;
logic [31:0] io_gpio_out;
logic io_success;
logic io_exit;
logic io_rgb_vs;
logic io_rgb_hs;
logic io_rgb_de;
logic [7:0] io_rgb_r;
logic [7:0] io_rgb_g;
logic [7:0] io_rgb_b;

//assign d = io_debug_pc[9:2];

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

logic cpu_clock;
assign cpu_clock = clock && !cpu_halt;

TopWithHDMI core(
  .clock(cpu_clock),
  .io_uart_tx(uart_tx),
  .io_uart_rx(uart_rx),
  .io_pixel_reset(reset_dvi),
  .io_pixel_clock(clock_dvi),
  .*
);

DVI_TX_Top dvi_tx(
  .I_rst_n(!reset_dvi), //input I_rst_n
  .I_rgb_clk(clock_dvi), //input I_rgb_clk
  .I_rgb_vs(!io_rgb_vs), //input I_rgb_vs
  .I_rgb_hs(!io_rgb_hs), //input I_rgb_hs
  .I_rgb_de(io_rgb_de), //input I_rgb_de
  .I_rgb_r(io_rgb_r), //input [7:0] I_rgb_r
  .I_rgb_g(io_rgb_g), //input [7:0] I_rgb_g
  .I_rgb_b(io_rgb_b), //input [7:0] I_rgb_b
  .O_tmds_clk_p(tmds_clk_p), //output O_tmds_clk_p
  .O_tmds_clk_n(tmds_clk_n), //output O_tmds_clk_n
  .O_tmds_data_p(tmds_data_p), //output [2:0] O_tmds_data_p
  .O_tmds_data_n(tmds_data_n) //output [2:0] O_tmds_data_n
);

endmodule
`default_nettype wire