`default_nettype none
`timescale 1ns/1ns
module memLCDdriver (
    // System Control Signals
    input   i_clk, // 100MHz
    input   i_reset,
    input   i_vcom_start,
    // For Logic analizer
    output  o_wfull,
    output  o_wfull_almost,
    output  o_rempty,
    output  o_rempty_almost,
    // SPI RX Port
    input   i_spi_mosi,
    input   i_spi_cs_n,
    input   i_spi_clk,
    output  o_spi_cts,
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
    wire [5:0]  w_lcd_data;
    wire        w_spi_dataValid;
    wire        w_rclk;
    wire        w_rinc;
    wire        w_rempty;
    wire        w_wfull;
    wire        w_rempty_almost;
    wire        w_wfull_almost;
    reg         r_spi_cts;
    reg         r_va;
    reg         r_vb;
    reg         r_vcom;

    // SPI Reciever
    spi_s spi_s(
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_spi_mosi(i_spi_mosi),
        .i_spi_cs_n(i_spi_cs_n),
        .i_spi_clk(i_spi_clk),
        .o_rx_data(w_spi_data),
        .o_rx_dataValid(w_spi_dataValid)
    );

    // Syncronous FIFO
    sfifo #(.DATA_WIDTH(6), .ADDR_WIDTH(6)) sfifo (
        .i_clk(i_clk),
        .i_reset(i_reset),
	    .o_rdata(w_lcd_data),
	    .i_wdata(w_spi_data[5:0]),
	    .i_rinc(w_rinc),
	    .i_winc(w_spi_dataValid),
	    .o_wfull(w_wfull),
	    .o_wfull_almost(w_wfull_almost),
	    .o_rempty(w_rempty),
	    .o_rempty_almost(w_rempty_almost)
    );

    // LCD controller
    memlcd_fsm #(.DATA_WIDTH(6)) memlcd_fsm (
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

    // Clear to Send
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_spi_cts <= 1'b1;
        end else if (w_rempty_almost) begin
            r_spi_cts <= 1'b1;
        end else if (w_wfull_almost) begin
            r_spi_cts <= 1'b0;
        end
    end
    assign o_spi_cts    =   r_spi_cts;


    // Generate 60Hz clock for VCOM, VA, and VB
    clockdiv #(.DIVISOR(1666666), .SIZE(20)) vcom_clockdiv (
        .i_clk(i_clk), 
        .i_reset(i_reset || !i_vcom_start), 
        .o_clk_div(w_clk_vcom)
    );
    always @(*) begin
        if (i_vcom_start) begin
            r_vcom   <= !w_clk_vcom;
            r_va     <= w_clk_vcom;
            r_vb     <= !w_clk_vcom;
        end else begin
            r_vcom   <= 1'b0;
            r_va     <= 1'b0;
            r_vb     <= 1'b0;
        end
    end
    assign o_vcom   = r_vcom;
    assign o_va     = r_va;
    assign o_vb     = r_vb;

    assign o_rempty         = w_rempty;
    assign o_wfull          = w_wfull;
    assign o_rempty_almost  = w_rempty_almost;
    assign o_wfull_almost   = w_wfull_almost;
endmodule