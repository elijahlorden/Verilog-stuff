`timescale 1ns / 1ps
module ps2Interface(
	input clk,
	input rx_enable,
	inout ps2clk, ps2data,
	output [7:0] rx_data_out,
	output reg rx_done_stb
);

localparam
state_idle 	= 1'b0,	//Waiting to receive or transmit data
state_rx 	= 1'b1;	//Receiving data

reg [15:0] ps2clk_filter = 0;
wire [15:0] ps2clk_filter_next;
reg ps2clk_filtered = 1'd0;
wire ps2clk_filtered_next;
wire ps2clk_negedge_stb;
wire ps2clk_posedge_stb;
reg [10:0] rx_data = 0, rx_data_next;
reg state = state_idle, state_next;
reg [3:0] rx_bitcount = 0, rx_bitcount_next;
reg [15:0] rx_timeout = 0, rx_timeout_next;

assign ps2clk_filter_next = {ps2clk, ps2clk_filter[15:1]};

assign ps2clk_filtered_next = (ps2clk_filter == 16'hFFFF) ? 1'b1 : (ps2clk_filter == 16'h0000) ? 1'b0 : ps2clk_filtered;

assign ps2clk_negedge_stb = ps2clk_filtered & ~ps2clk_filtered_next;

assign rx_data_out = rx_data[8:1];

//Latching for ps2 clock filtering and state logic
always @(posedge clk) begin
	ps2clk_filter <= ps2clk_filter_next;
	ps2clk_filtered <= ps2clk_filtered_next;
	state <= state_next;
	rx_bitcount <= rx_bitcount_next;
	rx_timeout <= rx_timeout_next;
	rx_data <= rx_data_next;
end

//Combinational state logic
always @* begin
	//Default values
	state_next = state;
	rx_done_stb = 1'b0;
	rx_bitcount_next = rx_bitcount;
	rx_data_next = rx_data;
	rx_timeout_next = rx_timeout;
	case(state)
		state_idle:
			if (ps2clk_negedge_stb & rx_enable) begin
				state_next = state_rx;
				rx_bitcount_next = 4'd10;
				rx_timeout_next = 16'hFFFF;
			end
		state_rx:
			begin
				rx_timeout_next = rx_timeout - 16'd1;
				if (ps2clk_negedge_stb) begin
					rx_data_next = {ps2data, rx_data[10:1]};
					rx_bitcount_next = rx_bitcount - 4'd1;
				end
				if (rx_bitcount == 0) begin
					state_next = state_idle;
					rx_done_stb = 1'b1;
				end else if (rx_timeout == 0) begin //If for some reason a bit is not received, this ensures that the state logic does not get stuck
					state_next = state_idle;
				end
			end
	endcase
end










endmodule
