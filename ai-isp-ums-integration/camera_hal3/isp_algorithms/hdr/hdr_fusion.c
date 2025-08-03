#include <stdint.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>

// HDR 融合演算法 - 基於曝光融合的多幀 HDR

typedef struct {
    uint16_t* frames[3];    // 短、中、長曝光
    float ev_gaps[3];       // 曝光值差異
    int width;
    int height;
    int bit_depth;
} hdr_context_t;

// 權重圖計算
typedef struct {
    float* contrast;
    float* saturation;
    float* well_exposedness;
} weight_maps_t;

// 計算對比度權重
void calculate_contrast_weight(uint16_t* frame, float* weight, 
                              int width, int height) {
    // 使用 Laplacian 濾波器計算局部對比度
    for (int y = 1; y < height - 1; y++) {
        for (int x = 1; x < width - 1; x++) {
            int idx = y * width + x;
            float laplacian = -4.0f * frame[idx] +
                             frame[idx - 1] + frame[idx + 1] +
                             frame[idx - width] + frame[idx + width];
            weight[idx] = fabsf(laplacian) / 1024.0f;  // 歸一化
        }
    }
}

// 計算飽和度權重
void calculate_saturation_weight(uint16_t* frame, float* weight,
                                int width, int height) {
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            int idx = y * width + x;
            // 簡化計算：使用像素值的標準差
            float mean = frame[idx] / 1024.0f;
            float saturation = fabsf(mean - 0.5f) * 2.0f;
            weight[idx] = powf(saturation, 0.5f);
        }
    }
}

// 計算曝光良好度權重
void calculate_well_exposedness_weight(uint16_t* frame, float* weight,
                                      int width, int height, int bit_depth) {
    float sigma = 0.2f;
    float mean = 0.5f;
    int max_val = (1 << bit_depth) - 1;
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            int idx = y * width + x;
            float normalized = (float)frame[idx] / max_val;
            float diff = normalized - mean;
            weight[idx] = expf(-(diff * diff) / (2 * sigma * sigma));
        }
    }
}

// 多尺度 Laplacian 金字塔融合
typedef struct {
    float** levels;
    int num_levels;
    int* widths;
    int* heights;
} pyramid_t;

// 建立 Gaussian 金字塔
pyramid_t* build_gaussian_pyramid(float* image, int width, int height, int levels) {
    pyramid_t* pyramid = malloc(sizeof(pyramid_t));
    pyramid->num_levels = levels;
    pyramid->levels = malloc(levels * sizeof(float*));
    pyramid->widths = malloc(levels * sizeof(int));
    pyramid->heights = malloc(levels * sizeof(int));
    
    // Level 0 是原始圖像
    pyramid->widths[0] = width;
    pyramid->heights[0] = height;
    pyramid->levels[0] = malloc(width * height * sizeof(float));
    memcpy(pyramid->levels[0], image, width * height * sizeof(float));
    
    // 建立金字塔
    for (int l = 1; l < levels; l++) {
        int prev_w = pyramid->widths[l-1];
        int prev_h = pyramid->heights[l-1];
        pyramid->widths[l] = prev_w / 2;
        pyramid->heights[l] = prev_h / 2;
        
        int new_size = pyramid->widths[l] * pyramid->heights[l];
        pyramid->levels[l] = malloc(new_size * sizeof(float));
        
        // 下採樣 with Gaussian 濾波
        for (int y = 0; y < pyramid->heights[l]; y++) {
            for (int x = 0; x < pyramid->widths[l]; x++) {
                float sum = 0;
                int src_x = x * 2;
                int src_y = y * 2;
                
                // 5x5 Gaussian kernel (simplified)
                float kernel[5][5] = {
                    {1, 4, 6, 4, 1},
                    {4, 16, 24, 16, 4},
                    {6, 24, 36, 24, 6},
                    {4, 16, 24, 16, 4},
                    {1, 4, 6, 4, 1}
                };
                
                float kernel_sum = 0;
                for (int ky = -2; ky <= 2; ky++) {
                    for (int kx = -2; kx <= 2; kx++) {
                        int sx = src_x + kx;
                        int sy = src_y + ky;
                        if (sx >= 0 && sx < prev_w && sy >= 0 && sy < prev_h) {
                            float k = kernel[ky+2][kx+2] / 256.0f;
                            sum += pyramid->levels[l-1][sy * prev_w + sx] * k;
                            kernel_sum += k;
                        }
                    }
                }
                pyramid->levels[l][y * pyramid->widths[l] + x] = sum / kernel_sum;
            }
        }
    }
    
    return pyramid;
}

// HDR 融合主函數
void hdr_fusion_process(hdr_context_t* ctx, uint16_t* output) {
    int size = ctx->width * ctx->height;
    
    // 為每個曝光計算權重圖
    weight_maps_t weights[3];
    for (int i = 0; i < 3; i++) {
        weights[i].contrast = malloc(size * sizeof(float));
        weights[i].saturation = malloc(size * sizeof(float));
        weights[i].well_exposedness = malloc(size * sizeof(float));
        
        calculate_contrast_weight(ctx->frames[i], weights[i].contrast, 
                                ctx->width, ctx->height);
        calculate_saturation_weight(ctx->frames[i], weights[i].saturation,
                                  ctx->width, ctx->height);
        calculate_well_exposedness_weight(ctx->frames[i], weights[i].well_exposedness,
                                        ctx->width, ctx->height, ctx->bit_depth);
    }
    
    // 組合權重並歸一化
    float* final_weights[3];
    for (int i = 0; i < 3; i++) {
        final_weights[i] = malloc(size * sizeof(float));
        for (int j = 0; j < size; j++) {
            final_weights[i][j] = weights[i].contrast[j] * 
                                 weights[i].saturation[j] * 
                                 weights[i].well_exposedness[j];
        }
    }
    
    // 歸一化權重
    for (int j = 0; j < size; j++) {
        float sum = final_weights[0][j] + final_weights[1][j] + final_weights[2][j];
        if (sum > 0) {
            for (int i = 0; i < 3; i++) {
                final_weights[i][j] /= sum;
            }
        }
    }
    
    // 多尺度融合
    int pyramid_levels = 6;
    pyramid_t* weight_pyramids[3];
    pyramid_t* image_pyramids[3];
    
    for (int i = 0; i < 3; i++) {
        // 建立權重金字塔
        weight_pyramids[i] = build_gaussian_pyramid(final_weights[i], 
                                                   ctx->width, ctx->height, 
                                                   pyramid_levels);
        
        // 轉換圖像為浮點並建立 Laplacian 金字塔
        float* float_image = malloc(size * sizeof(float));
        for (int j = 0; j < size; j++) {
            float_image[j] = (float)ctx->frames[i][j] / ((1 << ctx->bit_depth) - 1);
        }
        image_pyramids[i] = build_laplacian_pyramid(float_image, 
                                                   ctx->width, ctx->height,
                                                   pyramid_levels);
        free(float_image);
    }
    
    // 融合金字塔
    pyramid_t* fused_pyramid = malloc(sizeof(pyramid_t));
    fused_pyramid->num_levels = pyramid_levels;
    fused_pyramid->levels = malloc(pyramid_levels * sizeof(float*));
    fused_pyramid->widths = malloc(pyramid_levels * sizeof(int));
    fused_pyramid->heights = malloc(pyramid_levels * sizeof(int));
    
    for (int l = 0; l < pyramid_levels; l++) {
        int level_size = weight_pyramids[0]->widths[l] * weight_pyramids[0]->heights[l];
        fused_pyramid->widths[l] = weight_pyramids[0]->widths[l];
        fused_pyramid->heights[l] = weight_pyramids[0]->heights[l];
        fused_pyramid->levels[l] = malloc(level_size * sizeof(float));
        
        // 加權融合
        for (int j = 0; j < level_size; j++) {
            fused_pyramid->levels[l][j] = 0;
            for (int i = 0; i < 3; i++) {
                fused_pyramid->levels[l][j] += image_pyramids[i]->levels[l][j] * 
                                               weight_pyramids[i]->levels[l][j];
            }
        }
    }
    
    // 重建最終圖像
    float* final_float = reconstruct_from_pyramid(fused_pyramid);
    
    // 色調映射
    tone_mapping_reinhard(final_float, output, ctx->width, ctx->height, ctx->bit_depth);
    
    // 清理記憶體
    for (int i = 0; i < 3; i++) {
        free(weights[i].contrast);
        free(weights[i].saturation);
        free(weights[i].well_exposedness);
        free(final_weights[i]);
        free_pyramid(weight_pyramids[i]);
        free_pyramid(image_pyramids[i]);
    }
    free_pyramid(fused_pyramid);
    free(final_float);
}

// Reinhard 色調映射
void tone_mapping_reinhard(float* hdr_image, uint16_t* output,
                          int width, int height, int bit_depth) {
    float key = 0.18f;  // 場景關鍵值
    float burn = 0.95f; // 高光壓縮
    int max_val = (1 << bit_depth) - 1;
    
    // 計算對數平均亮度
    float sum_log = 0;
    int count = 0;
    for (int i = 0; i < width * height; i++) {
        if (hdr_image[i] > 0) {
            sum_log += logf(hdr_image[i] + 0.0001f);
            count++;
        }
    }
    float avg_lum = expf(sum_log / count);
    
    // Reinhard 映射
    for (int i = 0; i < width * height; i++) {
        float scaled = (key / avg_lum) * hdr_image[i];
        float mapped = scaled / (1 + scaled);
        
        // 高光恢復
        if (scaled > burn) {
            float t = (scaled - burn) / (1 - burn);
            mapped = burn + (1 - burn) * t / (1 + t);
        }
        
        output[i] = (uint16_t)(mapped * max_val);
    }
}
