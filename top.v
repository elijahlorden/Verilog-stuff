`timescale 1ns / 1ps
module top(
	input clk,
	inout ps2clk, ps2data, //Bi-directional PS/2 clock and data lines
	output [6:0] segments,
	output [3:0] segsel
);

reg [15:0] num = 0;
wire [7:0] ps2_rx_data;
reg rx_enable = 1;
wire rx_done_stb;

wire [7:0] key_data;
wire key_broken;
wire key_data_stb;

wire [7:0] ascii_data;
wire ascii_data_stb;

wire [2:0] led_status;

binary_7seg_converter segmentConverter ( .clk(clk), .segments(segments), .segsel(segsel), .dispNum(num) );

ps2Interface ps2Interface ( .clk(clk), .ps2clk(ps2clk), .ps2data(ps2data), .rx_data_out(ps2_rx_data), .rx_done_stb(rx_done_stb), .rx_enable(rx_enable) );
scancodeConverter scancodeConverter( .clk(clk), .ps2_rx_stb(rx_done_stb), .ps2_rx_data(ps2_rx_data), .key_data(key_data), .key_broken(key_broken), .key_data_stb(key_data_stb) );
keycodeConverter keycodeConverter ( .clk(clk), .key_data_stb(key_data_stb), .key_broken(key_broken), .key_data(key_data), .ascii_data(ascii_data), .ascii_data_stb(ascii_data_stb), .led_status(led_status) );

always @(posedge clk) begin
	if (ascii_data_stb) num[7:0] <= ascii_data;
end

endmodule
