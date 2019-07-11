`timescale 1ns / 1ps
//Converts keycodes into ASCII characters.
module keycodeConverter(
	input clk,
	input key_data_stb, //Should come from the scancodeConverter module
	input key_broken, //Should come from the scancodeConverter module
	input key_data, //Should come from the scancodeConverter module
	output ascii_data_stb, //High for one clock cycle when a new ASCII character is ready
	output [7:0] ascii_data //Generated ASCII character, valid when ascii_data_stb is high
);

reg caps_enabled = 0;
reg shift_enabled = 0;
reg alt_enabled = 0;

wire letter_uppercase;

assign letter_uppercase = caps_enabled ^ shift_enabled;






endmodule
