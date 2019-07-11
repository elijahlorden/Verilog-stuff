`timescale 1ns / 1ps
module binary_7seg_converter(
	input clk,
	input [15:0] dispNum,
	output reg [6:0] segments,
	output reg [3:0] segsel
);

reg [6:0] decoder [0:15];
reg [1:0] seg_ctr = 2'b0;
reg [31:1] clk_dvdr = 0;

initial begin
	$readmemb("nibble27seg_decoder", decoder);
end

always @(posedge clk) begin
	if (clk_dvdr >= 50000) begin //Divide the 50Mhz input clock down to 1Khz
		case (seg_ctr)
			0: begin segsel <= 4'b1110; segments <= ~decoder[dispNum[3:0]]; end
			1: begin segsel <= 4'b1101; segments <= ~decoder[dispNum[7:4]]; end
			2: begin segsel <= 4'b1011; segments <= ~decoder[dispNum[11:8]]; end
			3: begin segsel <= 4'b0111; segments <= ~decoder[dispNum[15:12]]; end
		endcase
		seg_ctr <= seg_ctr + 1;
		clk_dvdr <= 0;
	end
	else clk_dvdr <= clk_dvdr + 1;
end


endmodule
