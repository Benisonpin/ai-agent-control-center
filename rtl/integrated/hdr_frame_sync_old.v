// HDR Frame Synchronization Module
module hdr_frame_sync #(
    parameter DATA_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,
    
    // Input streams
    input wire [DATA_WIDTH-1:0] stream1_data,
    input wire stream1_valid,
    input wire stream1_sof,
    input wire stream1_eol,
    
    input wire [DATA_WIDTH-1:0] stream2_data,
    input wire stream2_valid,
    input wire stream2_sof,
    input wire stream2_eol,
    
    input wire [DATA_WIDTH-1:0] stream3_data,
    input wire stream3_valid,
    input wire stream3_sof,
    input wire stream3_eol,
    
    // Synchronized outputs
    output reg [DATA_WIDTH-1:0] sync_data1,
    output reg [DATA_WIDTH-1:0] sync_data2,
    output reg [DATA_WIDTH-1:0] sync_data3,
    output reg sync_valid,
    output reg sync_sof,
    output reg sync_eol
);

    // Simple synchronization - wait for all streams
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_data1 <= 0;
            sync_data2 <= 0;
            sync_data3 <= 0;
            sync_valid <= 0;
            sync_sof <= 0;
            sync_eol <= 0;
        end else begin
            if (stream1_valid && stream2_valid && stream3_valid) begin
                sync_data1 <= stream1_data;
                sync_data2 <= stream2_data;
                sync_data3 <= stream3_data;
                sync_valid <= 1;
                sync_sof <= stream1_sof && stream2_sof && stream3_sof;
                sync_eol <= stream1_eol && stream2_eol && stream3_eol;
            end else begin
                sync_valid <= 0;
                sync_sof <= 0;
                sync_eol <= 0;
            end
        end
    end

endmodule
