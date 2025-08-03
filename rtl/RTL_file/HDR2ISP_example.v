// Example: Integrating HDR IP with existing ISP Pipeline
// This shows how to modify your existing ISP to support HDR

module isp_pipeline_with_hdr #(
    parameter PIXEL_WIDTH = 12,
    parameter IMAGE_WIDTH = 1920,
    parameter IMAGE_HEIGHT = 1080,
    parameter USE_HDR = 1
)(
    input  wire                     clk,
    input  wire                     rst_n,
    
    // Normal sensor interface
    input  wire [PIXEL_WIDTH-1:0]   sensor_data,
    input  wire                     sensor_valid,
    input  wire                     sensor_href,
    input  wire                     sensor_vsync,
    
    // HDR sensor interfaces (only used if USE_HDR = 1)
    input  wire [PIXEL_WIDTH-1:0]   sensor_hcg_data,
    input  wire                     sensor_hcg_valid,
    input  wire [PIXEL_WIDTH-1:0]   sensor_lcg_data,
    input  wire                     sensor_lcg_valid,
    input  wire [PIXEL_WIDTH-1:0]   sensor_vs_data,
    input  wire                     sensor_vs_valid,
    
    // Processed output
    output wire [23:0]              rgb_out,
    output wire                     rgb_valid,
    output wire                     rgb_href,
    output wire                     rgb_vsync,
    
    // Configuration
    input  wire                     hdr_mode,
    input  wire [31:0]              isp_config_addr,
    input  wire [31:0]              isp_config_data,
    input  wire                     isp_config_write
);

// Internal signals
wire [PIXEL_WIDTH-1:0] raw_data;
wire raw_valid, raw_href, raw_vsync;

generate
if (USE_HDR) begin : gen_hdr
    // HDR processor signals
    wire [PIXEL_WIDTH-1:0] hdr_out_data;
    wire hdr_out_valid, hdr_out_href, hdr_out_vsync;
    
    // Instantiate HDR-ISP connector
    hdr_isp_connector #(
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) u_hdr_connector (
        .clk(clk),
        .rst_n(rst_n),
        
        // Multi-exposure inputs
        .sensor_hcg_data(sensor_hcg_data),
        .sensor_hcg_valid(sensor_hcg_valid),
        .sensor_hcg_href(sensor_href),
        .sensor_hcg_vsync(sensor_vsync),
        
        .sensor_lcg_data(sensor_lcg_data),
        .sensor_lcg_valid(sensor_lcg_valid),
        .sensor_lcg_href(sensor_href),
        .sensor_lcg_vsync(sensor_vsync),
        
        .sensor_vs_data(sensor_vs_data),
        .sensor_vs_valid(sensor_vs_valid),
        .sensor_vs_href(sensor_href),
        .sensor_vs_vsync(sensor_vsync),
        
        // Output to ISP
        .isp_raw_data(hdr_out_data),
        .isp_raw_valid(hdr_out_valid),
        .isp_href(hdr_out_href),
        .isp_vsync(hdr_out_vsync),
        .isp_ready(1'b1),
        
        // Configuration
        .hdr_enable(hdr_mode),
        .hdr_bypass(1'b0),
        
        // HDR configuration via ISP config bus
        .s_axi_awaddr(isp_config_addr[11:0]),
        .s_axi_awvalid(isp_config_write & (isp_config_addr[31:16] == 16'hHDR0)),
        .s_axi_wdata(isp_config_data),
        .s_axi_wvalid(isp_config_write & (isp_config_addr[31:16] == 16'hHDR0)),
        // ... other AXI signals
    );
    
    // Multiplexer for HDR mode
    assign raw_data = hdr_mode ? hdr_out_data : sensor_data;
    assign raw_valid = hdr_mode ? hdr_out_valid : sensor_valid;
    assign raw_href = hdr_mode ? hdr_out_href : sensor_href;
    assign raw_vsync = hdr_mode ? hdr_out_vsync : sensor_vsync;
    
end else begin : gen_no_hdr
    // No HDR - direct connection
    assign raw_data = sensor_data;
    assign raw_valid = sensor_valid;
    assign raw_href = sensor_href;
    assign raw_vsync = sensor_vsync;
end
endgenerate

// Original ISP pipeline stages
wire [PIXEL_WIDTH-1:0] blc_out;
wire blc_valid;

// Stage 1: Black Level Correction
black_level_correction #(
    .DATA_WIDTH(PIXEL_WIDTH)
) u_blc (
    .clk(clk),
    .rst_n(rst_n),
    .pixel_in(raw_data),
    .pixel_valid(raw_valid),
    .href_in(raw_href),
    .vsync_in(raw_vsync),
    .black_level(12'd64),
    .pixel_out(blc_out),
    .pixel_out_valid(blc_valid)
);

// Continue with other ISP stages...
// (Lens shading, Demosaic, AWB, CCM, Gamma, etc.)

endmodule

// Configuration example for software
module hdr_config_example;
    // HDR configuration registers
    localparam HDR_BASE_ADDR = 32'hHDR0_0000;
    
    // Register addresses
    localparam HDR_CONTROL      = HDR_BASE_ADDR + 32'h000;
    localparam HDR_THRESHOLD1   = HDR_BASE_ADDR + 32'h004;
    localparam HDR_DELTA1       = HDR_BASE_ADDR + 32'h008;
    localparam HDR_THRESHOLD_VS = HDR_BASE_ADDR + 32'h00C;
    localparam HDR_DELTA2       = HDR_BASE_ADDR + 32'h010;
    localparam HDR_EXPOSURE     = HDR_BASE_ADDR + 32'h014;
    localparam HDR_BLACK_LEVEL  = HDR_BASE_ADDR + 32'h018;
    
    // Example configuration sequence
    initial begin
        // Enable HDR with VS
        write_config(HDR_CONTROL, 32'h00000003);      // Enable + Use VS
        
        // DCG parameters
        write_config(HDR_THRESHOLD1, 32'h00000166);   // 0.65 * 256
        write_config(HDR_DELTA1, 32'h00000026);       // 0.15 * 256
        
        // VS parameters
        write_config(HDR_THRESHOLD_VS, 32'h000000E6); // 0.9 * 256
        write_config(HDR_DELTA2, 32'h00000019);       // 0.1 * 256
        write_config(HDR_EXPOSURE, 32'h00000020);     // 0.125 * 256
        
        // Black level
        write_config(HDR_BLACK_LEVEL, 32'h00000040);  // 64
    end
    
    task write_config(input [31:0] addr, input [31:0] data);
        // Implementation depends on your system
    endtask
endmodule

// Alternative: Direct integration into ISP pipeline
module isp_pipeline_integrated_hdr #(
    parameter PIXEL_WIDTH = 12
)(
    input  wire                     clk,
    input  wire                     rst_n,
    
    // Multi-exposure inputs
    input  wire [PIXEL_WIDTH-1:0]   hcg_data,
    input  wire [PIXEL_WIDTH-1:0]   lcg_data,
    input  wire [PIXEL_WIDTH-1:0]   vs_data,
    input  wire                     pixel_valid,
    input  wire                     line_valid,
    input  wire                     frame_valid,
    
    // RGB output
    output wire [23:0]              rgb_out,
    output wire                     rgb_valid
);

// HDR processing as first stage
wire [PIXEL_WIDTH-1:0] hdr_pixel;
wire hdr_valid;

// Instantiate only the HDR core modules
dcg_processor #(
    .PIXEL_WIDTH(PIXEL_WIDTH)
) u_dcg (
    .clk(clk),
    .rst_n(rst_n),
    .threshold1(16'd166),
    .delta1(16'd38),
    .hcg_data(hcg_data),
    .lcg_data(lcg_data),
    .data_valid(pixel_valid),
    .dcg_output(dcg_pixel),
    .output_valid(dcg_valid)
);

vs_mixer #(
    .PIXEL_WIDTH(PIXEL_WIDTH)
) u_vs (
    .clk(clk),
    .rst_n(rst_n),
    .threshold_vs(16'd230),
    .delta2(16'd25),
    .exposure_ratio(8'd32),
    .black_level(12'd64),
    .use_vs(1'b1),
    .dcg_data(dcg_pixel),
    .vs_data(vs_data),
    .data_valid(dcg_valid),
    .hdr_output(hdr_pixel),
    .output_valid(hdr_valid)
);

// Continue with ISP pipeline stages
// The HDR output feeds directly into the ISP pipeline
// without additional buffering or interface conversion

endmodule