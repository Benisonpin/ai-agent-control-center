`timescale 1ns/1ps

module test_minimal_system;
    reg clk, rst_n;
    reg [11:0] sensor_data;
    reg sensor_valid, sensor_hsync, sensor_vsync;
    
    wire [23:0] rgb_out;
    wire rgb_valid;
    wire [31:0] detected_scene;
    
    // DUT
    minimal_ai_isp_system u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .sensor_data(sensor_data),
        .sensor_valid(sensor_valid),
        .sensor_hsync(sensor_hsync),
        .sensor_vsync(sensor_vsync),
        .rgb_out(rgb_out),
        .rgb_valid(rgb_valid),
        .detected_scene(detected_scene)
    );
    
    // Clock
    initial clk = 0;
    always #5 clk = ~clk;
    
    // Test
    initial begin
        $dumpfile("test_minimal.vcd");
        $dumpvars(0, test_minimal_system);
        
        rst_n = 0;
        sensor_data = 0;
        sensor_valid = 0;
        sensor_hsync = 0;
        sensor_vsync = 0;
        
        #100 rst_n = 1;
        
        // Send some test data
        #20 sensor_vsync = 1;
        #20 sensor_vsync = 0;
        
        repeat(10) begin
            #10 sensor_data = $random;
            sensor_valid = 1;
            #10 sensor_valid = 0;
        end
        
        #100 $finish;
    end
    
endmodule
