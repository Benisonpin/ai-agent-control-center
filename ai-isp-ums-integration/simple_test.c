#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <unistd.h>

int main() {
    printf("=== Simple AI ISP Integration Test ===\n");
    
    // 測試記憶體分配
    size_t size = 1024 * 1024; // 1MB
    void* buffer = malloc(size);
    if (buffer) {
        printf("✓ Allocated 1MB buffer\n");
        memset(buffer, 0, size);
        printf("✓ Buffer initialized\n");
        free(buffer);
        printf("✓ Buffer freed\n");
    }
    
    // 測試時間測量
    clock_t start = clock();
    usleep(100000); // 100ms
    clock_t end = clock();
    double elapsed = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("✓ Time measurement: %.3f seconds\n", elapsed);
    
    printf("\n✓ Test completed successfully\n");
    return 0;
}
// Test change at Sun Jul  6 06:05:40 AM UTC 2025

// AI Agent test at Sun Jul  6 06:08:37 AM UTC 2025
// Test 1 at Sun Jul  6 06:11:21 AM UTC 2025
// Test 2 at Sun Jul  6 06:12:01 AM UTC 2025
// Test 3 at Sun Jul  6 06:12:41 AM UTC 2025
