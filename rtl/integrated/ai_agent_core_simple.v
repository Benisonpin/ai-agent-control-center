// Simplified AI Agent Core without array ports
module ai_agent_core #(
    parameter STATS_BITS = 32
)(
    input wire clk,
    input wire rst_n,
    input wire enable,
    
    // Statistics inputs (simplified)
    input wire [31:0] brightness_stats,
    input wire [31:0] contrast_stats,
    input wire stats_valid,
    
    // AI outputs
    output reg [31:0] scene_type,
    output reg [31:0] quality_score,
    output reg ready
);

    // Simple scene detection
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scene_type <= 0;
            quality_score <= 0;
            ready <= 0;
        end else if (enable && stats_valid) begin
            // Simple scene classification based on brightness
            if (brightness_stats < 32'd64) begin
                scene_type <= 32'd1; // Night
            end else if (brightness_stats > 32'd192) begin
                scene_type <= 32'd0; // Daylight
            end else begin
                scene_type <= 32'd3; // Normal
            end
            
            quality_score <= 32'd80;
            ready <= 1;
        end else begin
            ready <= 0;
        end
    end

endmodule
