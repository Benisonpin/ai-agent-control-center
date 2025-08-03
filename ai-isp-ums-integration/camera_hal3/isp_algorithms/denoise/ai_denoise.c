#include <stdint.h>
#include <math.h>
#include <string.h>

// AI 輔助的降噪演算法
// 結合傳統 BM3D 和 CNN 特徵

typedef struct {
    float* noise_model;      // AI 噪聲模型參數
    float noise_level;       // 估計的噪聲水平
    int patch_size;          // 塊大小
    float threshold;         // 相似度閾值
} ai_denoise_params_t;

// 噪聲估計（使用 MAD - Median Absolute Deviation）
float estimate_noise_level(uint8_t* image, int width, int height) {
    // 使用高頻小波係數估計噪聲
    float* high_freq = malloc(width * height * sizeof(float));
    
    // 簡化的高通濾波
    for (int y = 1; y < height - 1; y++) {
        for (int x = 1; x < width - 1; x++) {
            int idx = y * width + x;
            high_freq[idx] = -image[idx-width-1] - 2*image[idx-width] - image[idx-width+1]
                            -2*image[idx-1] + 8*image[idx] - 2*image[idx+1]
                            -image[idx+width-1] - 2*image[idx+width] - image[idx+width+1];
            high_freq[idx] = fabsf(high_freq[idx]) / 16.0f;
        }
    }
    
    // 計算 MAD
    float median = calculate_median(high_freq, width * height);
    float mad = calculate_mad(high_freq, median, width * height);
    
    free(high_freq);
    return mad * 1.4826f;  // MAD to standard deviation
}

// 非局部均值降噪 with AI 權重
void ai_nlm_denoise(uint8_t* noisy, uint8_t* denoised, 
                   int width, int height, ai_denoise_params_t* params) {
    int search_window = 21;
    int patch_radius = params->patch_size / 2;
    float h = params->threshold * params->noise_level;
    float h2 = h * h;
    
    for (int y = search_window/2; y < height - search_window/2; y++) {
        for (int x = search_window/2; x < width - search_window/2; x++) {
            float sum_weights = 0.0f;
            float sum_pixels = 0.0f;
            
            // 搜索相似塊
            for (int dy = -search_window/2; dy <= search_window/2; dy++) {
                for (int dx = -search_window/2; dx <= search_window/2; dx++) {
                    if (dx == 0 && dy == 0) continue;
                    
                    // 計算塊距離
                    float dist = 0.0f;
                    for (int py = -patch_radius; py <= patch_radius; py++) {
                        for (int px = -patch_radius; px <= patch_radius; px++) {
                            int idx1 = (y + py) * width + (x + px);
                            int idx2 = (y + dy + py) * width + (x + dx + px);
                            float diff = noisy[idx1] - noisy[idx2];
                            dist += diff * diff;
                        }
                    }
                    
                    // AI 調整的權重
                    float ai_factor = get_ai_weight(params->noise_model, x, y, dx, dy);
                    float weight = expf(-dist / h2) * ai_factor;
                    
                    sum_weights += weight;
                    sum_pixels += weight * noisy[(y + dy) * width + (x + dx)];
                }
            }
            
            // 包含中心像素
            sum_weights += 1.0f;
            sum_pixels += noisy[y * width + x];
            
            denoised[y * width + x] = (uint8_t)(sum_pixels / sum_weights);
        }
    }
}

// 簡化的 AI 權重計算
float get_ai_weight(float* model, int x, int y, int dx, int dy) {
    // 實際應用中，這裡會調用 NPU 進行推理
    // 現在使用簡化的計算
    float spatial_weight = expf(-(dx*dx + dy*dy) / 100.0f);
    return spatial_weight;
}
