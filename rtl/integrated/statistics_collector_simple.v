// Simplified Statistics Collector
module statistics_collector #(
    parameter PIXEL_WIDTH = 12,
    parameter STATS_BITS = 32
)(
    input wire clk,
    input wire rst_n,
    
    input wire [PIXEL_WIDTH-1:0] pixel_data,
    input wire pixel_valid,
    input wire frame_start,
    input wire line_start,
    
    output reg [31:0] brightness_out,
    output reg [31:0] contrast_out,
    output reg stats_valid
);

    reg [31:0] pixel_sum;
    reg [31:0] pixel_count;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_sum <= 0;
            pixel_count <= 0;
            brightness_out <= 0;
            contrast_out <= 0;
            stats_valid <= 0;
        end else begin
            if (frame_start) begin
                pixel_sum <= 0;
                pixel_count <= 0;
                stats_valid <= 0;
            end else if (pixel_valid) begin
                pixel_sum <= pixel_sum + pixel_data;
                pixel_count <= pixel_count + 1;
            end else if (pixel_count > 0 && !pixel_valid) begin
                brightness_out <= pixel_sum / pixel_count;
                contrast_out <= 32'd50; // Dummy value
                stats_valid <= 1;
            end else begin
                stats_valid <= 0;
            end
        end
    end

endmodule
