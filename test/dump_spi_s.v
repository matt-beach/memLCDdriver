module dump();
    initial begin
        $dumpfile ("spi_s.vcd");
        $dumpvars (0, spi_s);
        #1;
    end
endmodule
