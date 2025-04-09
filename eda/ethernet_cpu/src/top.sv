/**
* @file top.sv
* @brief Top module for PicoRV32 matrix LED example
*/
// Copyright 2023 Kenta IDA
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)
`default_nettype none

module top (
  input  wire  clock,
  output logic com_ser,
  output logic com_rclk,
  output logic com_srclk,
  output logic com_oe,
  output logic seg_ser,
  output logic seg_rclk,
  output logic seg_srclk,
  output logic seg_oe,
  output logic [5:0] led_out,
  input  wire  [7:0] switch_in,
  output logic [7:0] anode,
  output logic [7:0] cathode,
  input  wire  uart_rx,
  output logic uart_tx,
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

  logic io_uartTx;
  logic io_uartRx;
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
    com_oe    <= io_digitSelector_outputEnable;
    com_srclk <= io_digitSelector_shiftClock;
    com_rclk  <= io_digitSelector_latch;
    com_ser   <= io_digitSelector_data;
    seg_oe    <= io_segmentOut_outputEnable;
    seg_srclk <= io_segmentOut_shiftClock;
    seg_rclk  <= io_segmentOut_latch;
    seg_ser   <= io_segmentOut_data;

    led_out   <= ~io_ledOut[5:0];
    io_switchIn <= {24'd0, switch_in};
    anode     <= io_matrixColumnOut;
    cathode   <= ~io_matrixRowOut;

    uart_tx   <= io_uartTx;
    io_uartRx <= uart_rx;

    probe_out <= io_probeOut;
  end

  TopWithSegmentLed top(
    .clock(clock),
    .reset(reset),
    .io_debug_pc(),
    .io_success(),
    .io_exit(),
    .*
  );

endmodule
`default_nettype wire