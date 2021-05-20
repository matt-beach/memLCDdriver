`timescale 1ns/1ns
module sfifo #(
	parameter DATA_WIDTH = 8,
	parameter ADDR_WIDTH = 4,
    parameter FIFO_DEPTH = 1 << ADDR_WIDTH
)(
    input                       i_clk,
    input                       i_reset,

	output 	[DATA_WIDTH-1:0]	o_rdata,
	input	[DATA_WIDTH-1:0]	i_wdata,
	input						i_winc,
	input						i_rinc,

	output						o_wfull,
	output						o_wfull_almost,
	output						o_rempty,
	output						o_rempty_almost
);

    reg     [ADDR_WIDTH-1:0]    r_wr_ptr;
    reg     [ADDR_WIDTH-1:0]    r_rd_ptr;
    reg     [ADDR_WIDTH  :0]    r_status_cnt;
    reg     [DATA_WIDTH-1:0]    r_data_out ;
    wire    [DATA_WIDTH-1:0]    w_data_ram ;
    wire                        w_winc;
    wire                        w_rinc;
    reg                         r_wfull_almost;
    reg                         r_rempty_almost;
    wire    [ADDR_WIDTH-1:0]    w_bin_diff_rsw;
    wire    [ADDR_WIDTH-1:0]    w_bin_diff_wsr;

    assign o_wfull  = (r_status_cnt == (FIFO_DEPTH-1));
    assign o_rempty = (r_status_cnt == 0);
    assign o_rdata  = r_data_out;

    assign w_winc = i_winc & !o_wfull; // Protect from overflow
    assign w_rinc = i_rinc & !o_rempty; // Protect from underflow

    // Write Pointer
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_wr_ptr <= 0;
        end else if (w_winc) begin
            r_wr_ptr <= r_wr_ptr + 1;
        end
    end

    // Read Pointer
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_rd_ptr <= 0;
        end else if (w_rinc) begin
            r_rd_ptr <= r_rd_ptr + 1;
        end
    end

    // Status Counter
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_status_cnt <= 0;
        end else if (!w_winc && w_rinc && (r_status_cnt != 0)) begin // Read but no write when not empty
            r_status_cnt <= r_status_cnt - 1;
        end else if (w_winc && !w_rinc && (r_status_cnt != FIFO_DEPTH)) begin // Write but no read when not full
            r_status_cnt <= r_status_cnt + 1;
        end
    end

    // Read Data
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_data_out <= 0;
        end else if (w_rinc) begin
            r_data_out <= w_data_ram;
        end
    end

	// Almost Empty
	assign w_bin_diff_wsr = r_wr_ptr - r_rd_ptr;
	always @(*) begin
		if ((w_bin_diff_wsr > 0 && w_bin_diff_wsr <= 4) || o_rempty) begin
			r_rempty_almost <= 1'b1;
		end else begin
			r_rempty_almost <= 1'b0;
		end
	end
	assign o_rempty_almost = r_rempty_almost;

	// Almost Full
	assign w_bin_diff_rsw = r_rd_ptr - r_wr_ptr;
	always @(*) begin
		if ((w_bin_diff_rsw > 0 && w_bin_diff_rsw <= 4) || o_wfull) begin
			r_wfull_almost <= 1'b1;
		end else begin
			r_wfull_almost <= 1'b0;
		end
	end
	assign o_wfull_almost = r_wfull_almost;

    // Duel Port RAM
	fifomem #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) fifomem (
		.o_rdata(w_data_ram),
		.i_wdata(i_wdata),
		.i_waddr(r_wr_ptr),
		.i_raddr(r_rd_ptr),
		.i_wclken(i_winc),
		.i_wclk(i_clk)
	);

endmodule