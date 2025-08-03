#ifndef CAMERA_HAL3_INTERFACE_H
#define CAMERA_HAL3_INTERFACE_H

#include <hardware/camera3.h>
#include <system/camera_metadata.h>
#include "../hal/inc/ums_hal_integration.h"

// Camera HAL3 設備結構
typedef struct camera3_ums_device {
    camera3_device_t base;
    aisp_ums_context_t* ums_ctx;
    
    // Camera 參數
    struct {
        uint32_t sensor_width;
        uint32_t sensor_height;
        uint32_t pixel_format;
        uint32_t fps;
    } sensor_config;
    
    // Stream 配置
    camera3_stream_configuration_t stream_config;
    camera3_stream_t** streams;
    uint32_t num_streams;
    
    // Buffer 管理
    struct {
        buffer_handle_t* handles;
        void* ums_buffers;
        uint32_t count;
        uint32_t index;
    } buffer_pool;
    
    // ISP Pipeline
    void* isp_pipeline;
    
    // 3A 狀態
    struct {
        uint32_t ae_mode;
        uint32_t awb_mode;
        uint32_t af_mode;
        float exposure_time;
        int32_t iso;
    } control_3a;
    
} camera3_ums_device_t;

// HAL3 API 函數
int camera3_ums_open(const hw_module_t* module, const char* id,
                     hw_device_t** device);
int camera3_ums_initialize(const camera3_device_t* device,
                           const camera3_callback_ops_t* callback_ops);
int camera3_ums_configure_streams(const camera3_device_t* device,
                                  camera3_stream_configuration_t* stream_list);
int camera3_ums_process_capture_request(const camera3_device_t* device,
                                        camera3_capture_request_t* request);

#endif
