`timescale 1ns / 1ps
//Converts keycodes into ASCII characters.
//Allows character data to be entered directly by holding alt and typing a decimal number between 0-255,
//Hexadecimal may be used by first pressing the H key before entering the number
module keycodeConverter(
	input clk,
	input key_data_stb, //Should come from the scancodeConverter module
	input key_broken, //Should come from the scancodeConverter module
	input [7:0] key_data, //Should come from the scancodeConverter module
	output reg ascii_data_stb, //High for one clock cycle when a new ASCII character is ready
	output reg [7:0] ascii_data //Generated ASCII character, valid when ascii_data_stb is high
);

reg caps_enabled = 0;
reg shift_enabled = 0;
reg alt_enabled = 0;
reg ctrl_enabled = 0;

reg [11:0] altcode = 12'b0;
reg altcode_started = 1'b0;
reg altcode_is_hex = 1'b0;

wire ascii_uppercase;
reg [4:0] key_value; //Numeric representation of the current keycode
reg [7:0] ascii_value; //ASCII code for the current keycode, taking into account SHIFT and CAPS

assign ascii_uppercase = caps_enabled ^ shift_enabled;

always @(posedge clk) begin
	if (key_data_stb) begin
		//ALT, CTRL, SHIFT and CAPS detection
		if (key_data == 8'h2F) // LALT/RALT
			alt_enabled <= ~key_broken;
		else if (key_data == 8'h2E) // LCTRL/RCTRL
			ctrl_enabled <= ~key_broken;
		else if (key_data == 8'h2D) // LSHIFT/RSHIFT
			shift_enabled <= ~key_broken;
		else if (key_data == 8'h2C) // CAPS
			caps_enabled <= (key_broken) ? ~caps_enabled : caps_enabled;
		//Altcode detection
		if (alt_enabled && key_broken) begin
			if (key_data == 8'h2F) begin //Emit character if alt is broken and data was entered
				altcode <= 12'b0;
				altcode_is_hex <= 1'b0;
				if (altcode_started) begin
					ascii_data <= (altcode_is_hex) ? altcode[7:0] : (altcode[3:0] + (altcode[7:4] * 8'd10) + (altcode[11:8] * 8'd100));
					ascii_data_stb <= 1'b1;
					altcode_started <= 1'b0;
				end
			end else if (~key_value[4]) begin //Shift in numeric value (if valid)
				altcode_started <= 1'b1;
				altcode <= {altcode[7:0], key_value[3:0]};
			end else if (key_data == 8'h08 && key_broken) altcode_is_hex <= 1'b1;
		end else if (~key_broken && ascii_value != 0) begin //Emit ASCII character
			ascii_data <= ascii_value;
			ascii_data_stb <= 1'b1;
		end
	end
	if (ascii_data_stb) ascii_data_stb <= 1'b0; //Reset ascii_data_stb after one clock cycle
end

always @* begin
	case(key_data) //Converts keycodes into their numeric value
		8'h1B: key_value = 5'h0; //0
		8'h1C: key_value = 5'h1; //1
		8'h1D: key_value = 5'h2; //2
		8'h1E: key_value = 5'h3; //3
		8'h1F: key_value = 5'h4; //4
		8'h20: key_value = 5'h5; //5
		8'h21: key_value = 5'h6; //6
		8'h22: key_value = 5'h7; //7
		8'h23: key_value = 5'h8; //8
		8'h24: key_value = 5'h9; //9
		8'h01: key_value = 5'hA; //A
		8'h02: key_value = 5'hB; //B
		8'h03: key_value = 5'hC; //C
		8'h04: key_value = 5'hD; //D
		8'h05: key_value = 5'hE; //E
		8'h06: key_value = 5'hF; //F
		default: key_value = 5'b11111; //All other keys result in the invalid value of 32
	endcase
end

always @* begin
	case(key_data) //Decodes keycode and letter_uppercase into ASCII
		8'h01: ascii_value = (ascii_uppercase) ? 8'h41 : 8'h61; //Keycode 0x01 ASCII a -> A
		
		
		
		
		default: ascii_value = 8'h00; //Defaults to ASCII NULL which cannot be emitted
	endcase
end








endmodule
