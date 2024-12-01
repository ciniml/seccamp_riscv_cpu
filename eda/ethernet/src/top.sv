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

  // MSMP
  input  wire  msmp_rx,
  output logic msmp_tx,
  
  // RMII PHY interface
  input  wire        rmii_txclk,
  input  wire  [1:0] rmii_rxd,
  input  wire        rmii_crs_dv,
  output logic [1:0] rmii_txd,
  output logic       rmii_txen,
  input  wire        rmii_mdio,
  output logic       rmii_mdc,
  output logic       rmii_rstn,
  
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
  logic io_uartRx_1;
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

    msmp_tx     <= ~io_uartTx_1;// Invert MSMP TX signal
    io_uartRx_1 <= ~msmp_rx;    // Invert MSMP RX signal

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

endmodule
`default_nettype wire