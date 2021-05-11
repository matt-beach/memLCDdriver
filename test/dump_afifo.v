module dump();
    initial begin
        $dumpfile ("afifo.vcd");
        $dumpvars (0, afifo);
        #1;
    end
endmodule
