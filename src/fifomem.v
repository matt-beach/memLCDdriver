`default_nettype none
`timescale 1ns/1ns
module fifomem #(
	parameter DATA_WIDTH = 8, 					// Memory data word width
	parameter ADDR_WIDTH = 4, 					// Number of memory address bits
	parameter FIFO_DEPTH = (1 << ADDR_WIDTH)	// FIFO_DEPTH = 2**ADDR_WIDTH
)(
	output 	[DATA_WIDTH-1:0] 	o_rdata,
	input 	[DATA_WIDTH-1:0] 	i_wdata,
	input 	[ADDR_WIDTH-1:0] 	i_waddr, 
	input 	[ADDR_WIDTH-1:0] 	i_raddr,
	input 						i_wclken,
	input						i_wclk
);

	reg [DATA_WIDTH-1:0] MEM [0:FIFO_DEPTH-1];

	assign o_rdata = MEM[i_raddr];

	always @(posedge i_wclk) begin
		if (i_wclken) begin 
			MEM[i_waddr] <= i_wdata;
		end
	end

endmodule