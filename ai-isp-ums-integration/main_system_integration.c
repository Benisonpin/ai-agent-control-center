#include "FreeRTOS.h"
#include "task.h"
#include "rtos/kernel/core/rtos_core.h"
#include "rtos/middleware/ai_framework/ai_agent_framework.h"
#include "rtos/middleware/vision_pipeline/vision_pipeline.h"

// 系統配置
#define SYSTEM_STACK_SIZE    (64 * 1024)
#define HEAP_SIZE           (256 * 1024 * 1024)  // 256MB

// 全域系統上下文
typedef struct {
    // RTOS
    rtos_system_t* rtos;
    
    // HAL
    hal_manager_t* hal;
    
    // AI Framework
    ai_agent_manager_t* ai_manager;
    
    // Vision Pipeline
    vision_pipeline_t* vision_pipeline;
    
    // 系統狀態
    system_state_t state;
    system_config_t config;
    
} system_context_t;

static system_context_t g_system;

// 系統初始化
int system_init(void) {
    int ret = 0;
    
    printf("=== AI ISP System Initialization ===\n");
    
    // 1. 初始化 HAL
    printf("Initializing HAL...\n");
    g_system.hal = hal_manager_init();
    if (!g_system.hal) {
        printf("HAL initialization failed\n");
        return -1;
    }
    
    // 2. 初始化 UMS
    printf("Initializing UMS...\n");
    ret = ums_init();
    if (ret != 0) {
        printf("UMS initialization failed\n");
        return ret;
    }
    
    // 3. 初始化 AI Framework
    printf("Initializing AI Framework...\n");
    ret = ai_agent_framework_init();
    if (ret != 0) {
        printf("AI Framework initialization failed\n");
        return ret;
    }
    
    // 4. 建立 Vision Pipeline
    printf("Creating Vision Pipeline...\n");
    g_system.vision_pipeline = vision_pipeline_create(g_system.hal);
    if (!g_system.vision_pipeline) {
        printf("Vision Pipeline creation failed\n");
        return -1;
    }
    
    // 5. 初始化 RTOS
    printf("Initializing RTOS...\n");
    ret = rtos_system_init();
    if (ret != 0) {
        printf("RTOS initialization failed\n");
        return ret;
    }
    
    printf("System initialization completed successfully\n");
    
    return 0;
}

// 主函數
int main(void) {
    // 硬體初始化
    hardware_init();
    
    // 系統初始化
    if (system_init() != 0) {
        printf("System initialization failed\n");
        return -1;
    }
    
    // 啟動 RTOS 排程器
    printf("Starting RTOS scheduler...\n");
    vTaskStartScheduler();
    
    // 不應該到達這裡
    printf("Error: RTOS scheduler returned\n");
    return -1;
}

// FreeRTOS 鉤子函數
void vApplicationStackOverflowHook(TaskHandle_t xTask, char *pcTaskName) {
    printf("Stack overflow in task: %s\n", pcTaskName);
    while(1);
}

void vApplicationMallocFailedHook(void) {
    printf("Memory allocation failed\n");
    while(1);
}

void vApplicationIdleHook(void) {
    // 進入低功耗模式
    enter_low_power_mode();
}
