#include <stdint.h>
#include <string.h>
#include <math.h>

// AAHD (Adaptive Algorithm for Homogeneity-Directed) Demosaic
// 基於邊緣方向的自適應去馬賽克演算法

typedef struct {
    uint16_t* raw_data;
    uint8_t* rgb_output;
    int width;
    int height;
    int bayer_pattern;
} demosaic_context_t;

// 計算水平和垂直梯度
static void calculate_gradients(uint16_t* raw, int x, int y, int width,
                               float* grad_h, float* grad_v) {
    // 水平梯度
    *grad_h = fabsf(raw[y*width + x-1] - raw[y*width + x+1]) +
              fabsf(2*raw[y*width + x] - raw[y*width + x-2] - raw[y*width + x+2]);
    
    // 垂直梯度
    *grad_v = fabsf(raw[(y-1)*width + x] - raw[(y+1)*width + x]) +
              fabsf(2*raw[y*width + x] - raw[(y-2)*width + x] - raw[(y+2)*width + x]);
}

// 自適應顏色插值
static void adaptive_interpolation(demosaic_context_t* ctx, int x, int y,
                                  uint8_t* r, uint8_t* g, uint8_t* b) {
    float grad_h, grad_v;
    calculate_gradients(ctx->raw_data, x, y, ctx->width, &grad_h, &grad_v);
    
    // 根據梯度選擇插值方向
    float weight_h = 1.0f / (1.0f + grad_h);
    float weight_v = 1.0f / (1.0f + grad_v);
    float weight_sum = weight_h + weight_v;
    
    weight_h /= weight_sum;
    weight_v /= weight_sum;
    
    // Bayer pattern: RGGB
    int pos = y * ctx->width + x;
    int is_red = ((y & 1) == 0) && ((x & 1) == 0);
    int is_blue = ((y & 1) == 1) && ((x & 1) == 1);
    int is_green = !is_red && !is_blue;
    
    if (is_green) {
        *g = ctx->raw_data[pos] >> 2;  // 10-bit to 8-bit
        
        // 插值 R 和 B
        if ((y & 1) == 0) {  // Green in red row
            *r = ((ctx->raw_data[pos-1] + ctx->raw_data[pos+1]) >> 1) >> 2;
            *b = ((ctx->raw_data[pos-ctx->width] + ctx->raw_data[pos+ctx->width]) >> 1) >> 2;
        } else {  // Green in blue row
            *b = ((ctx->raw_data[pos-1] + ctx->raw_data[pos+1]) >> 1) >> 2;
            *r = ((ctx->raw_data[pos-ctx->width] + ctx->raw_data[pos+ctx->width]) >> 1) >> 2;
        }
    } else if (is_red) {
        *r = ctx->raw_data[pos] >> 2;
        
        // 自適應插值 G
        uint16_t g_h = (ctx->raw_data[pos-1] + ctx->raw_data[pos+1]) >> 1;
        uint16_t g_v = (ctx->raw_data[pos-ctx->width] + ctx->raw_data[pos+ctx->width]) >> 1;
        *g = (uint8_t)((weight_h * g_h + weight_v * g_v) / 256);
        
        // 插值 B
        *b = ((ctx->raw_data[pos-ctx->width-1] + ctx->raw_data[pos-ctx->width+1] +
               ctx->raw_data[pos+ctx->width-1] + ctx->raw_data[pos+ctx->width+1]) >> 2) >> 2;
    } else {  // blue
        *b = ctx->raw_data[pos] >> 2;
        
        // 自適應插值 G
        uint16_t g_h = (ctx->raw_data[pos-1] + ctx->raw_data[pos+1]) >> 1;
        uint16_t g_v = (ctx->raw_data[pos-ctx->width] + ctx->raw_data[pos+ctx->width]) >> 1;
        *g = (uint8_t)((weight_h * g_h + weight_v * g_v) / 256);
        
        // 插值 R
        *r = ((ctx->raw_data[pos-ctx->width-1] + ctx->raw_data[pos-ctx->width+1] +
               ctx->raw_data[pos+ctx->width-1] + ctx->raw_data[pos+ctx->width+1]) >> 2) >> 2;
    }
}

// 主要的 demosaic 函數
void aahd_demosaic_process(demosaic_context_t* ctx) {
    // 處理邊界（簡單複製）
    for (int y = 2; y < ctx->height - 2; y++) {
        for (int x = 2; x < ctx->width - 2; x++) {
            int out_idx = (y * ctx->width + x) * 3;
            adaptive_interpolation(ctx, x, y,
                                 &ctx->rgb_output[out_idx],
                                 &ctx->rgb_output[out_idx + 1],
                                 &ctx->rgb_output[out_idx + 2]);
        }
    }
}
