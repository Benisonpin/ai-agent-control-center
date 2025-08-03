// Simple AXI-Lite Slave Module
module axi_lite_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,
    
    // AXI Write Address Channel
    input wire [ADDR_WIDTH-1:0] s_axi_awaddr,
    input wire s_axi_awvalid,
    output reg s_axi_awready,
    
    // AXI Write Data Channel
    input wire [DATA_WIDTH-1:0] s_axi_wdata,
    input wire [3:0] s_axi_wstrb,
    input wire s_axi_wvalid,
    output reg s_axi_wready,
    
    // AXI Write Response Channel
    output reg [1:0] s_axi_bresp,
    output reg s_axi_bvalid,
    input wire s_axi_bready,
    
    // AXI Read Address Channel
    input wire [ADDR_WIDTH-1:0] s_axi_araddr,
    input wire s_axi_arvalid,
    output reg s_axi_arready,
    
    // AXI Read Data Channel
    output reg [DATA_WIDTH-1:0] s_axi_rdata,
    output reg [1:0] s_axi_rresp,
    output reg s_axi_rvalid,
    input wire s_axi_rready,
    
    // Register interface
    output reg [ADDR_WIDTH-1:0] reg_addr,
    output reg [DATA_WIDTH-1:0] reg_wdata,
    output reg reg_write,
    input wire [DATA_WIDTH-1:0] reg_rdata
);

    // Simple state machine implementation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_awready <= 1;
            s_axi_wready <= 0;
            s_axi_bvalid <= 0;
            s_axi_bresp <= 0;
            s_axi_arready <= 1;
            s_axi_rvalid <= 0;
            s_axi_rresp <= 0;
            reg_write <= 0;
        end else begin
            // Write handling
            if (s_axi_awvalid && s_axi_awready) begin
                reg_addr <= s_axi_awaddr;
                s_axi_awready <= 0;
                s_axi_wready <= 1;
            end
            
            if (s_axi_wvalid && s_axi_wready) begin
                reg_wdata <= s_axi_wdata;
                reg_write <= 1;
                s_axi_wready <= 0;
                s_axi_bvalid <= 1;
            end else begin
                reg_write <= 0;
            end
            
            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 0;
                s_axi_awready <= 1;
            end
            
            // Read handling
            if (s_axi_arvalid && s_axi_arready) begin
                reg_addr <= s_axi_araddr;
                s_axi_arready <= 0;
                s_axi_rvalid <= 1;
                s_axi_rdata <= reg_rdata;
            end
            
            if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 0;
                s_axi_arready <= 1;
            end
        end
    end

endmodule
