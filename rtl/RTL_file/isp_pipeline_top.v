// ISP Pipeline Top Module
// Complete Image Signal Processor Implementation

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
    output wire [23:0] rgb_out,
    output wire data_valid_out,
    output wire frame_start_out,
    output wire frame_end_out,
    
    // Configuration Interface
    input wire [31:0] config_addr,
    input wire [31:0] config_data,
    input wire config_write,
    input wire config_read,
    output wire [31:0] config_readdata,
    
    // Statistics Output
    output wire [31:0] awb_r_gain,
    output wire [31:0] awb_g_gain,
    output wire [31:0] awb_b_gain,
    output wire [31:0] ae_exposure,
    output wire [31:0] af_score
);

    // Internal signals
    wire [PIXEL_WIDTH-1:0] raw_data;
    wire raw_valid;
    wire [13:0] pixel_x, pixel_y;
    
    wire [PIXEL_WIDTH-1:0] blc_data;
    wire blc_valid;
    
    wire [PIXEL_WIDTH-1:0] lsc_data;
    wire lsc_valid;
    
    wire [PIXEL_WIDTH-1:0] dpc_data;
    wire dpc_valid;
    
    wire [PIXEL_WIDTH-1:0] bnr_data;
    wire bnr_valid;
    
    wire [PIXEL_WIDTH-1:0] demosaic_r, demosaic_g, demosaic_b;
    wire demosaic_valid;
    
    wire [PIXEL_WIDTH-1:0] awb_r, awb_g, awb_b;
    wire awb_valid;
    
    wire [PIXEL_WIDTH-1:0] ccm_r, ccm_g, ccm_b;
    wire ccm_valid;
    
    wire [7:0] gamma_r, gamma_g, gamma_b;
    wire gamma_valid;
    
    wire [7:0] csc_y, csc_u, csc_v;
    wire csc_valid;
    
    wire [7:0] tnr_y, tnr_u, tnr_v;
    wire tnr_valid;
    
    wire [7:0] ee_y, ee_u, ee_v;
    wire ee_valid;

    // Configuration registers
    reg [31:0] config_regs[0:255];
    
    // 1. Sensor Interface
    sensor_interface #(
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT)
    ) u_sensor_if (
        .clk(clk),
        .rst_n(rst_n),
        .sensor_data(sensor_data),
        .sensor_hsync(sensor_hsync),
        .sensor_vsync(sensor_vsync),
        .sensor_pclk(sensor_pclk),
        .raw_data(raw_data),
        .raw_valid(raw_valid),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );
    
    // 2. Black Level Correction
    black_level_correction #(
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) u_blc (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(raw_data),
        .valid_in(raw_valid),
        .black_level(config_regs[0][PIXEL_WIDTH-1:0]),
        .data_out(blc_data),
        .valid_out(blc_valid)
    );
    
    // 3. Lens Shading Correction
    lens_shading_correction #(
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT)
    ) u_lsc (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(blc_data),
        .valid_in(blc_valid),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .center_x(config_regs[1][13:0]),
        .center_y(config_regs[1][29:16]),
        .data_out(lsc_data),
        .valid_out(lsc_valid)
    );
    
    // 4. Defective Pixel Correction
    defective_pixel_correction #(
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) u_dpc (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(lsc_data),
        .valid_in(lsc_valid),
        .threshold(config_regs[2][7:0]),
        .data_out(dpc_data),
        .valid_out(dpc_valid)
    );
    
    // 5. Bayer Noise Reduction
    bayer_noise_reduction #(
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) u_bnr (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(dpc_data),
        .valid_in(dpc_valid),
        .strength(config_regs[3][3:0]),
        .data_out(bnr_data),
        .valid_out(bnr_valid)
    );
    
    // 6. Demosaic
    demosaic #(
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) u_demosaic (
        .clk(clk),
        .rst_n(rst_n),
        .bayer_in(bnr_data),
        .valid_in(bnr_valid),
        .bayer_pattern(config_regs[4][1:0]),
        .r_out(demosaic_r),
        .g_out(demosaic_g),
        .b_out(demosaic_b),
        .valid_out(demosaic_valid)
    );
    
    // 7. Auto White Balance
    auto_white_balance #(
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) u_awb (
        .clk(clk),
        .rst_n(rst_n),
        .r_in(demosaic_r),
        .g_in(demosaic_g),
        .b_in(demosaic_b),
        .valid_in(demosaic_valid),
        .awb_enable(config_regs[5][0]),
        .r_gain(awb_r_gain),
        .g_gain(awb_g_gain),
        .b_gain(awb_b_gain),
        .r_out(awb_r),
        .g_out(awb_g),
        .b_out(awb_b),
        .valid_out(awb_valid)
    );
    
    // 8. Color Correction Matrix
    color_correction_matrix #(
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) u_ccm (
        .clk(clk),
        .rst_n(rst_n),
        .r_in(awb_r),
        .g_in(awb_g),
        .b_in(awb_b),
        .valid_in(awb_valid),
        .ccm_coeff(config_regs[15:6]),
        .r_out(ccm_r),
        .g_out(ccm_g),
        .b_out(ccm_b),
        .valid_out(ccm_valid)
    );
    
    // 9. Gamma Correction
    gamma_correction #(
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .LUT_DEPTH(256)
    ) u_gamma (
        .clk(clk),
        .rst_n(rst_n),
        .r_in(ccm_r),
        .g_in(ccm_g),
        .b_in(ccm_b),
        .valid_in(ccm_valid),
        .gamma_enable(config_regs[16][0]),
        .r_out(gamma_r),
        .g_out(gamma_g),
        .b_out(gamma_b),
        .valid_out(gamma_valid)
    );
    
    // 10. Color Space Conversion (RGB to YUV)
    color_space_conversion #(
        .INPUT_WIDTH(8)
    ) u_csc (
        .clk(clk),
        .rst_n(rst_n),
        .r_in(gamma_r),
        .g_in(gamma_g),
        .b_in(gamma_b),
        .valid_in(gamma_valid),
        .y_out(csc_y),
        .u_out(csc_u),
        .v_out(csc_v),
        .valid_out(csc_valid)
    );
    
    // 11. Temporal Noise Reduction
    temporal_noise_reduction #(
        .PIXEL_WIDTH(8)
    ) u_tnr (
        .clk(clk),
        .rst_n(rst_n),
        .y_in(csc_y),
        .u_in(csc_u),
        .v_in(csc_v),
        .valid_in(csc_valid),
        .tnr_strength(config_regs[17][3:0]),
        .y_out(tnr_y),
        .u_out(tnr_u),
        .v_out(tnr_v),
        .valid_out(tnr_valid)
    );
    
    // 12. Edge Enhancement
    edge_enhancement #(
        .PIXEL_WIDTH(8)
    ) u_ee (
        .clk(clk),
        .rst_n(rst_n),
        .y_in(tnr_y),
        .u_in(tnr_u),
        .v_in(tnr_v),
        .valid_in(tnr_valid),
        .ee_strength(config_regs[18][3:0]),
        .y_out(ee_y),
        .u_out(ee_u),
        .v_out(ee_v),
        .valid_out(ee_valid)
    );
    
    // 13. YUV to RGB Conversion
    yuv_to_rgb #(
        .PIXEL_WIDTH(8)
    ) u_yuv2rgb (
        .clk(clk),
        .rst_n(rst_n),
        .y_in(ee_y),
        .u_in(ee_u),
        .v_in(ee_v),
        .valid_in(ee_valid),
        .rgb_out(rgb_out),
        .valid_out(data_valid_out)
    );
    
    // Configuration Interface
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 256; i++) begin
                config_regs[i] <= 32'h0;
            end
        end else if (config_write) begin
            config_regs[config_addr[7:0]] <= config_data;
        end
    end
    
    assign config_readdata = config_read ? config_regs[config_addr[7:0]] : 32'h0;
    
    // Frame control signals
    frame_controller u_frame_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .vsync(sensor_vsync),
        .data_valid(data_valid_out),
        .frame_start(frame_start_out),
        .frame_end(frame_end_out)
    );

endmodule

// Sensor Interface Module
module sensor_interface #(
    parameter PIXEL_WIDTH = 12,
    parameter IMAGE_WIDTH = 4096,
    parameter IMAGE_HEIGHT = 3072
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] sensor_data,
    input wire sensor_hsync,
    input wire sensor_vsync,
    input wire sensor_pclk,
    output reg [PIXEL_WIDTH-1:0] raw_data,
    output reg raw_valid,
    output reg [13:0] pixel_x,
    output reg [13:0] pixel_y
);

    reg hsync_d, vsync_d;
    reg [1:0] sync_state;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_x <= 14'd0;
            pixel_y <= 14'd0;
            raw_valid <= 1'b0;
            sync_state <= 2'b00;
        end else begin
            hsync_d <= sensor_hsync;
            vsync_d <= sensor_vsync;
            
            // Detect sync edges
            if (sensor_vsync && !vsync_d) begin
                pixel_y <= 14'd0;
                pixel_x <= 14'd0;
            end else if (sensor_hsync && !hsync_d) begin
                pixel_x <= 14'd0;
                if (pixel_y < IMAGE_HEIGHT - 1)
                    pixel_y <= pixel_y + 1'b1;
            end else if (!sensor_hsync && !sensor_vsync) begin
                if (pixel_x < IMAGE_WIDTH - 1) begin
                    pixel_x <= pixel_x + 1'b1;
                    raw_data <= sensor_data;
                    raw_valid <= 1'b1;
                end else begin
                    raw_valid <= 1'b0;
                end
            end else begin
                raw_valid <= 1'b0;
            end
        end
    end

endmodule

// Black Level Correction Module
module black_level_correction #(
    parameter PIXEL_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] data_in,
    input wire valid_in,
    input wire [PIXEL_WIDTH-1:0] black_level,
    output reg [PIXEL_WIDTH-1:0] data_out,
    output reg valid_out
);

    wire signed [PIXEL_WIDTH:0] corrected;
    
    assign corrected = $signed({1'b0, data_in}) - $signed({1'b0, black_level});
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= {PIXEL_WIDTH{1'b0}};
            valid_out <= 1'b0;
        end else if (valid_in) begin
            // Clamp to valid range
            if (corrected < 0)
                data_out <= {PIXEL_WIDTH{1'b0}};
            else if (corrected > {PIXEL_WIDTH{1'b1}})
                data_out <= {PIXEL_WIDTH{1'b1}};
            else
                data_out <= corrected[PIXEL_WIDTH-1:0];
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end

endmodule

// Lens Shading Correction Module
module lens_shading_correction #(
    parameter PIXEL_WIDTH = 12,
    parameter IMAGE_WIDTH = 4096,
    parameter IMAGE_HEIGHT = 3072
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] data_in,
    input wire valid_in,
    input wire [13:0] pixel_x,
    input wire [13:0] pixel_y,
    input wire [13:0] center_x,
    input wire [13:0] center_y,
    output reg [PIXEL_WIDTH-1:0] data_out,
    output reg valid_out
);

    reg [27:0] dx_squared, dy_squared;
    reg [28:0] distance_squared;
    reg [15:0] gain;
    reg [PIXEL_WIDTH+15:0] corrected;
    
    wire signed [14:0] dx = $signed({1'b0, pixel_x}) - $signed({1'b0, center_x});
    wire signed [14:0] dy = $signed({1'b0, pixel_y}) - $signed({1'b0, center_y});
    
    // Pipeline stage 1: Calculate distance
    always @(posedge clk) begin
        if (valid_in) begin
            dx_squared <= dx * dx;
            dy_squared <= dy * dy;
        end
    end
    
    // Pipeline stage 2: Calculate gain
    always @(posedge clk) begin
        distance_squared <= dx_squared + dy_squared;
        // Simplified gain calculation
        gain <= 16'h8000 + (distance_squared[28:13]);
    end
    
    // Pipeline stage 3: Apply correction
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= {PIXEL_WIDTH{1'b0}};
            valid_out <= 1'b0;
        end else begin
            corrected <= data_in * gain;
            data_out <= corrected[PIXEL_WIDTH+14:15];
            valid_out <= valid_in;
        end
    end

endmodule

// Defective Pixel Correction Module
module defective_pixel_correction #(
    parameter PIXEL_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] data_in,
    input wire valid_in,
    input wire [7:0] threshold,
    output reg [PIXEL_WIDTH-1:0] data_out,
    output reg valid_out
);

    // Line buffers for 3x3 window
    reg [PIXEL_WIDTH-1:0] line_buffer[0:2][0:2];
    reg [2:0] valid_buffer;
    
    wire [PIXEL_WIDTH-1:0] center = line_buffer[1][1];
    wire [PIXEL_WIDTH-1:0] neighbors[0:7];
    
    assign neighbors[0] = line_buffer[0][0];
    assign neighbors[1] = line_buffer[0][1];
    assign neighbors[2] = line_buffer[0][2];
    assign neighbors[3] = line_buffer[1][0];
    assign neighbors[4] = line_buffer[1][2];
    assign neighbors[5] = line_buffer[2][0];
    assign neighbors[6] = line_buffer[2][1];
    assign neighbors[7] = line_buffer[2][2];
    
    reg [PIXEL_WIDTH+2:0] neighbor_sum;
    reg [PIXEL_WIDTH-1:0] neighbor_avg;
    reg defective;
    
    // Shift register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 3; i++) begin
                for (int j = 0; j < 3; j++) begin
                    line_buffer[i][j] <= {PIXEL_WIDTH{1'b0}};
                end
            end
            valid_buffer <= 3'b0;
        end else if (valid_in) begin
            // Shift rows
            for (int i = 0; i < 3; i++) begin
                line_buffer[i][0] <= line_buffer[i][1];
                line_buffer[i][1] <= line_buffer[i][2];
            end
            line_buffer[0][2] <= line_buffer[1][2];
            line_buffer[1][2] <= line_buffer[2][2];
            line_buffer[2][2] <= data_in;
            
            valid_buffer <= {valid_buffer[1:0], 1'b1};
        end
    end
    
    // Defect detection
    always @(posedge clk) begin
        neighbor_sum = neighbors[0] + neighbors[1] + neighbors[2] + neighbors[3] +
                      neighbors[4] + neighbors[5] + neighbors[6] + neighbors[7];
        neighbor_avg = neighbor_sum[PIXEL_WIDTH+2:3];
        
        if (center > neighbor_avg + threshold || center < neighbor_avg - threshold)
            defective = 1'b1;
        else
            defective = 1'b0;
    end
    
    // Output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= {PIXEL_WIDTH{1'b0}};
            valid_out <= 1'b0;
        end else begin
            if (defective)
                data_out <= neighbor_avg;
            else
                data_out <= center;
            valid_out <= valid_buffer[2];
        end
    end

endmodule

// Bayer Noise Reduction Module
module bayer_noise_reduction #(
    parameter PIXEL_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] data_in,
    input wire valid_in,
    input wire [3:0] strength,
    output reg [PIXEL_WIDTH-1:0] data_out,
    output reg valid_out
);

    // 5x5 line buffer
    reg [PIXEL_WIDTH-1:0] line_buffer[0:4][0:4];
    reg [4:0] valid_buffer;
    
    wire [PIXEL_WIDTH-1:0] center = line_buffer[2][2];
    
    // Gaussian weights for 5x5 kernel
    wire [4:0] weights[0:4][0:4];
    assign weights[0][0] = 5'd1; assign weights[0][1] = 5'd2; assign weights[0][2] = 5'd4; assign weights[0][3] = 5'd2; assign weights[0][4] = 5'd1;
    assign weights[1][0] = 5'd2; assign weights[1][1] = 5'd4; assign weights[1][2] = 5'd8; assign weights[1][3] = 5'd4; assign weights[1][4] = 5'd2;
    assign weights[2][0] = 5'd4; assign weights[2][1] = 5'd8; assign weights[2][2] = 5'd16; assign weights[2][3] = 5'd8; assign weights[2][4] = 5'd4;
    assign weights[3][0] = 5'd2; assign weights[3][1] = 5'd4; assign weights[3][2] = 5'd8; assign weights[3][3] = 5'd4; assign weights[3][4] = 5'd2;
    assign weights[4][0] = 5'd1; assign weights[4][1] = 5'd2; assign weights[4][2] = 5'd4; assign weights[4][3] = 5'd2; assign weights[4][4] = 5'd1;
    
    reg [PIXEL_WIDTH+7:0] weighted_sum;
    reg [PIXEL_WIDTH-1:0] filtered;
    
    // Shift register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 5; i++) begin
                for (int j = 0; j < 5; j++) begin
                    line_buffer[i][j] <= {PIXEL_WIDTH{1'b0}};
                end
            end
            valid_buffer <= 5'b0;
        end else if (valid_in) begin
            // Shift columns
            for (int i = 0; i < 5; i++) begin
                for (int j = 0; j < 4; j++) begin
                    line_buffer[i][j] <= line_buffer[i][j+1];
                end
            end
            // Shift rows
            for (int i = 0; i < 4; i++) begin
                line_buffer[i][4] <= line_buffer[i+1][4];
            end
            line_buffer[4][4] <= data_in;
            
            valid_buffer <= {valid_buffer[3:0], 1'b1};
        end
    end
    
    // Apply filter
    always @(posedge clk) begin
        weighted_sum = 0;
        for (int i = 0; i < 5; i++) begin
            for (int j = 0; j < 5; j++) begin
                weighted_sum = weighted_sum + line_buffer[i][j] * weights[i][j];
            end
        end
        filtered = weighted_sum >> 7; // Divide by 128
    end
    
    // Blend with original based on strength
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= {PIXEL_WIDTH{1'b0}};
            valid_out <= 1'b0;
        end else begin
            data_out <= ((16 - strength) * center + strength * filtered) >> 4;
            valid_out <= valid_buffer[4];
        end
    end

endmodule

// Demosaic Module
module demosaic #(
    parameter PIXEL_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] bayer_in,
    input wire valid_in,
    input wire [1:0] bayer_pattern, // 00=RGGB, 01=GRBG, 10=GBRG, 11=BGGR
    output reg [PIXEL_WIDTH-1:0] r_out,
    output reg [PIXEL_WIDTH-1:0] g_out,
    output reg [PIXEL_WIDTH-1:0] b_out,
    output reg valid_out
);

    // 5x5 line buffer for interpolation
    reg [PIXEL_WIDTH-1:0] line_buffer[0:4][0:4];
    reg [4:0] valid_buffer;
    reg [13:0] x_cnt, y_cnt;
    
    wire [PIXEL_WIDTH-1:0] center = line_buffer[2][2];
    wire [1:0] pixel_type;
    
    // Determine pixel type based on position and Bayer pattern
    assign pixel_type = {y_cnt[0] ^ bayer_pattern[1], x_cnt[0] ^ bayer_pattern[0]};
    
    reg [PIXEL_WIDTH+1:0] r_sum, g_sum, b_sum;
    
    // Shift register and position counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 5; i++) begin
                for (int j = 0; j < 5; j++) begin
                    line_buffer[i][j] <= {PIXEL_WIDTH{1'b0}};
                end
            end
            valid_buffer <= 5'b0;
            x_cnt <= 14'd0;
            y_cnt <= 14'd0;
        end else if (valid_in) begin
            // Shift buffer
            for (int i = 0; i < 5; i++) begin
                for (int j = 0; j < 4; j++) begin
                    line_buffer[i][j] <= line_buffer[i][j+1];
                end
            end
            for (int i = 0; i < 4; i++) begin
                line_buffer[i][4] <= line_buffer[i+1][4];
            end
            line_buffer[4][4] <= bayer_in;
            
            valid_buffer <= {valid_buffer[3:0], 1'b1};
            
            // Update position
            x_cnt <= x_cnt + 1'b1;
            if (x_cnt == IMAGE_WIDTH - 1) begin
                x_cnt <= 14'd0;
                y_cnt <= y_cnt + 1'b1;
            end
        end
    end
    
    // Bilinear interpolation
    always @(posedge clk) begin
        case (pixel_type)
            2'b00: begin // Red pixel
                r_out <= center;
                g_sum <= line_buffer[1][2] + line_buffer[3][2] + 
                        line_buffer[2][1] + line_buffer[2][3];
                g_out <= g_sum >> 2;
                b_sum <= line_buffer[1][1] + line_buffer[1][3] + 
                        line_buffer[3][1] + line_buffer[3][3];
                b_out <= b_sum >> 2;
            end
            2'b01: begin // Green pixel (Red row)
                r_sum <= line_buffer[2][1] + line_buffer[2][3];
                r_out <= r_sum >> 1;
                g_out <= center;
                b_sum <= line_buffer[1][2] + line_buffer[3][2];
                b_out <= b_sum >> 1;
            end
            2'b10: begin // Green pixel (Blue row)
                r_sum <= line_buffer[1][2] + line_buffer[3][2];
                r_out <= r_sum >> 1;
                g_out <= center;
                b_sum <= line_buffer[2][1] + line_buffer[2][3];
                b_out <= b_sum >> 1;
            end
            2'b11: begin // Blue pixel
                r_sum <= line_buffer[1][1] + line_buffer[1][3] + 
                        line_buffer[3][1] + line_buffer[3][3];
                r_out <= r_sum >> 2;
                g_sum <= line_buffer[1][2] + line_buffer[3][2] + 
                        line_buffer[2][1] + line_buffer[2][3];
                g_out <= g_sum >> 2;
                b_out <= center;
            end
        endcase
        
        valid_out <= valid_buffer[4];
    end

endmodule

// Auto White Balance Module
module auto_white_balance #(
    parameter PIXEL_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] r_in,
    input wire [PIXEL_WIDTH-1:0] g_in,
    input wire [PIXEL_WIDTH-1:0] b_in,
    input wire valid_in,
    input wire awb_enable,
    output reg [31:0] r_gain,
    output reg [31:0] g_gain,
    output reg [31:0] b_gain,
    output reg [PIXEL_WIDTH-1:0] r_out,
    output reg [PIXEL_WIDTH-1:0] g_out,
    output reg [PIXEL_WIDTH-1:0] b_out,
    output reg valid_out
);

    // Statistics accumulation
    reg [31:0] r_acc, g_acc, b_acc;
    reg [31:0] pixel_count;
    reg [31:0] frame_count;
    
    // Gray world algorithm
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_acc <= 32'd0;
            g_acc <= 32'd0;
            b_acc <= 32'd0;
            pixel_count <= 32'd0;
            frame_count <= 32'd0;
            r_gain <= 32'h10000;
            g_gain <= 32'h10000;
            b_gain <= 32'h10000;
        end else if (valid_in) begin
            // Accumulate statistics
            r_acc <= r_acc + r_in;
            g_acc <= g_acc + g_in;
            b_acc <= b_acc + b_in;
            pixel_count <= pixel_count + 1'b1;
            
            // Update gains every frame
            if (pixel_count == IMAGE_WIDTH * IMAGE_HEIGHT - 1) begin
                if (awb_enable) begin
                    // Calculate average values
                    reg [31:0] r_avg = r_acc / pixel_count;
                    reg [31:0] g_avg = g_acc / pixel_count;
                    reg [31:0] b_avg = b_acc / pixel_count;
                    reg [31:0] gray_avg = (r_avg + g_avg + b_avg) / 3;
                    
                    // Update gains
                    r_gain <= (gray_avg << 16) / r_avg;
                    g_gain <= (gray_avg << 16) / g_avg;
                    b_gain <= (gray_avg << 16) / b_avg;
                end
                
                // Reset accumulators
                r_acc <= 32'd0;
                g_acc <= 32'd0;
                b_acc <= 32'd0;
                pixel_count <= 32'd0;
                frame_count <= frame_count + 1'b1;
            end
        end
    end
    
    // Apply gains
    reg [PIXEL_WIDTH+15:0] r_corrected, g_corrected, b_corrected;
    
    always @(posedge clk) begin
        r_corrected <= r_in * r_gain[23:8];
        g_corrected <= g_in * g_gain[23:8];
        b_corrected <= b_in * b_gain[23:8];
        
        // Clamp to valid range
        r_out <= (r_corrected[PIXEL_WIDTH+15:16] > {PIXEL_WIDTH{1'b1}}) ? 
                 {PIXEL_WIDTH{1'b1}} : r_corrected[PIXEL_WIDTH+7:8];
        g_out <= (g_corrected[PIXEL_WIDTH+15:16] > {PIXEL_WIDTH{1'b1}}) ? 
                 {PIXEL_WIDTH{1'b1}} : g_corrected[PIXEL_WIDTH+7:8];
        b_out <= (b_corrected[PIXEL_WIDTH+15:16] > {PIXEL_WIDTH{1'b1}}) ? 
                 {PIXEL_WIDTH{1'b1}} : b_corrected[PIXEL_WIDTH+7:8];
        
        valid_out <= valid_in;
    end

endmodule

// Color Correction Matrix Module
module color_correction_matrix #(
    parameter PIXEL_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] r_in,
    input wire [PIXEL_WIDTH-1:0] g_in,
    input wire [PIXEL_WIDTH-1:0] b_in,
    input wire valid_in,
    input wire [31:0] ccm_coeff[0:8], // 3x3 matrix coefficients
    output reg [PIXEL_WIDTH-1:0] r_out,
    output reg [PIXEL_WIDTH-1:0] g_out,
    output reg [PIXEL_WIDTH-1:0] b_out,
    output reg valid_out
);

    // Matrix multiplication
    reg signed [31:0] r_temp, g_temp, b_temp;
    
    always @(posedge clk) begin
        // R' = C00*R + C01*G + C02*B
        r_temp <= ($signed(ccm_coeff[0]) * $signed({1'b0, r_in})) +
                  ($signed(ccm_coeff[1]) * $signed({1'b0, g_in})) +
                  ($signed(ccm_coeff[2]) * $signed({1'b0, b_in}));
        
        // G' = C10*R + C11*G + C12*B
        g_temp <= ($signed(ccm_coeff[3]) * $signed({1'b0, r_in})) +
                  ($signed(ccm_coeff[4]) * $signed({1'b0, g_in})) +
                  ($signed(ccm_coeff[5]) * $signed({1'b0, b_in}));
        
        // B' = C20*R + C21*G + C22*B
        b_temp <= ($signed(ccm_coeff[6]) * $signed({1'b0, r_in})) +
                  ($signed(ccm_coeff[7]) * $signed({1'b0, g_in})) +
                  ($signed(ccm_coeff[8]) * $signed({1'b0, b_in}));
    end
    
    // Output with clamping
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_out <= {PIXEL_WIDTH{1'b0}};
            g_out <= {PIXEL_WIDTH{1'b0}};
            b_out <= {PIXEL_WIDTH{1'b0}};
            valid_out <= 1'b0;
        end else begin
            // Clamp negative values to 0
            r_out <= (r_temp[31]) ? {PIXEL_WIDTH{1'b0}} : 
                     (r_temp[30:PIXEL_WIDTH+14]) ? {PIXEL_WIDTH{1'b1}} : 
                     r_temp[PIXEL_WIDTH+13:14];
            
            g_out <= (g_temp[31]) ? {PIXEL_WIDTH{1'b0}} : 
                     (g_temp[30:PIXEL_WIDTH+14]) ? {PIXEL_WIDTH{1'b1}} : 
                     g_temp[PIXEL_WIDTH+13:14];
            
            b_out <= (b_temp[31]) ? {PIXEL_WIDTH{1'b0}} : 
                     (b_temp[30:PIXEL_WIDTH+14]) ? {PIXEL_WIDTH{1'b1}} : 
                     b_temp[PIXEL_WIDTH+13:14];
            
            valid_out <= valid_in;
        end
    end

endmodule

// Gamma Correction Module
module gamma_correction #(
    parameter PIXEL_WIDTH = 12,
    parameter LUT_DEPTH = 256
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] r_in,
    input wire [PIXEL_WIDTH-1:0] g_in,
    input wire [PIXEL_WIDTH-1:0] b_in,
    input wire valid_in,
    input wire gamma_enable,
    output reg [7:0] r_out,
    output reg [7:0] g_out,
    output reg [7:0] b_out,
    output reg valid_out
);

    // Gamma LUT (simplified - normally would be programmable)
    reg [7:0] gamma_lut[0:LUT_DEPTH-1];
    
    // Initialize LUT with gamma = 2.2
    initial begin
        for (int i = 0; i < LUT_DEPTH; i++) begin
            gamma_lut[i] = 8'd255 * (i/255.0) ** (1/2.2);
        end
    end
    
    // Scale input to LUT index
    wire [7:0] r_idx = r_in[PIXEL_WIDTH-1:PIXEL_WIDTH-8];
    wire [7:0] g_idx = g_in[PIXEL_WIDTH-1:PIXEL_WIDTH-8];
    wire [7:0] b_idx = b_in[PIXEL_WIDTH-1:PIXEL_WIDTH-8];
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_out <= 8'd0;
            g_out <= 8'd0;
            b_out <= 8'd0;
            valid_out <= 1'b0;
        end else if (valid_in) begin
            if (gamma_enable) begin
                r_out <= gamma_lut[r_idx];
                g_out <= gamma_lut[g_idx];
                b_out <= gamma_lut[b_idx];
            end else begin
                r_out <= r_idx;
                g_out <= g_idx;
                b_out <= b_idx;
            end
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end

endmodule

// Color Space Conversion (RGB to YUV) Module
module color_space_conversion #(
    parameter INPUT_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire [INPUT_WIDTH-1:0] r_in,
    input wire [INPUT_WIDTH-1:0] g_in,
    input wire [INPUT_WIDTH-1:0] b_in,
    input wire valid_in,
    output reg [INPUT_WIDTH-1:0] y_out,
    output reg [INPUT_WIDTH-1:0] u_out,
    output reg [INPUT_WIDTH-1:0] v_out,
    output reg valid_out
);

    // RGB to YUV conversion coefficients (ITU-R BT.601)
    // Y = 0.299*R + 0.587*G + 0.114*B
    // U = -0.147*R - 0.289*G + 0.436*B + 128
    // V = 0.615*R - 0.515*G - 0.100*B + 128
    
    reg [INPUT_WIDTH+7:0] y_temp, u_temp, v_temp;
    
    always @(posedge clk) begin
        // Fixed-point arithmetic (8-bit fraction)
        y_temp <= (77 * r_in) + (150 * g_in) + (29 * b_in);
        u_temp <= 32768 - (38 * r_in) - (74 * g_in) + (112 * b_in);
        v_temp <= 32768 + (157 * r_in) - (131 * g_in) - (26 * b_in);
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y_out <= 8'd0;
            u_out <= 8'd128;
            v_out <= 8'd128;
            valid_out <= 1'b0;
        end else if (valid_in) begin
            y_out <= y_temp[INPUT_WIDTH+7:8];
            u_out <= u_temp[INPUT_WIDTH+7:8];
            v_out <= v_temp[INPUT_WIDTH+7:8];
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end

endmodule

// Temporal Noise Reduction Module
module temporal_noise_reduction #(
    parameter PIXEL_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] y_in,
    input wire [PIXEL_WIDTH-1:0] u_in,
    input wire [PIXEL_WIDTH-1:0] v_in,
    input wire valid_in,
    input wire [3:0] tnr_strength,
    output reg [PIXEL_WIDTH-1:0] y_out,
    output reg [PIXEL_WIDTH-1:0] u_out,
    output reg [PIXEL_WIDTH-1:0] v_out,
    output reg valid_out
);

    // Frame buffer (simplified - normally would use external memory)
    reg [PIXEL_WIDTH-1:0] prev_y[0:255];
    reg [PIXEL_WIDTH-1:0] prev_u[0:255];
    reg [PIXEL_WIDTH-1:0] prev_v[0:255];
    reg [7:0] pixel_addr;
    
    reg [PIXEL_WIDTH-1:0] y_prev, u_prev, v_prev;
    reg [PIXEL_WIDTH:0] y_diff, u_diff, v_diff;
    reg [PIXEL_WIDTH+3:0] y_blend, u_blend, v_blend;
    
    // Read previous frame
    always @(posedge clk) begin
        if (valid_in) begin
            y_prev <= prev_y[pixel_addr];
            u_prev <= prev_u[pixel_addr];
            v_prev <= prev_v[pixel_addr];
            pixel_addr <= pixel_addr + 1'b1;
        end
    end
    
    // Calculate motion and blend
    always @(posedge clk) begin
        y_diff <= (y_in > y_prev) ? (y_in - y_prev) : (y_prev - y_in);
        u_diff <= (u_in > u_prev) ? (u_in - u_prev) : (u_prev - u_in);
        v_diff <= (v_in > v_prev) ? (v_in - v_prev) : (v_prev - v_in);
        
        // Adaptive blending based on motion
        if (y_diff > 16) begin // High motion
            y_blend <= y_in << 4;
            u_blend <= u_in << 4;
            v_blend <= v_in << 4;
        end else begin // Low motion
            y_blend <= ((16 - tnr_strength) * y_in + tnr_strength * y_prev);
            u_blend <= ((16 - tnr_strength) * u_in + tnr_strength * u_prev);
            v_blend <= ((16 - tnr_strength) * v_in + tnr_strength * v_prev);
        end
    end
    
    // Update frame buffer and output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y_out <= 8'd0;
            u_out <= 8'd128;
            v_out <= 8'd128;
            valid_out <= 1'b0;
            pixel_addr <= 8'd0;
        end else if (valid_in) begin
            y_out <= y_blend >> 4;
            u_out <= u_blend >> 4;
            v_out <= v_blend >> 4;
            
            // Store for next frame
            prev_y[pixel_addr-1] <= y_blend >> 4;
            prev_u[pixel_addr-1] <= u_blend >> 4;
            prev_v[pixel_addr-1] <= v_blend >> 4;
            
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end

endmodule

// Edge Enhancement Module
module edge_enhancement #(
    parameter PIXEL_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] y_in,
    input wire [PIXEL_WIDTH-1:0] u_in,
    input wire [PIXEL_WIDTH-1:0] v_in,
    input wire valid_in,
    input wire [3:0] ee_strength,
    output reg [PIXEL_WIDTH-1:0] y_out,
    output reg [PIXEL_WIDTH-1:0] u_out,
    output reg [PIXEL_WIDTH-1:0] v_out,
    output reg valid_out
);

    // 3x3 line buffer for edge detection
    reg [PIXEL_WIDTH-1:0] y_buffer[0:2][0:2];
    reg [2:0] valid_buffer;
    
    // Laplacian kernel for edge detection
    wire signed [PIXEL_WIDTH+3:0] edge_value;
    
    // Shift register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 3; i++) begin
                for (int j = 0; j < 3; j++) begin
                    y_buffer[i][j] <= {PIXEL_WIDTH{1'b0}};
                end
            end
            valid_buffer <= 3'b0;
        end else if (valid_in) begin
            // Shift buffer
            for (int i = 0; i < 3; i++) begin
                y_buffer[i][0] <= y_buffer[i][1];
                y_buffer[i][1] <= y_buffer[i][2];
            end
            y_buffer[0][2] <= y_buffer[1][2];
            y_buffer[1][2] <= y_buffer[2][2];
            y_buffer[2][2] <= y_in;
            
            valid_buffer <= {valid_buffer[1:0], 1'b1};
        end
    end
    
    // Apply Laplacian kernel
    assign edge_value = $signed({1'b0, y_buffer[1][1]} << 3) -
                       $signed({1'b0, y_buffer[0][1]}) -
                       $signed({1'b0, y_buffer[1][0]}) -
                       $signed({1'b0, y_buffer[1][2]}) -
                       $signed({1'b0, y_buffer[2][1]}) -
                       $signed({1'b0, y_buffer[0][0]}) -
                       $signed({1'b0, y_buffer[0][2]}) -
                       $signed({1'b0, y_buffer[2][0]}) -
                       $signed({1'b0, y_buffer[2][2]});
    
    // Apply enhancement
    reg signed [PIXEL_WIDTH+4:0] enhanced;
    
    always @(posedge clk) begin
        enhanced = $signed({1'b0, y_buffer[1][1]}) + 
                  (($signed(edge_value) * $signed({1'b0, ee_strength})) >>> 4);
    end
    
    // Output with clamping
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y_out <= 8'd0;
            u_out <= 8'd128;
            v_out <= 8'd128;
            valid_out <= 1'b0;
        end else if (valid_buffer[2]) begin
            // Clamp Y channel
            if (enhanced < 0)
                y_out <= 8'd0;
            else if (enhanced > 255)
                y_out <= 8'd255;
            else
                y_out <= enhanced[PIXEL_WIDTH-1:0];
            
            // Pass through U and V
            u_out <= u_in;
            v_out <= v_in;
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end

endmodule

// YUV to RGB Conversion Module
module yuv_to_rgb #(
    parameter PIXEL_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] y_in,
    input wire [PIXEL_WIDTH-1:0] u_in,
    input wire [PIXEL_WIDTH-1:0] v_in,
    input wire valid_in,
    output reg [23:0] rgb_out,
    output reg valid_out
);

    // YUV to RGB conversion
    // R = Y + 1.402*(V-128)
    // G = Y - 0.344*(U-128) - 0.714*(V-128)
    // B = Y + 1.772*(U-128)
    
    reg signed [PIXEL_WIDTH+8:0] r_temp, g_temp, b_temp;
    reg signed [PIXEL_WIDTH:0] u_centered, v_centered;
    
    always @(posedge clk) begin
        // Center U and V around 0
        u_centered <= $signed({1'b0, u_in}) - 128;
        v_centered <= $signed({1'b0, v_in}) - 128;
        
        // Fixed-point conversion
        r_temp <= $signed({1'b0, y_in}) + ((359 * v_centered) >>> 8);
        g_temp <= $signed({1'b0, y_in}) - ((88 * u_centered) >>> 8) - ((183 * v_centered) >>> 8);
        b_temp <= $signed({1'b0, y_in}) + ((454 * u_centered) >>> 8);
    end
    
    // Output with clamping
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rgb_out <= 24'd0;
            valid_out <= 1'b0;
        end else if (valid_in) begin
            // Clamp R
            if (r_temp < 0)
                rgb_out[23:16] <= 8'd0;
            else if (r_temp > 255)
                rgb_out[23:16] <= 8'd255;
            else
                rgb_out[23:16] <= r_temp[7:0];
            
            // Clamp G
            if (g_temp < 0)
                rgb_out[15:8] <= 8'd0;
            else if (g_temp > 255)
                rgb_out[15:8] <= 8'd255;
            else
                rgb_out[15:8] <= g_temp[7:0];
            
            // Clamp B
            if (b_temp < 0)
                rgb_out[7:0] <= 8'd0;
            else if (b_temp > 255)
                rgb_out[7:0] <= 8'd255;
            else
                rgb_out[7:0] <= b_temp[7:0];
            
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end

endmodule

// Frame Controller Module
module frame_controller (
    input wire clk,
    input wire rst_n,
    input wire vsync,
    input wire data_valid,
    output reg frame_start,
    output reg frame_end
);

    reg vsync_d1, vsync_d2;
    reg frame_active;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vsync_d1 <= 1'b0;
            vsync_d2 <= 1'b0;
            frame_start <= 1'b0;
            frame_end <= 1'b0;
            frame_active <= 1'b0;
        end else begin
            vsync_d1 <= vsync;
            vsync_d2 <= vsync_d1;
            
            // Detect vsync rising edge
            if (vsync_d1 && !vsync_d2) begin
                frame_start <= 1'b1;
                frame_active <= 1'b1;
            end else begin
                frame_start <= 1'b0;
            end
            
            // Detect vsync falling edge
            if (!vsync_d1 && vsync_d2 && frame_active) begin
                frame_end <= 1'b1;
                frame_active <= 1'b0;
            end else begin
                frame_end <= 1'b0;
            end
        end
    end

endmodule