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

// Reset sequencer.
logic [15:0] reset_seq;
initial begin
  reset_seq = '1;
end
always_ff @(posedge clock) begin
  reset_seq <= reset_seq >> 1;
end
logic reset;
assign reset = reset_seq[0];
logic resetn;
assign resetn = !reset;

logic [8:0] row_inner;
always_comb begin
    seven_seg = !row_inner[8];
end

// Assign GPIO output to LEDs.
logic [31:0] gpio_out;
logic [31:0] gpio_in;
logic [31:0] gpio_out_enable;
assign led = ~gpio_out[5:0];

logic [3:0] lcd_db_out;
logic [3:0] lcd_db_in;
logic [3:0] lcd_db_out_enable;
assign lcd_rs = gpio_out[12];
assign lcd_rw = gpio_out[13];
assign lcd_e = gpio_out[14];
assign lcd_db_out = gpio_out[11:8];
assign lcd_db_out_enable = gpio_out_enable[11:8];
assign gpio_in[11:8] = lcd_db_in;

//assign debug_out = gpio_out[15:12];

generate
    for(genvar i = 0; i < 4; i++) begin: lcd_db_io
        IOBUF lcd_db_io_buf(
            .I(lcd_db_out[i]),
            .O(lcd_db_in[i]),
            .IO(lcd_db[i]),
            .OEN(!lcd_db_out_enable[i])
        );
    end
endgenerate


// Invert row output
assign row = ~row_inner[7:0];

// RV core instance.
logic io_exit;
logic [8:0] io_imem_address;
logic [31:0] io_imem_data;
logic io_imem_enable;
(* mark_debug = "true" *) logic [8:0]  io_imemRead_address;
(* mark_debug = "true" *) logic [31:0] io_imemRead_data;
(* mark_debug = "true" *) logic        io_imemRead_enable;
(* mark_debug = "true" *) logic [8:0]  io_imemWrite_address;
(* mark_debug = "true" *) logic [31:0] io_imemWrite_data;
(* mark_debug = "true" *) logic        io_imemWrite_enable;
(* mark_debug = "true" *) logic [31:0] io_debugSignals_core_mem_reg_pc;
(* mark_debug = "true" *) logic [31:0] io_debugSignals_core_csr_rdata;
(* mark_debug = "true" *) logic [31:0] io_debugSignals_core_mem_reg_csr_addr;
(* mark_debug = "true" *) logic [63:0] io_debugSignals_core_cycle_counter;
(* mark_debug = "true" *) logic [31:0] io_debugSignals_raddr;
(* mark_debug = "true" *) logic [31:0] io_debugSignals_rdata;
(* mark_debug = "true" *) logic        io_debugSignals_ren;
(* mark_debug = "true" *) logic        io_debugSignals_rvalid;
(* mark_debug = "true" *) logic [31:0] io_debugSignals_waddr;
(* mark_debug = "true" *) logic        io_debugSignals_wen;
(* mark_debug = "true" *) logic        io_debugSignals_wready;
(* mark_debug = "true" *) logic [3:0]  io_debugSignals_wstrb;
(* mark_debug = "true" *) logic [31:0] io_debugSignals_wdata;


logic [3:0] debug_phase_counter = 0;
logic [31:0] debug_output_target;
logic [3:0] debug_out_data;
logic debug_out_valid;
logic debug_clock = 0;
assign debug_out = {debug_clock, debug_out_valid, debug_out_data};
always_ff @(posedge clock) begin
    if( reset ) begin
        debug_phase_counter <= 0;
        debug_clock <= 0;
        debug_out_valid <= 0;
        debug_out_data <= 0;
    end
    else begin
        debug_clock <= !debug_clock;
        if( !debug_clock ) begin
            debug_phase_counter <= debug_phase_counter == 3 ? 0 : debug_phase_counter + 1;
            debug_out_valid <= debug_phase_counter == 0;
            case(debug_phase_counter)
                3'd0: begin
                    debug_output_target <= io_debugSignals_core_mem_reg_pc;
                    debug_out_data <= io_debugSignals_core_mem_reg_pc[2 +: 4];
                end
                3'd1: begin
                    debug_out_data <= debug_output_target[6 +: 4];
                end
                3'd2: begin
                    debug_out_data <= debug_output_target[10 +: 4];
                end
                3'd3: begin
                    debug_out_data <= debug_output_target[14 +: 4];
                end
                default: begin
                    debug_out_data <= 0;
                end
            endcase
        end
    end
end

RiscV core(
    .reset(!resetn),
    .io_row(row_inner),
    .io_column(d),
    .io_gpio_out(gpio_out),
    .io_gpio_in(gpio_in),
    .io_gpio_out_enable(gpio_out_enable),
    .io_uart_tx(uart_tx),
    .io_uart_rx(uart_rx),
    .*
);

logic [31:0] imem [0:511];
initial begin
`ifdef BOOTROM_PATH
    $readmemh( `BOOTROM_PATH , imem);
`else
    $readmemh("../sw/bootrom.hex", imem);
`endif
end

// imem instruction bus access
always_ff @(posedge clock) begin
    if( !resetn ) begin
        io_imem_data <= 0;
    end
    else begin
        if( io_imem_enable ) begin
            io_imem_data <= imem[io_imem_address];
        end
    end
end
// imem data bus access
always_ff @(posedge clock) begin
    if( !resetn ) begin
        io_imemRead_data <= 0;
    end
    else begin
        if( io_imemRead_enable ) begin
            io_imemRead_data <= imem[io_imemRead_address];
        end
        if( io_imemWrite_enable ) begin
            imem[io_imemWrite_address] <= io_imemWrite_data;
        end
    end
end

endmodule
`default_nettype wire