`timescale 1ns / 1ps
//Implementation of pseudocode found at https://en.wikipedia.org/wiki/Integer_square_root
module intSqrt(
	input clk,
	input [30:0] n, //This module assumes that the 
	input calc,
	output reg calc_done,
	output reg [15:0] result
);

localparam
state_idle 			= 3'h0,
state_findShift 	= 3'h1,
state_getResult	= 3'h2;

reg [5:0] shift = 0;
reg [31:0] nShifted = 0;
reg [15:0] candidateResult = 0;

reg [2:0] state = 0;

initial begin
	result = 16'd0;
	calc_done = 1'b1;
end

always @(posedge clk) begin
	case(state)
		state_idle:
			begin
				if (calc) begin
					state <= state_findShift;
					shift <= 6'd2;
					nShifted <= n >> 'd2;
					calc_done <= 1'b0;
				end
			end
		state_findShift:
		begin
			if (nShifted == 0 || nShifted == n) begin
				shift <= shift - 6'd2;
				result <= 16'd0;
				state <= state_getResult;
			end else begin
				shift <= shift + 6'd2;
				nShifted <= n >> shift;
			end
		end
		state_getResult:
		begin
			result <= result << 1;
			shift = shift - 2;
			if (((result << 1) + 1) * ((result << 1) + 1) <= n >> shift) begin
				result <= (result << 1) + 1;
			end
			if (shift[5] || shift == 0) begin
				state <= state_idle;
				calc_done <= 1'b1;
			end
		end
	endcase
end





endmodule
