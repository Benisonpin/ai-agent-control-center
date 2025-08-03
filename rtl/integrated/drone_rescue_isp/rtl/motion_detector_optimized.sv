// 優化的運動偵測模組 for 搜救無人機
module motion_detector_optimized #(
    parameter WIDTH = 1920,
    parameter HEIGHT = 1080,
    parameter PIXEL_BITS = 10,
    parameter MAX_TARGETS = 10,
    parameter BLOCK_SIZE = 32
)(
    input logic clk,
    input logic rst_n,
    
    // 像素輸入流
    input logic [PIXEL_BITS-1:0] pixel_in,
    input logic pixel_valid,
    input logic frame_start,
    input logic line_start,
    
    // HDR 控制
    input logic [1:0] exposure_idx,  // 0:短 1:中 2:長曝光
    input logic hdr_enable,
    
    // 運動目標輸出
    output logic [MAX_TARGETS-1:0][15:0] target_positions,  // X[15:8], Y[7:0]
    output logic [MAX_TARGETS-1:0][7:0] target_confidence,
    output logic [MAX_TARGETS-1:0] target_valid,
    output logic targets_updated
);

    // 最小化記憶體使用 - 只保存 3 行
    logic [PIXEL_BITS-1:0] line_buffer[3][WIDTH/BLOCK_SIZE];
    logic [$clog2(WIDTH)-1:0] pixel_x;
    logic [$clog2(HEIGHT)-1:0] pixel_y;
    
    // 運動特徵提取
    logic [7:0] motion_map[WIDTH/BLOCK_SIZE][HEIGHT/BLOCK_SIZE];
    logic [7:0] current_block_diff;
    
    // 簡化的運動檢測
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            pixel_x <= 0;
            pixel_y <= 0;
        end else if (pixel_valid) begin
            // 位置計數
            if (line_start) begin
                pixel_x <= 0;
                if (frame_start) pixel_y <= 0;
                else pixel_y <= pixel_y + 1;
            end else begin
                pixel_x <= pixel_x + 1;
            end
            
            // 區塊級運動檢測
            if ((pixel_x[4:0] == 0) && (pixel_y[4:0] == 0)) begin
                // 每 32×32 計算一次
                current_block_diff <= calculate_block_difference();
            end
        end
    end
    
    // 輕量級目標追蹤
    target_tracker #(
        .MAX_TARGETS(MAX_TARGETS)
    ) u_tracker (
        .clk(clk),
        .rst_n(rst_n),
        .motion_map(motion_map),
        .targets_out(target_positions),
        .confidence_out(target_confidence),
        .valid_out(target_valid)
    );

endmodule
