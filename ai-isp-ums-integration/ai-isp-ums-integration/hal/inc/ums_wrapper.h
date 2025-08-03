#ifndef HAL_UMS_WRAPPER_H
#define HAL_UMS_WRAPPER_H

#include <stdint.h>
#include <stddef.h>

typedef struct {
    void* ums_handle;
    void* shared_pool;
    size_t pool_size;
    struct {
        void* isp_region;
        void* ai_region;
        void* cpu_region;
    } regions;
} hal_ums_ctx_t;

// UMS 初始化
int hal_ums_init(hal_ums_ctx_t** ctx);

// 記憶體分配
void* hal_ums_alloc_zero_copy(hal_ums_ctx_t* ctx, 
                              size_t size, 
                              uint32_t flags);

// 釋放記憶體
void hal_ums_free(hal_ums_ctx_t* ctx, void* ptr);

// 關閉 UMS
void hal_ums_close(hal_ums_ctx_t* ctx);

#endif
