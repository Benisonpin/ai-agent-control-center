// Support modules for the integrated AI + HDR + ISP system

// =========================================
// Sensor to AXI-Stream Converter
// =========================================
module sensor_to_axis #(
    parameter DATA_WIDTH = 12
)(
    input  wire                     clk,
    input  wire                     rst_n,
    
    // Sensor interface
    input  wire [DATA_WIDTH-1:0]    sensor_data,
    input  wire                     sensor_valid,
    input  wire                     sensor_href,
    input  wire                     sensor_vsync,
    
    // AXI-Stream interface
    output reg  [DATA_WIDTH-1:0]    axis_tdata,
    output reg                      axis_tvalid,
    input  wire                     axis_tready,
    output reg                      axis_tlast,
    output reg                      axis_tuser
);

    reg vsync_d1, href_d1;
    reg line_active;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axis_tdata <= 0;
            axis_tvalid <= 0;
            axis_tlast <= 0;
            axis_tuser <= 0;
            vsync_d1 <= 0;
            href_d1 <= 0;
            line_active <= 0;
        end else begin
            vsync_d1 <= sensor_vsync;
            href_d1 <= sensor_href;
            
            // Start of frame
            axis_tuser <= sensor_vsync && !vsync_d1;
            
            // End of line
            axis_tlast <= href_d1 && !sensor_href;
            
            // Data valid
            if (sensor_valid && sensor_href) begin
                axis_tdata <= sensor_data;
                axis_tvalid <= 1;
            end else if (axis_tready) begin
                axis_tvalid <= 0;
            end
        end
    end

endmodule

// =========================================
// AXI-Stream to Parallel Converter
// =========================================
module axis_to_parallel #(
    parameter DATA_WIDTH = 12
)(
    input  wire                     clk,
    input  wire                     rst_n,
    
    // AXI-Stream interface
    input  wire [DATA_WIDTH-1:0]    axis_tdata,
    input  wire                     axis_tvalid,
    output wire                     axis_tready,
    input  wire                     axis_tlast,
    input  wire                     axis_tuser,
    
    // Parallel interface
    output reg  [DATA_WIDTH-1:0]    parallel_data,
    output reg                      parallel_valid,
    output reg                      parallel_href,
    output reg                      parallel_vsync
);

    reg frame_active;
    reg line_active;
    
    assign axis_tready = 1'b1;  // Always ready
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            parallel_data <= 0;
            parallel_valid <= 0;
            parallel_href <= 0;
            parallel_vsync <= 0;
            frame_active <= 0;
            line_active <= 0;
        end else begin
            // Frame control
            if (axis_tuser && axis_tvalid) begin
                frame_active <= 1;
                parallel_vsync <= 1;
            end else if (!line_active && !axis_tvalid) begin
                frame_active <= 0;
                parallel_vsync <= 0;
            end
            
            // Line control
            if (frame_active && axis_tvalid && !line_active) begin
                line_active <= 1;
                parallel_href <= 1;
            end else if (axis_tlast && axis_tvalid) begin
                line_active <= 0;
                parallel_href <= 0;
            end
            
            // Data
            parallel_data <= axis_tdata;
            parallel_valid <= axis_tvalid;
        end
    end

endmodule
