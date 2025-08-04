#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"

// RTOS 核心配置
#define RTOS_TICK_RATE_HZ    1000
#define RTOS_MAX_PRIORITIES  32
#define RTOS_MIN_STACK_SIZE  512

// AI ISP 任務優先級定義
#define PRIORITY_CAMERA_CAPTURE   (tskIDLE_PRIORITY + 28)
#define PRIORITY_ISP_PIPELINE     (tskIDLE_PRIORITY + 26)
#define PRIORITY_AI_INFERENCE     (tskIDLE_PRIORITY + 24)
#define PRIORITY_DISPLAY_OUTPUT   (tskIDLE_PRIORITY + 22)
#define PRIORITY_SYSTEM_MONITOR   (tskIDLE_PRIORITY + 20)

// 系統任務結構
typedef struct {
    TaskHandle_t camera_task;
    TaskHandle_t isp_task;
    TaskHandle_t ai_task;
    TaskHandle_t display_task;
    TaskHandle_t monitor_task;
    
    // 任務間通訊
    QueueHandle_t frame_queue;
    QueueHandle_t result_queue;
    SemaphoreHandle_t frame_ready_sem;
    SemaphoreHandle_t processing_mutex;
    
    // 共享資源
    void* shared_frame_buffer;
    void* ai_model_buffer;
    
} rtos_system_t;

static rtos_system_t g_system;

// Camera Capture Task - 最高優先級
void vCameraCaptureTask(void* pvParameters) {
    TickType_t xLastWakeTime = xTaskGetTickCount();
    const TickType_t xFrequency = pdMS_TO_TICKS(33); // 30 FPS
    
    camera_handle_t* camera = (camera_handle_t*)pvParameters;
    frame_buffer_t frame;
    
    for (;;) {
        // 等待下一個捕獲週期
        vTaskDelayUntil(&xLastWakeTime, xFrequency);
        
        // 捕獲 RAW 影像
        if (camera_capture_frame(camera, &frame) == 0) {
            // 將 frame 加入佇列
            if (xQueueSend(g_system.frame_queue, &frame, 0) == pdTRUE) {
                // 通知 ISP 任務
                xSemaphoreGive(g_system.frame_ready_sem);
            } else {
                // 佇列滿，丟棄 frame
                frame_buffer_release(&frame);
            }
        }
        
        // 更新統計
        camera->stats.frames_captured++;
    }
}

// ISP Pipeline Task
void vISPPipelineTask(void* pvParameters) {
    isp_pipeline_t* pipeline = (isp_pipeline_t*)pvParameters;
    frame_buffer_t raw_frame, processed_frame;
    
    for (;;) {
        // 等待新的 frame
        if (xSemaphoreTake(g_system.frame_ready_sem, portMAX_DELAY) == pdTRUE) {
            // 從佇列取得 raw frame
            if (xQueueReceive(g_system.frame_queue, &raw_frame, 0) == pdTRUE) {
                // 取得處理鎖
                xSemaphoreTake(g_system.processing_mutex, portMAX_DELAY);
                
                // ISP 處理
                isp_process_frame(pipeline, &raw_frame, &processed_frame);
                
                // 釋放鎖
                xSemaphoreGive(g_system.processing_mutex);
                
                // 將處理後的 frame 送給 AI
                xQueueSend(g_system.result_queue, &processed_frame, 0);
                
                // 釋放 raw frame
                frame_buffer_release(&raw_frame);
            }
        }
    }
}

// AI Inference Task
void vAIInferenceTask(void* pvParameters) {
    ai_engine_t* ai_engine = (ai_engine_t*)pvParameters;
    frame_buffer_t processed_frame;
    ai_result_t inference_result;
    
    for (;;) {
        // 從 ISP 接收處理後的 frame
        if (xQueueReceive(g_system.result_queue, &processed_frame, portMAX_DELAY) == pdTRUE) {
            // 執行 AI 推理
            ai_engine_inference(ai_engine, &processed_frame, &inference_result);
            
            // 更新 ISP 參數（基於 AI 結果）
            if (inference_result.scene_changed) {
                isp_update_scene_params(inference_result.scene_type);
            }
            
            // 顯示結果
            display_show_frame_with_ai(&processed_frame, &inference_result);
            
            // 釋放 frame
            frame_buffer_release(&processed_frame);
        }
    }
}

// System Monitor Task
void vSystemMonitorTask(void* pvParameters) {
    system_stats_t stats;
    const TickType_t xDelay = pdMS_TO_TICKS(1000); // 每秒更新
    
    for (;;) {
        vTaskDelay(xDelay);
        
        // 收集系統統計
        stats.cpu_usage = get_cpu_usage();
        stats.memory_free = xPortGetFreeHeapSize();
        stats.fps = calculate_current_fps();
        stats.temperature = read_temperature_sensor();
        
        // 檢查系統健康
        if (stats.temperature > TEMP_THRESHOLD_HIGH) {
            // 降低效能以降溫
            reduce_system_performance();
        }
        
        // 更新看門狗
        watchdog_feed();
        
        // 記錄統計
        log_system_stats(&stats);
    }
}

// RTOS 系統初始化
int rtos_system_init(void) {
    // 建立佇列
    g_system.frame_queue = xQueueCreate(3, sizeof(frame_buffer_t));
    g_system.result_queue = xQueueCreate(2, sizeof(frame_buffer_t));
    
    // 建立信號量
    g_system.frame_ready_sem = xSemaphoreCreateBinary();
    g_system.processing_mutex = xSemaphoreCreateMutex();
    
    // 分配共享記憶體（使用 UMS）
    g_system.shared_frame_buffer = ums_alloc_shared(64 * 1024 * 1024);
    g_system.ai_model_buffer = ums_alloc_locked(16 * 1024 * 1024);
    
    // 初始化硬體
    camera_handle_t* camera = camera_init();
    isp_pipeline_t* pipeline = isp_pipeline_create();
    ai_engine_t* ai_engine = ai_engine_create();
    
    // 建立任務
    xTaskCreate(vCameraCaptureTask, "Camera", 2048, camera, 
                PRIORITY_CAMERA_CAPTURE, &g_system.camera_task);
    
    xTaskCreate(vISPPipelineTask, "ISP", 4096, pipeline,
                PRIORITY_ISP_PIPELINE, &g_system.isp_task);
    
    xTaskCreate(vAIInferenceTask, "AI", 8192, ai_engine,
                PRIORITY_AI_INFERENCE, &g_system.ai_task);
    
    xTaskCreate(vSystemMonitorTask, "Monitor", 1024, NULL,
                PRIORITY_SYSTEM_MONITOR, &g_system.monitor_task);
    
    // 啟動排程器
    vTaskStartScheduler();
    
    return 0;
}
