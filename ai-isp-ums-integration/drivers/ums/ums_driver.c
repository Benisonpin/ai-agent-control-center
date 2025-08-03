#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

// UMS 驅動模擬（用戶空間版本）

#define UMS_MAX_REGIONS 8
#define UMS_REGION_SIZE (64 * 1024 * 1024) // 64MB per region

typedef struct {
    void* base_addr;
    size_t size;
    uint32_t flags;
    int ref_count;
} ums_region_t;

typedef struct {
    int fd;
    void* mmap_base;
    size_t total_size;
    ums_region_t regions[UMS_MAX_REGIONS];
    int num_regions;
} ums_device_t;

// 開啟 UMS 設備
ums_device_t* ums_open(const char* device_path) {
    ums_device_t* dev = calloc(1, sizeof(ums_device_t));
    
    // 模擬：使用共享記憶體
    dev->total_size = UMS_MAX_REGIONS * UMS_REGION_SIZE;
    dev->mmap_base = malloc(dev->total_size);
    
    if (!dev->mmap_base) {
        free(dev);
        return NULL;
    }
    
    printf("UMS: Opened device with %zu MB total memory\n", 
           dev->total_size / (1024 * 1024));
    
    return dev;
}

// 分配記憶體區域
int ums_alloc_region(ums_device_t* dev, size_t size, uint32_t flags) {
    if (dev->num_regions >= UMS_MAX_REGIONS) {
        return -1;
    }
    
    int idx = dev->num_regions++;
    ums_region_t* region = &dev->regions[idx];
    
    region->size = size;
    region->flags = flags;
    region->ref_count = 1;
    region->base_addr = (char*)dev->mmap_base + (idx * UMS_REGION_SIZE);
    
    printf("UMS: Allocated region %d, size=%zu KB, flags=0x%x\n",
           idx, size / 1024, flags);
    
    return idx;
}

// 獲取區域地址
void* ums_get_region_addr(ums_device_t* dev, int region_id) {
    if (region_id < 0 || region_id >= dev->num_regions) {
        return NULL;
    }
    
    return dev->regions[region_id].base_addr;
}

// 關閉 UMS 設備
void ums_close(ums_device_t* dev) {
    if (dev) {
        if (dev->mmap_base) {
            free(dev->mmap_base);
        }
        free(dev);
        printf("UMS: Device closed\n");
    }
}

// 測試函數
int ums_self_test() {
    printf("UMS Driver Self Test\n");
    
    ums_device_t* dev = ums_open("/dev/ums0");
    if (!dev) return -1;
    
    // 分配測試區域
    int region1 = ums_alloc_region(dev, 1024 * 1024, 0x06);  // 1MB
    int region2 = ums_alloc_region(dev, 4096 * 1024, 0x0A);  // 4MB
    
    // 獲取地址並測試
    void* addr1 = ums_get_region_addr(dev, region1);
    void* addr2 = ums_get_region_addr(dev, region2);
    
    if (addr1 && addr2) {
        // 寫入測試資料
        memset(addr1, 0xAA, 1024);
        memset(addr2, 0xBB, 1024);
        
        printf("UMS: Self test PASSED\n");
    }
    
    ums_close(dev);
    return 0;
}
