`default_nettype none
`timescale 1ns/1ns
`define HLINES 123
`define VLINES 647
module memlcd_fsm #(
	parameter DATA_WIDTH = 8 
)(
	input 					i_clk,
    input 					i_reset,
    input [DATA_WIDTH-1:0] 	i_data,

    input 					i_rempty,
    output 					o_rinc,

    output 					o_intb,
    output 					o_gsp,
    output 					o_gck,
    output 					o_gen,
    output 					o_bsp,
    output 					o_bck,
    output 	[5:0]			o_rgb
);

	reg		[6:0]			r_count_iclk; 	// For adjusting control signal setup and hold times
	reg		[6:0]			r_count_h;		// Keep track of horizontal pixal position
	reg		[9:0]			r_count_v;		// Keep track of vertical pixal position
	reg 					r_active_h;
	reg  					r_finish_frame;

    reg 					r_intb;
    reg 					r_gsp;
    reg 					r_gck;
    reg 					r_gen;
    reg 					r_bsp;
    reg 					r_bck;
    reg 	[5:0]			r_rgb;

	reg 					r_rinc;	


	always @(posedge i_clk or posedge i_reset) begin
		if (i_reset) begin
			r_intb			<= 1'b0;
			r_gsp 			<= 1'b0;
			r_gck			<= 1'b0;
			r_gen			<= 1'b0;
			r_bsp			<= 1'b0;
			r_bck			<= 1'b0;
			r_rgb			<= 6'b0;
			r_rinc			<= 1'b0;

			r_count_iclk 	<= 0;
			r_count_h 		<= `HLINES-20;
			r_count_v 		<= `VLINES;

			r_active_h		<= 0; // Used as a wire in an always @(*)

		end else if (!i_rempty || r_finish_frame) begin // Only proceed with signaling if the FIFO is not empty
			// Update counter registers
			r_count_iclk <= (r_count_iclk == 127) ? 0 : r_count_iclk + 1'b1;
			if (r_count_iclk == 127) begin
				r_count_h <= (r_count_h == `HLINES) ? 0 : r_count_h + 1'b1;
			end
			if ((r_count_iclk == 127) && (r_count_h == `HLINES)) begin
				r_count_v <= (r_count_v == `VLINES) ? 0 : r_count_v + 1'b1;
			end

			// r_rinc control
			if ((r_count_iclk == 127) && ((r_count_h > 0) && (r_count_h < 121)) && r_active_h) begin
				r_rinc <= 1'b1;
			end else begin
				r_rinc <= 1'b0;
			end

			// r_rgb control
			if ((r_count_h > 0) && (r_count_h < 121) && r_active_h) begin
				r_rgb <= i_data[5:0];
			end else begin
				r_rgb <= 6'b0;
			end

			// r_bck control
			if ((r_count_iclk == 80) && r_active_h) begin
				r_bck <= ~r_bck;
			end

			// r_bsp control
			if ((r_count_iclk == 48) && (r_count_h == 0) && r_active_h) begin
				r_bsp <= 1'b1;
			end else if ((r_count_iclk == 48) && (r_count_h == 2)) begin
				r_bsp <= 1'b0;
			end

			// r_gck control
			if ((r_count_iclk == 16) && (r_count_h == 0)) begin
				r_gck <= ~r_gck;
			end

			// r_gsp control
			if ((r_count_v == `VLINES) && (r_count_h == 118)) begin
				r_gsp <= 1'b1;
			end else if ((r_count_v == 1) && (r_count_h == 118)) begin
				r_gsp <= 1'b0;
			end

			// r_gen control
			if ((r_count_v > 1) && (r_count_v < 642) && (r_count_h > 40) && (r_count_h < `HLINES - 40)) begin
				r_gen <= 1'b1;
			end else begin
				r_gen <= 1'b0;
			end

			// r_intb control
			if ((r_count_v == `VLINES) && (r_count_h == 110)) begin
				r_intb <= 1'b1;
			end else if ((r_count_v == 645) && (r_count_h == 110)) begin
				r_intb <= 1'b0;
			end
		end
	end


	always @(*) begin
		if ((r_count_v >= 1) && (r_count_v < 641)) begin
			r_active_h <= 1'b1;
		end else begin
			r_active_h <= 1'b0;
		end
	end

	// Finsh frame 
	always @(*) begin
		if ((r_count_v == 640) && (r_count_h == 120)) begin
			r_finish_frame <= 1'b1;
		end else if ((r_count_v == `VLINES) && (r_count_h == `HLINES-20)) begin
			r_finish_frame <= 1'b0;
		end
	end

	assign 	o_rgb 	= r_rgb;
	assign	o_intb	= r_intb;
	assign	o_gsp 	= r_gsp;
	assign	o_gck	= r_gck;
	assign	o_gen	= r_gen;
	assign	o_bsp	= r_bsp;
	assign	o_bck	= r_bck;
	assign	o_rinc	= r_rinc;

endmodule