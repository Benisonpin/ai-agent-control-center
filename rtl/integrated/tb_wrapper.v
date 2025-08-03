// Testbench wrapper for the integrated system

`timescale 1ns/1ps

module tb_wrapper;
    reg clk;
    reg rst_n;
    
    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz clock
    
    // Reset generation
    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
    end
    
    // Instantiate the integrated system
    ai_hdr_isp_integrated_top u_dut (
        .clk(clk),
        .rst_n(rst_n)
        // Connect other signals
    );
    
    // Test stimulus
    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, tb_wrapper);
        
        // Run simulation
        #10000;
        $finish;
    end
    
endmodule
