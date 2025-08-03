// DCG (Dual Conversion Gain) Processor Module
// Implements the DCG mixing algorithm for HDR

module dcg_processor #(
    parameter PIXEL_WIDTH = 12,
    parameter INTERNAL_WIDTH = 16,
    parameter FRAC_BITS = 8
)(
    input  wire                         clk,
    input  wire                         rst_n,
    
    // Configuration
    input  wire [15:0]                  threshold1,     // DCG threshold
    input  wire [15:0]                  delta1,         // DCG delta
    
    // Input pixel streams
    input  wire [PIXEL_WIDTH-1:0]       hcg_data,       // High conversion gain
    input  wire [PIXEL_WIDTH-1:0]       lcg_data,       // Low conversion gain
    input  wire                         data_valid,
    input  wire                         data_last,
    input  wire                         data_user,
    
    // Output
    output reg  [PIXEL_WIDTH-1:0]       dcg_output,
    output reg                          output_valid,
    output reg                          output_last,
    output reg                          output_user
);

// Constants in fixed-point
localparam [INTERNAL_WIDTH-1:0] ONE_FIXED = (1 << FRAC_BITS);      // 1.0
localparam [INTERNAL_WIDTH-1:0] THREE_FIXED = (3 << FRAC_BITS);    // 3.0

// Pipeline registers - Stage 1: Input capture
reg [INTERNAL_WIDTH-1:0] hcg_pixel_s1, lcg_pixel_s1;
reg [15:0] threshold1_s1, delta1_s1;
reg valid_s1, last_s1, user_s1;

// Pipeline registers - Stage 2: Edge calculation
reg [INTERNAL_WIDTH-1:0] hcg_pixel_s2, lcg_pixel_s2;
reg [INTERNAL_WIDTH-1:0] edge0_dcg_s2, edge1_dcg_s2;
reg [INTERNAL_WIDTH-1:0] diff_edges_dcg_s2;
reg [INTERNAL_WIDTH-1:0] diff_val_s2;
reg valid_s2, last_s2, user_s2;

// Pipeline registers - Stage 3: Normalization
reg [INTERNAL_WIDTH-1:0] hcg_pixel_s3, lcg_pixel_s3;
reg [INTERNAL_WIDTH-1:0] x_norm_s3;
reg valid_s3, last_s3, user_s3;

// Pipeline registers - Stage 4: Smooth function
reg [INTERNAL_WIDTH-1:0] hcg_pixel_s4, lcg_pixel_s4;
reg [INTERNAL_WIDTH-1:0] smooth_result_s4;
reg valid_s4, last_s4, user_s4;

// Pipeline registers - Stage 5: Final mixing
reg [INTERNAL_WIDTH-1:0] mixed_result_s5;
reg valid_s5, last_s5, user_s5;

// Stage 1: Input capture and parameter extraction
always @(posedge clk) begin
    if (!rst_n) begin
        hcg_pixel_s1 <= 0;
        lcg_pixel_s1 <= 0;
        threshold1_s1 <= 0;
        delta1_s1 <= 0;
        valid_s1 <= 1'b0;
        last_s1 <= 1'b0;
        user_s1 <= 1'b0;
    end else begin
        if (data_valid) begin
            // Convert to internal fixed-point representation
            hcg_pixel_s1 <= hcg_data << (FRAC_BITS - (PIXEL_WIDTH - 10));
            lcg_pixel_s1 <= lcg_data << (FRAC_BITS - (PIXEL_WIDTH - 10));
            threshold1_s1 <= threshold1;
            delta1_s1 <= delta1;
        end
        valid_s1 <= data_valid;
        last_s1 <= data_last;
        user_s1 <= data_user;
    end
end

// Stage 2: Edge calculation and difference computation
wire [INTERNAL_WIDTH-1:0] edge0_calc = threshold1_s1 - delta1_s1;
wire [INTERNAL_WIDTH-1:0] edge1_calc = threshold1_s1 + delta1_s1;
wire [INTERNAL_WIDTH-1:0] diff_edges_calc = edge1_calc - edge0_calc;
wire [INTERNAL_WIDTH-1:0] diff_val_calc = (hcg_pixel_s1 > edge0_calc) ? 
                                           (hcg_pixel_s1 - edge0_calc) : 0;

always @(posedge clk) begin
    if (!rst_n) begin
        hcg_pixel_s2 <= 0;
        lcg_pixel_s2 <= 0;
        edge0_dcg_s2 <= 0;
        edge1_dcg_s2 <= 0;
        diff_edges_dcg_s2 <= 0;
        diff_val_s2 <= 0;
        valid_s2 <= 1'b0;
        last_s2 <= 1'b0;
        user_s2 <= 1'b0;
    end else if (valid_s1) begin
        hcg_pixel_s2 <= hcg_pixel_s1;
        lcg_pixel_s2 <= lcg_pixel_s1;
        edge0_dcg_s2 <= edge0_calc;
        edge1_dcg_s2 <= edge1_calc;
        
        // Protect against division by zero
        diff_edges_dcg_s2 <= (diff_edges_calc == 0) ? ONE_FIXED : diff_edges_calc;
        diff_val_s2 <= diff_val_calc;
        
        valid_s2 <= valid_s1;
        last_s2 <= last_s1;
        user_s2 <= user_s1;
    end else begin
        valid_s2 <= 1'b0;
    end
end

// Stage 3: Normalization (division)
// Using a simplified divider - for full precision, use IP divider
wire [INTERNAL_WIDTH*2-1:0] ratio_calc = (diff_val_s2 << FRAC_BITS) / diff_edges_dcg_s2;
wire [INTERNAL_WIDTH-1:0] x_norm_calc = (ratio_calc > ONE_FIXED) ? ONE_FIXED : 
                                        (ratio_calc[INTERNAL_WIDTH-1:0]);

always @(posedge clk) begin
    if (!rst_n) begin
        hcg_pixel_s3 <= 0;
        lcg_pixel_s3 <= 0;
        x_norm_s3 <= 0;
        valid_s3 <= 1'b0;
        last_s3 <= 1'b0;
        user_s3 <= 1'b0;
    end else if (valid_s2) begin
        hcg_pixel_s3 <= hcg_pixel_s2;
        lcg_pixel_s3 <= lcg_pixel_s2;
        
        // Clamp x_norm to [0, 1]
        if (hcg_pixel_s2 <= edge0_dcg_s2) begin
            x_norm_s3 <= 0;
        end else if (hcg_pixel_s2 >= edge1_dcg_s2) begin
            x_norm_s3 <= ONE_FIXED;
        end else begin
            x_norm_s3 <= x_norm_calc;
        end
        
        valid_s3 <= valid_s2;
        last_s3 <= last_s2;
        user_s3 <= user_s2;
    end else begin
        valid_s3 <= 1'b0;
    end
end

// Stage 4: Smooth transition function
// f(t) = t^2 * (3 - 2t)
wire [INTERNAL_WIDTH*2-1:0] t_squared = (x_norm_s3 * x_norm_s3) >> FRAC_BITS;
wire [INTERNAL_WIDTH-1:0] two_t = x_norm_s3 << 1;
wire [INTERNAL_WIDTH-1:0] three_minus_2t = (THREE_FIXED > two_t) ? 
                                           (THREE_FIXED - two_t) : 0;
wire [INTERNAL_WIDTH*2-1:0] smooth_calc = (t_squared[INTERNAL_WIDTH-1:0] * three_minus_2t) >> FRAC_BITS;

always @(posedge clk) begin
    if (!rst_n) begin
        hcg_pixel_s4 <= 0;
        lcg_pixel_s4 <= 0;
        smooth_result_s4 <= 0;
        valid_s4 <= 1'b0;
        last_s4 <= 1'b0;
        user_s4 <= 1'b0;
    end else if (valid_s3) begin
        hcg_pixel_s4 <= hcg_pixel_s3;
        lcg_pixel_s4 <= lcg_pixel_s3;
        smooth_result_s4 <= smooth_calc[INTERNAL_WIDTH-1:0];
        
        valid_s4 <= valid_s3;
        last_s4 <= last_s3;
        user_s4 <= user_s3;
    end else begin
        valid_s4 <= 1'b0;
    end
end

// Stage 5: Final mixing
// dcg_output = weight * hcg + (1 - weight) * lcg
// where weight = 1 - smooth_result
wire [INTERNAL_WIDTH-1:0] weight_hcg = ONE_FIXED - smooth_result_s4;
wire [INTERNAL_WIDTH-1:0] weight_lcg = smooth_result_s4;

wire [INTERNAL_WIDTH*2-1:0] hcg_weighted = (hcg_pixel_s4 * weight_hcg) >> FRAC_BITS;
wire [INTERNAL_WIDTH*2-1:0] lcg_weighted = (lcg_pixel_s4 * weight_lcg) >> FRAC_BITS;
wire [INTERNAL_WIDTH-1:0] mixed_calc = hcg_weighted[INTERNAL_WIDTH-1:0] + 
                                       lcg_weighted[INTERNAL_WIDTH-1:0];

always @(posedge clk) begin
    if (!rst_n) begin
        mixed_result_s5 <= 0;
        valid_s5 <= 1'b0;
        last_s5 <= 1'b0;
        user_s5 <= 1'b0;
    end else if (valid_s4) begin
        mixed_result_s5 <= mixed_calc;
        valid_s5 <= valid_s4;
        last_s5 <= last_s4;
        user_s5 <= user_s4;
    end else begin
        valid_s5 <= 1'b0;
    end
end

// Output stage: Convert back to pixel width
always @(posedge clk) begin
    if (!rst_n) begin
        dcg_output <= 0;
        output_valid <= 1'b0;
        output_last <= 1'b0;
        output_user <= 1'b0;
    end else if (valid_s5) begin
        // Convert from fixed-point back to pixel width
        // Saturate if necessary
        if (mixed_result_s5 >= (ONE_FIXED << (PIXEL_WIDTH - 10))) begin
            dcg_output <= {PIXEL_WIDTH{1'b1}}; // Saturate to max
        end else begin
            dcg_output <= mixed_result_s5 >> (FRAC_BITS - (PIXEL_WIDTH - 10));
        end
        
        output_valid <= valid_s5;
        output_last <= last_s5;
        output_user <= user_s5;
    end else begin
        output_valid <= 1'b0;
    end
end

endmodule