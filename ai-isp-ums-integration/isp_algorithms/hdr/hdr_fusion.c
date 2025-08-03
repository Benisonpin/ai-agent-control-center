#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// HDR 融合演算法 - 簡化實作

typedef struct {
    uint16_t* short_exposure;
    uint16_t* medium_exposure;
    uint16_t* long_exposure;
    int width;
    int height;
    int bit_depth;
} hdr_input_t;

// 簡單的曝光融合
void simple_hdr_fusion(hdr_input_t* input, uint16_t* output) {
    int size = input->width * input->height;
    
    for (int i = 0; i < size; i++) {
        // 權重計算：根據像素值選擇最佳曝光
        float w_short = 0.0f, w_medium = 0.0f, w_long = 0.0f;
        
        uint16_t val_short = input->short_exposure[i];
        uint16_t val_medium = input->medium_exposure[i];
        uint16_t val_long = input->long_exposure[i];
        
        // 短曝光：用於高光區域
        if (val_short < 60000) {
            w_short = 1.0f - (val_short / 65535.0f);
        }
        
        // 中曝光：用於中間調
        float mid_point = 32768.0f;
        w_medium = expf(-powf((val_medium - mid_point) / 16384.0f, 2));
        
        // 長曝光：用於暗部
        if (val_long > 5000) {
            w_long = val_long / 65535.0f;
        }
        
        // 歸一化權重
        float total = w_short + w_medium + w_long;
        if (total > 0) {
            w_short /= total;
            w_medium /= total;
            w_long /= total;
        }
        
        // 融合
        float result = val_short * w_short + 
                      val_medium * w_medium + 
                      val_long * w_long;
        
        // 簡單的色調映射
        result = result / (1 + result / 65535.0f);
        
        output[i] = (uint16_t)(result);
    }
}

// HDR 處理入口
int process_hdr(uint16_t** frames, int num_frames, 
                int width, int height, uint16_t* output) {
    if (num_frames < 3) return -1;
    
    hdr_input_t input = {
        .short_exposure = frames[0],
        .medium_exposure = frames[1],
        .long_exposure = frames[2],
        .width = width,
        .height = height,
        .bit_depth = 16
    };
    
    simple_hdr_fusion(&input, output);
    return 0;
}
