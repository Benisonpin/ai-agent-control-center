#!/usr/bin/env python3
import json
import glob

# 找到最新的結果檔案
files = sorted(glob.glob("ai_isp_results_*.json"))
if files:
    latest = files[-1]
    print(f"📊 分析檔案: {latest}\n")
    
    with open(latest, 'r') as f:
        data = json.load(f)
    
    print("場景分布圖:")
    scene_count = {}
    for item in data:
        scene = item['scene_name']
        scene_count[scene] = scene_count.get(scene, 0) + 1
    
    for scene, count in scene_count.items():
        bar = "█" * (count * 10)
        print(f"{scene:15s} {bar} ({count})")
    
    print("\n參數變化:")
    for item in data:
        p = item['parameters']
        print(f"Frame {item['frame']}: BL=0x{p['black_level']:02X}, "
              f"AWB_R=0x{p['awb_r_gain']:03X}, NR={p['nr_strength']}")
else:
    print("找不到結果檔案!")
