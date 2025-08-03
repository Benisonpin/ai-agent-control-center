#include <stdio.h>
#include "hal/inc/ums_hal_integration.h"

int main() {
    printf("Testing UMS HAL Integration...\n");
    
    ums_aisp_config_t config = {
        .partitions = {
            .raw_buffer_size = 64 * 1024 * 1024,
            .isp_working_size = 32 * 1024 * 1024,
            .ai_model_size = 16 * 1024 * 1024,
            .ai_inference_size = 32 * 1024 * 1024
        },
        .performance = {
            .prefetch_depth = 32,
            .qos_level = 15,
            .cache_policy = UMS_CACHE_WRITE_BACK
        },
        .sharing = {
            .cpu_mask = 0x01,
            .isp_mask = 0x02,
            .npu_mask = 0x04
        }
    };
    
    aisp_ums_context_t* ctx;
    int ret = aisp_ums_init(&ctx, &config);
    
    if (ret == 0) {
        printf("UMS initialization successful!\n");
        aisp_ums_cleanup(ctx);
    } else {
        printf("UMS initialization failed: %d\n", ret);
    }
    
    return 0;
}
