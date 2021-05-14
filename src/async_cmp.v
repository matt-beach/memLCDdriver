`default_nettype none
`timescale 1ns/1ns
module async_cmp #(
	parameter ADDR_WIDTH = 4
)(
	output 					o_aempty_n,
	output 					o_afull_n,
	input [ADDR_WIDTH-1:0] 	i_wptr,
	input [ADDR_WIDTH-1:0] 	i_rptr,
	input 					i_wrst_n
);

	reg	 	direction;
	wire	high;
	wire 	dirset_n;
	wire	dirclr_n;

	assign high = 1'b1;
	assign dirset_n = ~((i_wptr[ADDR_WIDTH-1] ^ i_rptr[ADDR_WIDTH-2]) & ~(i_wptr[ADDR_WIDTH-2] ^ i_rptr[ADDR_WIDTH-1]));
	assign dirclr_n = ~((~(i_wptr[ADDR_WIDTH-1] ^ i_rptr[ADDR_WIDTH-2]) & (i_wptr[ADDR_WIDTH-2] ^ i_rptr[ADDR_WIDTH-1])) | ~i_wrst_n);
	
	// RS Flip-Flop
	// always @(posedge high or negedge dirset_n or negedge dirclr_n) begin
	// 	if (!dirclr_n) begin
	// 		direction <= 1'b0;
	// 	end else if (!dirset_n) begin
	// 		direction <= 1'b1;
	// 	end else begin
	// 		direction <= high;
	// 	end
	// end

	always @(negedge dirset_n or negedge dirclr_n) begin
		if (!dirclr_n) begin
			direction <= 1'b0;
		end else begin
			direction <= 1'b1;
		end
	end
	
	assign o_aempty_n 	= ~((i_wptr == i_rptr) && !direction);
	assign o_afull_n	= ~((i_wptr == i_rptr) && direction);

endmodule