`timescale 1ns / 1ps
//Converts PS/2 scancodes into a simple keycode for easier consumption.
module scancodeConverter(
	input clk,
	input ps2_rx_stb, //Should come from the ps2Listener module
	input [7:0] ps2_rx_data, //Should come from the ps2Listener module
	output reg [7:0] key_data = 0, //Generated keycode, valid when key_data_stb is high
	output reg key_broken = 0, //High if the generated keycode is the result of a key being released, valid when key_data_stb is also high
	output reg key_data_stb = 0 //High for one clock cycle when a new keycode is ready
);

reg [47:0] scancode_buffer = 48'b0;
reg [7:0] keycode = 0;
wire keycode_is_brk;

always @(posedge clk) begin
	if (ps2_rx_stb) scancode_buffer <= {scancode_buffer[39:0], ps2_rx_data}; //Shift scancodes in from the right
	if (keycode == 0) begin
		key_data_stb <= 1'b0;
	end else begin
		scancode_buffer <= 0;
		key_broken <= keycode_is_brk;
		key_data <= keycode;
		key_data_stb <= 1'b1;
	end
end

//Continuously checks the buffer for the breakcode indicator
assign keycode_is_brk = (scancode_buffer[15:8] == 8'hF0) ? 1'b1 : 1'b0;

//Continuously checks the buffer for a valid scancode
always @* begin
	if (scancode_buffer[39:32] == 8'hE1 || scancode_buffer[31:24] == 8'hE1 || scancode_buffer[23:16] == 8'hE1 || scancode_buffer[15:8] == 8'hE1 || scancode_buffer[23:16] == 8'hE1)
	case(scancode_buffer[7:0]) //Decoder just for PAUSE/BREAK, because it has a very different scancode
		8'h77: keycode = 8'h41; 	//'PAU/BK' key, 41
		default: keycode = 8'h00;
	endcase
	else
	if (scancode_buffer[15:8] == 8'hE0 || scancode_buffer[23:16] == 8'hE0)
	case(scancode_buffer[7:0]) //Decoder for E0-prefixed scancodes
		8'h14: keycode = 8'h2E; 	//'RCTRL ' key, 2E (Shared by LCTRL)
		8'h11: keycode = 8'h2F; 	//' RALT ' key, 2F (Shared by LALT)
		//LWIN and RWIN share keycode 32
		8'h1F: keycode = 8'h32; 	//' LWIN ' key, 32
		8'h27: keycode = 8'h32; 	//' RWIN ' key, 32
		8'h2F: keycode = 8'h33; 	//' MENU ' key, 33
		8'h7C: keycode = 8'h40;		//'PRNTSC' key, 40
		//Control keys (INSERT, HOME, PGUP, PGDN, DELETE, END, UDLR ARROWS)
		8'h70: keycode = 8'h41;		//'INSERT' key, 42
		8'h6C: keycode = 8'h42;		//' HOME ' key, 43
		8'h7D: keycode = 8'h43;		//' PGUP ' key, 44
		8'h7A: keycode = 8'h44;		//' PGDN ' key, 45
		8'h71: keycode = 8'h45;		//'DELETE' key, 46
		8'h69: keycode = 8'h46;		//' END  ' key, 47
		8'h75: keycode = 8'h47;		//'UARROW' key, 48
		8'h72: keycode = 8'h48;		//'DARROW' key, 49
		8'h6B: keycode = 8'h49;		//'LARROW' key, 4A
		8'h74: keycode = 8'h4A;		//'RARROW' key, 4B
		//Keypad keys
		8'h4A: keycode = 8'h54;		//'KP /  ' key, 54
		8'h5A: keycode = 8'h30;		//'KP ENT' key, 30
		default: keycode = 8'h00;
	endcase
	else
	case(scancode_buffer[7:0]) //Decoder for non-prefixed scancodes
		//A-Z letter keys
		8'h1C: keycode = 8'h01;	//'a -> A' key, 1
		8'h32: keycode = 8'h02;	//'b -> B' key, 2
		8'h21: keycode = 8'h03;	//'c -> C' key, 3
		8'h23: keycode = 8'h04;	//'d -> D' key, 4
		8'h24: keycode = 8'h05;	//'e -> E' key, 5
		8'h2B: keycode = 8'h06;	//'f -> F' key, 6
		8'h34: keycode = 8'h07;	//'g -> G' key, 7
		8'h33: keycode = 8'h08; //'h -> H' key, 8
		8'h43: keycode = 8'h09; //'i -> I' key, 9
		8'h3B: keycode = 8'h0A; //'j -> J' key, A
		8'h42: keycode = 8'h0B; //'k -> K' key, B
		8'h4B: keycode = 8'h0C; //'l -> L' key, C
		8'h3A: keycode = 8'h0D; //'m -> M' key, D
		8'h31: keycode = 8'h0E; //'n -> N' key, E
		8'h44: keycode = 8'h0F; //'o -> O' key, F
		8'h4D: keycode = 8'h10; //'p -> P' key, 10
		8'h15: keycode = 8'h11; //'q -> Q' key, 11
		8'h2D: keycode = 8'h12; //'r -> R' key, 12
		8'h1B: keycode = 8'h13; //'s -> S' key, 13
		8'h2C: keycode = 8'h14; //'t -> T' key, 14
		8'h3C: keycode = 8'h15; //'u -> U' key, 15
		8'h2A: keycode = 8'h16; //'v -> V' key, 16
		8'h1D: keycode = 8'h17; //'w -> W' key, 17
		8'h22: keycode = 8'h18; //'x -> X' key, 18
		8'h35: keycode = 8'h19; //'y -> Y' key, 19
		8'h1A: keycode = 8'h1A; //'z -> Z' key, 1A
		//number keys (0-9, `~, -_, =+, \|, BKSP)
		8'h70, //KP 0
		8'h45: keycode = 8'h1B; //'0 -> )' key, 1B
		8'h69, //KP 1
		8'h16: keycode = 8'h1C; //'1 -> !' key, 1C
		8'h72, //KP 2
		8'h1E: keycode = 8'h1D; //'2 -> @' key, 1D
		8'h7A, //KP 3
		8'h26: keycode = 8'h1E; //'3 -> #' key, 1E
		8'h6B, //KP 4
		8'h25: keycode = 8'h1F; //'4 -> $' key, 1F
		8'h73, //KP 5
		8'h2E: keycode = 8'h20; //'5 -> %' key, 20
		8'h74, //KP 6
		8'h36: keycode = 8'h21; //'6 -> ^' key, 21
		8'h6C, //KP 7
		8'h3D: keycode = 8'h22; //'7 -> &' key, 22
		8'h75, //KP 8
		8'h3E: keycode = 8'h23; //'8 -> *' key, 23
		8'h7D, //KP 9
		8'h46: keycode = 8'h24; //'9 -> (' key, 24
		8'h0E: keycode = 8'h25; //'` -> ~' key, 25
		8'h4E: keycode = 8'h26; //'- -> _' key, 26
		8'h55: keycode = 8'h27; //'= -> +' key, 27
		8'h5D: keycode = 8'h28; //'\ -> |' key, 28
		8'h66: keycode = 8'h29; //' BKSP ' key, 29
		//Control keys (SPACE, TAB, CAPS, SHIFT, CTRL, WIN, ALT, MENU, F0-F12, SCRLOCK, NUMLOCK)
		8'h29: keycode = 8'h2A; //'SPACE ' key, 2A
		8'h0D: keycode = 8'h2B; //' TAB  ' key, 2B
		8'h58: keycode = 8'h2C; //' CAPS ' key, 2C
		//LSHIFT and RSHIFT share keycode 2D
		8'h12: keycode = 8'h2D; //'LSHIFT' key, 2D
		8'h59: keycode = 8'h2D; //'RSHIFT' key, 2D
		8'h14: keycode = 8'h2E; //'LCTRL ' key, 2E (Shared by RCTRL)
		8'h11: keycode = 8'h2F; //' LALT ' key, 2F (Shared by RALT)
		8'h5A: keycode = 8'h30; //'ENTER ' key, 30
		8'h76: keycode = 8'h31; //' ESC  ' key, 31
		8'h05: keycode = 8'h34; //'  F1  ' key, 34
		8'h06: keycode = 8'h35; //'  F2  ' key, 35
		8'h04: keycode = 8'h36; //'  F3  ' key, 36
		8'h0C: keycode = 8'h37; //'  F4  ' key, 37
		8'h03: keycode = 8'h38; //'  F5  ' key, 38
		8'h0B: keycode = 8'h39; //'  F6  ' key, 39
		8'h83: keycode = 8'h3A; //'  F7  ' key, 3A
		8'h0A: keycode = 8'h3B; //'  F8  ' key, 3B
		8'h01: keycode = 8'h3C; //'  F9  ' key, 3C
		8'h09: keycode = 8'h3D; //'  F10 ' key, 3D
		8'h78: keycode = 8'h3E; //'  F11 ' key, 3E
		8'h07: keycode = 8'h3F; //'  F12 ' key, 3F
		8'h7E: keycode = 8'h4C; //'SCRLOCK' key, 4C
		8'h77: keycode = 8'h4D; //'NUMLOCK' key, 4D
		//Punctuation keys ([, ], ;, ', ,, ., /)
		8'h54: keycode = 8'h4E; //'   [   ' key, 4E
		8'h5B: keycode = 8'h4F; //'   ]   ' key, 4F
		8'h4C: keycode = 8'h50; //'   ;   ' key, 50
		8'h52: keycode = 8'h51; //'   '   ' key, 51
		8'h41: keycode = 8'h52; //'   ,   ' key, 52
		8'h49: keycode = 8'h53; //'   .   ' key, 53
		8'h4A: keycode = 8'h54; //'   /   ' key, 54
		//Keypad keys (KP *, KP -, KP +, KP .)
		8'h7C: keycode = 8'h55; //' KP *  ' key, 55
		8'h7B: keycode = 8'h56; //' KP -	 ' key, 56
		8'h79: keycode = 8'h57; //' KP +  ' key, 57
		8'h71: keycode = 8'h58; //' KP .  ' key, 58
		default: keycode = 8'h00;
	endcase
end



endmodule
