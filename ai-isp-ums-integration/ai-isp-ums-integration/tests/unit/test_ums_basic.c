#include <stdio.h>
#include <assert.h>
#include "../../hal/inc/ums_wrapper.h"

void test_ums_init() {
    printf("Testing UMS initialization...\n");
    
    hal_ums_ctx_t* ctx = NULL;
    int ret = hal_ums_init(&ctx);
    
    assert(ret == 0);
    assert(ctx != NULL);
    assert(ctx->shared_pool != NULL);
    
    printf("✓ UMS initialization test passed\n");
    
    hal_ums_close(ctx);
}

void test_zero_copy_alloc() {
    printf("Testing zero-copy allocation...\n");
    
    hal_ums_ctx_t* ctx = NULL;
    hal_ums_init(&ctx);
    
    // 分配 1MB
    void* buffer = hal_ums_alloc_zero_copy(ctx, 1024*1024, 0);
    assert(buffer != NULL);
    
    // 分配另一個 buffer
    void* buffer2 = hal_ums_alloc_zero_copy(ctx, 2048*1024, 0);
    assert(buffer2 != NULL);
    assert(buffer2 != buffer);
    
    printf("✓ Zero-copy allocation test passed\n");
    
    hal_ums_close(ctx);
}

int main() {
    printf("=== UMS Integration Tests ===\n");
    
    test_ums_init();
    test_zero_copy_alloc();
    
    printf("\nAll tests passed! ✓\n");
    return 0;
}
