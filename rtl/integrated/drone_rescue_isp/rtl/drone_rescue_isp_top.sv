// 無人機搜救 ISP 頂層模組
module drone_rescue_isp_top #(
    parameter WIDTH = 1920,
    parameter HEIGHT = 1080,
    parameter MAX_TARGETS = 10
)(
    // Zynq PS 介面
    input logic FCLK_CLK0,    // 100MHz from PS
    input logic FCLK_RESET0_N,
    
    // Camera 介面 (假設 MIPI CSI-2)
    input logic [9:0] cam_data_short,
    input logic [9:0] cam_data_medium,
    input logic [9:0] cam_data_long,
    input logic cam_valid,
    input logic cam_frame_start,
    input logic cam_line_start,
    
    // AXI HP 介面到 DDR (用於結果輸出)
    output logic [31:0] M_AXI_HP0_awaddr,
    output logic M_AXI_HP0_awvalid,
    input logic M_AXI_HP0_awready,
    // ... 其他 AXI 信號
    
    // 目標追蹤輸出 (低延遲)
    output logic target_irq,  // 發現新目標中斷
    output logic [MAX_TARGETS-1:0][31:0] target_info
);

    // 內部信號
    logic [9:0] hdr_pixel;
    logic hdr_valid;
    logic [2:0] scene_type;
    
    // HDR 處理
    hdr_processor_lite u_hdr (
        .clk(FCLK_CLK0),
        .rst_n(FCLK_RESET0_N),
        .pixel_short(cam_data_short),
        .pixel_medium(cam_data_medium),
        .pixel_long(cam_data_long),
        .pixels_valid(cam_valid),
        .hdr_pixel(hdr_pixel),
        .hdr_valid(hdr_valid),
        .scene_type(scene_type),
        .scene_valid()
    );
    
    // 運動偵測與追蹤
    motion_detector_optimized #(
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT),
        .MAX_TARGETS(MAX_TARGETS)
    ) u_motion (
        .clk(FCLK_CLK0),
        .rst_n(FCLK_RESET0_N),
        .pixel_in(hdr_pixel),
        .pixel_valid(hdr_valid),
        .frame_start(cam_frame_start),
        .line_start(cam_line_start),
        .exposure_idx(2'd1),
        .hdr_enable(1'b1),
        .target_positions(target_info[MAX_TARGETS-1:0][15:0]),
        .target_confidence(target_info[MAX_TARGETS-1:0][23:16]),
        .target_valid(target_info[MAX_TARGETS-1:0][31]),
        .targets_updated(target_irq)
    );

endmodule
