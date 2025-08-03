// AI + HDR + ISP Integrated System Top Module
// This module integrates HDR processing, AI scene detection, and complete ISP pipeline

module ai_hdr_isp_integrated_top #(
    parameter PIXEL_WIDTH = 12,
    parameter IMAGE_WIDTH = 4096,
    parameter IMAGE_HEIGHT = 3072
)(
    input  wire                         clk,
    input  wire                         rst_n,
    
    // Multi-exposure sensor inputs
    input  wire [PIXEL_WIDTH-1:0]       sensor_hcg_data,
    input  wire                         sensor_hcg_valid,
    input  wire                         sensor_lcg_data,
    input  wire                         sensor_lcg_valid,
    input  wire                         sensor_vs_data,
    input  wire                         sensor_vs_valid,
    input  wire                         sensor_hsync,
    input  wire                         sensor_vsync,
    input  wire                         sensor_pclk,
    
    // RGB output
    output wire [23:0]                  rgb_out,
    output wire                         rgb_valid,
    output wire                         hsync_out,
    output wire                         vsync_out,
    
    // AI outputs
    output wire [31:0]                  detected_scene,
    output wire [31:0]                  ai_confidence,
    output wire                         ai_ready,
    
    // Control
    input  wire                         hdr_enable,
    input  wire                         ai_enable,
    input  wire [1:0]                   hdr_mode,
    
    // Configuration
    input  wire [31:0]                  config_addr,
    input  wire [31:0]                  config_data,
    input  wire                         config_write
);

    // Internal signals
    wire [PIXEL_WIDTH-1:0] hdr_output;
    wire hdr_valid;
    wire [31:0] ai_params[0:15];
    wire ai_params_updated;
    wire [31:0] scene_stats;
    
    // Instantiate HDR processor
    hdr_processor_ip #(
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) u_hdr (
        .clk(clk),
        .rst_n(rst_n),
        // Connect HDR inputs/outputs
    );
    
    // Instantiate ISP pipeline
    isp_pipeline_top #(
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT)
    ) u_isp (
        .clk(clk),
        .rst_n(rst_n),
        .sensor_data(hdr_output),
        .sensor_hsync(sensor_hsync),
        .sensor_vsync(sensor_vsync),
        .sensor_pclk(hdr_valid),
        .rgb_out(rgb_out),
        .data_valid_out(rgb_valid),
        .frame_start_out(hsync_out),
        .frame_end_out(vsync_out)
    );
    
    // Instantiate AI agent
    ai_agent_core u_ai (
        .clk(clk),
        .rst_n(rst_n),
        .enable(ai_enable),
        .scene_type(detected_scene),
        .quality_score(ai_confidence),
        .ready(ai_ready)
    );

endmodule
