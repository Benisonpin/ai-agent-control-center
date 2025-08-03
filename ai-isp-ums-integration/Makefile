CC = gcc
CFLAGS = -Wall -g -O2 -I. -pthread
LDFLAGS = -pthread -lrt -lm

# 源文件
HAL_SRCS = hal/src/ums_wrapper.c hal/src/ums_hal_integration.c
ISP_SRCS = isp/isp_pipeline_ums.c

# 目標文件
HAL_OBJS = $(HAL_SRCS:.c=.o)
ISP_OBJS = $(ISP_SRCS:.c=.o)

# 可執行文件
TARGETS = test_simple test_aisp_integration

all: $(TARGETS)

# 編譯規則
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# 建立靜態庫
libaisp_ums.a: $(HAL_OBJS) $(ISP_OBJS)
	a
# 編譯 HAL 層
gcc -c -o hal_ums_wrapper.o hal/src/ums_wrapper.c -I. -pthread
gcc -c -o hal_ums_integration.o hal/src/ums_hal_integration.c -I. -pthread

# 編譯 ISP Pipeline
gcc -c -o isp_pipeline_ums.o isp/isp_pipeline_ums.c -I. -pthread

# 建立靜態庫
ar rcs libaisp_ums.a hal_ums_wrapper.o hal_ums_integration.o isp_pipeline_ums.o

# 編譯整合測試
gcc -o test_aisp_integration tests/integration/test_aisp_ums_integration.c -L. -laisp_ums -I. -pthread -lrt -lm
./test_aisp_integration
cat > simple_integration_test.c << 'ENDFILE'
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <unistd.h>

// 模擬 ISP 處理
void simulate_isp_processing(int width, int height, int frames) {
    printf("\n=== Simulated ISP Processing ===\n");
    printf("Resolution: %dx%d\n", width, height);
    printf("Frames: %d\n", frames);
    
    size_t frame_size = width * height * 2; // RAW
    void* buffer = malloc(frame_size);
    
    clock_t start = clock();
    
    for (int i = 0; i < frames; i++) {
        // 模擬處理時間
        usleep(10000); // 10ms per frame
        
        if (i % 10 == 0) {
            printf("  Processed frame %d\n", i);
        }
    }
    
    clock_t end = clock();
    double elapsed = ((double)(end - start)) / CLOCKS_PER_SEC;
    double fps = frames / elapsed;
    
    printf("\nResults:\n");
    printf("  Total time: %.2f seconds\n", elapsed);
    printf("  Average FPS: %.2f\n", fps);
    printf("  Throughput: %.2f MB/s\n", (frames * frame_size) / (elapsed * 1024 * 1024));
    
    free(buffer);
}

// 模擬零拷貝測試
void test_zero_copy() {
    printf("\n=== Zero Copy Test ===\n");
    
    size_t size = 4 * 1024 * 1024; // 4MB
    void* src = malloc(size);
    void* dst = malloc(size);
    
    // 填充資料
    memset(src, 0xAA, size);
    
    // 測試拷貝
    clock_t start = clock();
    memcpy(dst, src, size);
    clock_t end = clock();
    
    double copy_time = ((double)(end - start)) / CLOCKS_PER_SEC * 1000;
    printf("Memory copy time: %.3f ms\n", copy_time);
    printf("Bandwidth: %.2f GB/s\n", size / (copy_time * 1e6));
    
    // 驗證
    if (memcmp(src, dst, size) == 0) {
        printf("✓ Data verified\n");
    }
    
    free(src);
    free(dst);
}

int main() {
    printf("=== Simple AI ISP Integration Test ===\n");
    
    // 測試不同解析度
    simulate_isp_processing(640, 480, 100);   // VGA
    simulate_isp_processing(1920, 1080, 30);  // Full HD
    
    // 測試零拷貝
    test_zero_copy();
    
    printf("\n✓ All tests completed\n");
    return 0;
}

# 簡單測試目標
simple_test: simple_test.c
	$(CC) $(CFLAGS) -I./include -o $@ $< $(LDFLAGS)

basic_test: basic_test.c
	$(CC) $(CFLAGS) -I./include -o $@ $< $(LDFLAGS)

# OTA Module
ota: hal/src/ota_hal.c ai_models/scene_detection/scene_detector_ota.c
	$(CC) $(CFLAGS) -c hal/src/ota_hal.c -o build/hal/ota_hal.o
	$(CC) $(CFLAGS) -c ai_models/scene_detection/scene_detector_ota.c -o build/ai/scene_detector_ota.o
	@echo "✅ OTA module built successfully"
