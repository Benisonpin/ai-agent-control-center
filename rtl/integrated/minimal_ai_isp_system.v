// Minimal AI ISP System for Testing
module minimal_ai_isp_system (
    input wire clk,
    input wire rst_n,
    
    // Sensor input
    input wire [11:0] sensor_data,
    input wire sensor_valid,
    input wire sensor_hsync,
    input wire sensor_vsync,
    
    // Output
    output reg [23:0] rgb_out,
    output reg rgb_valid,
    
    // AI output
    output wire [31:0] detected_scene
);

    // Internal signals
    wire [31:0] brightness, contrast;
    wire stats_valid;
    
    // Statistics collector
    statistics_collector #(
        .PIXEL_WIDTH(12)
    ) u_stats (
        .clk(clk),
        .rst_n(rst_n),
        .pixel_data(sensor_data),
        .pixel_valid(sensor_valid),
        .frame_start(sensor_vsync),
        .line_start(sensor_hsync),
        .brightness_out(brightness),
        .contrast_out(contrast),
        .stats_valid(stats_valid)
    );
    
    // AI agent
    ai_agent_core #(
        .STATS_BITS(32)
    ) u_ai (
        .clk(clk),
        .rst_n(rst_n),
        .enable(1'b1),
        .brightness_stats(brightness),
        .contrast_stats(contrast),
        .stats_valid(stats_valid),
        .scene_type(detected_scene),
        .quality_score(),
        .ready()
    );
    
    // Simple RGB output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rgb_out <= 0;
            rgb_valid <= 0;
        end else begin
            rgb_out <= {sensor_data[11:4], sensor_data[11:4], sensor_data[11:4]};
            rgb_valid <= sensor_valid;
        end
    end

endmodule
