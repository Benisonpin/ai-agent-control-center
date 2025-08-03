#include "ums_wrapper.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// 模擬 UMS API (實際專案需要包含真實的 UMS 頭文件)
void* ums_open(const char* device) {
    printf("Opening UMS device: %s\n", device);
    return (void*)0x1234; // 模擬 handle
}

void* ums_alloc_shared(void* handle, size_t size, uint32_t flags) {
    printf("Allocating shared memory: %zu bytes\n", size);
    return malloc(size); // 實際應該是 UMS 分配
}

int hal_ums_init(hal_ums_ctx_t** ctx) {
    *ctx = calloc(1, sizeof(hal_ums_ctx_t));
    if (!*ctx) {
        return -1;
    }
    
    // 開啟 UMS 設備
    (*ctx)->ums_handle = ums_open("/dev/ums0");
    if (!(*ctx)->ums_handle) {
        printf("Failed to open UMS device\n");
        free(*ctx);
        return -1;
    }
    
    // 配置共享記憶體池 (64MB)
    (*ctx)->pool_size = 64 * 1024 * 1024;
    (*ctx)->shared_pool = ums_alloc_shared(
        (*ctx)->ums_handle,
        (*ctx)->pool_size,
        0x100 // UMS_ZERO_COPY flag
    );
    
    if (!(*ctx)->shared_pool) {
        printf("Failed to allocate shared pool\n");
        free(*ctx);
        return -1;
    }
    
    // 設定記憶體區域
    (*ctx)->regions.isp_region = (*ctx)->shared_pool;
    (*ctx)->regions.ai_region = (char*)(*ctx)->shared_pool + 32*1024*1024;
    (*ctx)->regions.cpu_region = (char*)(*ctx)->shared_pool + 48*1024*1024;
    
    printf("UMS initialized successfully\n");
    return 0;
}

void* hal_ums_alloc_zero_copy(hal_ums_ctx_t* ctx, 
                              size_t size, 
                              uint32_t flags) {
    // 簡單的分配邏輯 (實際應該更複雜)
    static size_t offset = 0;
    
    if (offset + size > ctx->pool_size) {
        printf("Out of memory\n");
        return NULL;
    }
    
    void* ptr = (char*)ctx->shared_pool + offset;
    offset += size;
    
    return ptr;
}

void hal_ums_free(hal_ums_ctx_t* ctx, void* ptr) {
    // 實際實作應該要有更複雜的記憶體管理
    printf("Freeing memory at %p\n", ptr);
}

void hal_ums_close(hal_ums_ctx_t* ctx) {
    if (ctx) {
        if (ctx->shared_pool) {
            free(ctx->shared_pool); // 實際應該是 UMS 釋放
        }
        free(ctx);
    }
}
