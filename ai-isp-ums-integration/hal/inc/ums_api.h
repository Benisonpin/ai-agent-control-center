#ifndef UMS_API_H
#define UMS_API_H

#include <stdint.h>
#include <stddef.h>

// UMS 句柄
typedef void* ums_handle_t;

// 記憶體區域
typedef struct {
    void* base_addr;
    size_t size;
    uint32_t flags;
} ums_mem_region_t;

// UMS 參數
typedef struct {
    uint32_t prefetch_depth;
    uint32_t qos_level;
    uint32_t cache_policy;
    uint32_t enable_ai_prediction;
    uint32_t enable_zero_copy;
} ums_param_t;

// UMS 統計
typedef struct {
    uint64_t total_allocated;
    uint64_t bytes_in_use;
    float fragmentation_percent;
    float bandwidth_mbps;
    uint32_t read_latency_ns_avg;
    uint32_t read_latency_ns_p99;
    uint32_t write_latency_ns_avg;
    uint32_t write_latency_ns_p99;
    float cache_hit_rate;
    float tlb_hit_rate;
    float prefetch_accuracy;
    float ai_prediction_accuracy;
    uint64_t zero_copy_count;
    float power_saving_percent;
    uint64_t custom_stats[8];
} ums_stats_t;

// 標誌定義
#define UMS_OPEN_SHARED         0x01
#define UMS_REGION_SHARED       0x02
#define UMS_REGION_CACHED       0x04
#define UMS_REGION_WRITE_COMBINE 0x08
#define UMS_REGION_LOCKED       0x10
#define UMS_REGION_READ_ONLY    0x20
#define UMS_REGION_ZERO_COPY    0x40
#define UMS_PREFETCH_2D_IMAGE   0x80
#define UMS_PREFETCH_SEQUENTIAL 0x100
#define UMS_ZERO_COPY_BIDIRECTIONAL 0x200
#define UMS_CACHE_WRITE_BACK    0x400

// API 函數宣告
ums_handle_t* ums_open(const char* device, uint32_t flags);
void ums_close(ums_handle_t* handle);
int ums_set_params(ums_handle_t* handle, const ums_param_t* params);
ums_mem_region_t* ums_create_region(ums_handle_t* handle, size_t size, uint32_t flags);
void ums_destroy_region(ums_mem_region_t* region);
void* ums_alloc_from_region(ums_mem_region_t* region, size_t size, size_t alignment);
void ums_set_access_mask(ums_mem_region_t* region, uint32_t mask);
int ums_prefetch_hint(ums_handle_t* handle, void* addr, size_t size, uint32_t flags);
int ums_create_zero_copy_mapping(ums_handle_t* handle, void* src, void* dst, uint32_t flags);
int ums_cache_flush(ums_handle_t* handle, void* addr, size_t size);
void ums_get_stats(ums_handle_t* handle, ums_stats_t* stats);

#endif
