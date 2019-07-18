`timescale 1ns / 1ps
//Signed 32-bit divider
module intDiv(
	input clk,
	input [31:0] dividend,
	input [31:0] divisor,
	input calc,
	output reg [31:0] quotient,
	output reg [31:0] remainder,
	output reg calc_done
);

localparam
state_idle = 1'b0,
state_calc = 1'b1;

reg state = state_idle;
reg [31:0] dvdnd = 31'd0;
reg [61:0] dvsor = 31'd0;
reg [4:0] count = 5'd0;
reg quot_sign = 0;

initial begin
	quotient = 31'd0;
	remainder = 31'd0;
	calc_done = 1'b1;
end

always @(posedge clk) begin
	case(state)
		state_idle:
			begin
				if (calc) begin
						quotient <= 31'b0;
						remainder <= 31'b0;
						calc_done <= 1'b0;
					if (dividend == 31'b0 || divisor == 31'b0) begin //Immediately return 0 if either the dividend or the divisor is 0
						calc_done <= 1'b1;
					end else begin
						state <= state_calc;
						quot_sign <= dividend[31] ^ divisor[31]; //Find the sign of the quotient
						dvdnd <= (dividend[31]) ? (~dividend) + 1 : dividend; //Get the absolute value of the dividend
						dvsor[61:31] <= (divisor[31]) ? (~divisor) + 1 : divisor; //Get the absolute value of the divisor
						count <= 5'd31;
					end
				end
			end
		state_calc:
			begin
				if (count > 5'd0) begin
					dvsor <= dvsor >> 1;
					count <= count - 5'd1;
					if (dvdnd >= (dvsor >> 1)) begin
						quotient[(count - 5'd1)] <= 1'b1;
						dvdnd <= dvdnd - (dvsor >> 1);
					end
				end else begin
					state <= state_idle;
					calc_done <= 1'b1;
					if (quot_sign) quotient <= (~quotient) + 1;  //Negate the quotient if the pre-calculated sign is negative
					remainder <= ((dividend[31]) ? (~dividend) + 1 : dividend) - (quotient * ((divisor[31]) ? (~divisor) + 1 : divisor));
				end
			end
	endcase
end



endmodule
