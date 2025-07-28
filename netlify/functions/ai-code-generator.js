exports.handler = async (event, context) => {
    // 只接受 POST 請求
    if (event.httpMethod !== 'POST') {
        return {
            statusCode: 405,
            body: JSON.stringify({ error: 'Method not allowed' })
        };
    }

    try {
        const { description, language, type } = JSON.parse(event.body);

        // 模擬 AI 生成程式碼
        const codeTemplates = {
            javascript: {
                function: `// ${description}
function processData(input) {
    // AI 生成的函數
    if (!input || !Array.isArray(input)) {
        throw new Error('Invalid input: expected array');
    }
    
    const result = input
        .filter(item => item != null)
        .map(item => ({
            ...item,
            processed: true,
            timestamp: new Date().toISOString()
        }));
    
    return {
        success: true,
        data: result,
        count: result.length
    };
}

module.exports = processData;`,
                api: `// ${description}
const express = require('express');
const router = express.Router();

router.post('/process', async (req, res) => {
    try {
        const { data } = req.body;
        
        // AI 生成的 API 邏輯
        const processed = data.map(item => ({
            id: item.id,
            result: item.value * 2,
            status: 'completed'
        }));
        
        res.json({
            success: true,
            results: processed
        });
    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});

module.exports = router;`
            },
            python: {
                function: `# ${description}
def process_data(input_data):
    """AI 生成的 Python 函數"""
    if not isinstance(input_data, list):
        raise ValueError("Input must be a list")
    
    # 處理邏輯
    result = []
    for item in input_data:
        if item is not None:
            processed_item = {
                'original': item,
                'processed': item * 2 if isinstance(item, (int, float)) else str(item).upper(),
                'timestamp': datetime.now().isoformat()
            }
            result.append(processed_item)
    
    return {
        'success': True,
        'data': result,
        'count': len(result)
    }`,
                class: `# ${description}
class DataProcessor:
    """AI 生成的 Python 類別"""
    
    def __init__(self):
        self.processed_count = 0
        self.errors = []
    
    def process(self, data):
        """處理數據"""
        try:
            result = self._validate_and_transform(data)
            self.processed_count += 1
            return result
        except Exception as e:
            self.errors.append(str(e))
            raise
    
    def _validate_and_transform(self, data):
        """驗證並轉換數據"""
        if not data:
            raise ValueError("Data cannot be empty")
        
        return {
            'original': data,
            'transformed': str(data).upper(),
            'metadata': {
                'processed_at': datetime.now().isoformat(),
                'processor_id': id(self)
            }
        }`
            },
            c: {
                function: `// ${description}
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int id;
    double value;
    char status[50];
} DataItem;

// AI 生成的 C 函數
int process_data(DataItem* input, int size, DataItem** output) {
    if (input == NULL || size <= 0) {
        return -1; // 錯誤：無效輸入
    }
    
    // 分配記憶體
    *output = (DataItem*)malloc(size * sizeof(DataItem));
    if (*output == NULL) {
        return -2; // 錯誤：記憶體分配失敗
    }
    
    // 處理數據
    for (int i = 0; i < size; i++) {
        (*output)[i].id = input[i].id;
        (*output)[i].value = input[i].value * 2.0;
        strcpy((*output)[i].status, "processed");
    }
    
    return size; // 返回處理的項目數
}`,
                embedded: `// ${description}
// 嵌入式系統程式碼
#include <stdint.h>

#define BUFFER_SIZE 128
#define SUCCESS 0
#define ERROR -1

typedef struct {
    uint8_t buffer[BUFFER_SIZE];
    uint16_t length;
    uint32_t timestamp;
} DataPacket;

// AI 生成的嵌入式處理函數
int8_t process_sensor_data(DataPacket* packet) {
    if (packet == NULL || packet->length == 0) {
        return ERROR;
    }
    
    // 數據處理
    uint16_t checksum = 0;
    for (uint16_t i = 0; i < packet->length; i++) {
        packet->buffer[i] = packet->buffer[i] ^ 0xAA; // 簡單加密
        checksum += packet->buffer[i];
    }
    
    // 添加檢查碼
    if (packet->length < BUFFER_SIZE - 2) {
        packet->buffer[packet->length] = (checksum >> 8) & 0xFF;
        packet->buffer[packet->length + 1] = checksum & 0xFF;
        packet->length += 2;
    }
    
    return SUCCESS;
}`
            },
            verilog: {
                module: `// ${description}
// AI 生成的 Verilog 模組
module data_processor #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire [DATA_WIDTH-1:0] data_in,
    input wire data_valid,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg data_ready,
    output reg busy
);

    // 內部暫存器
    reg [DATA_WIDTH-1:0] buffer;
    reg [2:0] state;
    
    // 狀態定義
    localparam IDLE = 3'b000;
    localparam LOAD = 3'b001;
    localparam PROCESS = 3'b010;
    localparam OUTPUT = 3'b011;
    
    // 狀態機
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            data_out <= 0;
            data_ready <= 0;
            busy <= 0;
            buffer <= 0;
        end else begin
            case (state)
                IDLE: begin
                    data_ready <= 0;
                    if (enable && data_valid) begin
                        buffer <= data_in;
                        busy <= 1;
                        state <= LOAD;
                    end
                end
                
                LOAD: begin
                    state <= PROCESS;
                end
                
                PROCESS: begin
                    // AI 邏輯：將數據乘以 2
                    data_out <= buffer << 1;
                    state <= OUTPUT;
                end
                
                OUTPUT: begin
                    data_ready <= 1;
                    busy <= 0;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule`,
                testbench: `// ${description} - Testbench
module tb_data_processor;
    reg clk;
    reg rst_n;
    reg enable;
    reg [31:0] data_in;
    reg data_valid;
    wire [31:0] data_out;
    wire data_ready;
    wire busy;
    
    // 實例化待測模組
    data_processor dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .data_in(data_in),
        .data_valid(data_valid),
        .data_out(data_out),
        .data_ready(data_ready),
        .busy(busy)
    );
    
    // 時鐘生成
    always #5 clk = ~clk;
    
    // 測試序列
    initial begin
        // 初始化
        clk = 0;
        rst_n = 0;
        enable = 0;
        data_in = 0;
        data_valid = 0;
        
        // 重置
        #20 rst_n = 1;
        
        // 測試案例 1
        #10 enable = 1;
        data_in = 32'h00000010;
        data_valid = 1;
        #10 data_valid = 0;
        
        // 等待結果
        wait(data_ready);
        $display("Input: %h, Output: %h", 32'h00000010, data_out);
        
        // 更多測試...
        #100 $finish;
    end
endmodule`
            }
        };

        // 生成程式碼
        const selectedLanguage = codeTemplates[language] || codeTemplates.javascript;
        const selectedType = type || (language === 'verilog' ? 'module' : 'function');
        const generatedCode = selectedLanguage[selectedType] || selectedLanguage[Object.keys(selectedLanguage)[0]];

        // 生成建議
        const suggestions = [
            '添加錯誤處理機制',
            '增加輸入驗證',
            '優化效能',
            '添加單元測試',
            '加入詳細註解'
        ];

        // 回傳結果
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: true,
                code: generatedCode,
                language: language,
                type: selectedType,
                suggestions: suggestions,
                metadata: {
                    generatedAt: new Date().toISOString(),
                    version: '1.0.0',
                    model: 'CTE-AI-CodeGen-v1'
                }
            })
        };
    } catch (error) {
        return {
            statusCode: 400,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: false,
                error: error.message
            })
        };
    }
};