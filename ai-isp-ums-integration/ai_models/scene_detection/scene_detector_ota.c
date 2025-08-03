#include <stdio.h>
#include <string.h>
#include "../../hal/inc/ota_hal_integration.h"

// 場景檢測模型版本信息
typedef struct {
    char version[16];
    uint32_t model_size;
    uint8_t* model_data;
} scene_model_t;

static scene_model_t g_current_model = {
    .version = "2.0.0",
    .model_size = 4280,
    .model_data = NULL
};

// OTA 更新回調
int scene_detector_ota_update(const char* new_version, uint8_t* new_model_data, uint32_t size) {
    printf("[Scene Detector] Updating from %s to %s\n", g_current_model.version, new_version);
    
    // 熱插拔更新
    scene_model_t new_model = {
        .model_size = size,
        .model_data = new_model_data
    };
    strcpy(new_model.version, new_version);
    
    // 原子切換
    scene_model_t old_model = g_current_model;
    g_current_model = new_model;
    
    // 釋放舊模型（如果需要）
    // free(old_model.model_data);
    
    printf("[Scene Detector] Successfully updated to version %s\n", new_version);
    return 0;
}

// 獲取當前版本
const char* scene_detector_get_version(void) {
    return g_current_model.version;
}
