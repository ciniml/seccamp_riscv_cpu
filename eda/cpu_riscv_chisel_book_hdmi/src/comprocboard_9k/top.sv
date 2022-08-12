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
    //output logic tmds_clk_n,
    output logic [2:0] tmds_data_p,
    //output logic [2:0] tmds_data_n,

    // Debug
    output logic [5:0] debug_out
);

assign debug_out = 0;

logic clock_dvi;
logic pll_lock;
logic clock_dvi_ser;
logic pll_lock_ser;

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
  .reset_in(reset_button[0] || !pll_lock || !pll_lock_ser),
  .reset_out(reset_ext)
);

gowin_rpll_dvi rpll_dvi(
    .clkout(clock_dvi), //output clkout
    .lock(pll_lock), //output lock
    .clkin(clock) //input clkin
);
gowin_rpll_ser rpll_dvi_ser(
    .clkout(clock_dvi_ser), //output clkout
    .lock(pll_lock_ser), //output lock
    .clkin(clock_dvi) //input clkin
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
logic [9:0] io_dvi_clock;
logic [9:0] io_dvi_data0;
logic [9:0] io_dvi_data1;
logic [9:0] io_dvi_data2;

assign led = ~{4'b000, pll_lock, pll_lock_ser}; // ~io_gpio_out[5:0]; //~{3'b000, reset, io_success, io_exit};

TopWithHDMI core(
  .clock(clock),
  .io_uart_tx(uart_tx),
  .io_uart_rx(uart_rx),
  .io_pixel_reset(reset_dvi),
  .io_pixel_clock(clock_dvi),
  .*
);

OSER10 #(
  .GSREN("false"),
  .LSREN("true")
) oser_dvi_clock(
  .Q(tmds_clk_p),
  .D0(io_dvi_clock[0]),
  .D1(io_dvi_clock[1]),
  .D2(io_dvi_clock[2]),
  .D3(io_dvi_clock[3]),
  .D4(io_dvi_clock[4]),
  .D5(io_dvi_clock[5]),
  .D6(io_dvi_clock[6]),
  .D7(io_dvi_clock[7]),
  .D8(io_dvi_clock[8]),
  .D9(io_dvi_clock[9]),
  .FCLK(clock_dvi_ser),
  .PCLK(clock_dvi),
  .RESET(reset_dvi)
);
OSER10 #(
  .GSREN("false"),
  .LSREN("true")
) oser_dvi_data0(
  .Q(tmds_data_p[0]),
  .D0(io_dvi_data0[0]),
  .D1(io_dvi_data0[1]),
  .D2(io_dvi_data0[2]),
  .D3(io_dvi_data0[3]),
  .D4(io_dvi_data0[4]),
  .D5(io_dvi_data0[5]),
  .D6(io_dvi_data0[6]),
  .D7(io_dvi_data0[7]),
  .D8(io_dvi_data0[8]),
  .D9(io_dvi_data0[9]),
  .FCLK(clock_dvi_ser),
  .PCLK(clock_dvi),
  .RESET(reset_dvi)
);
OSER10 #(
  .GSREN("false"),
  .LSREN("true")
) oser_dvi_data1(
  .Q(tmds_data_p[1]),
  .D0(io_dvi_data1[0]),
  .D1(io_dvi_data1[1]),
  .D2(io_dvi_data1[2]),
  .D3(io_dvi_data1[3]),
  .D4(io_dvi_data1[4]),
  .D5(io_dvi_data1[5]),
  .D6(io_dvi_data1[6]),
  .D7(io_dvi_data1[7]),
  .D8(io_dvi_data1[8]),
  .D9(io_dvi_data1[9]),
  .FCLK(clock_dvi_ser),
  .PCLK(clock_dvi),
  .RESET(reset_dvi)
);
OSER10 #(
  .GSREN("false"),
  .LSREN("true")
) oser_dvi_data2(
  .Q(tmds_data_p[2]),
  .D0(io_dvi_data2[0]),
  .D1(io_dvi_data2[1]),
  .D2(io_dvi_data2[2]),
  .D3(io_dvi_data2[3]),
  .D4(io_dvi_data2[4]),
  .D5(io_dvi_data2[5]),
  .D6(io_dvi_data2[6]),
  .D7(io_dvi_data2[7]),
  .D8(io_dvi_data2[8]),
  .D9(io_dvi_data2[9]),
  .FCLK(clock_dvi_ser),
  .PCLK(clock_dvi),
  .RESET(reset_dvi)
);

endmodule
`default_nettype wire