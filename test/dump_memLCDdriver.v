module dump();
    initial begin
        $dumpfile ("memLCDdriver.vcd");
        $dumpvars (0, memLCDdriver);
        #1;
    end
endmodule
