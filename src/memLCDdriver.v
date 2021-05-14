`default_nettype none
`timescale 1ns/1ns
module memLCDdriver (
    // System Control Signals
    input   i_clk, // 100MHz
    input   i_reset,
    output  o_wfull,
    output  o_wfull_almost,
    output  o_rempty,
    output  o_rempty_almost,
    // SPI RX Port
    input   i_spi_mosi,
    input   i_spi_nss,
    input   i_spi_clk,
    // Memory LCD signals
    output  o_va,
    output  o_vb,
    output  o_vcom,
    output  o_gsp,
    output  o_gck,
    output  o_gen,
    output  o_intb,
    output  o_bsp,
    output  o_bck,
    output  [5:0] o_rgb
);
    
    wire        w_clk_vcom;
    wire [7:0]  w_spi_data;
    wire [7:0]  w_lcd_data;
    wire        w_spi_dataValid;
    wire        w_rclk;
    wire        w_rinc;
    wire        w_rempty;
    wire        w_wfull;

    // Generate 60Hz clock for VCOM, VA, and VB
    clockdiv #(.DIVISOR(16666666), .SIZE(20)) vcom_clockdiv (
        .i_clk(i_clk), 
        .i_reset(i_reset), 
        .o_clk_div(w_clk_vcom)
    );

    // SPI Reciever
    spi_s spi_s(
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_spi_mosi(i_spi_mosi),
        .i_spi_nss(i_spi_nss),
        .i_spi_clk(i_spi_clk),
        .o_rx_data(w_spi_data),
        .o_rx_dataValid(w_spi_dataValid)
    );

    // Syncronous FIFO
    sfifo #(.DATA_WIDTH(8), .ADDR_WIDTH(12)) sfifo (
        .i_clk(i_clk),
        .i_reset(i_reset),
	    .o_rdata(w_lcd_data),
	    .i_wdata(w_spi_data),
	    .i_rinc(w_rinc),
	    .i_winc(w_spi_dataValid),
	    .o_wfull(w_wfull),
	    .o_wfull_almost(o_wfull_almost),
	    .o_rempty(w_rempty),
	    .o_rempty_almost(o_rempty_almost)
    );

    // LCD controller
    memlcd_fsm #(.DATA_WIDTH(8)) memlcd_fsm (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_data(w_lcd_data),
        .i_rempty(w_rempty),
        .o_rinc(w_rinc),
        .o_intb(o_intb),
        .o_gsp(o_gsp),
        .o_gck(o_gck),
        .o_gen(o_gen),
        .o_bsp(o_bsp),
        .o_bck(o_bck),
        .o_rgb(o_rgb)
    );

    assign o_vcom   = w_clk_vcom;
    assign o_va     = !w_clk_vcom;
    assign o_vb     = w_clk_vcom;
    assign o_rempty = w_rempty;
    assign o_wfull  = w_wfull;

endmodule