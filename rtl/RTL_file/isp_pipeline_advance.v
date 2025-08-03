// ISP Advanced Processing Modules
// Additional sophisticated image processing algorithms

// Auto Exposure (AE) Module
module auto_exposure #(
    parameter PIXEL_WIDTH = 12,
    parameter HIST_BINS = 256,
    parameter IMAGE_WIDTH = 1920,
    parameter IMAGE_HEIGHT = 1080
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] y_in,
    input wire valid_in,
    input wire frame_start,
    input wire frame_end,
    input wire ae_enable,
    input wire [7:0] target_brightness,
    output reg [31:0] exposure_time,
    output reg [31:0] analog_gain,
    output reg [31:0] digital_gain,
    output reg ae_converged
);

    // Histogram memory
    reg [31:0] histogram[0:HIST_BINS-1];
    reg [31:0] pixel_count;
    reg [39:0] brightness_sum;
    
    // AE algorithm parameters
    reg [31:0] current_brightness;
    reg [31:0] exposure_step;
    reg [31:0] gain_step;
    reg [3:0] convergence_count;
    
    // State machine
    typedef enum logic [2:0] {
        IDLE,
        COLLECT_STATS,
        CALCULATE,
        UPDATE_EXPOSURE,
        WAIT_FRAME
    } ae_state_t;
    
    ae_state_t state;
    
    // Histogram collection
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < HIST_BINS; i++)
                histogram[i] <= 32'd0;
            pixel_count <= 32'd0;
            brightness_sum <= 40'd0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (frame_start && ae_enable) begin
                        // Clear histogram
                        for (int i = 0; i < HIST_BINS; i++)
                            histogram[i] <= 32'd0;
                        pixel_count <= 32'd0;
                        brightness_sum <= 40'd0;
                        state <= COLLECT_STATS;
                    end
                end
                
                COLLECT_STATS: begin
                    if (valid_in) begin
                        // Update histogram
                        histogram[y_in[PIXEL_WIDTH-1:PIXEL_WIDTH-8]] <= 
                            histogram[y_in[PIXEL_WIDTH-1:PIXEL_WIDTH-8]] + 1'b1;
                        brightness_sum <= brightness_sum + y_in;
                        pixel_count <= pixel_count + 1'b1;
                    end
                    
                    if (frame_end) begin
                        state <= CALCULATE;
                    end
                end
                
                CALCULATE: begin
                    // Calculate average brightness
                    current_brightness <= brightness_sum / pixel_count;
                    state <= UPDATE_EXPOSURE;
                end
                
                UPDATE_EXPOSURE: begin
                    // Simple proportional control
                    if (current_brightness < target_brightness - 5) begin
                        // Too dark - increase exposure
                        if (exposure_time < 32'd33333) // Max 33ms
                            exposure_time <= exposure_time + exposure_step;
                        else if (analog_gain < 32'd16) // Max 16x
                            analog_gain <= analog_gain + gain_step;
                        else if (digital_gain < 32'd4) // Max 4x
                            digital_gain <= digital_gain + gain_step;
                        convergence_count <= 4'd0;
                    end else if (current_brightness > target_brightness + 5) begin
                        // Too bright - decrease exposure
                        if (digital_gain > 32'd1)
                            digital_gain <= digital_gain - gain_step;
                        else if (analog_gain > 32'd1)
                            analog_gain <= analog_gain - gain_step;
                        else if (exposure_time > 32'd100) // Min 100us
                            exposure_time <= exposure_time - exposure_step;
                        convergence_count <= 4'd0;
                    end else begin
                        // Within target range
                        if (convergence_count < 4'd10)
                            convergence_count <= convergence_count + 1'b1;
                    end
                    
                    ae_converged <= (convergence_count >= 4'd10);
                    state <= WAIT_FRAME;
                end
                
                WAIT_FRAME: begin
                    if (frame_start)
                        state <= IDLE;
                end
            endcase
        end
    end
    
    // Initialize parameters
    initial begin
        exposure_time = 32'd16666; // 16.66ms (60fps)
        analog_gain = 32'd1;
        digital_gain = 32'd1;
        exposure_step = 32'd1000;
        gain_step = 32'd1;
        ae_converged = 1'b0;
    end

endmodule

// Auto Focus (AF) Module using Contrast Detection
module auto_focus #(
    parameter PIXEL_WIDTH = 12,
    parameter ROI_WIDTH = 256,
    parameter ROI_HEIGHT = 256
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] y_in,
    input wire valid_in,
    input wire [13:0] pixel_x,
    input wire [13:0] pixel_y,
    input wire frame_start,
    input wire frame_end,
    input wire af_enable,
    input wire [13:0] roi_x,
    input wire [13:0] roi_y,
    output reg [31:0] focus_score,
    output reg [31:0] lens_position,
    output reg af_converged,
    output reg af_searching
);

    // Sobel edge detection for contrast measurement
    reg [PIXEL_WIDTH-1:0] line_buffer[0:2][0:ROI_WIDTH-1];
    reg [9:0] buffer_x;
    reg in_roi;
    
    // Focus statistics
    reg [39:0] contrast_sum;
    reg [31:0] edge_count;
    reg [31:0] prev_focus_score;
    reg [31:0] best_focus_score;
    reg [31:0] best_position;
    
    // AF state machine
    typedef enum logic [2:0] {
        AF_IDLE,
        AF_COARSE_SEARCH,
        AF_FINE_SEARCH,
        AF_CONVERGED,
        AF_TRACKING
    } af_state_t;
    
    af_state_t af_state;
    reg [31:0] search_direction;
    reg [31:0] search_step;
    
    // Check if pixel is in ROI
    always @(*) begin
        in_roi = (pixel_x >= roi_x) && (pixel_x < roi_x + ROI_WIDTH) &&
                 (pixel_y >= roi_y) && (pixel_y < roi_y + ROI_HEIGHT);
    end
    
    // Line buffer management
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            buffer_x <= 10'd0;
        end else if (valid_in && in_roi) begin
            // Shift line buffer
            line_buffer[0][buffer_x] <= line_buffer[1][buffer_x];
            line_buffer[1][buffer_x] <= line_buffer[2][buffer_x];
            line_buffer[2][buffer_x] <= y_in;
            
            buffer_x <= (buffer_x == ROI_WIDTH-1) ? 10'd0 : buffer_x + 1'b1;
        end
    end
    
    // Sobel edge detection
    wire signed [PIXEL_WIDTH+2:0] sobel_x, sobel_y;
    wire [PIXEL_WIDTH+3:0] edge_strength;
    
    assign sobel_x = $signed({1'b0, line_buffer[0][2]}) - $signed({1'b0, line_buffer[0][0]}) +
                     ($signed({1'b0, line_buffer[1][2]}) - $signed({1'b0, line_buffer[1][0]})) * 2 +
                     $signed({1'b0, line_buffer[2][2]}) - $signed({1'b0, line_buffer[2][0]});
    
    assign sobel_y = $signed({1'b0, line_buffer[2][0]}) - $signed({1'b0, line_buffer[0][0]}) +
                     ($signed({1'b0, line_buffer[2][1]}) - $signed({1'b0, line_buffer[0][1]})) * 2 +
                     $signed({1'b0, line_buffer[2][2]}) - $signed({1'b0, line_buffer[0][2]});
    
    assign edge_strength = (sobel_x[PIXEL_WIDTH+2] ? -sobel_x : sobel_x) + 
                          (sobel_y[PIXEL_WIDTH+2] ? -sobel_y : sobel_y);
    
    // Accumulate contrast
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            contrast_sum <= 40'd0;
            edge_count <= 32'd0;
        end else if (frame_start) begin
            contrast_sum <= 40'd0;
            edge_count <= 32'd0;
        end else if (valid_in && in_roi && buffer_x >= 2) begin
            if (edge_strength > 16'd100) begin // Threshold
                contrast_sum <= contrast_sum + edge_strength;
                edge_count <= edge_count + 1'b1;
            end
        end
    end
    
    // AF control state machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            af_state <= AF_IDLE;
            lens_position <= 32'd500; // Mid position
            search_direction <= 32'd1;
            search_step <= 32'd50;
            af_converged <= 1'b0;
            af_searching <= 1'b0;
        end else if (frame_end && af_enable) begin
            // Calculate focus score
            focus_score <= edge_count ? (contrast_sum / edge_count) : 32'd0;
            
            case (af_state)
                AF_IDLE: begin
                    if (af_enable) begin
                        af_state <= AF_COARSE_SEARCH;
                        af_searching <= 1'b1;
                        best_focus_score <= 32'd0;
                        best_position <= lens_position;
                    end
                end
                
                AF_COARSE_SEARCH: begin
                    if (focus_score > best_focus_score) begin
                        best_focus_score <= focus_score;
                        best_position <= lens_position;
                    end
                    
                    if (focus_score < prev_focus_score && prev_focus_score == best_focus_score) begin
                        // Passed peak, reverse and fine search
                        lens_position <= best_position;
                        search_step <= 32'd10;
                        af_state <= AF_FINE_SEARCH;
                    end else if (lens_position >= 32'd900 || lens_position <= 32'd100) begin
                        // Hit limit, go to best position
                        lens_position <= best_position;
                        af_state <= AF_CONVERGED;
                    end else begin
                        // Continue searching
                        lens_position <= lens_position + (search_direction * search_step);
                    end
                    
                    prev_focus_score <= focus_score;
                end
                
                AF_FINE_SEARCH: begin
                    if (focus_score >= best_focus_score - (best_focus_score >> 4)) begin
                        // Within 6.25% of best, converged
                        af_state <= AF_CONVERGED;
                        af_converged <= 1'b1;
                        af_searching <= 1'b0;
                    end else begin
                        // Fine adjust
                        if (focus_score > prev_focus_score) begin
                            lens_position <= lens_position + search_step;
                        end else begin
                            lens_position <= lens_position - search_step;
                        end
                    end
                    
                    prev_focus_score <= focus_score;
                end
                
                AF_CONVERGED: begin
                    // Monitor for scene change
                    if (focus_score < (best_focus_score >> 1)) begin
                        // Significant drop, re-search
                        af_state <= AF_IDLE;
                        af_converged <= 1'b0;
                    end
                end
            endcase
        end
    end

endmodule

// HDR (High Dynamic Range) Tone Mapping Module
module hdr_tone_mapping #(
    parameter PIXEL_WIDTH = 12,
    parameter LUT_DEPTH = 1024
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] r_in,
    input wire [PIXEL_WIDTH-1:0] g_in,
    input wire [PIXEL_WIDTH-1:0] b_in,
    input wire valid_in,
    input wire [31:0] exposure_ev,
    input wire hdr_enable,
    output reg [PIXEL_WIDTH-1:0] r_out,
    output reg [PIXEL_WIDTH-1:0] g_out,
    output reg [PIXEL_WIDTH-1:0] b_out,
    output reg valid_out
);

    // Reinhard tone mapping operator
    // L_out = L_in / (1 + L_in)
    
    // Convert to luminance
    reg [PIXEL_WIDTH+7:0] luminance;
    reg [PIXEL_WIDTH+15:0] l_scaled;
    reg [PIXEL_WIDTH-1:0] l_mapped;
    
    // Tone mapping LUT
    reg [PIXEL_WIDTH-1:0] tone_lut[0:LUT_DEPTH-1];
    
    // Initialize LUT with Reinhard curve
    initial begin
        for (int i = 0; i < LUT_DEPTH; i++) begin
            real x = i / 1023.0;
            real y = x / (1.0 + x);
            tone_lut[i] = y * 4095;
        end
    end
    
    // Pipeline stage 1: Calculate luminance
    always @(posedge clk) begin
        if (valid_in) begin
            // Y = 0.2126*R + 0.7152*G + 0.0722*B
            luminance <= (54 * r_in) + (183 * g_in) + (18 * b_in);
        end
    end
    
    // Pipeline stage 2: Apply exposure compensation
    always @(posedge clk) begin
        // exposure_ev is in fixed point format (16.16)
        l_scaled <= (luminance * exposure_ev) >> 16;
    end
    
    // Pipeline stage 3: Tone mapping
    always @(posedge clk) begin
        if (hdr_enable && l_scaled[PIXEL_WIDTH+15:PIXEL_WIDTH+6] < LUT_DEPTH) begin
            l_mapped <= tone_lut[l_scaled[PIXEL_WIDTH+15:PIXEL_WIDTH+6]];
        end else begin
            l_mapped <= l_scaled[PIXEL_WIDTH+5:6];
        end
    end
    
    // Pipeline stage 4: Apply mapping to RGB
    reg [PIXEL_WIDTH+15:0] r_hdr, g_hdr, b_hdr;
    reg [PIXEL_WIDTH+7:0] lum_ratio;
    
    always @(posedge clk) begin
        if (luminance > 0) begin
            lum_ratio <= (l_mapped << 8) / luminance[PIXEL_WIDTH+7:8];
        end else begin
            lum_ratio <= 8'd255;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_out <= {PIXEL_WIDTH{1'b0}};
            g_out <= {PIXEL_WIDTH{1'b0}};
            b_out <= {PIXEL_WIDTH{1'b0}};
            valid_out <= 1'b0;
        end else begin
            if (hdr_enable) begin
                r_hdr = (r_in * lum_ratio);
                g_hdr = (g_in * lum_ratio);
                b_hdr = (b_in * lum_ratio);
                
                // Clamp
                r_out <= (r_hdr[PIXEL_WIDTH+15:PIXEL_WIDTH+8]) ? {PIXEL_WIDTH{1'b1}} : r_hdr[PIXEL_WIDTH+7:8];
                g_out <= (g_hdr[PIXEL_WIDTH+15:PIXEL_WIDTH+8]) ? {PIXEL_WIDTH{1'b1}} : g_hdr[PIXEL_WIDTH+7:8];
                b_out <= (b_hdr[PIXEL_WIDTH+15:PIXEL_WIDTH+8]) ? {PIXEL_WIDTH{1'b1}} : b_hdr[PIXEL_WIDTH+7:8];
            end else begin
                r_out <= r_in;
                g_out <= g_in;
                b_out <= b_in;
            end
            
            valid_out <= valid_in;
        end
    end

endmodule

// Local Tone Mapping Module
module local_tone_mapping #(
    parameter PIXEL_WIDTH = 12,
    parameter BLOCK_SIZE = 16
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] y_in,
    input wire [PIXEL_WIDTH-1:0] u_in,
    input wire [PIXEL_WIDTH-1:0] v_in,
    input wire valid_in,
    input wire ltm_enable,
    input wire [3:0] ltm_strength,
    output reg [PIXEL_WIDTH-1:0] y_out,
    output reg [PIXEL_WIDTH-1:0] u_out,
    output reg [PIXEL_WIDTH-1:0] v_out,
    output reg valid_out
);

    // Local statistics calculation
    reg [PIXEL_WIDTH+7:0] block_sum[0:BLOCK_SIZE-1][0:BLOCK_SIZE-1];
    reg [PIXEL_WIDTH-1:0] block_avg[0:BLOCK_SIZE-1][0:BLOCK_SIZE-1];
    reg [9:0] block_x, block_y;
    reg [3:0] pixel_in_block_x, pixel_in_block_y;
    
    // Bilateral grid for edge-aware smoothing
    reg [PIXEL_WIDTH-1:0] bilateral_grid[0:63][0:63];
    
    // Calculate local average
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < BLOCK_SIZE; i++) begin
                for (int j = 0; j < BLOCK_SIZE; j++) begin
                    block_sum[i][j] <= {(PIXEL_WIDTH+8){1'b0}};
                    block_avg[i][j] <= {PIXEL_WIDTH{1'b0}};
                end
            end
        end else if (valid_in) begin
            // Accumulate block statistics
            block_sum[block_y][block_x] <= block_sum[block_y][block_x] + y_in;
            
            // Update position
            pixel_in_block_x <= pixel_in_block_x + 1'b1;
            if (pixel_in_block_x == BLOCK_SIZE-1) begin
                pixel_in_block_x <= 4'd0;
                block_x <= block_x + 1'b1;
                
                if (block_x == BLOCK_SIZE-1) begin
                    pixel_in_block_y <= pixel_in_block_y + 1'b1;
                    if (pixel_in_block_y == BLOCK_SIZE-1) begin
                        block_y <= block_y + 1'b1;
                    end
                end
            end
            
            // Calculate average when block is complete
            if (pixel_in_block_x == BLOCK_SIZE-1 && pixel_in_block_y == BLOCK_SIZE-1) begin
                block_avg[block_y][block_x] <= block_sum[block_y][block_x] >> 8; // /256
            end
        end
    end
    
    // Apply local tone mapping
    reg signed [PIXEL_WIDTH+3:0] detail;
    reg [PIXEL_WIDTH+3:0] enhanced;
    
    always @(posedge clk) begin
        if (ltm_enable) begin
            // Extract local detail
            detail = $signed({1'b0, y_in}) - $signed({1'b0, block_avg[block_y][block_x]});
            
            // Enhance detail based on strength
            enhanced = $signed({1'b0, y_in}) + ((detail * ltm_strength) >>> 2);
            
            // Clamp
            if (enhanced[PIXEL_WIDTH+3])
                y_out <= {PIXEL_WIDTH{1'b0}};
            else if (enhanced[PIXEL_WIDTH+2:PIXEL_WIDTH])
                y_out <= {PIXEL_WIDTH{1'b1}};
            else
                y_out <= enhanced[PIXEL_WIDTH-1:0];
        end else begin
            y_out <= y_in;
        end
        
        u_out <= u_in;
        v_out <= v_in;
        valid_out <= valid_in;
    end

endmodule

// 2D Noise Reduction Module
module spatial_noise_reduction #(
    parameter PIXEL_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] data_in,
    input wire valid_in,
    input wire [3:0] nr_strength,
    input wire [7:0] edge_threshold,
    output reg [PIXEL_WIDTH-1:0] data_out,
    output reg valid_out
);

    // 7x7 line buffer for bilateral filter
    reg [PIXEL_WIDTH-1:0] line_buffer[0:6][0:6];
    reg [6:0] valid_buffer;
    
    // Gaussian weights for spatial filter
    wire [5:0] gauss_weights[0:6][0:6];
    
    // Initialize Gaussian kernel (approximation)
    assign gauss_weights[0][0] = 6'd1;  assign gauss_weights[0][1] = 6'd2;  assign gauss_weights[0][2] = 6'd3;  assign gauss_weights[0][3] = 6'd4;  assign gauss_weights[0][4] = 6'd3;  assign gauss_weights[0][5] = 6'd2;  assign gauss_weights[0][6] = 6'd1;
    assign gauss_weights[1][0] = 6'd2;  assign gauss_weights[1][1] = 6'd4;  assign gauss_weights[1][2] = 6'd6;  assign gauss_weights[1][3] = 6'd8;  assign gauss_weights[1][4] = 6'd6;  assign gauss_weights[1][5] = 6'd4;  assign gauss_weights[1][6] = 6'd2;
    assign gauss_weights[2][0] = 6'd3;  assign gauss_weights[2][1] = 6'd6;  assign gauss_weights[2][2] = 6'd9;  assign gauss_weights[2][3] = 6'd12; assign gauss_weights[2][4] = 6'd9;  assign gauss_weights[2][5] = 6'd6;  assign gauss_weights[2][6] = 6'd3;
    assign gauss_weights[3][0] = 6'd4;  assign gauss_weights[3][1] = 6'd8;  assign gauss_weights[3][2] = 6'd12; assign gauss_weights[3][3] = 6'd16; assign gauss_weights[3][4] = 6'd12; assign gauss_weights[3][5] = 6'd8;  assign gauss_weights[3][6] = 6'd4;
    assign gauss_weights[4][0] = 6'd3;  assign gauss_weights[4][1] = 6'd6;  assign gauss_weights[4][2] = 6'd9;  assign gauss_weights[4][3] = 6'd12; assign gauss_weights[4][4] = 6'd9;  assign gauss_weights[4][5] = 6'd6;  assign gauss_weights[4][6] = 6'd3;
    assign gauss_weights[5][0] = 6'd2;  assign gauss_weights[5][1] = 6'd4;  assign gauss_weights[5][2] = 6'd6;  assign gauss_weights[5][3] = 6'd8;  assign gauss_weights[5][4] = 6'd6;  assign gauss_weights[5][5] = 6'd4;  assign gauss_weights[5][6] = 6'd2;
    assign gauss_weights[6][0] = 6'd1;  assign gauss_weights[6][1] = 6'd2;  assign gauss_weights[6][2] = 6'd3;  assign gauss_weights[6][3] = 6'd4;  assign gauss_weights[6][4] = 6'd3;  assign gauss_weights[6][5] = 6'd2;  assign gauss_weights[6][6] = 6'd1;
    
    wire [PIXEL_WIDTH-1:0] center = line_buffer[3][3];
    
    // Shift register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 7; i++) begin
                for (int j = 0; j < 7; j++) begin
                    line_buffer[i][j] <= {PIXEL_WIDTH{1'b0}};
                end
            end
            valid_buffer <= 7'b0;
        end else if (valid_in) begin
            // Shift buffer
            for (int i = 0; i < 7; i++) begin
                for (int j = 0; j < 6; j++) begin
                    line_buffer[i][j] <= line_buffer[i][j+1];
                end
            end
            for (int i = 0; i < 6; i++) begin
                line_buffer[i][6] <= line_buffer[i+1][6];
            end
            line_buffer[6][6] <= data_in;
            
            valid_buffer <= {valid_buffer[5:0], 1'b1};
        end
    end
    
    // Bilateral filter calculation
    reg [PIXEL_WIDTH+9:0] weighted_sum;
    reg [9:0] weight_sum;
    reg [PIXEL_WIDTH:0] pixel_diff;
    reg [7:0] range_weight;
    reg [13:0] total_weight;
    
    always @(posedge clk) begin
        weighted_sum = 0;
        weight_sum = 0;
        
        for (int i = 0; i < 7; i++) begin
            for (int j = 0; j < 7; j++) begin
                // Calculate range weight based on pixel difference
                pixel_diff = (line_buffer[i][j] > center) ? 
                            (line_buffer[i][j] - center) : 
                            (center - line_buffer[i][j]);
                
                if (pixel_diff < edge_threshold) begin
                    // Similar pixel, include in filter
                    range_weight = 8'd255 - (pixel_diff << 2);
                    total_weight = gauss_weights[i][j] * range_weight;
                    
                    weighted_sum = weighted_sum + line_buffer[i][j] * total_weight;
                    weight_sum = weight_sum + total_weight;
                end
            end
        end
    end
    
    // Output with strength blending
    reg [PIXEL_WIDTH+9:0] filtered;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= {PIXEL_WIDTH{1'b0}};
            valid_out <= 1'b0;
        end else begin
            if (weight_sum > 0) begin
                filtered = weighted_sum / weight_sum;
                // Blend with original based on strength
                data_out <= ((16 - nr_strength) * center + 
                            nr_strength * filtered[PIXEL_WIDTH-1:0]) >> 4;
            end else begin
                data_out <= center;
            end
            
            valid_out <= valid_buffer[6];
        end
    end

endmodule

// Chromatic Aberration Correction Module
module chromatic_aberration_correction #(
    parameter PIXEL_WIDTH = 12,
    parameter IMAGE_WIDTH = 1920,
    parameter IMAGE_HEIGHT = 1080
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] r_in,
    input wire [PIXEL_WIDTH-1:0] g_in,
    input wire [PIXEL_WIDTH-1:0] b_in,
    input wire valid_in,
    input wire [13:0] pixel_x,
    input wire [13:0] pixel_y,
    input wire ca_enable,
    input wire [7:0] ca_strength,
    output reg [PIXEL_WIDTH-1:0] r_out,
    output reg [PIXEL_WIDTH-1:0] g_out,
    output reg [PIXEL_WIDTH-1:0] b_out,
    output reg valid_out
);

    // Calculate radial distance from center
    wire signed [14:0] dx = $signed({1'b0, pixel_x}) - (IMAGE_WIDTH / 2);
    wire signed [14:0] dy = $signed({1'b0, pixel_y}) - (IMAGE_HEIGHT / 2);
    
    reg [29:0] dist_squared;
    reg [14:0] dist;
    
    // Radial shift calculation
    reg signed [7:0] r_shift_x, r_shift_y;
    reg signed [7:0] b_shift_x, b_shift_y;
    
    // Line buffers for shifted pixel access
    reg [PIXEL_WIDTH-1:0] r_buffer[0:4][0:4];
    reg [PIXEL_WIDTH-1:0] b_buffer[0:4][0:4];
    
    // Distance calculation pipeline
    always @(posedge clk) begin
        dist_squared <= dx * dx + dy * dy;
        // Approximate square root
        dist <= dist_squared[29:15];
    end
    
    // Calculate chromatic shift
    always @(posedge clk) begin
        if (ca_enable) begin
            // Red channel shifts outward
            r_shift_x <= (dx * ca_strength * dist) >>> 20;
            r_shift_y <= (dy * ca_strength * dist) >>> 20;
            
            // Blue channel shifts inward
            b_shift_x <= -(dx * ca_strength * dist) >>> 20;
            b_shift_y <= -(dy * ca_strength * dist) >>> 20;
        end else begin
            r_shift_x <= 8'd0;
            r_shift_y <= 8'd0;
            b_shift_x <= 8'd0;
            b_shift_y <= 8'd0;
        end
    end
    
    // Buffer management
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 5; i++) begin
                for (int j = 0; j < 5; j++) begin
                    r_buffer[i][j] <= {PIXEL_WIDTH{1'b0}};
                    b_buffer[i][j] <= {PIXEL_WIDTH{1'b0}};
                end
            end
        end else if (valid_in) begin
            // Shift buffers
            for (int i = 0; i < 5; i++) begin
                for (int j = 0; j < 4; j++) begin
                    r_buffer[i][j] <= r_buffer[i][j+1];
                    b_buffer[i][j] <= b_buffer[i][j+1];
                end
            end
            for (int i = 0; i < 4; i++) begin
                r_buffer[i][4] <= r_buffer[i+1][4];
                b_buffer[i][4] <= b_buffer[i+1][4];
            end
            r_buffer[4][4] <= r_in;
            b_buffer[4][4] <= b_in;
        end
    end
    
    // Apply correction with bilinear interpolation
    reg [PIXEL_WIDTH+1:0] r_interp, b_interp;
    wire [2:0] r_x_int = 3'd2 + r_shift_x[2:0];
    wire [2:0] r_y_int = 3'd2 + r_shift_y[2:0];
    wire [2:0] b_x_int = 3'd2 + b_shift_x[2:0];
    wire [2:0] b_y_int = 3'd2 + b_shift_y[2:0];
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_out <= {PIXEL_WIDTH{1'b0}};
            g_out <= {PIXEL_WIDTH{1'b0}};
            b_out <= {PIXEL_WIDTH{1'b0}};
            valid_out <= 1'b0;
        end else begin
            if (ca_enable) begin
                // Simple nearest neighbor for now
                r_out <= r_buffer[r_y_int][r_x_int];
                g_out <= g_in; // Green stays centered
                b_out <= b_buffer[b_y_int][b_x_int];
            end else begin
                r_out <= r_in;
                g_out <= g_in;
                b_out <= b_in;
            end
            
            valid_out <= valid_in;
        end
    end

endmodule

// Image Stabilization Correction Module
module image_stabilization #(
    parameter PIXEL_WIDTH = 12,
    parameter MOTION_BITS = 8,
    parameter BUFFER_SIZE = 16
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] data_in,
    input wire valid_in,
    input wire frame_start,
    input wire signed [MOTION_BITS-1:0] motion_x,
    input wire signed [MOTION_BITS-1:0] motion_y,
    input wire stabilization_enable,
    output reg [PIXEL_WIDTH-1:0] data_out,
    output reg valid_out
);

    // Motion accumulator for stabilization
    reg signed [MOTION_BITS+3:0] accumulated_x;
    reg signed [MOTION_BITS+3:0] accumulated_y;
    reg signed [MOTION_BITS+3:0] correction_x;
    reg signed [MOTION_BITS+3:0] correction_y;
    
    // Low-pass filter for motion
    reg signed [MOTION_BITS+7:0] filtered_x;
    reg signed [MOTION_BITS+7:0] filtered_y;
    
    // Frame buffer control
    reg [13:0] write_x, write_y;
    reg [13:0] read_x, read_y;
    
    // Motion filtering
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accumulated_x <= 0;
            accumulated_y <= 0;
            filtered_x <= 0;
            filtered_y <= 0;
        end else if (frame_start) begin
            // Update motion accumulation
            accumulated_x <= accumulated_x + motion_x;
            accumulated_y <= accumulated_y + motion_y;
            
            // Low-pass filter (IIR)
            filtered_x <= (filtered_x * 7 + (accumulated_x << 4)) >> 3;
            filtered_y <= (filtered_y * 7 + (accumulated_y << 4)) >> 3;
            
            // Calculate correction offset
            correction_x <= accumulated_x - (filtered_x >> 4);
            correction_y <= accumulated_y - (filtered_y >> 4);
        end
    end
    
    // Apply stabilization offset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= {PIXEL_WIDTH{1'b0}};
            valid_out <= 1'b0;
        end else if (valid_in) begin
            if (stabilization_enable) begin
                // Apply correction (simplified - actual implementation would
                // require frame buffering and interpolation)
                data_out <= data_in;
            end else begin
                data_out <= data_in;
            end
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end

endmodule