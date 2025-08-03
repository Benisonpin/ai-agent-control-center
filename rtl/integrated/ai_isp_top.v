// Top-level AI ISP Controller
module ai_isp_top #(
    parameter PIXEL_WIDTH = 12,
    parameter IMAGE_WIDTH = 1920,
    parameter IMAGE_HEIGHT = 1080
)(
    input wire clk,
    input wire rst_n,
    
    // Sensor Interface
    input wire [PIXEL_WIDTH-1:0] sensor_data,
    input wire sensor_hsync,
    input wire sensor_vsync,
    input wire sensor_pclk,
    
    // Output Interface
    output wire [23:0] rgb_out,
    output wire data_valid_out,
    output wire hsync_out,
    output wire vsync_out,
    
    // AI Control
    input wire ai_enable,
    output wire [31:0] detected_scene,
    output wire [31:0] quality_score,
    output wire ai_ready,
    
    // Debug Interface
    output wire [31:0] debug_awb_r_gain,
    output wire [31:0] debug_aw
cat > testbench/ai_isp_tb.v << 'EOF'
// AI ISP Testbench
`timescale 1ns/1ps

module ai_isp_tb;
    parameter PIXEL_WIDTH = 12;
    parameter IMAGE_WIDTH = 64;  // Small for simulation
    parameter IMAGE_HEIGHT = 48;
    
    reg clk, rst_n;
    reg [PIXEL_WIDTH-1:0] sensor_data;
    reg sensor_hsync, sensor_vsync, sensor_pclk;
    reg ai_enable;
    
    wire [23:0] rgb_out;
    wire data_valid_out;
    wire [31:0] detected_scene;
    wire [31:0] quality_score;
    wire ai_ready;
    wire [31:0] frame_count;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz
    end
    
    initial begin
        sensor_pclk = 0;
        forever #10 sensor_pclk = ~sensor_pclk;  // 50MHz
    end
    
    // DUT
    ai_isp_top #(
        .P
cat > testbench/ai_isp_tb.v << 'EOF'
// AI ISP Testbench
`timescale 1ns/1ps

module ai_isp_tb;
    parameter PIXEL_WIDTH = 12;
    parameter IMAGE_WIDTH = 64;  // Small for simulation
    parameter IMAGE_HEIGHT = 48;
    
    reg clk, rst_n;
    reg [PIXEL_WIDTH-1:0] sensor_data;
    reg sensor_hsync, sensor_vsync, sensor_pclk;
    reg ai_enable;
    
    wire [23:0] rgb_out;
    wire data_valid_out;
    wire [31:0] detected_scene;
    wire [31:0] quality_score;
    wire ai_ready;
    wire [31:0] frame_count;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz
    end
    
    initial begin
        sensor_pclk = 0;
        forever #10 sensor_pclk = ~sensor_pclk;  // 50MHz
    end
    
    // DUT
    ai_isp_top #(
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .sensor_data(sensor_data),
        .sensor_hsync(sensor_hsync),
        .sensor_vsync(sensor_vsync),
        .sensor_pclk(sensor_pclk),
        .rgb_out(rgb_out),
        .data_valid_out(data_valid_out),
        .hsync_out(),
        .vsync_out(),
        .ai_enable(ai_enable),
        .detected_scene(detected_scene),
        .quality_score(quality_score),
        .ai_ready(ai_ready),
        .debug_awb_r_gain(),
        .debug_awb_b_gain(),
        .debug_nr_strength(),
        .frame_count(frame_count)
    );
    
    // Test stimulus
    initial begin
        $dumpfile("ai_isp.vcd");
        $dumpvars(0, ai_isp_tb);
        
        // Initialize
        rst_n = 0;
        ai_enable = 1;
        sensor_data = 0;
        sensor_hsync = 1;
        sensor_vsync = 1;
        
        #100 rst_n = 1;
        
        // Generate test frames
        repeat(3) begin
            generate_frame();
            #1000;
        end
        
        $display("Test completed!");
        $display("Frames processed: %d", frame_count);
        $display("Detected scene: %d", detected_scene);
        $display("Quality score: %d", quality_score);
        
        #1000 $finish;
    end
    
    // Frame generation task
    task generate_frame;
        integer x, y;
        begin
            // VSYNC pulse
            sensor_vsync = 1;
            repeat(10) @(posedge sensor_pclk);
            sensor_vsync = 0;
            
            // Active frame
            for (y = 0; y < IMAGE_HEIGHT; y = y + 1) begin
                // HSYNC pulse
                sensor_hsync = 1;
                repeat(10) @(posedge sensor_pclk);
                sensor_hsync = 0;
                
                // Active line
                for (x = 0; x < IMAGE_WIDTH; x = x + 1) begin
                    // Generate test pattern
                    sensor_data = ((x + y) * 4095) / (IMAGE_WIDTH + IMAGE_HEIGHT);
                    @(posedge sensor_pclk);
                end
                
                // H blanking
                sensor_hsync = 1;
                repeat(20) @(posedge sensor_pclk);
            end
            
            // V blanking
            sensor_vsync = 1;
            repeat(100) @(posedge sensor_pclk);
        end
    endtask
    
    // Monitor scene changes
    always @(posedge ai_ready) begin
        case (detected_scene)
            0: $display("Scene: DAYLIGHT detected at frame %d", frame_count);
            1: $display("Scene: LOWLIGHT detected at frame %d", frame_count);
            2: $display("Scene: PORTRAIT detected at frame %d", frame_count);
            3: $display("Scene: LANDSCAPE detected at frame %d", frame_count);
            4: $display("Scene: HIGH CONTRAST detected at frame %d", frame_count);
        endcase
    end

endmodule
