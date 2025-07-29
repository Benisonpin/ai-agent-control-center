exports.handler = async (event, context) => {
    const { path, action } = JSON.parse(event.body || '{}');
    
    // 模擬 Cloud Shell 專案結構
    const projectStructure = {
        summary: {
            total_files: 11268,
            total_dirs: 1519,
            size_mb: 269,
            last_modified: new Date().toISOString()
        },
        languages: {
            verilog: { count: 51, percentage: 0.45 },
            c: { count: 36, percentage: 0.32 },
            headers: { count: 65, percentage: 0.58 },
            python: { count: 4999, percentage: 44.38 },
            shell: { count: 65, percentage: 0.58 }
        },
        key_modules: {
            rtos_tasks: [
                {
                    file: "vision_task.c",
                    path: "/home/benison_pin/ai_isp_agent/src/rtos/tasks/vision_task.c",
                    size: 15234,
                    last_modified: "2025-07-15T10:30:00Z",
                    status: "compiled"
                },
                {
                    file: "ai_inference_task.c",
                    path: "/home/benison_pin/ai_isp_agent/src/rtos/tasks/ai_inference_task.c",
                    size: 23456,
                    last_modified: "2025-07-20T14:22:00Z",
                    status: "compiled"
                },
                {
                    file: "tracker_task.c",
                    path: "/home/benison_pin/ai_isp_agent/src/rtos/tasks/tracker_task.c",
                    size: 18765,
                    last_modified: "2025-07-18T09:15:00Z",
                    status: "compiled"
                },
                {
                    file: "comm_task.c",
                    path: "/home/benison_pin/ai_isp_agent/src/rtos/tasks/comm_task.c",
                    size: 12890,
                    last_modified: "2025-07-22T16:45:00Z",
                    status: "compiled"
                }
            ],
            rtl_modules: [
                {
                    file: "ai_accelerator_top.v",
                    path: "/home/benison_pin/ai_isp_agent/rtl/ai_accelerator_top.v",
                    size: 45678,
                    last_modified: "2025-07-10T11:20:00Z",
                    status: "synthesized"
                },
                {
                    file: "isp_pipeline.v",
                    path: "/home/benison_pin/ai_isp_agent/rtl/isp_pipeline.v",
                    size: 34567,
                    last_modified: "2025-07-12T13:30:00Z",
                    status: "synthesized"
                },
                {
                    file: "memory_controller.v",
                    path: "/home/benison_pin/ai_isp_agent/rtl/memory_controller.v",
                    size: 28901,
                    last_modified: "2025-07-14T15:45:00Z",
                    status: "synthesized"
                }
            ],
            python_controls: [
                {
                    file: "ai_agent_main.py",
                    path: "/home/benison_pin/ai_isp_agent/python/ai_agent_main.py",
                    size: 12345,
                    last_modified: "2025-07-25T10:00:00Z",
                    status: "active"
                },
                {
                    file: "isp_controller.py",
                    path: "/home/benison_pin/ai_isp_agent/python/isp_controller.py",
                    size: 8765,
                    last_modified: "2025-07-24T14:30:00Z",
                    status: "active"
                },
                {
                    file: "task_scheduler.py",
                    path: "/home/benison_pin/ai_isp_agent/python/task_scheduler.py",
                    size: 9876,
                    last_modified: "2025-07-23T09:15:00Z",
                    status: "active"
                }
            ]
        },
        project_tree: {
            "ai_isp_agent": {
                "src": {
                    "rtos": {
                        "tasks": ["vision_task.c", "ai_inference_task.c", "tracker_task.c", "comm_task.c"],
                        "drivers": ["camera_driver.c", "dma_driver.c", "spi_driver.c"],
                        "kernel": ["scheduler.c", "memory_manager.c", "ipc.c"]
                    },
                    "hal": {
                        "includes": ["hal_gpio.h", "hal_timer.h", "hal_dma.h"],
                        "src": ["hal_init.c", "hal_config.c"]
                    }
                },
                "rtl": {
                    "core": ["ai_accelerator_top.v", "npu_core.v", "tensor_unit.v"],
                    "isp": ["isp_pipeline.v", "demosaic.v", "noise_reduction.v"],
                    "memory": ["memory_controller.v", "ddr_interface.v", "cache.v"]
                },
                "python": {
                    "core": ["ai_agent_main.py", "task_scheduler.py"],
                    "controllers": ["isp_controller.py", "inference_controller.py"],
                    "utils": ["data_processor.py", "performance_monitor.py"]
                },
                "scripts": {
                    "build": ["build_all.sh", "compile_rtl.sh", "build_rtos.sh"],
                    "test": ["run_tests.sh", "validate_rtl.sh"],
                    "deploy": ["deploy_fpga.sh", "flash_firmware.sh"]
                }
            }
        }
    };
    
    // 根據不同的 action 返回不同的資料
    if (action === 'get_summary') {
        return {
            statusCode: 200,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ summary: projectStructure.summary })
        };
    } else if (action === 'get_structure') {
        return {
            statusCode: 200,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ structure: projectStructure.project_tree })
        };
    } else if (action === 'get_modules') {
        return {
            statusCode: 200,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ modules: projectStructure.key_modules })
        };
    } else {
        // 預設返回完整資訊
        return {
            statusCode: 200,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(projectStructure)
        };
    }
};
