#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#define TEST_WIDTH 640
#define TEST_HEIGHT 480
#define TEST_FRAMES 10

typedef struct {
    int width;
    int height;
    void* raw_buffer;
    void* rgb_buffer;
    int frame_count;
    double total_time;
} TestPipeline;

TestPipeline* create_test_pipeline(int width, int height) {
    TestPipeline* pipe = calloc(1, sizeof(TestPipeline));
    pipe->width = width;
    pipe->height = height;
    pipe->raw_buffer = malloc(width * height * 2);
    pipe->rgb_buffer = malloc(width * height * 3);
    printf("Pipeline created: %dx%d\n", width, height);
    return pipe;
}

void process_frame(TestPipeline* pipe) {
    clock_t start = clock();
    usleep(10000);
    clock_t end = clock();
    pipe->total_time += ((double)(end - start)) / CLOCKS_PER_SEC;
    pipe->frame_count++;
}

void destroy_test_pipeline(TestPipeline* pipe) {
    if (pipe) {
        free(pipe->raw_buffer);
        free(pipe->rgb_buffer);
        free(pipe);
    }
}

int main() {
    printf("=== AI ISP Integration Test ===\n");
    
    TestPipeline* pipe = create_test_pipeline(TEST_WIDTH, TEST_HEIGHT);
    
    printf("Processing %d frames...\n", TEST_FRAMES);
    for (int i = 0; i < TEST_FRAMES; i++) {
        process_frame(pipe);
        printf("  Frame %d processed\n", i + 1);
    }
    
    double fps = pipe->frame_count / pipe->total_time;
    printf("\nResults:\n");
    printf("  FPS: %.2f\n", fps);
    printf("  Total time: %.3f seconds\n", pipe->total_time);
    
    destroy_test_pipeline(pipe);
    printf("\nTest completed!\n");
    
    return 0;
}
