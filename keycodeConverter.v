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
	output reg [7:0] ascii_data, //Generated ASCII character, valid when ascii_data_stb is high
	output [2:0] led_status //{caps_enabled, num_enabled, scroll_enabled}
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

assign led_status = {caps_enabled, 1'b0, 1'b0};

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
		//A-Z-a-z
		8'h01: ascii_value = (ascii_uppercase) ? 8'h41 : 8'h61; //Keycode 0x01 ASCII a -> A
		8'h02: ascii_value = (ascii_uppercase) ? 8'h42 : 8'h62; //Keycode 0x02 ASCII b -> B
		8'h03: ascii_value = (ascii_uppercase) ? 8'h43 : 8'h63; //Keycode 0x03 ASCII c -> C
		8'h04: ascii_value = (ascii_uppercase) ? 8'h44 : 8'h64; //Keycode 0x04 ASCII d -> D
		8'h05: ascii_value = (ascii_uppercase) ? 8'h45 : 8'h65; //Keycode 0x05 ASCII e -> E
		8'h06: ascii_value = (ascii_uppercase) ? 8'h46 : 8'h66; //Keycode 0x06 ASCII f -> F
		8'h07: ascii_value = (ascii_uppercase) ? 8'h47 : 8'h67; //Keycode 0x07 ASCII g -> G
		8'h08: ascii_value = (ascii_uppercase) ? 8'h48 : 8'h68; //Keycode 0x08 ASCII h -> H
		8'h09: ascii_value = (ascii_uppercase) ? 8'h49 : 8'h69; //Keycode 0x09 ASCII i -> I
		8'h0A: ascii_value = (ascii_uppercase) ? 8'h4A : 8'h6A; //Keycode 0x0A ASCII j -> J
		8'h0B: ascii_value = (ascii_uppercase) ? 8'h4B : 8'h6B; //Keycode 0x0B ASCII k -> K
		8'h0C: ascii_value = (ascii_uppercase) ? 8'h4C : 8'h6C; //Keycode 0x0C ASCII l -> L
		8'h0D: ascii_value = (ascii_uppercase) ? 8'h4D : 8'h6D; //Keycode 0x0D ASCII m -> M
		8'h0E: ascii_value = (ascii_uppercase) ? 8'h4E : 8'h6E; //Keycode 0x0E ASCII n -> N
		8'h0F: ascii_value = (ascii_uppercase) ? 8'h4F : 8'h6F; //Keycode 0x0F ASCII o -> O
		8'h10: ascii_value = (ascii_uppercase) ? 8'h50 : 8'h70; //Keycode 0x20 ASCII p -> P
		8'h11: ascii_value = (ascii_uppercase) ? 8'h51 : 8'h71; //Keycode 0x21 ASCII q -> Q
		8'h12: ascii_value = (ascii_uppercase) ? 8'h52 : 8'h72; //Keycode 0x22 ASCII r -> R
		8'h13: ascii_value = (ascii_uppercase) ? 8'h53 : 8'h73; //Keycode 0x23 ASCII s -> S
		8'h14: ascii_value = (ascii_uppercase) ? 8'h54 : 8'h74; //Keycode 0x24 ASCII t -> T
		8'h15: ascii_value = (ascii_uppercase) ? 8'h55 : 8'h75; //Keycode 0x25 ASCII u -> U
		8'h16: ascii_value = (ascii_uppercase) ? 8'h56 : 8'h76; //Keycode 0x26 ASCII v -> V
		8'h17: ascii_value = (ascii_uppercase) ? 8'h57 : 8'h77; //Keycode 0x27 ASCII w -> W
		8'h18: ascii_value = (ascii_uppercase) ? 8'h58 : 8'h78; //Keycode 0x28 ASCII x -> X
		8'h19: ascii_value = (ascii_uppercase) ? 8'h59 : 8'h79; //Keycode 0x29 ASCII y -> Y
		8'h1A: ascii_value = (ascii_uppercase) ? 8'h5A : 8'h7A; //Keycode 0x2A ASCII z -> Z
		//0-9 `~!@#$%^&*()-_=+\|
		8'h1B: ascii_value = (shift_enabled) ? 8'h29 : 8'h30; //Keycode 0x2A ASCII 0 -> )
		8'h1C: ascii_value = (shift_enabled) ? 8'h21 : 8'h31; //Keycode 0x2A ASCII 1 -> !
		8'h1D: ascii_value = (shift_enabled) ? 8'h40 : 8'h32; //Keycode 0x2A ASCII 2 -> @
		8'h1E: ascii_value = (shift_enabled) ? 8'h23 : 8'h33; //Keycode 0x2A ASCII 3 -> #
		8'h1F: ascii_value = (shift_enabled) ? 8'h24 : 8'h34; //Keycode 0x2A ASCII 4 -> $
		8'h20: ascii_value = (shift_enabled) ? 8'h25 : 8'h35; //Keycode 0x2A ASCII 5 -> %
		8'h21: ascii_value = (shift_enabled) ? 8'h5E : 8'h36; //Keycode 0x2A ASCII 6 -> ^
		8'h22: ascii_value = (shift_enabled) ? 8'h26 : 8'h37; //Keycode 0x2A ASCII 7 -> &
		8'h23: ascii_value = (shift_enabled) ? 8'h2A : 8'h38; //Keycode 0x2A ASCII 8 -> *
		8'h24: ascii_value = (shift_enabled) ? 8'h28 : 8'h39; //Keycode 0x2A ASCII 9 -> (
		8'h25: ascii_value = (shift_enabled) ? 8'h7E : 8'h60; //Keycode 0x2A ASCII ` -> ~
		8'h26: ascii_value = (shift_enabled) ? 8'h5F : 8'h2D; //Keycode 0x2A ASCII - -> _
		8'h27: ascii_value = (shift_enabled) ? 8'h2B : 8'h3D; //Keycode 0x2A ASCII = -> +
		8'h28: ascii_value = (shift_enabled) ? 8'h7C : 8'h5C; //Keycode 0x2A ASCII \ -> |
		//KP *-+./
		8'h55: ascii_value = 8'h2A; //Keycode 0x55 ASCII *
		8'h56: ascii_value = 8'h2D; //Keycode 0x56 ASCII -
		8'h57: ascii_value = 8'h2B; //Keycode 0x57 ASCII +
		8'h58: ascii_value = 8'h2E; //Keycode 0x58 ASCII .
		8'h59: ascii_value = 8'h2F; //Keycode 0x59 ASCII /
		//[{}];:'",<.>/?
		8'h4E: ascii_value = (shift_enabled) ? 8'h7B : 8'h5C; //Keycode 0x4E ASCII [ -> {
		8'h4F: ascii_value = (shift_enabled) ? 8'h7D : 8'h5D; //Keycode 0x4F ASCII ] -> }
		8'h50: ascii_value = (shift_enabled) ? 8'h3B : 8'h3B; //Keycode 0x50 ASCII ; -> :
		8'h51: ascii_value = (shift_enabled) ? 8'h22 : 8'h27; //Keycode 0x51 ASCII ' -> "
		8'h52: ascii_value = (shift_enabled) ? 8'h3C : 8'h2C; //Keycode 0x52 ASCII , -> <
		8'h53: ascii_value = (shift_enabled) ? 8'h3E : 8'h2E; //Keycode 0x53 ASCII . -> >
		8'h54: ascii_value = (shift_enabled) ? 8'h3F : 8'h2F; //Keycode 0x54 ASCII / -> ?
		//SP LF BS
		8'h2A: ascii_value = 8'h20; //Keycode 0x2A ASCII SP
		8'h30: ascii_value = 8'h0A; //Keycode 0x30 ASCII LF
		8'h29: ascii_value = 8'h08; //Keycode 0x29 ASCII BS
		default: ascii_value = 8'h00; //Defaults to ASCII NULL which cannot be emitted
	endcase
end








endmodule
