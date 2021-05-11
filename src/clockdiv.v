`default_nettype none
`timescale 1ns/1ns
module clockdiv #(
	parameter SIZE = 32,
	parameter DIVISOR = 16
)(
    input i_clk,
    input i_reset,

    output reg o_clk_div

 );

	reg [SIZE-1:0] counter;

	always @(posedge i_clk or posedge i_reset) begin
		if (i_reset) begin
			counter <= 0;
			o_clk_div <= 1'b0;
		end else begin
			counter <= counter + 1'b1;
			if (counter == DIVISOR/2) begin
				o_clk_div <= !o_clk_div;
				counter <= 0;
			end
		end
	end

endmodule