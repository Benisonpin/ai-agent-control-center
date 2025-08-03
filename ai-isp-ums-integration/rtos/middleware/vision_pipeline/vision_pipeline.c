#include "vision_pipeline.h"
#include "ai_agent_framework.h"
#include "hal_abstraction.h"

// Vision Pipeline 配置
typedef struct {
    // Pipeline 階段
    bool enable_hdr;
    bool enable_night_mode;
    bool enable_portrait;
    bool enable_ai_enhance;
    
    // 品質設定
    uint32_t output_width;
    uint32_t output_height;
    uint32_t output_format;
    uint32_t jpeg_quality;
    
    // AI 設定
    uint32_t ai_model_version;
    float ai_strength;
    
} vision_pipeline_config_t;

// Vision Pipeline 上下文
typedef struct {
    // HAL 介面
    hal_manager_t* hal;
    
    // Pipeline 配置
    vision_pipeline_config_t config;
    
    // Buffer 管理
    frame_buffer_pool_t* input_pool;
    frame_buffer_pool_t* output_pool;
    frame_buffer_pool_t* working_pool;
    
    // AI Agents
    ai_agent_t* scene_agent;
    ai_agent_t* face_agent;
    ai_agent_t* enhance_agent;
    
    // 狀態機
    pipeline_state_t state;
    
    // 統計
    pipeline_stats_t stats;
    
} vision_pipeline_t;

// Pipeline 處理流程
int vision_pipeline_process(vision_pipeline_t* pipeline, 
                           frame_buffer_t* input,
                           frame_buffer_t** output) {
    int ret = 0;
    
    // 1. 場景檢測（並行）
    ai_agent_send_frame(pipeline->scene_agent, input);
    
    // 2. ISP 前處理
    frame_buffer_t* isp_input = frame_buffer_pool_get(pipeline->working_pool);
    memcpy(isp_input->data, input->data, input->size);
    
    // 3. HDR 處理（如果啟用）
    if (pipeline->config.enable_hdr) {
        frame_buffer_t* hdr_frames[3];
        capture_hdr_frames(pipeline->hal->camera, hdr_frames, 3);
        
        hdr_fusion_params_t params = {
            .tone_mapping = TONE_MAP_REINHARD,
            .ghost_removal = true
        };
        
        process_hdr(hdr_frames, 3, isp_input, &params);
        
        for (int i = 0; i < 3; i++) {
            frame_buffer_release(hdr_frames[i]);
        }
    }
    
    // 4. 基礎 ISP 處理
    frame_buffer_t* isp_output = frame_buffer_pool_get(pipeline->working_pool);
    
    isp_params_t isp_params = {
        .denoise_level = 3,
        .sharpness = 1.2f,
        .contrast = 1.1f,
        .saturation = 1.05f
    };
    
    // 等待場景檢測結果
    scene_result_t scene_result;
    ai_agent_get_result(pipeline->scene_agent, &scene_result, 50); // 50ms timeout
    
    // 根據場景調整 ISP 參數
    adjust_isp_params_for_scene(&isp_params, scene_result.scene_type);
    
    // 執行 ISP
    pipeline->hal->isp->process_raw(isp_input->data, isp_output->data);
    
    // 5. 人像模式（如果啟用）
    if (pipeline->config.enable_portrait && scene_result.scene_type == SCENE_PORTRAIT) {
        // 人臉檢測
        ai_agent_send_frame(pipeline->face_agent, isp_output);
        
        face_result_t face_result;
        if (ai_agent_get_result(pipeline->face_agent, &face_result, 30) == 0) {
            if (face_result.num_faces > 0) {
                // 深度估計
                depth_map_t* depth = estimate_depth_from_single_image(isp_output);
                
                // 背景虛化
                apply_bokeh_effect(isp_output, depth, &face_result);
                
                // 美顏
                apply_face_beautification(isp_output, &face_result);
                
                free(depth);
            }
        }
    }
    
    // 6. 夜景模式（如果啟用）
    if (pipeline->config.enable_night_mode && scene_result.scene_type == SCENE_NIGHT) {
        // 多幀降噪
        frame_buffer_t* night_frames[6];
        capture_night_frames(pipeline->hal->camera, night_frames, 6);
        
        night_mode_params_t params = {
            .motion_compensation = true,
            .ghost_removal = true,
            .brightness_boost = 1.8f
        };
        
        process_night_mode(night_frames, 6, isp_output, &params);
        
        for (int i = 0; i < 6; i++) {
            frame_buffer_release(night_frames[i]);
        }
    }
    
    // 7. AI 增強（如果啟用）
    if (pipeline->config.enable_ai_enhance) {
        ai_agent_send_frame(pipeline->enhance_agent, isp_output);
        
        enhance_result_t enhance_result;
        if (ai_agent_get_result(pipeline->enhance_agent, &enhance_result, 50) == 0) {
            apply_ai_enhancement(isp_output, &enhance_result, pipeline->config.ai_strength);
        }
    }
    
    // 8. 後處理和輸出
    *output = frame_buffer_pool_get(pipeline->output_pool);
    
    // 格式轉換
    if (pipeline->config.output_format == FORMAT_JPEG) {
        jpeg_encode(isp_output, *output, pipeline->config.jpeg_quality);
    } else {
        format_convert(isp_output, *output, pipeline->config.output_format);
    }
    
    // 釋放中間 buffers
    frame_buffer_release(isp_input);
    frame_buffer_release(isp_output);
    
    // 更新統計
    pipeline->stats.frames_processed++;
    pipeline->stats.total_processing_time_ms += get_processing_time();
    
    return ret;
}

// 建立 Vision Pipeline
vision_pipeline_t* vision_pipeline_create(hal_manager_t* hal) {
    vision_pipeline_t* pipeline = pvPortMalloc(sizeof(vision_pipeline_t));
    
    pipeline->hal = hal;
    
    // 預設配置
    pipeline->config.enable_hdr = true;
    pipeline->config.enable_night_mode = true;
    pipeline->config.enable_portrait = true;
    pipeline->config.enable_ai_enhance = true;
    pipeline->config.output_width = 4000;
    pipeline->config.output_height = 3000;
    pipeline->config.output_format = FORMAT_JPEG;
    pipeline->config.jpeg_quality = 95;
    pipeline->config.ai_strength = 0.8f;
    
    // 建立 buffer pools
    pipeline->input_pool = frame_buffer_pool_create(3, 
        pipeline->config.output_width * pipeline->config.output_height * 2);
    pipeline->output_pool = frame_buffer_pool_create(2,
        pipeline->config.output_width * pipeline->config.output_height * 3);
    pipeline->working_pool = frame_buffer_pool_create(4,
        pipeline->config.output_width * pipeline->config.output_height * 3);
    
    // 獲取 AI agents
    pipeline->scene_agent = ai_agent_get(AGENT_SCENE_DETECTOR);
    pipeline->face_agent = ai_agent_get(AGENT_FACE_DETECTOR);
    pipeline->enhance_agent = ai_agent_get(AGENT_IMAGE_ENHANCER);
    
    pipeline->state = PIPELINE_IDLE;
    
    return pipeline;
}
