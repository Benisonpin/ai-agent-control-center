module test_simple;
    reg clk;
    initial begin
        clk = 0;
        #100 $finish;
    end
    always #5 clk = ~clk;
endmodule
