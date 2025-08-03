// Statistics Collector Module for AI ISP
module statistics_collector #(
    parameter PIXEL_WIDTH = 12,
    parameter STATS_BITS = 32
)(
    input wire clk,
    input wire rst_n,
    
    // Pixel input
    input wire [PIXEL_WIDTH-1:0] pixel_data,
    input wire pixel_valid,
    input wire frame_start,
    input wire line_start,
    
    // Statistics output - 使用參數化輸出
    output reg [31:0] brightness_out,
    output reg [31:0] contrast_out,
    output reg stats_valid
);

    // Internal registers
    reg [31:0] pixel_count;
    reg [31:0] pixel_sum;
    reg [31:0] pixel_sum_sq;
    reg frame_active;
    
    // Histogram memory - 內部使用
    reg [STATS_BITS-1:0] histogram [0:255];
    
    // 宣告迴圈變數
    integer i;
    
    // Initialize and process
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 重置所有暫存器
            pixel_count <= 0;
            pixel_sum <= 0;
            pixel_sum_sq <= 0;
            brightness_out <= 0;
            contrast_out <= 0;
            stats_valid <= 0;
            frame_active <= 0;
            
            // 初始化直方圖
            for (i = 0; i < 256; i = i + 1) begin
                histogram[i] <= 0;
            end
        end else begin
            // Frame control
            if (frame_start) begin
                frame_active <= 1;
                pixel_count <= 0;
                pixel_sum <= 0;
                pixel_sum_sq <= 0;
                // 清除直方圖
                for (i = 0; i < 256; i = i + 1) begin
                    histogram[i] <= 0;
                end
            end
            
            // Collect statistics
            if (frame_active && pixel_valid) begin
                // Update histogram (simplified - assumes 8-bit)
                if (PIXEL_WIDTH >= 8) begin
                    histogram[pixel_data[PIXEL_WIDTH-1:PIXEL_WIDTH-8]] <= 
                        histogram[pixel_data[PIXEL_WIDTH-1:PIXEL_WIDTH-8]] + 1;
                end else begin
                    histogram[pixel_data] <= histogram[pixel_data] + 1;
                end
                
                // Update sums
                pixel_count <= pixel_count + 1;
                pixel_sum <= pixel_sum + pixel_data;
                pixel_sum_sq <= pixel_sum_sq + (pixel_data * pixel_data);
            end
            
            // Output statistics at end of frame
            if (frame_active && !pixel_valid && pixel_count > 0) begin
                brightness_out <= pixel_sum / pixel_count;
                contrast_out <= pixel_sum_sq / pixel_count;
                stats_valid <= 1;
                frame_active <= 0;
            end else begin
                stats_valid <= 0;
            end
        end
    end

endmodule
