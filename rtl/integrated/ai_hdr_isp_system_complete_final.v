// Complete AI + HDR + ISP Pipeline Integration - Part 1
// Module declaration and HDR processing section

module ai_hdr_isp_system_complete #(
    // Pixel parameters
    parameter PIXEL_WIDTH = 12,
    parameter INTERNAL_WIDTH = 16,
    parameter FRAC_BITS = 8,
    
    // Image dimensions
    parameter IMAGE_WIDTH = 4096,
    parameter IMAGE_HEIGHT = 3072,
    
    // Pipeline parameters
    parameter PIPELINE_STAGES = 16,
    parameter BURST_LENGTH = 16,
    
    // AXI parameters
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ADDR_WIDTH = 12,
    
    // AI parameters
    parameter AI_STATS_BITS = 32,
    parameter AI_SCENE_TYPES = 8,
    
    // Buffer parameters
    parameter BUFFER_DEPTH = 2048,
    parameter USE_BRAM = 1
)(
    // Global signals
    input  wire                         clk,
    input  wire                         rst_n,
    
    // Multi-exposure sensor interfaces
    input  wire [PIXEL_WIDTH-1:0]       sensor_hcg_data,
    input  wire                         sensor_hcg_valid,
    input  wire                         sensor_hcg_href,
    input  wire                         sensor_hcg_vsync,
    
    input  wire [PIXEL_WIDTH-1:0]       sensor_lcg_data,
    input  wire                         sensor_lcg_valid,
    input  wire                         sensor_lcg_href,
    input  wire                         sensor_lcg_vsync,
    
    input  wire [PIXEL_WIDTH-1:0]       sensor_vs_data,
    input  wire                         sensor_vs_valid,
    input  wire                         sensor_vs_href,
    input  wire                         sensor_vs_vsync,
    
    // Processed RGB output
    output wire [23:0]                  rgb_out,
    output wire                         rgb_valid,
    output wire                         rgb_href,
    output wire                         rgb_vsync,
    
    // AI outputs
    output wire [31:0]                  detected_scene,
    output wire [31:0]                  ai_confidence,
    output wire [31:0]                  quality_score,
    output wire                         ai_ready,
    
    // HDR status
    output wire                         hdr_active,
    output wire                         hdr_error,
    output wire [31:0]                  hdr_debug_status,
    
    // Control inputs
    input  wire                         hdr_enable,
    input  wire                         ai_enable,
    input  wire                         isp_bypass,
    input  wire [2:0]                   hdr_mode,
    
    // AXI4-Lite configuration interface
    input  wire [AXI_ADDR_WIDTH-1:0]    s_axi_awaddr,
    input  wire                         s_axi_awvalid,
    output wire                         s_axi_awready,
    input  wire [AXI_DATA_WIDTH-1:0]    s_axi_wdata,
    input  wire                         s_axi_wvalid,
    output wire                         s_axi_wready,
    output wire                         s_axi_bvalid,
    input  wire                         s_axi_bready,
    input  wire [AXI_ADDR_WIDTH-1:0]    s_axi_araddr,
    input  wire                         s_axi_arvalid,
    output wire                         s_axi_arready,
    output wire [AXI_DATA_WIDTH-1:0]    s_axi_rdata,
    output wire                         s_axi_rvalid,
    input  wire                         s_axi_rready,
    
    // UMS memory interface
    output wire [39:0]                  ums_addr,
    output wire [127:0]                 ums_wdata,
    output wire                         ums_write,
    output wire                         ums_read,
    input  wire [127:0]                 ums_rdata,
    input  wire                         ums_ready,
    
    // Debug interfaces
    output wire [31:0]                  debug_isp_state,
    output wire [31:0]                  debug_ai_params[0:15],
    output wire [31:0]                  debug_hdr_stats
);

// =========================================
// Internal signals
// =========================================

// HDR processor outputs
wire [PIXEL_WIDTH-1:0] hdr_output_data;
wire hdr_output_valid, hdr_output_href, hdr_output_vsync;
wire [31:0] hdr_stats_brightness, hdr_stats_contrast;

// DCG processor signals
wire [PIXEL_WIDTH-1:0] dcg_output_data;
wire dcg_output_valid;

// AI agent signals
wire [31:0] ai_params[0:31];
wire ai_params_updated;
wire [AI_STATS_BITS-1:0] histogram_data[0:255];
wire stats_ready;

// ISP pipeline signals
wire [23:0] isp_rgb_out;
wire isp_data_valid_out;
wire isp_frame_start_out;
wire isp_frame_end_out;

// Configuration registers
reg [31:0] config_regs[0:63];
wire [15:0] dcg_threshold = config_regs[0][15:0];
wire [15:0] dcg_delta = config_regs[0][31:16];
wire [15:0] hdr_exposure_ratio_1 = config_regs[1][15:0];
wire [15:0] hdr_exposure_ratio_2 = config_regs[1][31:16];
wire [11:0] black_level = config_regs[2][11:0];

// Position counters
reg [11:0] x_counter, y_counter;

// =========================================
// HDR Processing Stage
// =========================================

// Convert sensor interfaces to AXI-Stream
wire [PIXEL_WIDTH-1:0] hcg_stream_data, lcg_stream_data, vs_stream_data;
wire hcg_stream_valid, lcg_stream_valid, vs_stream_valid;
wire hcg_stream_ready, lcg_stream_ready, vs_stream_ready;
wire hcg_stream_last, lcg_stream_last, vs_stream_last;
wire hcg_stream_user, lcg_stream_user, vs_stream_user;

// HCG sensor to AXI-Stream
sensor_to_axis #(
    .DATA_WIDTH(PIXEL_WIDTH)
) u_hcg_converter (
    .clk(clk),
    .rst_n(rst_n),
    .sensor_data(sensor_hcg_data),
    .sensor_valid(sensor_hcg_valid),
    .sensor_href(sensor_hcg_href),
    .sensor_vsync(sensor_hcg_vsync),
    .axis_tdata(hcg_stream_data),
    .axis_tvalid(hcg_stream_valid),
    .axis_tready(hcg_stream_ready),
    .axis_tlast(hcg_stream_last),
    .axis_tuser(hcg_stream_user)
);

// LCG sensor to AXI-Stream
sensor_to_axis #(
    .DATA_WIDTH(PIXEL_WIDTH)
) u_lcg_converter (
    .clk(clk),
    .rst_n(rst_n),
    .sensor_data(sensor_lcg_data),
    .sensor_valid(sensor_lcg_valid),
    .sensor_href(sensor_lcg_href),
    .sensor_vsync(sensor_lcg_vsync),
    .axis_tdata(lcg_stream_data),
    .axis_tvalid(lcg_stream_valid),
    .axis_tready(lcg_stream_ready),
    .axis_tlast(lcg_stream_last),
    .axis_tuser(lcg_stream_user)
);

// VS sensor to AXI-Stream
sensor_to_axis #(
    .DATA_WIDTH(PIXEL_WIDTH)
) u_vs_converter (
    .clk(clk),
    .rst_n(rst_n),
    .sensor_data(sensor_vs_data),
    .sensor_valid(sensor_vs_valid),
    .sensor_href(sensor_vs_href),
    .sensor_vsync(sensor_vs_vsync),
    .axis_tdata(vs_stream_data),
    .axis_tvalid(vs_stream_valid),
    .axis_tready(vs_stream_ready),
    .axis_tlast(vs_stream_last),
    .axis_tuser(vs_stream_user)
);

// HDR processor output stream
wire [PIXEL_WIDTH-1:0] hdr_stream_data;
wire hdr_stream_valid, hdr_stream_ready, hdr_stream_last, hdr_stream_user;

// Instantiate HDR processor
hdr_processor_ip #(
    .PIXEL_WIDTH(PIXEL_WIDTH),
    .INTERNAL_WIDTH(INTERNAL_WIDTH),
    .FRAC_BITS(FRAC_BITS),
    .MAX_WIDTH(IMAGE_WIDTH),
    .MAX_HEIGHT(IMAGE_HEIGHT),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
    .BUFFER_DEPTH(BUFFER_DEPTH),
    .USE_BRAM(USE_BRAM)
) u_hdr_processor (
    .clk(clk),
    .rst_n(rst_n),
    
    // Multi-exposure inputs
    .s_axis_hcg_tdata(hcg_stream_data),
    .s_axis_hcg_tvalid(hcg_stream_valid),
    .s_axis_hcg_tready(hcg_stream_ready),
    .s_axis_hcg_tlast(hcg_stream_last),
    .s_axis_hcg_tuser(hcg_stream_user),
    
    .s_axis_lcg_tdata(lcg_stream_data),
    .s_axis_lcg_tvalid(lcg_stream_valid),
    .s_axis_lcg_tready(lcg_stream_ready),
    .s_axis_lcg_tlast(lcg_stream_last),
    .s_axis_lcg_tuser(lcg_stream_user),
    
    .s_axis_vs_tdata(vs_stream_data),
    .s_axis_vs_tvalid(vs_stream_valid),
    .s_axis_vs_tready(vs_stream_ready),
    .s_axis_vs_tlast(vs_stream_last),
    .s_axis_vs_tuser(vs_stream_user),
    
    // HDR output
    .m_axis_tdata(hdr_stream_data),
    .m_axis_tvalid(hdr_stream_valid),
    .m_axis_tready(hdr_stream_ready),
    .m_axis_tlast(hdr_stream_last),
    .m_axis_tuser(hdr_stream_user)
);

// Convert HDR stream back to parallel
axis_to_parallel #(
    .DATA_WIDTH(PIXEL_WIDTH)
) u_hdr_to_parallel (
    .clk(clk),
    .rst_n(rst_n),
    .axis_tdata(hdr_stream_data),
    .axis_tvalid(hdr_stream_valid),
    .axis_tready(hdr_stream_ready),
    .axis_tlast(hdr_stream_last),
    .axis_tuser(hdr_stream_user),
    .parallel_data(hdr_output_data),
    .parallel_valid(hdr_output_valid),
    .parallel_href(hdr_output_href),
    .parallel_vsync(hdr_output_vsync)
);
// Part 2 - DCG, ISP Pipeline, AI Agent and remaining modules

// =========================================
// DCG Processing (alternative path)
// =========================================

dcg_processor #(
    .PIXEL_WIDTH(PIXEL_WIDTH),
    .INTERNAL_WIDTH(INTERNAL_WIDTH),
    .FRAC_BITS(FRAC_BITS)
) u_dcg_processor (
    .clk(clk),
    .rst_n(rst_n),
    .threshold1(dcg_threshold),
    .delta1(dcg_delta),
    .hcg_data(sensor_hcg_data),
    .lcg_data(sensor_lcg_data),
    .data_valid(sensor_hcg_valid && sensor_lcg_valid),
    .data_last(sensor_hcg_href),
    .data_user(sensor_hcg_vsync),
    .dcg_output(dcg_output_data),
    .output_valid(dcg_output_valid),
    .output_last(),
    .output_user()
);

// Select between HDR and DCG output
wire [PIXEL_WIDTH-1:0] raw_data_selected;
wire raw_valid_selected;
wire raw_href_selected;
wire raw_vsync_selected;

assign raw_data_selected = (hdr_mode == 3'd1) ? dcg_output_data : 
                          (hdr_enable) ? hdr_output_data : sensor_hcg_data;
assign raw_valid_selected = (hdr_mode == 3'd1) ? dcg_output_valid : 
                           (hdr_enable) ? hdr_output_valid : sensor_hcg_valid;
assign raw_href_selected = (hdr_enable) ? hdr_output_href : sensor_hcg_href;
assign raw_vsync_selected = (hdr_enable) ? hdr_output_vsync : sensor_hcg_vsync;

// =========================================
// ISP Pipeline Integration
// =========================================

isp_pipeline_top #(
    .PIXEL_WIDTH(PIXEL_WIDTH),
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .IMAGE_HEIGHT(IMAGE_HEIGHT),
    .PIPELINE_STAGES(PIPELINE_STAGES),
    .BURST_LENGTH(BURST_LENGTH)
) u_isp_pipeline (
    .clk(clk),
    .rst_n(rst_n),
    
    // Sensor Interface
    .sensor_data(raw_data_selected),
    .sensor_hsync(raw_href_selected),
    .sensor_vsync(raw_vsync_selected),
    .sensor_pclk(raw_valid_selected),
    
    // Output Interface
    .rgb_out(isp_rgb_out),
    .data_valid_out(isp_data_valid_out),
    .frame_start_out(isp_frame_start_out),
    .frame_end_out(isp_frame_end_out)
);

// =========================================
// Statistics Collection for AI
// =========================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        x_counter <= 0;
        y_counter <= 0;
    end else if (raw_vsync_selected) begin
        x_counter <= 0;
        y_counter <= 0;
    end else if (raw_href_selected && raw_valid_selected) begin
        if (x_counter == IMAGE_WIDTH - 1) begin
            x_counter <= 0;
            y_counter <= y_counter + 1;
        end else begin
            x_counter <= x_counter + 1;
        end
    end
end

statistics_collector #(
    .PIXEL_WIDTH(PIXEL_WIDTH),
    .STATS_BITS(AI_STATS_BITS)
) u_stats (
    .clk(clk),
    .rst_n(rst_n),
    .pixel_data(raw_data_selected),
    .pixel_valid(raw_valid_selected),
    .frame_start(raw_vsync_selected),
    .line_start(raw_href_selected),
    .histogram_out(histogram_data),
    .brightness_out(hdr_stats_brightness),
    .contrast_out(hdr_stats_contrast),
    .stats_valid(stats_ready)
);

// =========================================
// AI Agent Core
// =========================================

ai_agent_core_enhanced #(
    .STATS_BITS(AI_STATS_BITS),
    .SCENE_TYPES(AI_SCENE_TYPES)
) u_ai_agent (
    .clk(clk),
    .rst_n(rst_n),
    .enable(ai_enable),
    .histogram_data(histogram_data),
    .brightness_stats(hdr_stats_brightness),
    .contrast_stats(hdr_stats_contrast),
    .hdr_active(hdr_enable),
    .scene_context(hdr_mode),
    .stats_valid(stats_ready),
    .ai_params(ai_params),
    .params_updated(ai_params_updated),
    .scene_type(detected_scene),
    .confidence(ai_confidence),
    .quality_score(quality_score),
    .ready(ai_ready)
);

// =========================================
// UMS Memory Interface
// =========================================

wire [PIXEL_WIDTH*3-1:0] rgb_pixel_data;
assign rgb_pixel_data = {isp_rgb_out[23:16], isp_rgb_out[15:8], isp_rgb_out[7:0]};

ums_frame_buffer #(
    .PIXEL_WIDTH(8),
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .IMAGE_HEIGHT(IMAGE_HEIGHT)
) u_frame_buffer (
    .clk(clk),
    .rst_n(rst_n),
    .pixel_data(rgb_pixel_data),
    .pixel_valid(isp_data_valid_out),
    .frame_start(isp_frame_start_out),
    .ums_addr(ums_addr),
    .ums_wdata(ums_wdata),
    .ums_write(ums_write),
    .ums_ready(ums_ready),
    .ai_read_req(1'b0),
    .ai_read_addr(40'h0)
);

assign ums_read = 1'b0;

// =========================================
// Configuration Interface
// =========================================

wire [7:0] config_wr_addr, config_rd_addr;
wire [31:0] config_wr_data, config_rd_data;
wire config_wr_en;

axi4_lite_slave #(
    .DATA_WIDTH(AXI_DATA_WIDTH),
    .ADDR_WIDTH(AXI_ADDR_WIDTH)
) u_axi_slave (
    .clk(clk),
    .rst_n(rst_n),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready),
    .reg_wr_addr(config_wr_addr),
    .reg_wr_data(config_wr_data),
    .reg_wr_en(config_wr_en),
    .reg_rd_addr(config_rd_addr),
    .reg_rd_data(config_rd_data)
);

// Configuration register management
integer i;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        config_regs[0] <= 32'h0100_0800;
        config_regs[1] <= 32'h0040_0100;
        config_regs[2] <= 32'h0000_0040;
        for (i = 3; i < 64; i = i + 1) begin
            config_regs[i] <= 32'h0;
        end
    end else if (config_wr_en) begin
        config_regs[config_wr_addr[5:0]] <= config_wr_data;
    end
end

assign config_rd_data = config_regs[config_rd_addr[5:0]];

// =========================================
// Output assignments
// =========================================

assign rgb_out = isp_rgb_out;
assign rgb_valid = isp_data_valid_out;
assign rgb_href = isp_frame_start_out;
assign rgb_vsync = isp_frame_end_out;

assign hdr_active = hdr_enable;
assign hdr_error = 1'b0;
assign hdr_debug_status = {16'h0, hdr_stats_brightness[15:0]};

// Debug outputs
assign debug_isp_state = {
    8'd0,
    isp_data_valid_out, raw_valid_selected, hdr_output_valid, ai_ready,
    4'd0,
    hdr_mode,
    detected_scene[3:0]
};

genvar j;
generate
    for (j = 0; j < 16; j = j + 1) begin : gen_debug_ai
        assign debug_ai_params[j] = ai_params[j];
    end
endgenerate

assign debug_hdr_stats = {hdr_stats_brightness[15:0], hdr_stats_contrast[15:0]};

endmodule
