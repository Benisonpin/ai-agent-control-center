// HDR Frame Synchronization Module - Complete version
module hdr_frame_sync #(
    parameter PIXEL_WIDTH = 12,
    parameter DATA_WIDTH = 12,
    parameter BUFFER_DEPTH = 2048,
    parameter USE_BRAM = 1
)(
    input wire clk,
    input wire rst_n,
    
    // AXI-Stream inputs
    input wire [DATA_WIDTH-1:0] s_axis_hcg_tdata,
    input wire s_axis_hcg_tvalid,
    input wire s_axis_hcg_tready,
    input wire s_axis_hcg_tlast,
    input wire s_axis_hcg_tuser,
    
    input wire [DATA_WIDTH-1:0] s_axis_lcg_tdata,
    input wire s_axis_lcg_tvalid,
    input wire s_axis_lcg_tready,
    input wire s_axis_lcg_tlast,
    input wire s_axis_lcg_tuser,
    
    input wire [DATA_WIDTH-1:0] s_axis_vs_tdata,
    input wire s_axis_vs_tvalid,
    input wire s_axis_vs_tready,
    input wire s_axis_vs_tlast,
    input wire s_axis_vs_tuser,
    
    // Synchronized outputs
    output reg [DATA_WIDTH-1:0] sync_hcg_data,
    output reg [DATA_WIDTH-1:0] sync_lcg_data,
    output reg [DATA_WIDTH-1:0] sync_vs_data,
    output reg sync_valid,
    output reg sync_sof,
    output reg sync_eol
);

    // Simple synchronization
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_hcg_data <= 0;
            sync_lcg_data <= 0;
            sync_vs_data <= 0;
            sync_valid <= 0;
            sync_sof <= 0;
            sync_eol <= 0;
        end else begin
            if (s_axis_hcg_tvalid && s_axis_lcg_tvalid && s_axis_vs_tvalid) begin
                sync_hcg_data <= s_axis_hcg_tdata;
                sync_lcg_data <= s_axis_lcg_tdata;
                sync_vs_data <= s_axis_vs_tdata;
                sync_valid <= 1;
                sync_sof <= s_axis_hcg_tuser && s_axis_lcg_tuser && s_axis_vs_tuser;
                sync_eol <= s_axis_hcg_tlast && s_axis_lcg_tlast && s_axis_vs_tlast;
            end else begin
                sync_valid <= 0;
                sync_sof <= 0;
                sync_eol <= 0;
            end
        end
    end

endmodule
