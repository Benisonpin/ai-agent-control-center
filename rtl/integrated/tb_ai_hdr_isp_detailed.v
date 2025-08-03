`timescale 1ns/1ps

module tb_ai_hdr_isp_detailed;
    // Parameters
    parameter PIXEL_WIDTH = 12;
    parameter IMAGE_WIDTH = 64;  // 縮小用於測試
    parameter IMAGE_HEIGHT = 48;
    parameter CLK_PERIOD = 10;   // 100MHz
    
    // Signals
    reg clk;
    reg rst_n;
    
    // Sensor signals
    reg [PIXEL_WIDTH-1:0] sensor_hcg_data;
    reg sensor_hcg_valid;
    reg sensor_hcg_href;
    reg sensor_hcg_vsync;
    
    // Clock generation
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // Simple test
    initial begin
        $dumpfile("ai_hdr_isp_sim.vcd");
        $dumpvars(0, tb_ai_hdr_isp_detailed);
        
        // Reset
        rst_n = 0;
        sensor_hcg_data = 0;
        sensor_hcg_valid = 0;
        sensor_hcg_href = 0;
        sensor_hcg_vsync = 0;
        
        #100 rst_n = 1;
        #1000 $finish;
    end
endmodule
