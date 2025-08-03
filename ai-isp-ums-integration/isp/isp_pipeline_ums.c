#include "isp_pipeline_ums.h"
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <time.h>
#include <stdio.h>

#define LOG(fmt, ...) printf("[ISP] " fmt "\n", ##__VA_ARGS__)

// 時間測量
static inline uint64_t get_time_us() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec * 1000000ULL + ts.tv_nsec / 1000;
}

// 模擬的 ISP 模組函數
static void* isp_demosaic_init(uint32_t w, uint32_t h, bayer_pattern_t pattern) {
    LOG("Demosaic init: %dx%d, pattern=%d", w, h, pattern);
    return (void*)0x1001;
}

static void* isp_awb_init() { return (void*)0x1002; }
static void* isp_ae_init() { return (void*)0x1003; }
static void* isp_af_init() { return (void*)0x1004; }
static void* isp_nr_init(uint32_t w, uint32_t h) { return (void*)0x1005; }
static void* isp_sharpen_init(uint32_t w, uint32_t h) { return (void*)0x1006; }

static void isp_demosaic_process(void* ctx, void* in, void* out) {
    // 模擬處理
    usleep(1000); // 1ms
}

static void isp_awb_process(void* ctx, void* buf) { usleep(500); }
static void isp_ae_process(void* ctx, void* buf) { usleep(500); }
static void isp_af_process(void* ctx, void* buf) { usleep(500); }
static void isp_nr_process(void* ctx, void* buf) { usleep(2000); }
static void isp_sharpen_process(void* ctx, void* buf) { usleep(1000); }

static void isp_demosaic_destroy(void* ctx) {}
static void isp_awb_destroy(void* ctx) {}
static void isp_ae_destroy(void* ctx) {}
static void isp_af_destroy(void* ctx) {}
static void isp_nr_destroy(void* ctx) {}
static void isp_sharpen_destroy(void* ctx) {}

static void isp_rgb_to_yuv(void* rgb, void* yuv, uint32_t w, uint32_t h) {
    // 模擬 RGB to YUV 轉換
    usleep(2000);
}

// AI Agent 函數
static ai_agent_t* ai_agent_create_with_ums(const ai_agent_config_t* config, 
                                            aisp_ums_context_t* ums_ctx) {
    ai_agent_t* agent = calloc(1, sizeof(ai_agent_t));
    if (agent) {
        memcpy(&agent->config, config, sizeof(ai_agent_config_t));
        LOG("AI Agent created: %s", config->model_path);
    }
    return agent;
}

static void ai_agent_process_zero_copy(ai_agent_t* agent, void* buffer) {
    // 模擬 AI 處理
    usleep(5000); // 5ms
}

static void ai_agent_destroy(ai_agent_t* agent) {
    if (agent) {
        free(agent);
    }
}

// 線程資料結構
struct isp_thread_data {
    isp_pipeline_t* pipeline;
    void* input;
    void* output;
};

struct ai_thread_data {
    isp_pipeline_t* pipeline;
    void* buffer;
};

// ISP 處理線程
static void* isp_process_thread(void* arg) {
    struct isp_thread_data* data = (struct isp_thread_data*)arg;
    isp_pipeline_t* pipeline = data->pipeline;
    
    // Demosaic
    isp_demosaic_process(pipeline->modules.demosaic, data->input, data->output);
    
    // 3A 處理
    if (pipeline->config.features.enable_3a) {
        isp_awb_process(pipeline->modules.awb, data->output);
        isp_ae_process(pipeline->modules.ae, data->output);
        isp_af_process(pipeline->modules.af, data->output);
    }
    
    // 降噪
    if (pipeline->config.features.enable_nr) {
        isp_nr_process(pipeline->modules.nr, data->output);
    }
    
    // 銳化
    if (pipeline->config.features.enable_sharpening) {
        isp_sharpen_process(pipeline->modules.sharpening, data->output);
    }
    
    return NULL;
}

// AI 處理線程
static void* ai_process_thread(void* arg) {
    struct ai_thread_data* data = (struct ai_thread_data*)arg;
    isp_pipeline_t* pipeline = data->pipeline;
    
    // 執行所有 AI agents
    for (int i = 0; i < pipeline->num_agents; i++) {
        ai_agent_process_zero_copy(pipeline->ai_agents[i], data->buffer);
    }
    
    return NULL;
}

// 建立 Pipeline
isp_pipeline_t* isp_pipeline_create(const isp_pipeline_config_t* config) {
    isp_pipeline_t* pipeline = calloc(1, sizeof(isp_pipeline_t));
    if (!pipeline) {
        return NULL;
    }
    
    // 複製配置
    memcpy(&pipeline->config, config, sizeof(isp_pipeline_config_t));
    
    // 初始化 UMS
    int ret = aisp_ums_init(&pipeline->ums_ctx, &config->ums_config);
    if (ret < 0) {
        LOG("Failed to initialize UMS: %d", ret);
        free(pipeline);
        return NULL;
    }
    
    // 計算 buffer 大小
    size_t raw_size = config->width * config->height * 2;
    size_t rgb_size = config->width * config->height * 3;
    size_t yuv_size = config->width * config->height * 3 / 2;
    
    // 分配工作緩衝區
    pipeline->buffers.raw_buffer = aisp_ums_alloc_frame_buffer(pipeline->ums_ctx, raw_size);
    pipeline->buffers.rgb_buffer = aisp_ums_alloc_frame_buffer(pipeline->ums_ctx, rgb_size);
    pipeline->buffers.yuv_buffer = aisp_ums_alloc_frame_buffer(pipeline->ums_ctx, yuv_size);
    pipeline->buffers.ai_buffer = aisp_ums_alloc_frame_buffer(pipeline->ums_ctx, rgb_size);
    
    if (!pipeline->buffers.raw_buffer || !pipeline->buffers.rgb_buffer ||
        !pipeline->buffers.yuv_buffer || !pipeline->buffers.ai_buffer) {
        LOG("Failed to allocate buffers");
        isp_pipeline_destroy(pipeline);
        return NULL;
    }
    
    // 設定零拷貝映射
    aisp_ums_setup_zero_copy(pipeline->ums_ctx,
                            pipeline->buffers.rgb_buffer,
                            pipeline->buffers.ai_buffer);
    
    // 初始化 ISP 模組
    pipeline->modules.demosaic = isp_demosaic_init(config->width, config->height, config->bayer_pattern);
    pipeline->modules.awb = isp_awb_init();
    pipeline->modules.ae = isp_ae_init();
    pipeline->modules.af = isp_af_init();
    
    if (config->features.enable_nr) {
        pipeline->modules.nr = isp_nr_init(config->width, config->height);
    }
    
    if (config->features.enable_sharpening) {
        pipeline->modules.sharpening = isp_sharpen_init(config->width, config->height);
    }
    
    LOG("ISP Pipeline created successfully");
    return pipeline;
}

// 處理單一 frame
int isp_pipeline_process_frame(isp_pipeline_t* pipeline, 
                              const void* raw_data,
                              void* output_data) {
    uint64_t start_time = get_time_us();
    
    // 1. 複製 RAW 資料到 UMS buffer
    size_t raw_size = pipeline->config.width * pipeline->config.height * 2;
    memcpy(pipeline->buffers.raw_buffer, raw_data, raw_size);
    
    // 2. 同步快取
    aisp_ums_sync_cache(pipeline->ums_ctx, pipeline->buffers.raw_buffer, raw_size);
    
    // 3. ISP 處理線程
    pthread_t isp_thread, ai_thread;
    
    struct isp_thread_data isp_data = {
        .pipeline = pipeline,
        .input = pipeline->buffers.raw_buffer,
        .output = pipeline->buffers.rgb_buffer
    };
    
    pthread_create(&isp_thread, NULL, isp_process_thread, &isp_data);
    
    // 4. AI 處理 (如果啟用)
    if (pipeline->config.features.enable_ai_enhance && pipeline->num_agents > 0) {
        struct ai_thread_data ai_data = {
            .pipeline = pipeline,
            .buffer = pipeline->buffers.ai_buffer
        };
        
        pthread_create(&ai_thread, NULL, ai_process_thread, &ai_data);
        pthread_join(ai_thread, NULL);
    }
    
    // 等待 ISP 完成
    pthread_join(isp_thread, NULL);
    
    // 5. RGB to YUV 轉換
    isp_rgb_to_yuv(pipeline->buffers.rgb_buffer,
                   pipeline->buffers.yuv_buffer,
                   pipeline->config.width,
                   pipeline->config.height);
    
    // 6. 複製輸出
    size_t yuv_size = pipeline->config.width * pipeline->config.height * 3 / 2;
    memcpy(output_data, pipeline->buffers.yuv_buffer, yuv_size);
    
    // 7. 更新統計
    uint64_t end_time = get_time_us();
    pipeline->stats.frame_count++;
    pipeline->stats.total_time_us += (end_time - start_time);
    pipeline->stats.avg_fps = (float)pipeline->stats.frame_count * 1000000.0f / 
                             pipeline->stats.total_time_us;
    
    return 0;
}

// 加入 AI Agent
int isp_pipeline_add_ai_agent(isp_pipeline_t* pipeline,
                             const ai_agent_config_t* agent_config) {
    if (pipeline->num_agents >= MAX_AI_AGENTS) {
        return -1;
    }
    
    ai_agent_t* agent = ai_agent_create_with_ums(agent_config, pipeline->ums_ctx);
    if (!agent) {
        return -1;
    }
    
    pipeline->ai_agents[pipeline->num_agents++] = agent;
    return 0;
}

// 取得統計資料
void isp_pipeline_get_stats(isp_pipeline_t* pipeline, isp_stats_t* stats) {
    stats->avg_fps = pipeline->stats.avg_fps;
    stats->frames_processed = pipeline->stats.frame_count;
    if (pipeline->stats.frame_count > 0) {
        stats->avg_latency_ms = (float)pipeline->stats.total_time_us / 
                               pipeline->stats.frame_count / 1000.0f;
    }
}

// 清理 Pipeline
void isp_pipeline_destroy(isp_pipeline_t* pipeline) {
    if (!pipeline) return;
    
    // 清理 AI agents
    for (int i = 0; i < pipeline->num_agents; i++) {
        ai_agent_destroy(pipeline->ai_agents[i]);
    }
    
    // 清理 ISP 模組
    if (pipeline->modules.demosaic) isp_demosaic_destroy(pipeline->modules.demosaic);
    if (pipeline->modules.awb) isp_awb_destroy(pipeline->modules.awb);
    if (pipeline->modules.ae) isp_ae_destroy(pipeline->modules.ae);
    if (pipeline->modules.af) isp_af_destroy(pipeline->modules.af);
    if (pipeline->modules.nr) isp_nr_destroy(pipeline->modules.nr);
    if (pipeline->modules.sharpening) isp_sharpen_destroy(pipeline->modules.sharpening);
    
    // 清理 UMS
    aisp_ums_cleanup(pipeline->ums_ctx);
    
    free(pipeline);
    LOG("ISP Pipeline destroyed");
}
