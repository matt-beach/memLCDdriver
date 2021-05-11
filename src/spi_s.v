`default_nettype none
`timescale 1ns/1ns
module spi_s (
	input			i_clk,
	input			i_reset,

	input 			i_spi_mosi,
	input 			i_spi_nss,
	input			i_spi_clk,

	output	[7:0] 	o_rx_data,
	output 			o_rx_dataValid
);

	// Registers
	reg				r_spi_mosi;
	reg 			r_spi_nss;
	reg 			r_spi_clk;
	reg 			r_prev_spi_clk;
	reg 			r_prev_spi_nss;
	reg 	[7:0] 	r_rx_data;
	reg 	[2:0]	r_rx_indx;

	// Wires
	wire 			w_rising_spi_clk;
	wire 			w_valid_spi_bit;
	wire 			w_spi_packet_start;
	wire    [7:0]	w_rx_data;
	wire 	[2:0]	w_rx_indx;
	wire 			w_rx_dataValid;


	always @(posedge i_clk) begin
		// Buffered input data
		r_spi_mosi	<= i_spi_mosi;
		r_spi_nss 	<= i_spi_nss;
		r_spi_clk 	<= i_spi_clk;
		// Previous state history
		r_prev_spi_clk <= r_spi_clk;
		r_prev_spi_nss <= r_spi_nss;
	end
	assign w_rising_spi_clk = r_spi_clk & ~r_prev_spi_clk;   // Pulse on rising spi clk edge
	assign w_valid_spi_bit	= w_rising_spi_clk & ~r_spi_nss; // Valid spi bit when nss is low
	assign w_spi_packet_start = r_prev_spi_nss & ~r_spi_nss; // Packet start on falling nss edge

	// Capture incoming SPI Data
	always @(posedge i_clk) begin
		if (w_valid_spi_bit) begin
			r_rx_data[w_rx_indx] <= r_spi_mosi;
			r_rx_indx <= (w_rx_indx > 0 ? w_rx_indx - 1 : 7);
		end else begin
			r_rx_indx <= w_rx_indx;
		end
	end
	assign w_rx_indx = (i_reset || w_spi_packet_start ? 7 : r_rx_indx);
	assign w_rx_data = {r_rx_data[7:1], r_spi_mosi};
	assign w_rx_dataValid = (w_valid_spi_bit && w_rx_indx == 0 ? 1 : 0);

	// Push wires to output ports
	assign o_rx_data = w_rx_data;
	assign o_rx_dataValid = w_rx_dataValid;
	
endmodule