`timescale 1ns / 1ps
//This 
module alu(
	input clk,
	input [31:0] operand_a, operand_b,
	input [4:0] operation,
	input calc,
	output reg [31:0] result,
	output reg calc_done,
	output [4:0] flags
);

localparam
state_idle 	= 3'h0,
state_div 	= 3'h1,
state_sqrt 	= 3'h2,

op_add 	= 5'h00, //ADD
op_sub 	= 5'h01, //SUBTRACT
op_neg 	= 5'h02, //NEGATE
op_inc	= 5'h03, //INCREMENT
op_dec	= 5'h04, //DECREMENT
op_mul 	= 5'h05, //MULTIPLY
op_div 	= 5'h06, //DIVIDE
op_rem 	= 5'h07, //REMAINDER
op_sqrt	= 5'h08, //SQUARE ROOT
op_and	= 5'h09, //BITWISE AND
op_or		= 5'h0A, //BITWISE OR
op_nand	= 5'h0B, //BITWISE NAND
op_nor	= 5'h0C, //BITWISE NOR
op_not	= 5'h0D, //BITWISE NOT
op_xor	= 5'h0E, //BITWISE XOR
op_lsh	= 5'h0F, //BITWISE LEFT SHIFT
op_rsh	= 5'h10, //BITWISE RIGHT SHIFT
op_alsh	= 5'h11, //BITWISE ARITHMATIC LEFT SHIFT
op_arsh	= 5'h12; //BITWISE ARITHMATIC RIGHT SHIFT

reg flag_carry = 1'b0; //Set if operation results in a carry-out
reg flag_overflow = 1'b0; //Set if operation results in an overflow
wire flag_zero; //Set if result is zero
wire flag_gtz; //Set if result is greater than zero
wire flag_ltz; //Set if result is lower than zero

reg flag_carry_comb;
reg flag_overflow_comb;
reg [31:0] result_comb;

reg [63:0] mul_temp;
reg [31:0] mul_result;
reg mul_overflow;

reg [3:0] state = state_idle;

assign flags = {flag_ltz, flag_gtz, flag_zero, flag_overflow, flag_carry};
assign flag_zero = (result == 31'd0) ? 1'b1 : 1'b0;
assign flag_ltz = result[31];
assign flag_gtz = (~result[31] && result[30:0] > 31'd0) ? 1'b1 : 1'b0;

initial begin
	result = 32'd0;
	calc_done = 1'b1;
end

//Combinational block for most of the ALU operations
always @* begin
	//Signed multiplier
	flag_carry_comb = 1'b0;
	flag_overflow_comb = 1'b0;
	result_comb = 32'b0;
	case (operation)
		op_add:
			begin
				{flag_carry_comb, result_comb} = operand_a + operand_b;
				flag_overflow_comb = ((operand_a[31] && operand_b[31] && ~result_comb[31]) || (~operand_a[31] && ~operand_b[31] && result_comb[31])) ? 1'b1 : 1'b0;
			end
		op_sub:
			begin
				{flag_carry_comb, result_comb} = operand_a - operand_b;
				flag_overflow_comb = ((operand_a[31] && operand_b[31] && ~result_comb[31]) || (~operand_a[31] && ~operand_b[31] && result_comb[31])) ? 1'b1 : 1'b0;
			end
		op_neg:
			begin
				result_comb = (~operand_a) + 32'b1;
			end
		op_inc:
			begin
				{flag_carry_comb, result_comb} = operand_a + 32'b1;
				flag_overflow_comb = ((~operand_a[31] && result_comb[31])) ? 1'b1 : 1'b0;
			end
		op_dec:
			begin
				{flag_carry_comb, result_comb} = operand_a - 32'b1;
				flag_overflow_comb = ((operand_a[31] && ~result_comb[31])) ? 1'b1 : 1'b0;
			end
		op_mul:
			begin
				mul_temp = ((operand_a[31]) ? (~operand_a) + 1 : operand_a) * ((operand_b[31]) ? (~operand_b) + 1 : operand_b);
				result_comb = {operand_a[31] ^ operand_b[31], (operand_a[31] ^ operand_b[31]) ? (~mul_temp[30:0]) + 31'b1 : mul_temp[30:0]};
				flag_overflow_comb = (mul_temp[63:32] > 0) ? 1'b1 : 1'b0;
			end
		op_and:
			begin
				result_comb = operand_a & operand_b;
			end
		op_or:
			begin
				result_comb = operand_a | operand_b;
			end
		op_nand:
			begin
				result_comb = ~(operand_a & operand_b);
			end
		op_nor:
			begin
				result_comb = ~(operand_a | operand_b);
			end
		op_not:
			begin
				result_comb = ~operand_a;
			end
		op_xor:
			begin
				result_comb = operand_a ^ operand_b;
			end
			
			
			
			
			
			
	endcase
end

always @(posedge clk) begin
	case(state)
		state_idle:
			if (calc) begin
				calc_done <= 1'b0;
				if (operation == op_div) begin
					
				end else if (operation == op_sqrt) begin
					
				end else begin
					flag_overflow <= flag_overflow_comb;
					flag_carry <= flag_carry_comb;
					result <= result_comb;
					calc_done <= 1'b1;
				end
			end
		
		
		
	endcase
end














endmodule
