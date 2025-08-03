#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdint.h>  // 加入這個標頭檔

// 場景類型定義
typedef enum {
    SCENE_AUTO = 0,
    SCENE_PORTRAIT,
    SCENE_LANDSCAPE,
    SCENE_NIGHT,
    SCENE_SUNSET,
    SCENE_INDOOR,
    SCENE_FOOD,
    SCENE_TEXT,
    SCENE_MACRO,
    SCENE_SPORTS,
    SCENE_MAX
} scene_type_t;

// 場景檢測器結構
typedef struct {
    int input_width;
    int input_height;
    float confidence_threshold;
} scene_detector_t;

// 場景名稱
static const char* scene_names[] = {
    "Auto", "Portrait", "Landscape", "Night", "Sunset",
    "Indoor", "Food", "Text", "Macro", "Sports"
};

// 建立場景檢測器
scene_detector_t* create_scene_detector() {
    scene_detector_t* detector = malloc(sizeof(scene_detector_t));
    detector->input_width = 224;
    detector->input_height = 224;
    detector->confidence_threshold = 0.7f;
    
    // 初始化隨機數（模擬用）
    srand(time(NULL));
    
    return detector;
}

// 模擬場景檢測
scene_type_t detect_scene(scene_detector_t* detector, 
                         uint8_t* image, int width, int height,
                         float* confidence) {
    // 實際應用中這裡會呼叫 AI 模型
    // 現在使用簡單的規則模擬
    
    // 計算圖像統計資訊
    long sum = 0;
    int pixels = width * height;
    
    for (int i = 0; i < pixels * 3; i += 3) {
        sum += image[i] + image[i+1] + image[i+2];
    }
    
    float avg_brightness = sum / (float)(pixels * 3);
    
    // 基於亮度的簡單場景判斷
    scene_type_t scene;
    
    if (avg_brightness < 50) {
        scene = SCENE_NIGHT;
        *confidence = 0.85f;
    } else if (avg_brightness > 200) {
        scene = SCENE_SUNSET;
        *confidence = 0.75f;
    } else {
        // 隨機選擇其他場景（模擬）
        scene = (rand() % (SCENE_MAX - 3)) + 1;
        *confidence = 0.7f + (rand() % 30) / 100.0f;
    }
    
    printf("Scene detected: %s (confidence: %.2f)\n", 
           scene_names[scene], *confidence);
    
    return scene;
}

// 根據場景獲取 ISP 參數
void get_scene_isp_params(scene_type_t scene, float* params) {
    // params[0]: exposure_compensation
    // params[1]: contrast
    // params[2]: saturation
    // params[3]: sharpness
    
    switch (scene) {
        case SCENE_PORTRAIT:
            params[0] = 0.3f;
            params[1] = 0.9f;
            params[2] = 0.95f;
            params[3] = 0.7f;
            break;
            
        case SCENE_LANDSCAPE:
            params[0] = 0.0f;
            params[1] = 1.2f;
            params[2] = 1.15f;
            params[3] = 1.2f;
            break;
            
        case SCENE_NIGHT:
            params[0] = 0.7f;
            params[1] = 1.1f;
            params[2] = 0.9f;
            params[3] = 0.8f;
            break;
            
        default:
            params[0] = 0.0f;
            params[1] = 1.0f;
            params[2] = 1.0f;
            params[3] = 1.0f;
            break;
    }
}

// 釋放檢測器
void destroy_scene_detector(scene_detector_t* detector) {
    free(detector);
}
