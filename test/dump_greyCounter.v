module dump();
    initial begin
        $dumpfile ("greyCounter.vcd");
        $dumpvars (0, greyCounter);
        #1;
    end
endmodule
