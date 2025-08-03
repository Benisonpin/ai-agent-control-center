// 測試平台
`timescale 1ns/1ps

module tb_drone_rescue_isp;
    logic clk, rst_n;
    logic [9:0] cam_data_s, cam_data_m, cam_data_l;
    logic cam_valid, cam_frame_start, cam_line_start;
    logic target_irq;
    logic [9:0][31:0] target_info;
    
    // DUT
    drone_rescue_isp_top #(
        .WIDTH(64),    // 縮小用於仿真
        .HEIGHT(48),
        .MAX_TARGETS(10)
    ) dut (.*);
    
    // Clock
    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz
    
    // Test scenario
    initial begin
        $dumpfile("drone_isp.vcd");
        $dumpvars(0, tb_drone_rescue_isp);
        
        rst_n = 0;
        cam_valid = 0;
        #100 rst_n = 1;
        
        // 模擬運動物體
        generate_moving_target();
        
        #10000 $finish;
    end
    
    task generate_moving_target();
        // 簡化的測試圖案生成
        // 實際實現...
    endtask
    
endmodule
