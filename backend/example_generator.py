#!/usr/bin/env python3
"""
範例：使用 AI Agent 生成 Verilog 模組
"""

import asyncio
import requests
import json

API_URL = "http://localhost:8000"

async def generate_edge_detection_filter():
    """生成邊緣檢測濾波器"""
    specs = {
        "input_width": 8,
        "input_height": 8,
        "pixel_width": 8,
        "filter_type": "sobel",
        "pipeline_stages": 3
    }
    
    response = requests.post(
        f"{API_URL}/generate/verilog",
        json={
            "module_type": "filter",
            "specifications": specs,
            "creativity_level": 0.8
        }
    )
    
    result = response.json()
    print("生成的 Verilog 程式碼：")
    print(result["verilog_code"])
    
    # 儲存到檔案
    with open("generated_modules/edge_detection.v", "w") as f:
        f.write(result["verilog_code"])

async def optimize_existing_module():
    """優化現有模組"""
    with open("path/to/existing/module.v", "r") as f:
        code = f.read()
    
    response = requests.post(
        f"{API_URL}/optimize/verilog",
        json={
            "verilog_code": code,
            "optimization_goals": ["area", "speed"]
        }
    )
    
    result = response.json()
    print("優化結果：")
    print(result["optimized_code"])

if __name__ == "__main__":
    asyncio.run(generate_edge_detection_filter())
