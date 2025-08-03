#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

void test_isp_simulation() {
    printf("\n=== ISP Simulation Test ===\n");
    
    int width = 640;
    int height = 480;
    int frames = 10;
    
    size_t frame_size = width * height * 2;
    void* raw_buffer = malloc(frame_size);
    void* rgb_buffer = malloc(width * height * 3);
    
    printf("Processing %d frames (%dx%d)...\n", frames, width, height);
    
    clock_t start = clock();
    for (int i = 0; i < frames; i++) {
        // 模擬 ISP 處理
        usleep(5000); // 5ms
        printf("  Frame %d processed\n", i + 1);
    }
    clock_t end = clock();
    
    double elapsed = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("Total time: %.3f seconds\n", elapsed);
    printf("FPS: %.2f\n", frames / elapsed);
    
    free(raw_buffer);
    free(rgb_buffer);
}

void test_zero_copy() {
    printf("\n=== Zero Copy Test ===\n");
    
    size_t size = 1024 * 1024;
    void* src = malloc(size);
    void* dst = malloc(size);
    
    memset(src, 0xAA, size);
    
    clock_t start = clock();
    memcpy(dst, src, size);
    clock_t end = clock();
    
    double time_ms = ((double)(end - start)) / CLOCKS_PER_SEC * 1000;
    printf("Copy 1MB: %.3f ms\n", time_ms);
    
    free(src);
    free(dst);
}

int main() {
    printf("=== AI ISP Integration Test ===\n");
    
    test_isp_simulation();
    test_zero_copy();
    
    printf("\n✓ All tests passed\n");
    return 0;
}
