// 輕量級 HDR 處理器
module hdr_processor_lite #(
    parameter PIXEL_BITS = 10
)(
    input logic clk,
    input logic rst_n,
    
    // 多重曝光輸入
    input logic [PIXEL_BITS-1:0] pixel_short,
    input logic [PIXEL_BITS-1:0] pixel_medium,
    input logic [PIXEL_BITS-1:0] pixel_long,
    input logic pixels_valid,
    
    // HDR 輸出
    output logic [PIXEL_BITS-1:0] hdr_pixel,
    output logic hdr_valid,
    
    // 場景資訊 for AI
    output logic [2:0] scene_type,  // 0:正常 1:高對比 2:低光 3:運動模糊
    output logic scene_valid
);

    // 簡化的 HDR 融合
    logic [PIXEL_BITS+1:0] weighted_sum;
    logic [2:0] weight_short, weight_medium, weight_long;
    
    // 動態權重計算
    always_comb begin
        // 基於像素值的簡單權重
        if (pixel_medium > 900) begin
            // 過曝區域用短曝光
            weight_short = 4;
            weight_medium = 2;
            weight_long = 0;
            scene_type = 3'd1; // 高對比
        end else if (pixel_medium < 100) begin
            // 欠曝區域用長曝光
            weight_short = 0;
            weight_medium = 2;
            weight_long = 4;
            scene_type = 3'd2; // 低光
        end else begin
            // 正常區域平衡
            weight_short = 1;
            weight_medium = 4;
            weight_long = 1;
            scene_type = 3'd0; // 正常
        end
        
        weighted_sum = (pixel_short * weight_short + 
                       pixel_medium * weight_medium + 
                       pixel_long * weight_long) >> 3;
    end
    
    // 輸出註冊
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            hdr_pixel <= 0;
            hdr_valid <= 0;
            scene_valid <= 0;
        end else if (pixels_valid) begin
            hdr_pixel <= weighted_sum[PIXEL_BITS-1:0];
            hdr_valid <= 1;
            scene_valid <= 1;
        end else begin
            hdr_valid <= 0;
            scene_valid <= 0;
        end
    end

endmodule
