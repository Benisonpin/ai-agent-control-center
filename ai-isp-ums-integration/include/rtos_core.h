#ifndef RTOS_CORE_H
#define RTOS_CORE_H

#include <stdint.h>
#include <stdbool.h>

// 基本 RTOS 定義
typedef void (*task_func_t)(void* params);

typedef struct {
    char name[32];
    task_func_t function;
    void* params;
    uint32_t priority;
    uint32_t stack_size;
} rtos_task_t;

// RTOS API
int rtos_init(void);
int rtos_create_task(rtos_task_t* task);
int rtos_start_scheduler(void);
void rtos_delay(uint32_t ms);

// 同步原語
typedef struct {
    uint32_t count;
} rtos_semaphore_t;

int rtos_sem_create(rtos_semaphore_t* sem, uint32_t initial);
int rtos_sem_take(rtos_semaphore_t* sem, uint32_t timeout);
int rtos_sem_give(rtos_semaphore_t* sem);

#endif // RTOS_CORE_H
