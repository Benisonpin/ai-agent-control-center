// Complete AI + HDR + ISP Pipeline Integration
// Combines HDR processing, AI scene detection, and full ISP pipeline
// with UMS memory management support

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
    // HCG (High Conversion Gain) - for low light
    input  wire [PIXEL_WIDTH-1:0]       sensor_hcg_data,
    input  wire                         sensor_hcg_valid,
    input  wire                         sensor_hcg_href,
    input  wire                         sensor_hcg_vsync,
    
    // LCG (Low Conversion Gain) - for bright light
    input  wire [PIXEL_WIDTH-1:0]       sensor_lcg_data,
    input  wire                         sensor_lcg_valid,
    input  wire                         sensor_lcg_href,
    input  wire                         sensor_lcg_vsync,
    
    // VS (Very Short exposure) - for highlights
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
    input  wire [2:0]                   hdr_mode,  // 0: Off, 1: DCG, 2: 3-exposure, 3: AI-adaptive
    
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

// Internal signals and module instantiations will be added here
// This is the main integration module that connects:
// 1. HDR processor (HDR_TOP_Verilog.v)
// 2. DCG processor (DCG_Module.v)
// 3. ISP pipeline (isp_pipeline_top.v)
// 4. AI agent (ai_agent_core.v)
// 5. Support modules (support_modules_complete.v)

endmodule
