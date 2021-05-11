`default_nettype none
`timescale 1ns/1ns
module wptr_full #(
	parameter ADDR_WIDTH = 4
)(
	output reg						o_wfull,
	output reg	[ADDR_WIDTH-1:0]	o_wptr,
	output		[ADDR_WIDTH-1:0]	o_wptr_bin,
	input							i_afull_n,
	input							i_winc,
	input							i_wclk,
	input							i_wrst_n
);

	reg		[ADDR_WIDTH-1:0] 	r_wbin;
	reg							r_wfull2;
	wire 	[ADDR_WIDTH-1:0]	w_wgnext;
	wire	[ADDR_WIDTH-1:0] 	w_wbnext;

	assign o_wptr_bin = r_wbin;

	// Grey Code Pointer
	always @(posedge i_wclk or negedge i_wrst_n) begin
		if (!i_wrst_n) begin
			o_wptr <= 0;
			r_wbin <= 0;
		end else begin
			o_wptr <= w_wgnext;
			r_wbin <= w_wbnext;
		end
	end

	assign w_wbnext = !o_wfull ? r_wbin + i_winc : r_wbin;
	assign w_wgnext = (w_wbnext >> 1) ^ w_wbnext;

	// Increment binary counter if not empty
	always @(posedge i_wclk or negedge i_afull_n or negedge i_wrst_n) begin
		if (!i_wrst_n) begin
			{o_wfull, r_wfull2} <= 1'b00;
		end else if (!i_afull_n) begin
			{o_wfull, r_wfull2} <= 2'b11;
		end else begin
			{o_wfull, r_wfull2} <= {r_wfull2, ~i_afull_n};
		end
	end

endmodule