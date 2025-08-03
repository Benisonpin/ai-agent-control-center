#include "ai_agent_framework.h"
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "timers.h"

// AI Agent 類型
typedef enum {
    AGENT_SCENE_DETECTOR,
    AGENT_FACE_DETECTOR,
    AGENT_OBJECT_TRACKER,
    AGENT_IMAGE_ENHANCER,
    AGENT_AUTO_EXPOSURE,
    AGENT_AUTO_FOCUS,
    AGENT_MAX
} ai_agent_type_t;

// AI Agent 基礎結構
typedef struct ai_agent {
    ai_agent_type_t type;
    char name[32];
    uint32_t priority;
    bool enabled;
    
    // 任務管理
    TaskHandle_t task_handle;
    QueueHandle_t input_queue;
    QueueHandle_t output_queue;
    
    // 模型資訊
    void* model_data;
    uint32_t model_size;
    npu_hal_t* npu;
    
    // 回調函數
    void (*process)(struct ai_agent* agent, void* input, void* output);
    void (*on_result)(struct ai_agent* agent, void* result);
    
    // 統計
    struct {
        uint32_t frames_processed;
        uint32_t total_inference_time_ms;
        uint32_t errors;
    } stats;
    
} ai_agent_t;

// AI Agent 管理器
typedef struct {
    ai_agent_t* agents[AGENT_MAX];
    uint32_t num_agents;
    
    // 協調器
    TaskHandle_t coordinator_task;
    QueueHandle_t event_queue;
    
    // 資源管理
    SemaphoreHandle_t npu_mutex;
    uint32_t npu_usage_percent;
    
} ai_agent_manager_t;

static ai_agent_manager_t g_ai_manager;

// Scene Detector Agent
void scene_detector_process(ai_agent_t* agent, void* input, void* output) {
    frame_buffer_t* frame = (frame_buffer_t*)input;
    scene_result_t* result = (scene_result_t*)output;
    
    // 預處理：縮放到模型輸入大小
    void* resized = resize_image(frame->data, frame->width, frame->height,
                                224, 224);
    
    // NPU 推理
    xSemaphoreTake(g_ai_manager.npu_mutex, portMAX_DELAY);
    agent->npu->inference(SCENE_MODEL_ID, resized, result);
    xSemaphoreGive(g_ai_manager.npu_mutex);
    
    // 後處理：選擇最高信心度的場景
    result->scene_type = get_max_confidence_scene(result->confidences);
    
    // 更新統計
    agent->stats.frames_processed++;
    
    free(resized);
}

// Face Detector Agent
void face_detector_process(ai_agent_t* agent, void* input, void* output) {
    frame_buffer_t* frame = (frame_buffer_t*)input;
    face_result_t* result = (face_result_t*)output;
    
    // 轉換到適合人臉檢測的格式
    void* preprocessed = preprocess_for_face_detection(frame);
    
    // NPU 推理
    xSemaphoreTake(g_ai_manager.npu_mutex, portMAX_DELAY);
    agent->npu->inference(FACE_MODEL_ID, preprocessed, result);
    xSemaphoreGive(g_ai_manager.npu_mutex);
    
    // 後處理：NMS 和座標轉換
    apply_nms_to_faces(result);
    convert_face_coordinates(result, frame->width, frame->height);
    
    // 如果檢測到人臉，觸發美顏
    if (result->num_faces > 0 && agent->on_result) {
        agent->on_result(agent, result);
    }
    
    free(preprocessed);
}

// Auto Exposure Agent
void auto_exposure_process(ai_agent_t* agent, void* input, void* output) {
    frame_stats_t* stats = (frame_stats_t*)input;
    ae_result_t* result = (ae_result_t*)output;
    
    // AI 輔助的自動曝光
    // 1. 分析直方圖
    histogram_t hist;
    calculate_histogram(stats->luminance_data, &hist);
    
    // 2. 使用 AI 模型預測最佳曝光
    ae_input_t ae_input = {
        .histogram = hist,
        .scene_type = stats->scene_type,
        .face_regions = stats->face_regions,
        .num_faces = stats->num_faces
    };
    
    xSemaphoreTake(g_ai_manager.npu_mutex, portMAX_DELAY);
    agent->npu->inference(AE_MODEL_ID, &ae_input, result);
    xSemaphoreGive(g_ai_manager.npu_mutex);
    
    // 3. 平滑調整
    smooth_exposure_transition(result);
}

// AI Agent 任務函數
void vAIAgentTask(void* pvParameters) {
    ai_agent_t* agent = (ai_agent_t*)pvParameters;
    void* input_buffer = pvPortMalloc(MAX_INPUT_SIZE);
    void* output_buffer = pvPortMalloc(MAX_OUTPUT_SIZE);
    
    for (;;) {
        // 等待輸入
        if (xQueueReceive(agent->input_queue, input_buffer, portMAX_DELAY) == pdTRUE) {
            // 處理
            TickType_t start = xTaskGetTickCount();
            
            agent->process(agent, input_buffer, output_buffer);
            
            TickType_t end = xTaskGetTickCount();
            agent->stats.total_inference_time_ms += (end - start);
            
            // 發送結果
            xQueueSend(agent->output_queue, output_buffer, 0);
        }
    }
}

// AI Coordinator Task - 協調多個 AI Agent
void vAICoordinatorTask(void* pvParameters) {
    ai_event_t event;
    
    for (;;) {
        if (xQueueReceive(g_ai_manager.event_queue, &event, portMAX_DELAY) == pdTRUE) {
            switch (event.type) {
                case EVENT_NEW_FRAME:
                    // 分發 frame 給需要的 agents
                    distribute_frame_to_agents(event.frame);
                    break;
                    
                case EVENT_SCENE_CHANGED:
                    // 場景變化，調整其他 agents
                    adjust_agents_for_scene(event.scene_type);
                    break;
                    
                case EVENT_FACE_DETECTED:
                    // 人臉檢測，啟動追蹤
                    enable_face_tracking(event.face_info);
                    break;
                    
                case EVENT_LOW_LIGHT:
                    // 低光環境，調整策略
                    switch_to_night_mode();
                    break;
            }
        }
    }
}

// 建立 AI Agent
ai_agent_t* create_ai_agent(ai_agent_type_t type, const char* name, uint32_t priority) {
    ai_agent_t* agent = pvPortMalloc(sizeof(ai_agent_t));
    
    agent->type = type;
    strncpy(agent->name, name, sizeof(agent->name) - 1);
    agent->priority = priority;
    agent->enabled = true;
    
    // 建立佇列
    agent->input_queue = xQueueCreate(2, MAX_INPUT_SIZE);
    agent->output_queue = xQueueCreate(2, MAX_OUTPUT_SIZE);
    
    // 設定處理函數
    switch (type) {
        case AGENT_SCENE_DETECTOR:
            agent->process = scene_detector_process;
            break;
        case AGENT_FACE_DETECTOR:
            agent->process = face_detector_process;
            break;
        case AGENT_AUTO_EXPOSURE:
            agent->process = auto_exposure_process;
            break;
        // ... 其他 agents
    }
    
    // 建立任務
    xTaskCreate(vAIAgentTask, name, 4096, agent, priority, &agent->task_handle);
    
    return agent;
}

// 初始化 AI Agent 框架
int ai_agent_framework_init(void) {
    // 建立 NPU 互斥鎖
    g_ai_manager.npu_mutex = xSemaphoreCreateMutex();
    
    // 建立事件佇列
    g_ai_manager.event_queue = xQueueCreate(10, sizeof(ai_event_t));
    
    // 建立協調器任務
    xTaskCreate(vAICoordinatorTask, "AICoordinator", 2048, NULL,
                tskIDLE_PRIORITY + 25, &g_ai_manager.coordinator_task);
    
    // 建立各個 AI Agents
    g_ai_manager.agents[AGENT_SCENE_DETECTOR] = 
        create_ai_agent(AGENT_SCENE_DETECTOR, "SceneDetector", tskIDLE_PRIORITY + 23);
    
    g_ai_manager.agents[AGENT_FACE_DETECTOR] = 
        create_ai_agent(AGENT_FACE_DETECTOR, "FaceDetector", tskIDLE_PRIORITY + 22);
    
    g_ai_manager.agents[AGENT_AUTO_EXPOSURE] = 
        create_ai_agent(AGENT_AUTO_EXPOSURE, "AutoExposure", tskIDLE_PRIORITY + 21);
    
    g_ai_manager.num_agents = 3;
    
    return 0;
}

// 動態調整 AI Agents
void adjust_ai_agents_for_performance(void) {
    float cpu_usage = get_cpu_usage();
    float temp = get_temperature();
    
    if (cpu_usage > 80.0f || temp > 70.0f) {
        // 降低 AI 頻率
        for (int i = 0; i < g_ai_manager.num_agents; i++) {
            if (g_ai_manager.agents[i]->type != AGENT_SCENE_DETECTOR) {
                // 降低非關鍵 agent 的優先級
                vTaskPrioritySet(g_ai_manager.agents[i]->task_handle,
                               g_ai_manager.agents[i]->priority - 2);
            }
        }
    }
}
