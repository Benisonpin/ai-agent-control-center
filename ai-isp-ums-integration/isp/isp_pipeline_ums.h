#ifndef ISP_PIPELINE_UMS_H
#define ISP_PIPELINE_UMS_H

#include <stdint.h>
#include <stdbool.h>
#include "../hal/inc/ums_hal_integration.h"

#define MAX_AI_AGENTS 4

// 基本類型定義
typedef enum {
    BAYER_RGGB = 0,
    BAYER_GRBG = 1,
    BAYER_GBRG = 2,
    BAYER_BGGR = 3
} bayer_pattern_t;

typedef enum {
    FORMAT_RGB888 = 0,
    FORMAT_YUV420 = 1,
    FORMAT_YUV422 = 2
} pixel_format_t;

// AI Agent 配置
typedef struct {
    const char* model_path;
    uint32_t input_width;
    uint32_t input_height;
    pixel_format_t input_format;
} ai_agent_config_t;

// AI Agent 結構
typedef struct ai_agent {
    void* model;
    void* interpreter;
    ai_agent_config_t config;
    void* working_buffer;
} ai_agent_t;

// ISP 統計資料
typedef struct {
    float avg_fps;
    float avg_latency_ms;
    uint64_t frames_processed;
} isp_stats_t;

// ISP Pipeline 配置
typedef struct {
    uint32_t width;
    uint32_t height;
    bayer_pattern_t bayer_pattern;
    uint32_t bit_depth;
    uint32_t num_ai_agents;
    ai_agent_config_t ai_configs[MAX_AI_AGENTS];
    ums_aisp_config_t ums_config;
    
    struct {
        bool enable_3a;
        bool enable_nr;
        bool enable_sharpening;
        bool enable_ai_enhance;
    } features;
} isp_pipeline_config_t;

// ISP Pipeline 結構
typedef struct {
    isp_pipeline_config_t config;
    aisp_ums_context_t* ums_ctx;
    
    struct {
        void* demosaic;
        void* awb;
        void* ae;
        void* af;
        void* nr;
        void* sharpening;
    } modules;
    
    ai_agent_t* ai_agents[MAX_AI_AGENTS];
    uint32_t num_agents;
    
    struct {
        void* raw_buffer;
        void* rgb_buffer;
        void* yuv_buffer;
        void* ai_buffer;
    } buffers;
    
    struct {
        uint64_t frame_count;
        uint64_t total_time_us;
        float avg_fps;
    } stats;
} isp_pipeline_t;

// API 函數
isp_pipeline_t* isp_pipeline_create(const isp_pipeline_config_t* config);
int isp_pipeline_process_frame(isp_pipeline_t* pipeline, const void* raw_data, void* output_data);
int isp_pipeline_add_ai_agent(isp_pipeline_t* pipeline, const ai_agent_config_t* agent_config);
void isp_pipeline_get_stats(isp_pipeline_t* pipeline, isp_stats_t* stats);
void isp_pipeline_destroy(isp_pipeline_t* pipeline);

#endif
