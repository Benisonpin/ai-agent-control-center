// Very Short exposure Mixer Module
module vs_mixer #(
    parameter DATA_WIDTH = 12,
    parameter WEIGHT_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    
    // Input pixels
    input wire [DATA_WIDTH-1:0] pixel_hcg,
    input wire [DATA_WIDTH-1:0] pixel_lcg,
    input wire [DATA_WIDTH-1:0] pixel_vs,
    input wire pixel_valid,
    
    // Mixing weights
    input wire [WEIGHT_WIDTH-1:0] weight_vs,
    input wire [WEIGHT_WIDTH-1:0] weight_normal,
    
    // Output
    output reg [DATA_WIDTH-1:0] mixed_pixel,
    output reg mixed_valid
);

    wire [DATA_WIDTH+WEIGHT_WIDTH:0] weighted_vs;
    wire [DATA_WIDTH+WEIGHT_WIDTH:0] weighted_normal;
    wire [DATA_WIDTH+WEIGHT_WIDTH:0] sum;
    
    // Weight calculations
    assign weighted_vs = pixel_vs * weight_vs;
    assign weighted_normal = pixel_hcg * weight_normal;
    assign sum = weighted_vs + weighted_normal;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mixed_pixel <= 0;
            mixed_valid <= 0;
        end else if (pixel_valid) begin
            // Normalize by total weight (assume weights sum to 256)
            mixed_pixel <= sum[DATA_WIDTH+WEIGHT_WIDTH:WEIGHT_WIDTH];
            mixed_valid <= 1;
        end else begin
            mixed_valid <= 0;
        end
    end

endmodule
