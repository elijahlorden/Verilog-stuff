`timescale 1ns / 1ps
module top(
	input clk,
	input ps2clk, ps2data, //ps2-specific inputs
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

binary_7seg_converter segConverter ( .clk(clk), .segments(segments), .segsel(segsel), .dispNum(num) );
ps2Listener keyboardListener ( .clk(clk), .ps2clk(ps2clk), .ps2data(ps2data), .rx_data_out(ps2_rx_data), .rx_done_stb(rx_done_stb), .rx_enable(rx_enable)  );

scancodeConverter scConverter( .clk(clk), .ps2_rx_stb(rx_done_stb), .ps2_rx_data(ps2_rx_data), .key_data(key_data), .key_broken(key_broken), .key_data_stb(key_data_stb) );

always @(posedge clk) begin
	if (key_data_stb) begin
		num[7:0] <= key_data;
		num[8] <= key_broken;
	end
end

endmodule
