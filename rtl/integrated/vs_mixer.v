// Very Short exposure Mixer Module - Complete version
module vs_mixer #(
    parameter PIXEL_WIDTH = 12,
    parameter INTERNAL_WIDTH = 16,
    parameter DATA_WIDTH = 12,
    parameter FRAC_BITS = 8
)(
    input wire clk,
    input wire rst_n,
    
    // Input pixels
    input wire [DATA_WIDTH-1:0] pixel_hcg,
    input wire [DATA_WIDTH-1:0] pixel_lcg,
    input wire [DATA_WIDTH-1:0] pixel_vs,
    input wire pixel_valid,
    
    // Configuration
    input wire [15:0] vs_ratio,
    input wire [15:0] threshold,
    
    // Output
    output reg [DATA_WIDTH-1:0] mixed_pixel,
    output reg mixed_valid
);

    reg [INTERNAL_WIDTH-1:0] weighted_sum;
    reg [7:0] weight_vs, weight_normal;
    
    // Weight calculation based on brightness
    always @(*) begin
        if (pixel_vs < threshold) begin
            weight_vs = 255;
            weight_normal = 0;
        end else begin
            weight_vs = 128;
            weight_normal = 128;
        end
    end
    
    // Mixing
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mixed_pixel <= 0;
            mixed_valid <= 0;
        end else if (pixel_valid) begin
            weighted_sum <= (pixel_vs * weight_vs + pixel_hcg * weight_normal) >> 8;
            mixed_pixel <= weighted_sum[DATA_WIDTH-1:0];
            mixed_valid <= 1;
        end else begin
            mixed_valid <= 0;
        end
    end

endmodule
