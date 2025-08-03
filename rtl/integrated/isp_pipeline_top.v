// Simplified ISP Pipeline Top for testing
module isp_pipeline_top #(
    parameter PIXEL_WIDTH = 12,
    parameter IMAGE_WIDTH = 4096,
    parameter IMAGE_HEIGHT = 3072,
    parameter PIPELINE_STAGES = 16,
    parameter BURST_LENGTH = 16
)(
    input wire clk,
    input wire rst_n,
    
    // Sensor Interface
    input wire [PIXEL_WIDTH-1:0] sensor_data,
    input wire sensor_hsync,
    input wire sensor_vsync,
    input wire sensor_pclk,
    
    // Output Interface
    output reg [23:0] rgb_out,
    output reg data_valid_out,
    output reg frame_start_out,
    output reg frame_end_out
);

    // Simple pass-through for testing
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rgb_out <= 24'h0;
            data_valid_out <= 1'b0;
            frame_start_out <= 1'b0;
            frame_end_out <= 1'b0;
        end else begin
            // Simple RGB conversion
            rgb_out <= {sensor_data[11:4], sensor_data[11:4], sensor_data[11:4]};
            data_valid_out <= sensor_pclk;
            frame_start_out <= sensor_vsync;
            frame_end_out <= sensor_hsync;
        end
    end

endmodule
