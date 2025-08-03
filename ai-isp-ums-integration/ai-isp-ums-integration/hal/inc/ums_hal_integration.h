#ifndef UMS_HAL_INTEGRATION_H
#define UMS_HAL_INTEGRATION_H

#include <stdint.h>
#include <stddef.h>
#include "ums_api.h"  // 真實的 UMS SDK 頭文件

// AI ISP 專用的 UMS 配置
typedef struct {
    // 記憶體分區配置
    struct {
        size_t raw_buffer_size;      // RAW 影像緩衝區
        size_t isp_working_size;     // ISP 工作區
        size_t ai_model_size;        // AI 模型區
        size_t ai_inference_size;    // AI 推論區
    } partitions;
    
    // 效能配置
    struct {
        uint32_t prefetch_depth;     // 預取深度
        uint32_t qos_level;          // QoS 等級
        uint32_t cac
cat > hal/src/ums_hal_integration.c << 'EOF'
#include "ums_hal_integration.h"
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <errno.h>
#include <syslog.h>

#define LOG_TAG "AISP_UMS"
#define LOGI(...) syslog(LOG_INFO, LOG_TAG ": " __VA_ARGS__)
#define LOGE(...) syslog(LOG_ERR, LOG_TAG ": " __VA_ARGS__)

// 內部輔助函數
static int setup_memory_regions(aisp_ums_context_t* ctx) {
    int ret;
    
    // 1. 配置 RAW buffer 區域
    ctx->regions.raw_region = ums_create_region(
        ctx->ums_handle,
        ctx->config.partitions.raw_buffer_size,
        UMS_REGION_SHARED | UMS_REGION_CACHED
    );
    if (!ctx->regions.raw_region) {
        LOGE("Failed to create RAW buffer region");
        return -ENOMEM;
    }
    
    // 2. 配置 ISP 工作區
    ctx->regions.isp_region = ums_create_region(
        ctx->ums_handle,
        ctx->config.partitions.isp_working_size,
        UMS_REGION_SHARED | UMS_REGION_WRITE_COMBINE
    );
    if (!ctx->regions.isp_region) {
        LOGE("Failed to create ISP working region");
        return -ENOMEM;
    }
    
    // 3. 配置 AI 模型區 (locked in memory)
    ctx->regions.ai_model_region = ums_create_region(
        ctx->ums_handle,
        ctx->config.partitions.ai_model_size,
        UMS_REGION_LOCKED | UMS_REGION_READ_ONLY
    );
    if (!ctx->regions.ai_model_region) {
        LOGE("Failed to create AI model region");
        return -ENOMEM;
    }
    
    // 4. 配置 AI 工作區
    ctx->regions.ai_work_region = ums_create_region(
        ctx->ums_handle,
        ctx->config.partitions.ai_inference_size,
        UMS_REGION_SHARED | UMS_REGION_CACHED | UMS_REGION_ZERO_COPY
    );
    if (!ctx->regions.ai_work_region) {
        LOGE("Failed to create AI working region");
        return -ENOMEM;
    }
    
    // 5. 設定存取權限
    ums_set_access_mask(ctx->regions.raw_region, 
                       ctx->config.sharing.cpu_mask | 
                       ctx->config.sharing.isp_mask);
    
    ums_set_access_mask(ctx->regions.ai_work_region,
                       ctx->config.sharing.cpu_mask | 
                       ctx->config.sharing.npu_mask);
    
    LOGI("Memory regions setup completed");
    retur
cat > isp/isp_pipeline_ums.h << 'EOF'
#ifndef ISP_PIPELINE_UMS_H
#define ISP_PIPELINE_UMS_H

#include "hal/inc/ums_hal_integration.h"
#include "isp_core.h"
#include "ai_agent.h"

// ISP Pipeline 配置
typedef struct {
    // 基本參數
    uint32_t width;
    uint32_t height;
    uint32_t bayer_pattern;
    uint32_t bit_depth;
    
    // AI 配置
    uint32_t num_ai_agents;
    ai_agent_config_t ai_configs[MAX_AI_AGENTS];
    
    // UMS 配置
    ums_aisp_config_t ums_config;
    
    // Pipeline 配置
    struct {
        bool enable_3a;
        bool enable_nr;
        bool enable_sharpening;
        bool enable_ai_enhance;
    } features;
} isp_pipeline_config_t;

// ISP Pipeline 上下文
typedef struct {
    // 配置
    isp_pipeline_config_t config;
    
    // UMS 上下文
    aisp_ums_context_t* ums_ctx;
    
    // ISP 模組
    struct {
        void* demosaic;
        void* awb;
        void* ae;
        void* af;
        void* nr;
        void* sharpening;
    } modules;
    
    // AI Agents
    ai_agent_t* ai_agents[MAX_AI_AGENTS];
    uint32_t num_agents;
    
    // 工作緩衝區
    struct {
        void* raw_buffer;
        void* rgb_buffer;
        void* yuv_buffer;
        void* ai_buffer;
    } buffers;
    
    // 統計
    struct {
        uint64_t frame_count;
        uint64_t total_time_us;
        float avg_fps;
    } stats;
} isp_pipeline_t;

// Pipeline API
isp_pipeline_t* isp_pipeline_create(const isp_pipeline_config_t* config);
int isp_pipeline_process_frame(isp_pipeline_t* pipeline, 
                              const void* raw_data,
                              void* output_data);
int isp_pipeline_add_ai_agent(isp_pipeline_t* pipeline,
                             const ai_agent_config_t* agent_config);
void isp_pipeline_get_stats(isp_pipeline_t* pipeline, 
                           isp_stats_t* stats);
void isp_pipeline_destroy(isp_pipeline_t* pipeline);

#endif
