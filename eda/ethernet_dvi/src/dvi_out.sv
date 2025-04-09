// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2022.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)
/**
 * @file dvi_out.sv
 * @brief RGB to DVI signal encoder.
 */
`default_nettype none

module dvi_out (
    input wire clock,
    input wire reset,

    input wire  [23:0] video_data,
    input wire         video_de,
    input wire         video_hsync,
    input wire         video_vsync,

    output logic [9:0] dvi_clock,
    output logic [9:0] dvi_data0,
    output logic [9:0] dvi_data1,
    output logic [9:0] dvi_data2
);

assign dvi_clock = 10'b00000_11111;

// Video signal register type
typedef struct packed {
    logic        de;
    logic        hsync;
    logic        vsync;
    logic [26:0] data;
} video_reg_t;

localparam VIDEO_REGS_DEPTH = 1;

function automatic logic [1:0] popCount2(input logic [1:0] in);
    popCount2 = {1'b0, in[0]} + {1'b0, in[1]};
endfunction
function automatic logic [2:0] popCount4(input logic [3:0] in);
    popCount4 = {1'b0, popCount2(in[3:2])} + {1'b0, popCount2(in[1:0])};
endfunction

function automatic logic [3:0] popCount8(input logic [9:0] in);
    popCount8 = {1'b0, popCount4(in[7:4])} + {1'b0, popCount4(in[3:0])};
endfunction

function automatic logic [8:0] transitionMinimized(input logic [7:0] in);
begin
    logic [3:0] pop_count;
    logic xnor_process;
    logic [7:0] bits;

    pop_count = popCount8(in);
    xnor_process = pop_count > 4'd4 || (pop_count == 4'd4 && !in[0]);
    bits[0] = in[0];
    for(int i = 1; i < 8; i++) bits[i] = (bits[i-1] ^ in[i]) ^ xnor_process;
    transitionMinimized = {!xnor_process, bits}; 
end
endfunction

typedef struct packed {
    logic [9:0] out;
    logic [7:0] counter;
} dc_balancing_t;

function automatic dc_balancing_t dcBalancing(input logic [8:0] in, logic [7:0] counter);
begin
    logic [3:0] n1;
    logic [7:0] n0n1;
    dc_balancing_t result;

    n1 = popCount8(in[7:0]);
    n0n1 = 8'd8 - {3'b000, n1, 1'b0};

    if(counter == '0 || n0n1 == '0) begin
        result.out = {!in[8], in[8], in[8] ? in[7:0] : ~in[7:0]};
        result.counter = in[8] ? counter - n0n1 : counter + n0n1; 
    end
    else if( (!counter[7] && n0n1[7]) || (counter[7] && !n0n1[7]) ) begin
        result.out = {1'b1, in[8], ~in[7:0]};
        result.counter = in[8] ? counter + n0n1 + 8'd2 : counter + n0n1;
    end
    else begin
        result.out = {1'b0, in[8], in[7:0]};
        result.counter = in[8] ? counter - n0n1 : counter - n0n1 - 8'd2;
    end
    dcBalancing = result;
end
endfunction

function automatic logic [9:0] transitionMaximized(input logic [1:0] in);
begin
    case(in)
        2'b00: transitionMaximized = 10'b1101010100;
        2'b01: transitionMaximized = 10'b0010101011;
        2'b10: transitionMaximized = 10'b0101010100;
        2'b11: transitionMaximized = 10'b1010101011;
    endcase
end
endfunction


video_reg_t video_reg_in;
video_reg_t [VIDEO_REGS_DEPTH-1:0] video_regs;
video_reg_t video;
assign video = video_regs[0];

logic [7:0] counter0;
logic [7:0] counter1;
logic [7:0] counter2;
assign video_reg_in.de    = video_de;
assign video_reg_in.hsync = video_hsync;
assign video_reg_in.vsync = video_vsync;
assign video_reg_in.data  = {transitionMinimized(video_data[23:16]), transitionMinimized(video_data[15:8]), transitionMinimized(video_data[7:0])};

always_ff @(posedge clock) begin
    if( reset ) begin
        video_reg_t reg_default;
        reg_default.de = 0;
        reg_default.data = 0;
        reg_default.hsync = 1;
        reg_default.vsync = 1;
        for(int i = 0; i < VIDEO_REGS_DEPTH; i++) begin
            video_regs[i] <= reg_default;
        end
    end
    else begin
        video_regs[VIDEO_REGS_DEPTH-1] <= video_reg_in; 
        for(int i = 0; i < VIDEO_REGS_DEPTH-1; i++) begin
            video_regs[i] <= video_regs[i+1];
        end
    end
end

always_ff @(posedge clock) begin
    if( reset ) begin
        counter0 <= 0;
        counter1 <= 0;
        counter2 <= 0;
        dvi_data0 <= 0;
        dvi_data1 <= 0;
        dvi_data2 <= 0;
    end
    else begin
        if( !video.de ) begin
            dvi_data0 <= transitionMaximized({video.vsync, video.hsync});
            dvi_data1 <= transitionMaximized(2'b00);
            dvi_data2 <= transitionMaximized(2'b00);
            counter0 <= 0;
            counter1 <= 0;
            counter2 <= 0;
        end
        else begin
            begin
                dc_balancing_t result;
                result = dcBalancing(video.data[8:0], counter0);
                dvi_data0 <= result.out;
                counter0 <= result.counter;
            end
            begin
                dc_balancing_t result;
                result = dcBalancing(video.data[17:9], counter1);
                dvi_data1 <= result.out;
                counter1 <= result.counter;
            end
            begin
                dc_balancing_t result;
                result = dcBalancing(video.data[26:18], counter2);
                dvi_data2 <= result.out;
                counter2 <= result.counter;
            end
        end
    end
end

endmodule
`default_nettype wire