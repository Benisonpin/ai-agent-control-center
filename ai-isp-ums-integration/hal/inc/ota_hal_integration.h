#ifndef OTA_HAL_INTEGRATION_H
#define OTA_HAL_INTEGRATION_H

#include <stdint.h>
#include "ums_hal_integration.h"

// OTA 更新狀態
typedef enum {
    OTA_STATE_IDLE = 0,
    OTA_STATE_CHECKING,
    OTA_STATE_DOWNLOADING,
    OTA_STATE_VERIFYING,
    OTA_STATE_INSTALLING,
    OTA_STATE_COMPLETE,
    OTA_STATE_ERROR
} ota_state_t;

// OTA HAL 接口
typedef struct {
    int (*check_update)(void);
    int (*download_model)(const char* model_name, const char* version);
    int (*install_model)(const char* model_path);
    int (*verify_model)(const char* model_path);
    ota_state_t (*get_status)(void);
} ota_hal_ops_t;

// OTA HAL 初始化
int ota_hal_init(ota_hal_ops_t* ops);

// 模型熱插拔支持
int ota_hot_swap_model(const char* old_model, const char* new_model);

#endif // OTA_HAL_INTEGRATION_H
