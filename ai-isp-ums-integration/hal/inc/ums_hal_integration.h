#ifndef UMS_HAL_INTEGRATION_H
#define UMS_HAL_INTEGRATION_H

#include <stdint.h>
#include <stddef.h>
#include "ums_api.h"

typedef struct {
    struct {
        size_t raw_buffer_size;
        size_t isp_working_size;
        size_t ai_model_size;
        size_t ai_inference_size;
    } partitions;
    
    struct {
        uint32_t prefetch_depth;
        uint32_t qos_level;
        uint32_t cache_policy;
    } performance;
    
    struct {
        uint32_t cpu_mask;
        uint32_t isp_mask;
        uint32_t npu_mask;
    } sharing;
} ums_aisp_config_t;

typedef struct {
    ums_handle_t* ums_handle;
    ums_aisp_config_t config;
    
    struct {
        ums_mem_region_t* raw_region;
        ums_mem_region_t* isp_region;
        ums_mem_region_t* ai_model_region;
        ums_mem_region_t* ai_work_region;
    } regions;
    
    struct {
        uint64_t frames_processed;
        uint64_t total_latency_ns;
        uint64_t bandwidth_bytes;
    } stats;
} aisp_ums_context_t;

int aisp_ums_init(aisp_ums_context_t** ctx, const ums_aisp_config_t* config);
void* aisp_ums_alloc_frame_buffer(aisp_ums_context_t* ctx, size_t size);
int aisp_ums_setup_zero_copy(aisp_ums_context_t* ctx, void* src, void* dst);
int aisp_ums_sync_cache(aisp_ums_context_t* ctx, void* addr, size_t size);
void aisp_ums_get_stats(aisp_ums_context_t* ctx, ums_stats_t* stats);
void aisp_ums_cleanup(aisp_ums_context_t* ctx);

#endif
