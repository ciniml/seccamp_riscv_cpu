/**
* @file top.sv
* @brief Top module for seccamp RISC-V CPU with Ethernet
*/
// Copyright 2024 Kenta IDA
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)
`default_nettype none

module top (
  input  wire  clock,

  // 6-digit 7+1-segment LED
  // output logic com_ser,
  // output logic com_rclk,
  // output logic com_srclk,
  // output logic com_oe,
  // output logic seg_ser,
  // output logic seg_rclk,
  // output logic seg_srclk,
  // output logic seg_oe,
  
  // Tang Nano 9K on board LED
  output logic [5:0] led_out,

  // Push switches
  input  wire  [7:0] switch_in,
  
  // Matrix LED
  // output logic [7:0] anode,
  // output logic [7:0] cathode,
  
  // UART
  input  wire  uart_rx,
  output logic uart_tx,

  // RMII PHY interface
  input  wire        rmii_txclk,
  input  wire  [1:0] rmii_rxd,
  input  wire        rmii_crs_dv,
  output logic [1:0] rmii_txd,
  output logic       rmii_txen,
  input  wire        rmii_mdio,
  output logic       rmii_mdc,
  output logic       rmii_rstn,

  // DVI
  output logic tmds_clk_p,
  //output logic tmds_clk_n,
  output logic [2:0] tmds_data_p,
  //output logic [2:0] tmds_data_n,
    
  // Debug probe output
  output logic probe_out
);

  logic io_exit;

  // リセット回路 (16サイクル)
  logic reset;
  logic [15:0] reset_reg = '1;
  assign reset = reset_reg[0];
  always_ff @(posedge clock) begin
      reset_reg <= {1'b0, reset_reg[15:1]};
  end

  // DVI  
  logic clock_dvi;
  logic pll_lock_dvi;
  logic clock_dvi_ser;
  logic pll_lock_ser;
  gowin_rpll_dvi rpll_dvi(
      .clkout(clock_dvi), //output clkout
      .lock(pll_lock_dvi), //output lock
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
    .reset_in(0),
    .reset_out(reset_dvi)
  );

  logic reset_rmii;
  reset_seq reset_seq_ext(
    .clock(rmii_txclk),
    .reset_in(0),
    .reset_out(reset_rmii)
  );

  // RMII interfaces
  assign rmii_rstn = !reset_rmii;
  assign rmii_mdc = 0;

  logic [7:0] tx_saxis_tdata;
  logic       tx_saxis_tvalid;
  logic       tx_saxis_tready;
  logic       tx_saxis_tlast;

  logic [7:0] rx_maxis_tdata;
  logic       rx_maxis_tvalid;
  logic       rx_maxis_tready;
  logic       rx_maxis_tlast;
  logic       rx_maxis_tuser;

  rmii_mac rmii_mac_inst (
    .tx_clock(rmii_txclk),
    .tx_reset(reset_rmii),
    .tx_rmii_d(rmii_txd),
    .tx_rmii_en(rmii_txen),
    .rx_clock(rmii_txclk),
    .rx_reset(reset_rmii),
    .rx_rmii_d(rmii_rxd),
    .rx_rmii_dv(rmii_crs_dv),
    .tx_saxis_bypass_tdata(0),
    .tx_saxis_bypass_tvalid(0),
    .tx_saxis_bypass_tready(),
    .tx_saxis_bypass_tlast(0),
    .*
  );

  logic io_uartTx_0;
  logic io_uartRx_0;
  logic io_uartTx_1;
  logic io_uartRx_1 = 1'b1;
  logic io_segmentOut_outputEnable;
  logic io_segmentOut_shiftClock;
  logic io_segmentOut_latch;
  logic io_segmentOut_data;
  logic io_digitSelector_outputEnable;
  logic io_digitSelector_shiftClock;
  logic io_digitSelector_latch;
  logic io_digitSelector_data;
  logic [31:0] io_ledOut;
  logic [31:0] io_switchIn;
  logic [7:0]  io_matrixColumnOut;
  logic [7:0]  io_matrixRowOut;
  logic [31:0] io_dviDigitsOut;
  logic io_probeOut;
  
  always_comb begin
    // com_oe    <= io_digitSelector_outputEnable;
    // com_srclk <= io_digitSelector_shiftClock;
    // com_rclk  <= io_digitSelector_latch;
    // com_ser   <= io_digitSelector_data;
    // seg_oe    <= io_segmentOut_outputEnable;
    // seg_srclk <= io_segmentOut_shiftClock;
    // seg_rclk  <= io_segmentOut_latch;
    // seg_ser   <= io_segmentOut_data;

    led_out   <= ~io_ledOut[5:0];
    io_switchIn <= {24'd0, switch_in};
    //anode     <= io_matrixColumnOut;
    //cathode   <= ~io_matrixRowOut;

    uart_tx     <= io_uartTx_0;
    io_uartRx_0 <= uart_rx;

    probe_out <= io_probeOut;
  end

  TopWithEthernet top(
    .clock(clock),
    .reset(reset),
    .io_debug_pc(),
    .io_success(),
    .io_exit(),
    // Ethernet MAC interface
    .io_rmiiClock(rmii_txclk),
    .io_rmiiReset(reset_rmii),
    .io_macInData (rx_maxis_tdata),
    .io_macInValid(rx_maxis_tvalid),
    .io_macInReady(rx_maxis_tready),
    .io_macInLast (rx_maxis_tlast),
    .io_macOutData (tx_saxis_tdata),
    .io_macOutValid(tx_saxis_tvalid),
    .io_macOutReady(tx_saxis_tready),
    .io_macOutLast (tx_saxis_tlast),
    .*
  );

  // DVI out
    
  logic [9:0] dvi_clock;
  logic [9:0] dvi_data0;
  logic [9:0] dvi_data1;
  logic [9:0] dvi_data2;
  logic video_de;
  logic video_hsync;
  logic video_vsync;
  logic [23:0] video_data;

  test_pattern_generator #(
    .BOUNCE_TIMER(1),
    .FONT_PATH("fonts.hex"),
    .FONT_COLOR(24'h000000)  
  ) tpg_inst (
    .clock(clock_dvi),
    .reset(reset_dvi),
    //.timer_values({8'h54, 4'ha, 8'h32, 4'ha, 8'h10}),
    .timer_values(io_dviDigitsOut),
    .*
  );

  dvi_out dvi_out_inst (
    .clock(clock_dvi),
    .reset(reset_dvi),
    .*
  );

  OSER10 #(
    .GSREN("false"),
    .LSREN("true")
  ) oser_dvi_clock(
    .Q(tmds_clk_p),
    .D0(dvi_clock[0]),
    .D1(dvi_clock[1]),
    .D2(dvi_clock[2]),
    .D3(dvi_clock[3]),
    .D4(dvi_clock[4]),
    .D5(dvi_clock[5]),
    .D6(dvi_clock[6]),
    .D7(dvi_clock[7]),
    .D8(dvi_clock[8]),
    .D9(dvi_clock[9]),
    .FCLK(clock_dvi_ser),
    .PCLK(clock_dvi),
    .RESET(reset_dvi)
  );
  OSER10 #(
    .GSREN("false"),
    .LSREN("true")
  ) oser_dvi_data0(
    .Q(tmds_data_p[0]),
    .D0(dvi_data0[0]),
    .D1(dvi_data0[1]),
    .D2(dvi_data0[2]),
    .D3(dvi_data0[3]),
    .D4(dvi_data0[4]),
    .D5(dvi_data0[5]),
    .D6(dvi_data0[6]),
    .D7(dvi_data0[7]),
    .D8(dvi_data0[8]),
    .D9(dvi_data0[9]),
    .FCLK(clock_dvi_ser),
    .PCLK(clock_dvi),
    .RESET(reset_dvi)
  );
  OSER10 #(
    .GSREN("false"),
    .LSREN("true")
  ) oser_dvi_data1(
    .Q(tmds_data_p[1]),
    .D0(dvi_data1[0]),
    .D1(dvi_data1[1]),
    .D2(dvi_data1[2]),
    .D3(dvi_data1[3]),
    .D4(dvi_data1[4]),
    .D5(dvi_data1[5]),
    .D6(dvi_data1[6]),
    .D7(dvi_data1[7]),
    .D8(dvi_data1[8]),
    .D9(dvi_data1[9]),
    .FCLK(clock_dvi_ser),
    .PCLK(clock_dvi),
    .RESET(reset_dvi)
  );
  OSER10 #(
    .GSREN("false"),
    .LSREN("true")
  ) oser_dvi_data2(
    .Q(tmds_data_p[2]),
    .D0(dvi_data2[0]),
    .D1(dvi_data2[1]),
    .D2(dvi_data2[2]),
    .D3(dvi_data2[3]),
    .D4(dvi_data2[4]),
    .D5(dvi_data2[5]),
    .D6(dvi_data2[6]),
    .D7(dvi_data2[7]),
    .D8(dvi_data2[8]),
    .D9(dvi_data2[9]),
    .FCLK(clock_dvi_ser),
    .PCLK(clock_dvi),
    .RESET(reset_dvi)
  );
endmodule
`default_nettype wire