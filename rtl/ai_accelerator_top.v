/*
 * AI Accelerator Top Module
 * 支援知識蒸餾後的學生模型推論
 * CTE TW-LCEO-AISP-2025
 */

module ai_accelerator_top #(
    parameter DATA_WIDTH     = 32,
    parameter ADDR_WIDTH     = 16,
    parameter MAC_ARRAY_SIZE = 512,
    parameter NUM_PE         = 4,
    parameter WEIGHT_WIDTH   = 8,       // INT8 量化權重
    parameter ACTIVATION_WIDTH = 8,     // INT8 量化激活
    parameter FIFO_DEPTH     = 1024
)(
    // 時鐘與復位
    input  wire                         clk,
    input  wire                         rst_n,
    
    // AXI4-Stream 輸入介面 (來自 ISP)
    input  wire [DATA_WIDTH-1:0]        s_axis_tdata,
    input  wire                         s_axis_tvalid,
    output wire                         s_axis_tready,
    input  wire                         s_axis_tlast,
    input  wire                         s_axis_tuser,
    
    // AXI4-Stream 輸出介面 (推論結果)
    output wire [DATA_WIDTH-1:0]        m_axis_tdata,
    output wire                         m_axis_tvalid,
    input  wire                         m_axis_tready,
    output wire                         m_axis_tlast,
    output wire                         m_axis_tuser,
    
    // 模型控制介面
    input  wire [31:0]                  model_id,
    input  wire                         load_model,
    output wire                         model_ready,
    
    // 狀態信號
    output wire                         npu_busy,
    output wire                         inference_done,
    output wire [31:0]                  performance_counter,
    output wire                         error_flag
);

// 蒸餾學生模型支援
reg [31:0] student_model_params [0:15];
reg [2:0] current_model_type;
reg [31:0] distillation_config;

// 學生模型類型定義
localparam MODEL_MOBILENETV3_SCENE = 3'b001;  // MobileNetV3 場景檢測
localparam MODEL_YOLOV5N_OBJECT    = 3'b010;  // YOLOv5n 物件檢測
localparam MODEL_EFFICIENTNET_B0   = 3'b011;  // EfficientNet-B0 分類

// 知識蒸餾模型載入控制
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_model_type <= MODEL_MOBILENETV3_SCENE;
        model_ready <= 1'b0;
        distillation_config <= 32'h0;
    end else if (load_model) begin
        case (model_id)
            32'h1001: begin // MobileNetV3 場景檢測 (從 ConvNeXt-Base 蒸餾)
                current_model_type <= MODEL_MOBILENETV3_SCENE;
                student_model_params[0] <= 32'd20000000;  // 20M 參數
                student_model_params[1] <= 32'd923;       // 92.3% 準確率 (*1000)
                student_model_params[2] <= 32'd18;        // 18ms 推論時間
                student_model_params[3] <= 32'd850;       // 850mW 功耗
                distillation_config <= {8'h40, 8'h70, 16'h0000}; // temp=4.0, alpha=0.7
            end
            32'h1002: begin // YOLOv5n 物件檢測
                current_model_type <= MODEL_YOLOV5N_OBJECT;
                student_model_params[0] <= 32'd1900000;   // 1.9M 參數
                student_model_params[1] <= 32'd845;       // 84.5% 準確率
                student_model_params[2] <= 32'd25;        // 25ms 推論時間
                student_model_params[3] <= 32'd1200;      // 1200mW 功耗
                distillation_config <= {8'h35, 8'h60, 16'h0000}; // temp=3.5, alpha=0.6
            end
            default: begin
                current_model_type <= MODEL_MOBILENETV3_SCENE;
                distillation_config <= {8'h40, 8'h70, 16'h0000};
            end
        endcase
        model_ready <= 1'b1;
    end
end

endmodule
