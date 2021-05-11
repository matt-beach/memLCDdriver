module dump();
    initial begin
        $dumpfile ("memlcd_fsm.vcd");
        $dumpvars (0, memlcd_fsm);
        #1;
    end
endmodule
