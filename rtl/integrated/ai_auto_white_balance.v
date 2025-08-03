// Simplified AI Auto White Balance Module
module ai_auto_white_balance #(
    parameter PIXEL_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,
    
    // Input RGB
    input wire [PIXEL_WIDTH-1:0] r_in,
    input wire [PIXEL_WIDTH-1:0] g_in,
    input wire [PIXEL_WIDTH-1:0] b_in,
    input wire valid_in,
    
    // Gain control
    input wire [15:0] r_gain,
    input wire [15:0] g_gain,
    input wire [15:0] b_gain,
    input wire awb_enable,
    
    // Output RGB
    output reg [PIXEL_WIDTH-1:0] r_out,
    output reg [PIXEL_WIDTH-1:0] g_out,
    output reg [PIXEL_WIDTH-1:0] b_out,
    output reg valid_out
);

    // Apply gains
    wire [PIXEL_WIDTH+15:0] r_temp, g_temp, b_temp;
    
    assign r_temp = r_in * r_gain;
    assign g_temp = g_in * g_gain;
    assign b_temp = b_in * b_gain;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_out <= 0;
            g_out <= 0;
            b_out <= 0;
            valid_out <= 0;
        end else if (awb_enable && valid_in) begin
            // Apply gain with saturation
            r_out <= (r_temp[PIXEL_WIDTH+15:8] > {PIXEL_WIDTH{1'b1}}) ? 
                     {PIXEL_WIDTH{1'b1}} : r_temp[PIXEL_WIDTH+7:8];
            g_out <= (g_temp[PIXEL_WIDTH+15:8] > {PIXEL_WIDTH{1'b1}}) ? 
                     {PIXEL_WIDTH{1'b1}} : g_temp[PIXEL_WIDTH+7:8];
            b_out <= (b_temp[PIXEL_WIDTH+15:8] > {PIXEL_WIDTH{1'b1}}) ? 
                     {PIXEL_WIDTH{1'b1}} : b_temp[PIXEL_WIDTH+7:8];
            valid_out <= 1;
        end else if (!awb_enable && valid_in) begin
            // Bypass mode
            r_out <= r_in;
            g_out <= g_in;
            b_out <= b_in;
            valid_out <= 1;
        end else begin
            valid_out <= 0;
        end
    end

endmodule
