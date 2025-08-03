// HDR Processor IP - Standalone IP for Multi-Exposure HDR Processing
// Implements OV9716 Staggered HDR Algorithm
// Author: HDR IP Team
// Date: 2024

module hdr_processor_ip #(
    // Pixel parameters
    parameter PIXEL_WIDTH = 12,
    parameter INTERNAL_WIDTH = 16,
    parameter FRAC_BITS = 8,
    
    // Image dimensions
    parameter MAX_WIDTH = 4096,
    parameter MAX_HEIGHT = 3072,
    
    // AXI parameters
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ADDR_WIDTH = 12,
    
    // Buffer parameters
    parameter BUFFER_DEPTH = 2048,
    parameter USE_BRAM = 1
)(
    // Global signals
    input  wire                         clk,
    input  wire                         rst_n,
    
    // AXI4-Stream slave interfaces for multi-exposure inputs
    // HCG (High Conversion Gain) input
    input  wire [PIXEL_WIDTH-1:0]       s_axis_hcg_tdata,
    input  wire                         s_axis_hcg_tvalid,
    output wire                         s_axis_hcg_tready,
    input  wire                         s_axis_hcg_tlast,
    input  wire                         s_axis_hcg_tuser,  // Start of frame
    
    // LCG (Low Conversion Gain) input
    input  wire [PIXEL_WIDTH-1:0]       s_axis_lcg_tdata,
    input  wire                         s_axis_lcg_tvalid,
    output wire                         s_axis_lcg_tready,
    input  wire                         s_axis_lcg_tlast,
    input  wire                         s_axis_lcg_tuser,
    
    // VS (Very Short exposure) input
    input  wire [PIXEL_WIDTH-1:0]       s_axis_vs_tdata,
    input  wire                         s_axis_vs_tvalid,
    output wire                         s_axis_vs_tready,
    input  wire                         s_axis_vs_tlast,
    input  wire                         s_axis_vs_tuser,
    
    // AXI4-Stream master interface for HDR output
    output wire [PIXEL_WIDTH-1:0]       m_axis_tdata,
    output wire                         m_axis_tvalid,
    input  wire                         m_axis_tready,
    output wire                         m_axis_tlast,
    output wire                         m_axis_tuser,
    
    // AXI4-Lite slave interface for configuration
    input  wire [AXI_ADDR_WIDTH-1:0]    s_axi_awaddr,
    input  wire [2:0]                   s_axi_awprot,
    input  wire                         s_axi_awvalid,
    output wire                         s_axi_awready,
    
    input  wire [AXI_DATA_WIDTH-1:0]    s_axi_wdata,
    input  wire [3:0]                   s_axi_wstrb,
    input  wire                         s_axi_wvalid,
    output wire                         s_axi_wready,
    
    output wire [1:0]                   s_axi_bresp,
    output wire                         s_axi_bvalid,
    input  wire                         s_axi_bready,
    
    input  wire [AXI_ADDR_WIDTH-1:0]    s_axi_araddr,
    input  wire [2:0]                   s_axi_arprot,
    input  wire                         s_axi_arvalid,
    output wire                         s_axi_arready,
    
    output wire [AXI_DATA_WIDTH-1:0]    s_axi_rdata,
    output wire [1:0]                   s_axi_rresp,
    output wire                         s_axi_rvalid,
    input  wire                         s_axi_rready,
    
    // Status signals
    output wire                         hdr_busy,
    output wire                         frame_done,
    output wire [31:0]                  frame_count,
    output wire                         error_flag
);

// Configuration registers
reg [15:0] reg_threshold1;      // DCG threshold
reg [15:0] reg_delta1;          // DCG delta
reg [15:0] reg_threshold_vs;    // VS threshold
reg [15:0] reg_delta2;          // VS delta
reg [7:0]  reg_exposure_ratio;  // VS exposure ratio
reg [11:0] reg_black_level;     // Black level
reg        reg_enable;          // HDR enable
reg        reg_use_vs;          // Use VS mode
reg [15:0] reg_img_width;       // Image width
reg [15:0] reg_img_height;      // Image height
reg        reg_bypass;          // Bypass mode

// AXI4-Lite register map
localparam REG_CONTROL      = 12'h000;  // Control register
localparam REG_THRESHOLD1   = 12'h004;  // DCG threshold
localparam REG_DELTA1       = 12'h008;  // DCG delta
localparam REG_THRESHOLD_VS = 12'h00C;  // VS threshold
localparam REG_DELTA2       = 12'h010;  // VS delta
localparam REG_EXPOSURE     = 12'h014;  // Exposure ratio
localparam REG_BLACK_LEVEL  = 12'h018;  // Black level
localparam REG_IMG_SIZE     = 12'h01C;  // Image size
localparam REG_STATUS       = 12'h020;  // Status register
localparam REG_FRAME_COUNT  = 12'h024;  // Frame counter

// Internal signals
wire [PIXEL_WIDTH-1:0] sync_hcg_data, sync_lcg_data, sync_vs_data;
wire sync_data_valid, sync_data_last, sync_data_user;
wire sync_data_ready;

wire [PIXEL_WIDTH-1:0] dcg_output;
wire dcg_valid, dcg_ready, dcg_last, dcg_user;

wire [PIXEL_WIDTH-1:0] hdr_output;
wire hdr_valid, hdr_ready, hdr_last, hdr_user;

// Frame synchronization and buffering
hdr_frame_sync #(
    .PIXEL_WIDTH(PIXEL_WIDTH),
    .BUFFER_DEPTH(BUFFER_DEPTH),
    .USE_BRAM(USE_BRAM)
) u_frame_sync (
    .clk(clk),
    .rst_n(rst_n),
    
    // Input streams
    .hcg_tdata(s_axis_hcg_tdata),
    .hcg_tvalid(s_axis_hcg_tvalid),
    .hcg_tready(s_axis_hcg_tready),
    .hcg_tlast(s_axis_hcg_tlast),
    .hcg_tuser(s_axis_hcg_tuser),
    
    .lcg_tdata(s_axis_lcg_tdata),
    .lcg_tvalid(s_axis_lcg_tvalid),
    .lcg_tready(s_axis_lcg_tready),
    .lcg_tlast(s_axis_lcg_tlast),
    .lcg_tuser(s_axis_lcg_tuser),
    
    .vs_tdata(s_axis_vs_tdata),
    .vs_tvalid(s_axis_vs_tvalid),
    .vs_tready(s_axis_vs_tready),
    .vs_tlast(s_axis_vs_tlast),
    .vs_tuser(s_axis_vs_tuser),
    
    // Synchronized output
    .sync_hcg_data(sync_hcg_data),
    .sync_lcg_data(sync_lcg_data),
    .sync_vs_data(sync_vs_data),
    .sync_valid(sync_data_valid),
    .sync_ready(sync_data_ready),
    .sync_last(sync_data_last),
    .sync_user(sync_data_user),
    
    .use_vs(reg_use_vs)
);

// DCG processor
dcg_processor #(
    .PIXEL_WIDTH(PIXEL_WIDTH),
    .INTERNAL_WIDTH(INTERNAL_WIDTH),
    .FRAC_BITS(FRAC_BITS)
) u_dcg_processor (
    .clk(clk),
    .rst_n(rst_n),
    
    // Configuration
    .threshold1(reg_threshold1),
    .delta1(reg_delta1),
    
    // Input
    .hcg_data(sync_hcg_data),
    .lcg_data(sync_lcg_data),
    .data_valid(sync_data_valid & sync_data_ready),
    .data_last(sync_data_last),
    .data_user(sync_data_user),
    
    // Output
    .dcg_output(dcg_output),
    .output_valid(dcg_valid),
    .output_last(dcg_last),
    .output_user(dcg_user)
);

// VS mixer and tone mapping
vs_mixer #(
    .PIXEL_WIDTH(PIXEL_WIDTH),
    .INTERNAL_WIDTH(INTERNAL_WIDTH),
    .FRAC_BITS(FRAC_BITS)
) u_vs_mixer (
    .clk(clk),
    .rst_n(rst_n),
    
    // Configuration
    .threshold_vs(reg_threshold_vs),
    .delta2(reg_delta2),
    .exposure_ratio(reg_exposure_ratio),
    .black_level(reg_black_level),
    .use_vs(reg_use_vs),
    
    // Input
    .dcg_data(dcg_output),
    .vs_data(sync_vs_data),
    .data_valid(dcg_valid),
    .data_last(dcg_last),
    .data_user(dcg_user),
    
    // Output
    .hdr_output(hdr_output),
    .output_valid(hdr_valid),
    .output_last(hdr_last),
    .output_user(hdr_user)
);

// Output assignment with bypass option
assign m_axis_tdata = reg_bypass ? sync_hcg_data : hdr_output;
assign m_axis_tvalid = reg_bypass ? (sync_data_valid & sync_data_ready) : hdr_valid;
assign m_axis_tlast = reg_bypass ? sync_data_last : hdr_last;
assign m_axis_tuser = reg_bypass ? sync_data_user : hdr_user;

assign sync_data_ready = reg_bypass ? m_axis_tready : 1'b1;
assign hdr_ready = m_axis_tready;

// Frame counter and status
reg [31:0] frame_counter;
reg frame_done_reg;

always @(posedge clk) begin
    if (!rst_n) begin
        frame_counter <= 32'd0;
        frame_done_reg <= 1'b0;
    end else begin
        frame_done_reg <= m_axis_tvalid & m_axis_tready & m_axis_tlast;
        if (m_axis_tvalid & m_axis_tready & m_axis_tlast)
            frame_counter <= frame_counter + 1'b1;
    end
end

assign frame_count = frame_counter;
assign frame_done = frame_done_reg;
assign hdr_busy = sync_data_valid | dcg_valid | hdr_valid;

// Error detection
wire sync_error, dcg_error, vs_error;
assign error_flag = sync_error | dcg_error | vs_error;

// AXI4-Lite interface
axi_lite_slave #(
    .DATA_WIDTH(AXI_DATA_WIDTH),
    .ADDR_WIDTH(AXI_ADDR_WIDTH)
) u_axi_lite_slave (
    .clk(clk),
    .rst_n(rst_n),
    
    // AXI interface
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awprot(s_axi_awprot),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arprot(s_axi_arprot),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready),
    
    // Register interface
    .reg_wr_en(reg_wr_en),
    .reg_wr_addr(reg_wr_addr),
    .reg_wr_data(reg_wr_data),
    .reg_rd_en(reg_rd_en),
    .reg_rd_addr(reg_rd_addr),
    .reg_rd_data(reg_rd_data)
);

// Register write logic
always @(posedge clk) begin
    if (!rst_n) begin
        reg_enable <= 1'b0;
        reg_use_vs <= 1'b1;
        reg_bypass <= 1'b0;
        reg_threshold1 <= 16'd166;      // 0.65 * 256
        reg_delta1 <= 16'd38;           // 0.15 * 256
        reg_threshold_vs <= 16'd230;    // 0.9 * 256
        reg_delta2 <= 16'd25;           // 0.1 * 256
        reg_exposure_ratio <= 8'd32;    // 0.125 * 256
        reg_black_level <= 12'd64;      // Black level
        reg_img_width <= 16'd1920;
        reg_img_height <= 16'd1080;
    end else if (reg_wr_en) begin
        case (reg_wr_addr)
            REG_CONTROL: begin
                reg_enable <= reg_wr_data[0];
                reg_use_vs <= reg_wr_data[1];
                reg_bypass <= reg_wr_data[2];
            end
            REG_THRESHOLD1: reg_threshold1 <= reg_wr_data[15:0];
            REG_DELTA1: reg_delta1 <= reg_wr_data[15:0];
            REG_THRESHOLD_VS: reg_threshold_vs <= reg_wr_data[15:0];
            REG_DELTA2: reg_delta2 <= reg_wr_data[15:0];
            REG_EXPOSURE: reg_exposure_ratio <= reg_wr_data[7:0];
            REG_BLACK_LEVEL: reg_black_level <= reg_wr_data[11:0];
            REG_IMG_SIZE: begin
                reg_img_width <= reg_wr_data[15:0];
                reg_img_height <= reg_wr_data[31:16];
            end
        endcase
    end
end

// Register read logic
always @(*) begin
    case (reg_rd_addr)
        REG_CONTROL: reg_rd_data = {29'd0, reg_bypass, reg_use_vs, reg_enable};
        REG_THRESHOLD1: reg_rd_data = {16'd0, reg_threshold1};
        REG_DELTA1: reg_rd_data = {16'd0, reg_delta1};
        REG_THRESHOLD_VS: reg_rd_data = {16'd0, reg_threshold_vs};
        REG_DELTA2: reg_rd_data = {16'd0, reg_delta2};
        REG_EXPOSURE: reg_rd_data = {24'd0, reg_exposure_ratio};
        REG_BLACK_LEVEL: reg_rd_data = {20'd0, reg_black_level};
        REG_IMG_SIZE: reg_rd_data = {reg_img_height, reg_img_width};
        REG_STATUS: reg_rd_data = {28'd0, error_flag, frame_done_reg, hdr_busy, reg_enable};
        REG_FRAME_COUNT: reg_rd_data = frame_counter;
        default: reg_rd_data = 32'd0;
    endcase
end

endmodule