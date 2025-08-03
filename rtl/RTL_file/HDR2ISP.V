// HDR to ISP Pipeline Connection Module
// This module demonstrates how to connect the HDR IP to an existing ISP pipeline

module hdr_isp_connector #(
    parameter PIXEL_WIDTH = 12,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ADDR_WIDTH = 12
)(
    // Global signals
    input  wire                         clk,
    input  wire                         rst_n,
    
    // Sensor interfaces (multi-exposure)
    input  wire [PIXEL_WIDTH-1:0]       sensor_hcg_data,
    input  wire                         sensor_hcg_valid,
    input  wire                         sensor_hcg_href,
    input  wire                         sensor_hcg_vsync,
    
    input  wire [PIXEL_WIDTH-1:0]       sensor_lcg_data,
    input  wire                         sensor_lcg_valid,
    input  wire                         sensor_lcg_href,
    input  wire                         sensor_lcg_vsync,
    
    input  wire [PIXEL_WIDTH-1:0]       sensor_vs_data,
    input  wire                         sensor_vs_valid,
    input  wire                         sensor_vs_href,
    input  wire                         sensor_vs_vsync,
    
    // ISP pipeline interface
    output wire [PIXEL_WIDTH-1:0]       isp_raw_data,
    output wire                         isp_raw_valid,
    output wire                         isp_href,
    output wire                         isp_vsync,
    input  wire                         isp_ready,
    
    // Configuration
    input  wire                         hdr_enable,
    input  wire                         hdr_bypass,
    
    // AXI4-Lite interface for HDR configuration
    input  wire [AXI_ADDR_WIDTH-1:0]    s_axi_awaddr,
    input  wire                         s_axi_awvalid,
    output wire                         s_axi_awready,
    input  wire [AXI_DATA_WIDTH-1:0]    s_axi_wdata,
    input  wire                         s_axi_wvalid,
    output wire                         s_axi_wready,
    output wire                         s_axi_bvalid,
    input  wire                         s_axi_bready,
    input  wire [AXI_ADDR_WIDTH-1:0]    s_axi_araddr,
    input  wire                         s_axi_arvalid,
    output wire                         s_axi_arready,
    output wire [AXI_DATA_WIDTH-1:0]    s_axi_rdata,
    output wire                         s_axi_rvalid,
    input  wire                         s_axi_rready,
    
    // Status
    output wire                         hdr_active,
    output wire                         hdr_error
);

// Internal signals
wire [PIXEL_WIDTH-1:0] hdr_output_data;
wire hdr_output_valid, hdr_output_ready, hdr_output_last, hdr_output_user;

// Convert sensor timing to AXI-Stream
wire [PIXEL_WIDTH-1:0] hcg_stream_data, lcg_stream_data, vs_stream_data;
wire hcg_stream_valid, lcg_stream_valid, vs_stream_valid;
wire hcg_stream_last, lcg_stream_last, vs_stream_last;
wire hcg_stream_user, lcg_stream_user, vs_stream_user;

// Sensor to AXI-Stream converters
sensor_to_axis #(
    .DATA_WIDTH(PIXEL_WIDTH)
) u_hcg_converter (
    .clk(clk),
    .rst_n(rst_n),
    .sensor_data(sensor_hcg_data),
    .sensor_valid(sensor_hcg_valid),
    .sensor_href(sensor_hcg_href),
    .sensor_vsync(sensor_hcg_vsync),
    .axis_tdata(hcg_stream_data),
    .axis_tvalid(hcg_stream_valid),
    .axis_tready(hcg_stream_ready),
    .axis_tlast(hcg_stream_last),
    .axis_tuser(hcg_stream_user)
);

sensor_to_axis #(
    .DATA_WIDTH(PIXEL_WIDTH)
) u_lcg_converter (
    .clk(clk),
    .rst_n(rst_n),
    .sensor_data(sensor_lcg_data),
    .sensor_valid(sensor_lcg_valid),
    .sensor_href(sensor_lcg_href),
    .sensor_vsync(sensor_lcg_vsync),
    .axis_tdata(lcg_stream_data),
    .axis_tvalid(lcg_stream_valid),
    .axis_tready(lcg_stream_ready),
    .axis_tlast(lcg_stream_last),
    .axis_tuser(lcg_stream_user)
);

sensor_to_axis #(
    .DATA_WIDTH(PIXEL_WIDTH)
) u_vs_converter (
    .clk(clk),
    .rst_n(rst_n),
    .sensor_data(sensor_vs_data),
    .sensor_valid(sensor_vs_valid),
    .sensor_href(sensor_vs_href),
    .sensor_vsync(sensor_vs_vsync),
    .axis_tdata(vs_stream_data),
    .axis_tvalid(vs_stream_valid),
    .axis_tready(vs_stream_ready),
    .axis_tlast(vs_stream_last),
    .axis_tuser(vs_stream_user)
);

// HDR Processor instantiation
hdr_processor_ip #(
    .PIXEL_WIDTH(PIXEL_WIDTH),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
) u_hdr_processor (
    .clk(clk),
    .rst_n(rst_n),
    
    // Multi-exposure inputs
    .s_axis_hcg_tdata(hcg_stream_data),
    .s_axis_hcg_tvalid(hcg_stream_valid),
    .s_axis_hcg_tready(hcg_stream_ready),
    .s_axis_hcg_tlast(hcg_stream_last),
    .s_axis_hcg_tuser(hcg_stream_user),
    
    .s_axis_lcg_tdata(lcg_stream_data),
    .s_axis_lcg_tvalid(lcg_stream_valid),
    .s_axis_lcg_tready(lcg_stream_ready),
    .s_axis_lcg_tlast(lcg_stream_last),
    .s_axis_lcg_tuser(lcg_stream_user),
    
    .s_axis_vs_tdata(vs_stream_data),
    .s_axis_vs_tvalid(vs_stream_valid),
    .s_axis_vs_tready(vs_stream_ready),
    .s_axis_vs_tlast(vs_stream_last),
    .s_axis_vs_tuser(vs_stream_user),
    
    // HDR output
    .m_axis_tdata(hdr_output_data),
    .m_axis_tvalid(hdr_output_valid),
    .m_axis_tready(hdr_output_ready),
    .m_axis_tlast(hdr_output_last),
    .m_axis_tuser(hdr_output_user),
    
    // Configuration
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awprot(3'b000),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(4'b1111),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    .s_axi_bresp(),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arprot(3'b000),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready),
    
    // Status
    .hdr_busy(hdr_active),
    .error_flag(hdr_error)
);

// AXI-Stream to ISP interface converter
axis_to_isp #(
    .DATA_WIDTH(PIXEL_WIDTH)
) u_axis_to_isp (
    .clk(clk),
    .rst_n(rst_n),
    
    // AXI-Stream input
    .axis_tdata(hdr_output_data),
    .axis_tvalid(hdr_output_valid),
    .axis_tready(hdr_output_ready),
    .axis_tlast(hdr_output_last),
    .axis_tuser(hdr_output_user),
    
    // ISP interface output
    .isp_data(isp_raw_data_hdr),
    .isp_valid(isp_raw_valid_hdr),
    .isp_href(isp_href_hdr),
    .isp_vsync(isp_vsync_hdr),
    .isp_ready(isp_ready)
);

// Multiplexer for HDR enable/bypass
assign isp_raw_data = hdr_enable ? isp_raw_data_hdr : sensor_hcg_data;
assign isp_raw_valid = hdr_enable ? isp_raw_valid_hdr : sensor_hcg_valid;
assign isp_href = hdr_enable ? isp_href_hdr : sensor_hcg_href;
assign isp_vsync = hdr_enable ? isp_vsync_hdr : sensor_hcg_vsync;

endmodule

// Helper module: Sensor timing to AXI-Stream converter
module sensor_to_axis #(
    parameter DATA_WIDTH = 12
)(
    input  wire                   clk,
    input  wire                   rst_n,
    
    // Sensor interface
    input  wire [DATA_WIDTH-1:0]  sensor_data,
    input  wire                   sensor_valid,
    input  wire                   sensor_href,
    input  wire                   sensor_vsync,
    
    // AXI-Stream interface
    output reg  [DATA_WIDTH-1:0]  axis_tdata,
    output reg                    axis_tvalid,
    input  wire                   axis_tready,
    output reg                    axis_tlast,
    output reg                    axis_tuser
);

reg vsync_d1, vsync_d2;
reg href_d1, href_d2;
wire vsync_rising, href_falling;

// Edge detection
always @(posedge clk) begin
    if (!rst_n) begin
        vsync_d1 <= 1'b0;
        vsync_d2 <= 1'b0;
        href_d1 <= 1'b0;
        href_d2 <= 1'b0;
    end else begin
        vsync_d1 <= sensor_vsync;
        vsync_d2 <= vsync_d1;
        href_d1 <= sensor_href;
        href_d2 <= href_d1;
    end
end

assign vsync_rising = vsync_d1 & ~vsync_d2;
assign href_falling = ~href_d1 & href_d2;

// Pixel counter for line end detection
reg [15:0] pixel_count;
reg [15:0] line_length;
reg first_line;

always @(posedge clk) begin
    if (!rst_n) begin
        axis_tdata <= {DATA_WIDTH{1'b0}};
        axis_tvalid <= 1'b0;
        axis_tlast <= 1'b0;
        axis_tuser <= 1'b0;
        pixel_count <= 16'd0;
        line_length <= 16'd1920; // Default
        first_line <= 1'b1;
    end else begin
        // Start of frame
        axis_tuser <= vsync_rising;
        
        // Valid data
        if (sensor_valid && sensor_href) begin
            axis_tdata <= sensor_data;
            axis_tvalid <= 1'b1;
            pixel_count <= pixel_count + 1'b1;
            
            // End of line detection
            if (pixel_count == line_length - 1'b1) begin
                axis_tlast <= 1'b1;
                pixel_count <= 16'd0;
            end else begin
                axis_tlast <= 1'b0;
            end
        end else begin
            axis_tvalid <= 1'b0;
            axis_tlast <= 1'b0;
            
            // Learn line length from first line
            if (href_falling && first_line) begin
                line_length <= pixel_count;
                first_line <= 1'b0;
            end
            
            // Reset counter at line end
            if (!sensor_href) begin
                pixel_count <= 16'd0;
            end
        end
        
        // Reset at frame start
        if (vsync_rising) begin
            first_line <= 1'b1;
            pixel_count <= 16'd0;
        end
    end
end

endmodule

// Helper module: AXI-Stream to ISP interface converter
module axis_to_isp #(
    parameter DATA_WIDTH = 12
)(
    input  wire                   clk,
    input  wire                   rst_n,
    
    // AXI-Stream interface
    input  wire [DATA_WIDTH-1:0]  axis_tdata,
    input  wire                   axis_tvalid,
    output wire                   axis_tready,
    input  wire                   axis_tlast,
    input  wire                   axis_tuser,
    
    // ISP interface
    output reg  [DATA_WIDTH-1:0]  isp_data,
    output reg                    isp_valid,
    output reg                    isp_href,
    output reg                    isp_vsync,
    input  wire                   isp_ready
);

// State machine for timing generation
localparam IDLE = 2'b00;
localparam VSYNC = 2'b01;
localparam ACTIVE = 2'b10;
localparam HBLANK = 2'b11;

reg [1:0] state;
reg [15:0] hblank_count;
reg frame_active;

assign axis_tready = isp_ready & (state == ACTIVE);

always @(posedge clk) begin
    if (!rst_n) begin
        state <= IDLE;
        isp_data <= {DATA_WIDTH{1'b0}};
        isp_valid <= 1'b0;
        isp_href <= 1'b0;
        isp_vsync <= 1'b0;
        hblank_count <= 16'd0;
        frame_active <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                isp_valid <= 1'b0;
                isp_href <= 1'b0;
                isp_vsync <= 1'b0;
                
                // Wait for start of frame
                if (axis_tuser && axis_tvalid) begin
                    state <= VSYNC;
                    isp_vsync <= 1'b1;
                    frame_active <= 1'b1;
                end
            end
            
            VSYNC: begin
                // VSYNC pulse duration
                if (hblank_count < 16'd10) begin
                    hblank_count <= hblank_count + 1'b1;
                    isp_vsync <= 1'b1;
                end else begin
                    hblank_count <= 16'd0;
                    isp_vsync <= 1'b0;
                    state <= ACTIVE;
                end
            end
            
            ACTIVE: begin
                if (axis_tvalid && axis_tready) begin
                    isp_data <= axis_tdata;
                    isp_valid <= 1'b1;
                    isp_href <= 1'b1;
                    
                    // End of line
                    if (axis_tlast) begin
                        state <= HBLANK;
                        isp_href <= 1'b0;
                    end
                end else begin
                    isp_valid <= 1'b0;
                end
            end
            
            HBLANK: begin
                isp_valid <= 1'b0;
                isp_href <= 1'b0;
                
                // Horizontal blanking period
                if (hblank_count < 16'd100) begin
                    hblank_count <= hblank_count + 1'b1;
                end else begin
                    hblank_count <= 16'd0;
                    
                    // Check for new frame
                    if (axis_tuser && axis_tvalid) begin
                        state <= VSYNC;
                    end else begin
                        state <= ACTIVE;
                    end
                end
            end
        endcase
        
        // Frame end detection
        if (!frame_active || (!axis_tvalid && state == IDLE)) begin
            state <= IDLE;
            frame_active <= 1'b0;
        end
    end
end

endmodule