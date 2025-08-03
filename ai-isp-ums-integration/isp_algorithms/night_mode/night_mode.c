#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// 夜景模式 - 多幀降噪簡化實作

typedef struct {
    uint16_t** frames;
    int num_frames;
    int width;
    int height;
    float iso;
} night_mode_input_t;

// 簡單的時域降噪
void temporal_denoise_simple(night_mode_input_t* input, uint16_t* output) {
    int size = input->width * input->height;
    
    // 累加所有幀
    float* accumulated = calloc(size, sizeof(float));
    
    for (int f = 0; f < input->num_frames; f++) {
        for (int i = 0; i < size; i++) {
            accumulated[i] += input->frames[f][i];
        }
    }
    
    // 平均並增強亮度
    float brightness_boost = 1.5f; // 夜景增亮
    
    for (int i = 0; i < size; i++) {
        float avg = accumulated[i] / input->num_frames;
        avg *= brightness_boost;
        
        // 限制範圍
        if (avg > 65535) avg = 65535;
        
        output[i] = (uint16_t)avg;
    }
    
    free(accumulated);
}

// 簡單的空間降噪（3x3 中值濾波）
void spatial_denoise_median(uint16_t* input, uint16_t* output, 
                           int width, int height) {
    for (int y = 1; y < height - 1; y++) {
        for (int x = 1; x < width - 1; x++) {
            // 收集 3x3 鄰域
            uint16_t values[9];
            int idx = 0;
            
            for (int dy = -1; dy <= 1; dy++) {
                for (int dx = -1; dx <= 1; dx++) {
                    values[idx++] = input[(y + dy) * width + (x + dx)];
                }
            }
            
            // 簡單排序找中值
            for (int i = 0; i < 9; i++) {
                for (int j = i + 1; j < 9; j++) {
                    if (values[i] > values[j]) {
                        uint16_t temp = values[i];
                        values[i] = values[j];
                        values[j] = temp;
                    }
                }
            }
            
            output[y * width + x] = values[4]; // 中值
        }
    }
    
    // 複製邊界
    for (int x = 0; x < width; x++) {
        output[x] = input[x];
        output[(height - 1) * width + x] = input[(height - 1) * width + x];
    }
    for (int y = 0; y < height; y++) {
        output[y * width] = input[y * width];
        output[y * width + width - 1] = input[y * width + width - 1];
    }
}

// 夜景模式處理入口
int process_night_mode(uint16_t** frames, int num_frames,
                      int width, int height, float iso, uint16_t* output) {
    night_mode_input_t input = {
        .frames = frames,
        .num_frames = num_frames,
        .width = width,
        .height = height,
        .iso = iso
    };
    
    // 臨時緩衝區
    uint16_t* temp = malloc(width * height * sizeof(uint16_t));
    
    // 1. 時域降噪
    temporal_denoise_simple(&input, temp);
    
    // 2. 空間降噪
    spatial_denoise_median(temp, output, width, height);
    
    free(temp);
    return 0;
}
