// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2022.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)
/**
 * @file test_pattern_generator.sv
 * @brief Test pattern video signal generator
 */
`default_nettype none

module test_pattern_generator #(
    parameter int HSYNC = 40,
    parameter int HBACK = 220,
    parameter int HACTIVE = 1280,
    parameter int HFRONT = 110,
    parameter int VSYNC = 5,
    parameter int VBACK = 20,
    parameter int VACTIVE = 720,
    parameter int VFRONT = 5,
    parameter bit BOUNCE_TIMER = 0,
    parameter int FONT_COLOR = 0,
    parameter     FONT_PATH = ""
)(
    input wire clock,
    input wire reset,

    input wire [4*8-1:0] timer_values,  // hh:mm:ss = 8 digits, 4 bits for each digit.

    output logic  [23:0] video_data,
    output logic         video_de,
    output logic         video_hsync,
    output logic         video_vsync
);

logic  [23:0] video_data_value;

localparam int HTOTAL = HSYNC + HBACK + HACTIVE + HFRONT;
localparam int VTOTAL = VSYNC + VBACK + VACTIVE + VFRONT;
localparam int HCOUNTER_BITS = $clog2(HTOTAL);
localparam int VCOUNTER_BITS = $clog2(VTOTAL);

typedef logic [HCOUNTER_BITS-1:0] hcounter_t;
typedef logic [VCOUNTER_BITS-1:0] vcounter_t;

hcounter_t hcounter = 0;
vcounter_t vcounter = 0;

localparam int TIMER_WIDTH = 64*8; // hh:mm:ss = 8 characters
localparam int TIMER_HEIGHT = 64;
localparam int TIMER_STRIDE = (TIMER_WIDTH + 7) & ~7;
localparam int TIMER_BITS   = TIMER_STRIDE*TIMER_HEIGHT;
localparam int TIMER_BYTES  = TIMER_BITS >> 3;
typedef logic [$clog2(TIMER_BITS)-1:0] timer_address_t;
localparam int FONT_WIDTH = 64;
localparam int FONT_HEIGHT = 64;
localparam int FONT_DIGITS = 11;
localparam int FONT_BYTES = FONT_WIDTH*FONT_HEIGHT*FONT_DIGITS/8;
localparam int FONT_INDEX_BITS = $clog2(FONT_BYTES);
typedef logic [FONT_INDEX_BITS-1:0] font_address_t;
logic [7:0] font_memory[FONT_BYTES];

hcounter_t logo_x = 0;
vcounter_t logo_y = 0;
logic logo_dx = 0;
logic logo_dy = 0;

timer_address_t timer_address = 0;
logic [7:0] timer_pixels = 0;
logic logo_pixel = 0;
logic within_logo = 0;

if( BOUNCE_TIMER ) begin: bounce_logo_memory_load
    initial begin
        $readmemh(FONT_PATH, font_memory);
    end
    always_ff @(posedge clock) begin
        if( reset ) begin
            timer_pixels <= 0; 
        end
        else begin
            var timer_address_t next_timer_address;
            var logic [2:0]     digit_index;
            var logic [3:0]     digit_value;
            var logic [5:0]     y;
            var logic [2:0]     x_in_font;
            var font_address_t  font_address;
            next_timer_address = timer_address + 1;
            digit_index = next_timer_address[6 +: 3]; // 64 pixels per digit 
            digit_value = timer_values[digit_index*4 +: 4];
            y = next_timer_address >> 9;             // 512 pixels
            x_in_font = next_timer_address[3 +: 3];
            font_address = {digit_value, y, x_in_font};   // 64 pixels = 8 bytes per character 
            timer_pixels <= font_memory[font_address];
        end
    end
end


always_comb begin
    logo_pixel = timer_pixels[timer_address&7];

    within_logo = HSYNC + HBACK + logo_x <= hcounter && hcounter < HSYNC + HBACK + logo_x + TIMER_WIDTH
               && VSYNC + VBACK + logo_y <= vcounter && vcounter < VSYNC + VBACK + logo_y + TIMER_HEIGHT;
end

always_ff @(posedge clock) begin
    if( reset ) begin
        hcounter <= '0;
        vcounter <= '0;
        timer_address <= '0;
        video_de <= 0;
        video_hsync <= 0;
        video_vsync <= 0;
        video_data <= 0;
    end
    else begin
        if( within_logo ) begin
            timer_address <= timer_address + 1;
        end

        if( hcounter == HTOTAL - 1) begin
            hcounter <= '0;
            if( vcounter == VTOTAL - 1) begin
                vcounter <= '0;
                timer_address <= '0;
                // Update logo position
                if( logo_dx && logo_x == 0 || !logo_dx && logo_x == (HACTIVE - TIMER_WIDTH - 1)) begin
                    logo_dx <= !logo_dx;
                end
                if( logo_dy && logo_y == 0 || !logo_dy && logo_y == (VACTIVE - TIMER_HEIGHT - 1)) begin
                    logo_dy <= !logo_dy;
                end
                logo_x <= logo_dx ? logo_x - 1 : logo_x + 1;
                logo_y <= logo_dy ? logo_y - 1 : logo_y + 1;
            end
            else begin
                timer_address <= (timer_address + timer_address_t'(7)) & ~timer_address_t'(7);
                vcounter <= vcounter + vcounter_t'(1);
            end
        end
        else begin
            hcounter <= hcounter + hcounter_t'(1);
        end

        video_de <= HSYNC + HBACK <= hcounter && hcounter < HSYNC + HBACK + HACTIVE
                && VSYNC + VBACK <= vcounter && vcounter < VSYNC + VBACK + VACTIVE;
        video_hsync <= hcounter < HSYNC;
        video_vsync <= vcounter < VSYNC;
        
        if( BOUNCE_TIMER && within_logo && logo_pixel ) begin
            video_data <= FONT_COLOR;
        end
        else if( hcounter < HSYNC + HBACK + (HACTIVE*1/7) ) begin
            video_data <= 24'hffffff;
        end
        else if( hcounter < HSYNC + HBACK + (HACTIVE*2/7) ) begin
            video_data <= 24'hff0000;
        end
        else if( hcounter < HSYNC + HBACK + (HACTIVE*3/7) ) begin
            video_data <= 24'hffff00;
        end
        else if( hcounter < HSYNC + HBACK + (HACTIVE*4/7) ) begin
            video_data <= 24'h00ff00;
        end
        else if( hcounter < HSYNC + HBACK + (HACTIVE*5/7) ) begin
            video_data <= 24'h00ffff;
        end
        else if( hcounter < HSYNC + HBACK + (HACTIVE*6/7) ) begin
            video_data <= 24'h0000ff;
        end
        else begin
            video_data <= 24'hff00ff;
        end
    end
end

endmodule
`default_nettype wire