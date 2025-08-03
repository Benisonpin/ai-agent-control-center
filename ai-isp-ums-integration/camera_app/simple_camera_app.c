#define _GNU_SOURCE  // for usleep
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>  // for usleep

// 簡化的相機應用程式

typedef struct {
    int width;
    int height;
    int mode;
    float zoom;
    int iso;
    float exposure_time;
} camera_config_t;

typedef enum {
    MODE_AUTO = 0,
    MODE_PORTRAIT,
    MODE_NIGHT,
    MODE_HDR,
    MODE_PRO
} capture_mode_t;

// 模擬拍照
void capture_photo(camera_config_t* config) {
    printf("\n📸 Capturing photo...\n");
    printf("Mode: ");
    
    switch (config->mode) {
        case MODE_AUTO:
            printf("Auto (AI-powered)\n");
            break;
        case MODE_PORTRAIT:
            printf("Portrait (with bokeh)\n");
            break;
        case MODE_NIGHT:
            printf("Night (multi-frame)\n");
            break;
        case MODE_HDR:
            printf("HDR (3-exposure)\n");
            break;
        case MODE_PRO:
            printf("Pro (manual)\n");
            break;
    }
    
    printf("Resolution: %dx%d\n", config->width, config->height);
    printf("ISO: %d\n", config->iso);
    printf("Exposure: 1/%.0f sec\n", 1.0f / config->exposure_time);
    printf("Zoom: %.1fx\n", config->zoom);
    
    // 模擬處理時間
    usleep(500000); // 500ms
    
    // 生成檔名
    time_t t = time(NULL);
    struct tm* tm = localtime(&t);
    char filename[256];
    sprintf(filename, "IMG_%04d%02d%02d_%02d%02d%02d.jpg",
            tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
            tm->tm_hour, tm->tm_min, tm->tm_sec);
    
    printf("\n✅ Photo saved: %s\n", filename);
    printf("Size: %.1f MB\n", 3.5f + (rand() % 20) / 10.0f);
}

// 相機應用主程式
int main() {
    printf("=== AI ISP Camera App ===\n");
    printf("Version 1.0\n\n");
    
    camera_config_t config = {
        .width = 4000,
        .height = 3000,
        .mode = MODE_AUTO,
        .zoom = 1.0f,
        .iso = 100,
        .exposure_time = 1.0f / 60.0f
    };
    
    while (1) {
        printf("\n📷 Camera Ready\n");
        printf("1. Take Photo\n");
        printf("2. Change Mode\n");
        printf("3. Settings\n");
        printf("4. Exit\n");
        printf("Choice: ");
        
        int choice;
        if (scanf("%d", &choice) != 1) {
            // 清除輸入緩衝區
            while (getchar() != '\n');
            printf("Invalid input\n");
            continue;
        }
        
        switch (choice) {
            case 1:
                capture_photo(&config);
                break;
                
            case 2:
                printf("\nSelect Mode:\n");
                printf("0. Auto\n");
                printf("1. Portrait\n");
                printf("2. Night\n");
                printf("3. HDR\n");
                printf("4. Pro\n");
                printf("Mode: ");
                if (scanf("%d", &config.mode) != 1 || 
                    config.mode < 0 || config.mode > 4) {
                    printf("Invalid mode\n");
                    config.mode = MODE_AUTO;
                }
                break;
                
            case 3:
                printf("\nCamera Settings:\n");
                printf("ISO (100-3200): ");
                if (scanf("%d", &config.iso) != 1) {
                    config.iso = 100;
                }
                if (config.iso < 100) config.iso = 100;
                if (config.iso > 3200) config.iso = 3200;
                
                printf("Zoom (1.0-10.0): ");
                if (scanf("%f", &config.zoom) != 1) {
                    config.zoom = 1.0f;
                }
                if (config.zoom < 1.0f) config.zoom = 1.0f;
                if (config.zoom > 10.0f) config.zoom = 10.0f;
                break;
                
            case 4:
                printf("\nGoodbye!\n");
                return 0;
                
            default:
                printf("\nInvalid choice\n");
        }
    }
    
    return 0;
}
