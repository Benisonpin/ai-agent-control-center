#include "../inc/ums_hal_integration.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>

#define LOG(fmt, ...) printf("[UMS_HAL] " fmt "\n", ##__VA_ARGS__)

// 模擬的 UMS API 實作
ums_handle_t* ums_open(const char* device, uint32_t flags) {
    LOG("Opening UMS device: %s with flags: 0x%x", device, flags);
    return (ums_handle_t*)malloc(sizeof(void*));
}

void ums_close(ums_handle_t* handle) {
    if (handle) free(handle);
}

int ums_set_params(ums_handle_t* handle, const ums_param_t* params) {
    LOG("Setting UMS params: prefetch=%d, qos=%d", 
        params->prefetch_depth, params->qos_level);
    return 0;
}

ums_mem_region_t* ums_create_region(ums_handle_t* handle, size_t size, uint32_t flags) {
    ums_mem_region_t* region = malloc(sizeof(ums_mem_region_t));
    if (region) {
        region->size = size;
        region->flags = flags;
        region->base_addr = malloc(size);
        LOG("Created region: size=%zu, flags=0x%x", size, flags);
    }
    return region;
}

void ums_destroy_region(ums_mem_region_t* region) {
    if (region) {
        if (region->base_addr) free(region->base_addr);
        free(region);
    }
}

void* ums_alloc_from_region(ums_mem_region_t* region, size_t size, size_t alignment) {
    // 簡化實作：直接返回 region 的 base address
    return region ? region->base_addr : NULL;
}

void ums_set_access_mask(ums_mem_region_t* region, uint32_t mask) {
    LOG("Setting access mask: 0x%x", mask);
}

int ums_prefetch_hint(ums_handle_t* handle, void* addr, size_t size, uint32_t flags) {
    return 0;
}

int ums_create_zero_copy_mapping(ums_handle_t* handle, void* src, void* dst, uint32_t flags) {
    LOG("Creating zero-copy mapping: src=%p, dst=%p", src, dst);
    return 0;
}

int ums_cache_flush(ums_handle_t* handle, void* addr, size_t size) {
    return 0;
}

void ums_get_stats(ums_handle_t* handle, ums_stats_t* stats) {
    memset(stats, 0, sizeof(ums_stats_t));
    stats->bandwidth_mbps = 25600.0;
    stats->cache_hit_rate = 95.5;
    stats->prefetch_accuracy = 85.0;
}

// AI ISP UMS 整合實作
int aisp_ums_init(aisp_ums_context_t** ctx, const ums_aisp_config_t* config) {
    *ctx = calloc(1, sizeof(aisp_ums_context_t));
    if (!*ctx) return -ENOMEM;
    
    memcpy(&(*ctx)->config, config, sizeof(ums_aisp_config_t));
    
    (*ctx)->ums_handle = ums_open("/dev/ums0", UMS_OPEN_SHARED);
    if (!(*ctx)->ums_handle) {
        free(*ctx);
        return -ENODEV;
    }
    
    // 設定參數
    ums_param_t params = {
        .prefetch_depth = config->performance.prefetch_depth,
        .qos_level = config->performance.qos_level,
        .cache_policy = config->performance.cache_policy,
        .enable_ai_prediction = 1,
        .enable_zero_copy = 1
    };
    
    ums_set_params((*ctx)->ums_handle, &params);
    
    // 建立記憶體區域
    (*ctx)->regions.raw_region = ums_create_region(
        (*ctx)->ums_handle,
        config->partitions.raw_buffer_size,
        UMS_REGION_SHARED | UMS_REGION_CACHED
    );
    
    (*ctx)->regions.isp_region = ums_create_region(
        (*ctx)->ums_handle,
        config->partitions.isp_working_size,
        UMS_REGION_SHARED | UMS_REGION_WRITE_COMBINE
    );
    
    (*ctx)->regions.ai_model_region = ums_create_region(
        (*ctx)->ums_handle,
        config->partitions.ai_model_size,
        UMS_REGION_LOCKED | UMS_REGION_READ_ONLY
    );
    
    (*ctx)->regions.ai_work_region = ums_create_region(
        (*ctx)->ums_handle,
        config->partitions.ai_inference_size,
        UMS_REGION_SHARED | UMS_REGION_CACHED | UMS_REGION_ZERO_COPY
    );
    
    LOG("AI ISP UMS initialized successfully");
    return 0;
}

void* aisp_ums_alloc_frame_buffer(aisp_ums_context_t* ctx, size_t size) {
    return ums_alloc_from_region(ctx->regions.raw_region, size, 64);
}

int aisp_ums_setup_zero_copy(aisp_ums_context_t* ctx, void* src, void* dst) {
    return ums_create_zero_copy_mapping(ctx->ums_handle, src, dst, 
                                       UMS_ZERO_COPY_BIDIRECTIONAL);
}

int aisp_ums_sync_cache(aisp_ums_context_t* ctx, void* addr, size_t size) {
    return ums_cache_flush(ctx->ums_handle, addr, size);
}

void aisp_ums_get_stats(aisp_ums_context_t* ctx, ums_stats_t* stats) {
    ums_get_stats(ctx->ums_handle, stats);
    stats->custom_stats[0] = ctx->stats.frames_processed;
    stats->custom_stats[1] = ctx->stats.total_latency_ns;
    stats->custom_stats[2] = ctx->stats.bandwidth_bytes;
}

void aisp_ums_cleanup(aisp_ums_context_t* ctx) {
    if (!ctx) return;
    
    if (ctx->regions.raw_region) ums_destroy_region(ctx->regions.raw_region);
    if (ctx->regions.isp_region) ums_destroy_region(ctx->regions.isp_region);
    if (ctx->regions.ai_model_region) ums_destroy_region(ctx->regions.ai_model_region);
    if (ctx->regions.ai_work_region) ums_destroy_region(ctx->regions.ai_work_region);
    
    if (ctx->ums_handle) ums_close(ctx->ums_handle);
    
    free(ctx);
    LOG("AI ISP UMS cleaned up");
}
