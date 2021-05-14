module dump();
    initial begin
        $dumpfile ("sfifo.vcd");
        $dumpvars (0, sfifo);
        #1;
    end
endmodule
