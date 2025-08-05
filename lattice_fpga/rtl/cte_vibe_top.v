//==============================================================================
// CTE Vibe Code Top Module for Lattice LIFCL-40
// Target: LIFCL-40-9BG400C, Performance Grade 9, High-Performance 1.0V
// Integration with IMX25 Camera Sensor for AI Image Processing
//==============================================================================

module cte_vibe_top (
    // Clock and Reset
    input  wire         clk_200m,           // 200MHz main clock
    input  wire         clk_100m,           // 100MHz system clock  
    input  wire         rst_n,              // Active low reset
    
    // IMX25 Camera Interface
    input  wire [11:0]  imx25_data,         // 12-bit pixel data
    input  wire         imx25_pclk,         // Pixel clock from IMX25
    input  wire         imx25_href,         // Horizontal reference
    input  wire         imx25_vsync,        // Vertical sync
    output wire         imx25_reset_n,      // Camera reset
    output wire         imx25_pwdn,         // Camera power down
    
    // AI Processing Interface
    output wire [31:0]  ai_data_out,        // Processed AI data
    output wire         ai_data_valid,      // AI data valid signal
    input  wire [7:0]   ai_config,          // AI configuration
    
    // CTE Vibe Code Control Interface
    input  wire [31:0]  vibe_cmd,           // Vibe command input
    output wire [31:0]  vibe_status,        // Vibe status output
    output wire         vibe_interrupt,     // Interrupt to host
    
    // Memory Interface (DDR3/4)
    output wire [13:0]  ddr_addr,
    output wire [2:0]   ddr_ba,
    output wire         ddr_cas_n,
    output wire         ddr_ck,
    output wire         ddr_cke,
    output wire         ddr_cs_n,
    inout  wire [31:0]  ddr_dq,
    inout  wire [3:0]   ddr_dqs,
    output wire         ddr_odt,
    output wire         ddr_ras_n,
    output wire         ddr_reset_n,
    output wire         ddr_we_n,
    
    // Debug and Test
    output wire [7:0]   debug_led,
    input  wire [3:0]   debug_sw,
    output wire         test_point
);

//==============================================================================
// Parameters for LIFCL-40 Optimization
//==============================================================================
parameter DEVICE_FAMILY = "LIFCL";
parameter PERFORMANCE_GRADE = "9_High-Performance_1.0V";
parameter PACKAGE = "CABGA400";
parameter TARGET_FPS = 32.5;
parameter TARGET_LATENCY_MS = 28;
parameter TARGET_POWER_W = 3.5;

//==============================================================================
// Clock Management - Optimized for Lattice LIFCL
//==============================================================================
wire clk_pll_lock;
wire clk_ai_proc;      // AI processing clock
wire clk_pixel;        // Pixel processing clock
wire clk_memory;       // Memory interface clock

// Lattice PLL IP for clock generation
cte_pll u_cte_pll (
    .ref_clk_i      (clk_100m),
    .rst_n_i        (rst_n),
    .lock_o         (clk_pll_lock),
    .outcore_o      (clk_ai_proc),     // 250MHz for AI processing
    .outglobal_o    (clk_pixel),       // 200MHz for pixel pipeline
    .outglobal2_o   (clk_memory)       // 400MHz for DDR interface
);

//==============================================================================
// CTE Vibe Code AI Processing Pipeline
//==============================================================================
wire [31:0] pipeline_data [0:7];   // 8-stage pipeline
wire [7:0]  pipeline_valid;
wire [15:0] frame_counter;
wire [15:0] latency_counter;

// Stage 1: IMX25 Camera Interface
cte_imx25_interface u_imx25_if (
    .clk            (clk_pixel),
    .rst_n          (rst_n & clk_pll_lock),
    
    .imx25_data     (imx25_data),
    .imx25_pclk     (imx25_pclk),
    .imx25_href     (imx25_href),
    .imx25_vsync    (imx25_vsync),
    .imx25_reset_n  (imx25_reset_n),
    .imx25_pwdn     (imx25_pwdn),
    
    .pixel_data_o   (pipeline_data[0]),
    .pixel_valid_o  (pipeline_valid[0]),
    .frame_start_o  (frame_start),
    .line_start_o   (line_start)
);

// Stage 2: ISP Preprocessing (Demosaic, HDR, Denoise)
cte_isp_pipeline u_isp_pipeline (
    .clk            (clk_pixel),
    .rst_n          (rst_n & clk_pll_lock),
    
    .raw_data_i     (pipeline_data[0]),
    .raw_valid_i    (pipeline_valid[0]),
    
    .rgb_data_o     (pipeline_data[1]),
    .rgb_valid_o    (pipeline_valid[1]),
    
    .frame_start_i  (frame_start),
    .line_start_i   (line_start)
);

// Stage 3-6: AI Processing Stages
genvar i;
generate
    for (i = 2; i <= 5; i = i + 1) begin : ai_stages
        cte_ai_processing_stage #(
            .STAGE_ID(i-1)
        ) u_ai_stage (
            .clk            (clk_ai_proc),
            .rst_n          (rst_n & clk_pll_lock),
            
            .data_i         (pipeline_data[i-1]),
            .valid_i        (pipeline_valid[i-1]),
            .config_i       (ai_config),
            
            .data_o         (pipeline_data[i]),
            .valid_o        (pipeline_valid[i])
        );
    end
endgenerate

// Stage 7: Output Formatting
cte_output_formatter u_output_fmt (
    .clk            (clk_ai_proc),
    .rst_n          (rst_n & clk_pll_lock),
    
    .ai_result_i    (pipeline_data[5]),
    .ai_valid_i     (pipeline_valid[5]),
    
    .formatted_o    (pipeline_data[6]),
    .formatted_valid_o (pipeline_valid[6])
);

// Stage 8: Vibe Code Interface
cte_vibe_interface u_vibe_if (
    .clk            (clk_ai_proc),
    .rst_n          (rst_n & clk_pll_lock),
    
    .data_i         (pipeline_data[6]),
    .valid_i        (pipeline_valid[6]),
    .vibe_cmd_i     (vibe_cmd),
    
    .ai_data_o      (ai_data_out),
    .ai_valid_o     (ai_data_valid),
    .vibe_status_o  (vibe_status),
    .vibe_interrupt_o (vibe_interrupt)
);

//==============================================================================
// Performance Monitoring for 32.5fps @ 28ms Latency
//==============================================================================
cte_performance_monitor u_perf_mon (
    .clk            (clk_ai_proc),
    .rst_n          (rst_n & clk_pll_lock),
    
    .frame_start_i  (frame_start),
    .ai_valid_i     (ai_data_valid),
    
    .fps_counter_o  (frame_counter),
    .latency_ms_o   (latency_counter),
    .performance_ok_o (performance_ok)
);

//==============================================================================
// Memory Controller for DDR3/4
//==============================================================================
cte_memory_controller u_mem_ctrl (
    .clk_mem        (clk_memory),
    .clk_sys        (clk_ai_proc),
    .rst_n          (rst_n & clk_pll_lock),
    
    // DDR Interface
    .ddr_addr       (ddr_addr),
    .ddr_ba         (ddr_ba),
    .ddr_cas_n      (ddr_cas_n),
    .ddr_ck         (ddr_ck),
    .ddr_cke        (ddr_cke),
    .ddr_cs_n       (ddr_cs_n),
    .ddr_dq         (ddr_dq),
    .ddr_dqs        (ddr_dqs),
    .ddr_odt        (ddr_odt),
    .ddr_ras_n      (ddr_ras_n),
    .ddr_reset_n    (ddr_reset_n),
    .ddr_we_n       (ddr_we_n),
    
    // Internal Interface
    .mem_req_i      (mem_req),
    .mem_addr_i     (mem_addr),
    .mem_data_i     (mem_data_i),
    .mem_data_o     (mem_data_o),
    .mem_ready_o    (mem_ready)
);

//==============================================================================
// Debug and Status
//==============================================================================
assign debug_led = {
    performance_ok,     // [7] Performance OK
    clk_pll_lock,       // [6] PLL Locked
    ai_data_valid,      // [5] AI Processing Active
    pipeline_valid[0],  // [4] Camera Data Valid
    frame_counter[3:0]  // [3:0] Frame Counter
};

assign test_point = ai_data_valid & (latency_counter < 28);

endmodule
