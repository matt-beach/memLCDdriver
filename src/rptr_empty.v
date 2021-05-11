`default_nettype none
`timescale 1ns/1ns
module rptr_empty #(
	parameter ADDR_WIDTH = 4
)(
	output reg						o_rempty,
	output reg 	[ADDR_WIDTH-1:0]	o_rptr,
	output		[ADDR_WIDTH-1:0]	o_rptr_bin,
	input							i_aempty_n,
	input							i_rinc,
	input							i_rclk,
	input							i_rrst_n
);

	reg		[ADDR_WIDTH-1:0] 	r_rbin;
	reg							r_rempty2;
	wire 	[ADDR_WIDTH-1:0]	w_rgnext;
	wire	[ADDR_WIDTH-1:0] 	w_rbnext;

	assign o_rptr_bin = r_rbin;

	// Grey Code Pointer
	always @(posedge i_rclk or negedge i_rrst_n) begin
		if (!i_rrst_n) begin
			o_rptr <= 0;
			r_rbin <= 0;
		end else begin
			o_rptr <= w_rgnext;
			r_rbin <= w_rbnext;
		end
	end

	assign w_rbnext = !o_rempty ? r_rbin + i_rinc : r_rbin;
	assign w_rgnext = (w_rbnext >> 1) ^ w_rbnext;

	// Increment binary counter if not empty
	always @(posedge i_rclk or negedge i_aempty_n) begin
		if (!i_aempty_n) begin
			{o_rempty, r_rempty2} <= 2'b11;
		end else begin
			{o_rempty, r_rempty2} <= {r_rempty2, ~i_aempty_n};
		end
	end

endmodule