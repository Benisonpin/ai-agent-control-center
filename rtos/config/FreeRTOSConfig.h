/**
 * @file FreeRTOSConfig.h
 * @brief FreeRTOS Configuration for CTE Vibe Code Drone AI
 */

#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

/* Scheduling */
#define configUSE_PREEMPTION                    1
#define configUSE_TIME_SLICING                  1
#define configMAX_PRIORITIES                    8
#define configIDLE_SHOULD_YIELD                 1

/* System */
#define configCPU_CLOCK_HZ                      200000000  // 200MHz
#define configTICK_RATE_HZ                      1000       // 1ms tick
#define configMAX_TASK_NAME_LEN                 16
#define configUSE_16_BIT_TICKS                  0

/* Memory management */
#define configMINIMAL_STACK_SIZE                128
#define configTOTAL_HEAP_SIZE                   (64 * 1024)  // 64KB heap
#define configUSE_MALLOC_FAILED_HOOK            1

/* Power management for 3.5W efficiency */
#define configUSE_IDLE_HOOK                     1
#define configUSE_TICKLESS_IDLE                 1

/* AI task optimization */
#define configUSE_TASK_NOTIFICATIONS            1
#define configUSE_COUNTING_SEMAPHORES           1
#define configUSE_QUEUE_SETS                    1

/* Performance monitoring */
#define configGENERATE_RUN_TIME_STATS           1
#define configUSE_STATS_FORMATTING_FUNCTIONS    1

#endif /* FREERTOS_CONFIG_H */
