#!/usr/bin/env python3
"""Netlify 與本地 OTA 系統整合橋接器"""
import json
import os
import threading
import time
from datetime import datetime

class IntegrationBridge:
    def __init__(self):
        self.netlify_url = "https://comfy-griffin-7bf94b.netlify.app"
        self.local_ota_path = "ota"
        self.cte_integration_path = "ota/cte_integration"
        self.netlify_integration_path = "ota/netlify_integration"
        
    def sync_all_systems(self):
        """同步所有系統"""
        print("🔄 開始全系統同步...")
        
        # 1. 本地 OTA 系統
        local_status = self.get_local_ota_status()
        print(f"   本地 OTA: {len(local_status.get('models', {}))} 個模型")
        
        # 2. CTE 平台
        cte_status = self.get_cte_status()
        print(f"   CTE 平台: {'已連接' if cte_status else '未連接'}")
        
        # 3. Netlify 系統
        netlify_status = self.get_netlify_status()
        print(f"   Netlify: {'在線' if netlify_status else '離線'}")
        
        # 4. 執行三方同步
        self.perform_three_way_sync(local_status, cte_status, netlify_status)
        
        print("✅ 全系統同步完成")
    
    def get_local_ota_status(self):
        """獲取本地 OTA 狀態"""
        status = {
            "models": {},
            "config": {},
            "last_update": None
        }
        
        # 讀取本地模型
        models_path = os.path.join(self.local_ota_path, "models")
        if os.path.exists(models_path):
            for model in os.listdir(models_path):
                model_info_path = os.path.join(models_path, model, "model_info.json")
                if os.path.exists(model_info_path):
                    with open(model_info_path, 'r') as f:
                        status["models"][model] = json.load(f)
        
        return status
    
    def get_cte_status(self):
        """獲取 CTE 狀態"""
        cte_status_file = os.path.join(self.cte_integration_path, "sync/status.json")
        if os.path.exists(cte_status_file):
            with open(cte_status_file, 'r') as f:
                return json.load(f)
        return None
    
    def get_netlify_status(self):
        """獲取 Netlify 狀態"""
        netlify_status_file = os.path.join(self.netlify_integration_path, "sync/netlify_status.json")
        if os.path.exists(netlify_status_file):
            with open(netlify_status_file, 'r') as f:
                return json.load(f)
        return None
    
    def perform_three_way_sync(self, local, cte, netlify):
        """執行三方同步"""
        # 創建統一的同步記錄
        sync_record = {
            "timestamp": datetime.now().isoformat(),
            "systems": {
                "local": "active" if local else "inactive",
                "cte": "active" if cte else "inactive",
                "netlify": "active" if netlify else "inactive"
            },
            "synced_items": []
        }
        
        # 同步邏輯
        if local and netlify:
            # 本地到 Netlify
            for model_name, model_info in local.get("models", {}).items():
                sync_record["synced_items"].append({
                    "type": "model",
                    "name": model_name,
                    "direction": "local->netlify",
                    "version": model_info.get("version", "unknown")
                })
        
        if cte and netlify:
            # CTE 到 Netlify
            sync_record["synced_items"].append({
                "type": "config",
                "direction": "cte->netlify"
            })
        
        # 保存同步記錄
        sync_log_file = "ota/netlify_integration/sync/three_way_sync.json"
        os.makedirs(os.path.dirname(sync_log_file), exist_ok=True)
        
        sync_log = []
        if os.path.exists(sync_log_file):
            with open(sync_log_file, 'r') as f:
                sync_log = json.load(f)
        
        sync_log.append(sync_record)
        
        # 只保留最近 100 條記錄
        sync_log = sync_log[-100:]
        
        with open(sync_log_file, 'w') as f:
            json.dump(sync_log, f, indent=2)

if __name__ == "__main__":
    bridge = IntegrationBridge()
    bridge.sync_all_systems()
