//http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf
//http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO2.pdf
`default_nettype none
`timescale 1ns/1ns
module afifo #(
	parameter DATA_WIDTH = 8,
	parameter ADDR_WIDTH = 4
)(
	output 	[DATA_WIDTH-1:0]	o_rdata,
	output						o_wfull,
	output						o_wfull_almost,
	output						o_rempty,
	output						o_rempty_almost,
	
	input	[DATA_WIDTH-1:0]	i_wdata,
	input						i_winc,
	input						i_wclk,
	input						i_wrst_n,
	input						i_rinc,
	input						i_rclk,
	input						i_rrst_n
);

	wire	[ADDR_WIDTH-1:0]	w_wptr;
	wire	[ADDR_WIDTH-1:0]	w_rptr;
	wire	[ADDR_WIDTH-1:0]	w_wptr_bin;
	wire	[ADDR_WIDTH-1:0]	w_rptr_bin;
	wire 						w_aempty_n;
	wire						w_afull_n;
	wire						w_winc;
	wire						w_rinc;
	wire 	[ADDR_WIDTH-1:0] 	w_bin_diff_wsr;
	wire 	[ADDR_WIDTH-1:0] 	w_bin_diff_rsw;
	reg 						r_rempty_almost;
	reg 						r_wfull_almost;
	

	// Almost Empty Condition
	assign w_bin_diff_wsr = w_wptr_bin - w_rptr_bin;
	assign o_rempty_almost = r_rempty_almost;
	always @(*) begin
		if ((w_bin_diff_wsr > 0 && w_bin_diff_wsr < 4) || o_rempty) begin
			r_rempty_almost <= 1'b1;
		end else begin
			r_rempty_almost <= 1'b0;
		end
	end

	// Almost Full Condition
	assign w_bin_diff_rsw = w_rptr_bin - w_wptr_bin;
	assign o_wfull_almost = r_wfull_almost;
	always @(*) begin
		if ((w_bin_diff_rsw > 0 && w_bin_diff_rsw < 4) || o_wfull) begin
			r_wfull_almost <= 1'b1;
		end else begin
			r_wfull_almost <= 1'b0;
		end
	end
	
	// Oveflow and underflow protection
	assign w_winc = i_winc & w_afull_n;
	assign w_rinc = i_rinc & w_aempty_n;

	async_cmp #(.ADDR_WIDTH(ADDR_WIDTH)) async_cmp (
		.o_aempty_n(w_aempty_n),
		.o_afull_n(w_afull_n),
		.i_wptr(w_wptr),
		.i_rptr(w_rptr),
		.i_wrst_n(i_wrst_n)
	);

	fifomem #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) fifomem (
		.o_rdata(o_rdata),
		.i_wdata(i_wdata),
		.i_waddr(w_wptr),
		.i_raddr(w_rptr),
		.i_wclken(w_winc),
		.i_wclk(i_wclk)
	);

	rptr_empty #(.ADDR_WIDTH(ADDR_WIDTH)) rptr_empty (
		.o_rempty(o_rempty),
		.o_rptr(w_rptr),
		.o_rptr_bin(w_rptr_bin),
		.i_aempty_n(w_aempty_n),
		.i_rinc(w_rinc),
		.i_rclk(i_rclk),
		.i_rrst_n(i_rrst_n)
	);

	wptr_full #(.ADDR_WIDTH(ADDR_WIDTH)) wptr_full (
		.o_wfull(o_wfull),
		.o_wptr(w_wptr),
		.o_wptr_bin(w_wptr_bin),
		.i_afull_n(w_afull_n),
		.i_winc(w_winc),
		.i_wclk(i_wclk),
		.i_wrst_n(i_wrst_n)		
	);

endmodule