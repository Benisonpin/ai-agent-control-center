#ifndef HAL_ABSTRACTION_H
#define HAL_ABSTRACTION_H

#include <stdint.h>
#include <stdbool.h>

// HAL 錯誤碼
typedef enum {
    HAL_OK = 0,
    HAL_ERROR = -1,
    HAL_BUSY = -2,
    HAL_TIMEOUT = -3,
    HAL_INVALID_PARAM = -4,
    HAL_NO_MEMORY = -5
} hal_status_t;

// 通用 HAL 介面
typedef struct {
    hal_status_t (*init)(void* config);
    hal_status_t (*deinit)(void);
    hal_status_t (*start)(void);
    hal_status_t (*stop)(void);
    hal_status_t (*ioctl)(uint32_t cmd, void* arg);
    void* priv_data;
} hal_interface_t;

// Camera HAL 介面
typedef struct {
    hal_interface_t base;
    
    // Camera 特定函數
    hal_status_t (*set_resolution)(uint32_t width, uint32_t height);
    hal_status_t (*set_fps)(uint32_t fps);
    hal_status_t (*capture_frame)(void* buffer, uint32_t timeout_ms);
    hal_status_t (*set_exposure)(uint32_t exposure_us);
    hal_status_t (*set_gain)(float gain);
    
    // 3A 控制
    hal_status_t (*set_ae_mode)(uint32_t mode);
    hal_status_t (*set_awb_mode)(uint32_t mode);
    hal_status_t (*set_af_mode)(uint32_t mode);
    
} camera_hal_t;

// ISP HAL 介面
typedef struct {
    hal_interface_t base;
    
    // ISP 處理函數
    hal_status_t (*process_raw)(void* input, void* output);
    hal_status_t (*set_pipeline_config)(void* config);
    hal_status_t (*enable_stage)(uint32_t stage_id, bool enable);
    
    // ISP 參數設定
    hal_status_t (*set_denoise_level)(uint32_t level);
    hal_status_t (*set_sharpness)(float sharpness);
    hal_status_t (*set_color_correction)(float* ccm);
    
} isp_hal_t;

// NPU HAL 介面
typedef struct {
    hal_interface_t base;
    
    // 模型管理
    hal_status_t (*load_model)(void* model_data, uint32_t size);
    hal_status_t (*unload_model)(uint32_t model_id);
    
    // 推理
    hal_status_t (*inference)(uint32_t model_id, void* input, void* output);
    hal_status_t (*inference_async)(uint32_t model_id, void* input, 
                                   void (*callback)(void* output));
    
    // 效能控制
    hal_status_t (*set_power_mode)(uint32_t mode);
    hal_status_t (*get_performance_stats)(void* stats);
    
} npu_hal_t;

// Display HAL 介面
typedef struct {
    hal_interface_t base;
    
    // 顯示控制
    hal_status_t (*set_mode)(uint32_t width, uint32_t height, uint32_t refresh);
    hal_status_t (*show_frame)(void* buffer);
    hal_status_t (*show_frame_async)(void* buffer, void (*callback)(void));
    
    // OSD 覆蓋
    hal_status_t (*draw_overlay)(void* overlay_data);
    hal_status_t (*clear_overlay)(void);
    
} display_hal_t;

// HAL 管理器
typedef struct {
    camera_hal_t* camera;
    isp_hal_t* isp;
    npu_hal_t* npu;
    display_hal_t* display;
    
    // 電源管理
    hal_status_t (*set_system_power_mode)(uint32_t mode);
    hal_status_t (*get_power_consumption)(float* watts);
    
} hal_manager_t;

// HAL 初始化
hal_manager_t* hal_manager_init(void);
void hal_manager_deinit(hal_manager_t* manager);

#endif // HAL_ABSTRACTION_H
