// netlify/functions/file-viewer.js
exports.handler = async (event, context) => {
    const { filename, path } = JSON.parse(event.body || '{}');
    
    // 模擬檔案內容
    const fileContents = {
        'vision_task.c': `/* Vision Task - RTOS Implementation */
#include "FreeRTOS.h"
#include "task.h"
#include "vision_api.h"

void visionTask(void *pvParameters) {
    VisionConfig_t config = {
        .resolution = RESOLUTION_4K,
        .fps = 30,
        .pipeline = PIPELINE_AI_ISP
    };
    
    while(1) {
        // Process frame
        processFrame(&config);
        vTaskDelay(pdMS_TO_TICKS(33));
    }
}`,
        'ai_accelerator_top.v': `// AI Accelerator Top Module
module ai_accelerator_top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out
);
    // Implementation...
endmodule`,
        // 更多檔案內容...
    };
    
    return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            filename: filename,
            content: fileContents[filename] || '// File not found',
            language: filename.endsWith('.c') ? 'c' : 
                     filename.endsWith('.v') ? 'verilog' : 
                     filename.endsWith('.py') ? 'python' : 'text'
        })
    };
};
