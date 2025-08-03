// Statistics Collector for AI Analysis
module statistics_collector #(
    parameter PIXEL_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,
    
    input wire [PIXEL_WIDTH-1:0] r_in,
    input wire [PIXEL_WIDTH-1:0] g_in,
    input wire [PIXEL_WIDTH-1:0] b_in,
    input wire valid_in,
    input wire frame_start,
    input wire frame_end,
    
    output reg [31:0] histogram[256],
    output reg [31:0] awb_stats,
    output reg [31:0] ae_stats,
    output reg stats_ready
);

    reg [31:0] r_sum, g_sum, b_sum;
    reg [31:0] pixel_count;
    wire [7:0] luma;
    
    // Calculate luminance
    assign luma = (r_in[11:4] * 77 + g_in[11:4] * 150 + b_in[11:4] * 29) >> 8;
    
    always @(posedge clk) begin
        if (!rst_n || frame_start) begin
            for (int i = 0; i < 256; i++)
                histogram[i] <= 0;
            r_sum <= 0;
            g_sum <= 0;
            b_sum <= 0;
            pixel_count <= 0;
            stats_ready <= 0;
        end else if (valid_in) begin
            histogram[luma] <= histogram[luma] + 1;
            r_sum <= r_sum + r_in;
            g_sum <= g_sum + g_in;
            b_sum <= b_sum + b_in;
            pixel_count <= pixel_count + 1;
        end else if (frame_end && pixel_count > 0) begin
            awb_stats <= {r_sum[31:16] / pixel_count[15:0], b_sum[31:16] / pixel_count[15:0]};
            ae_stats <= (r_sum + g_sum + b_sum) / (pixel_count * 3);
            stats_ready <= 1;
        end
    end

endmodule
