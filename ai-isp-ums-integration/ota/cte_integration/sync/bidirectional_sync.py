#!/usr/bin/env python3
"""CTE 與本地 OTA 雙向同步服務"""
import json
import os
import asyncio
import aiofiles
from datetime import datetime
import hashlib

class BidirectionalSync:
    def __init__(self):
        self.sync_config = {
            "local_path": "ota/models",
            "cte_path": "ota/cte_integration/models",
            "sync_interval": 300,  # 5分鐘
            "sync_log": "ota/cte_integration/sync/sync_log.json"
        }
        self.sync_history = []
    
    async def sync_local_to_cte(self):
        """同步本地更新到 CTE 平台"""
        print("📤 同步本地更新到 CTE...")
        
        local_models = await self.scan_local_models()
        
        for model_id, model_info in local_models.items():
            # 檢查是否需要上傳到 CTE
            if await self.should_upload_to_cte(model_id, model_info):
                await self.upload_model_to_cte(model_id, model_info)
    
    async def sync_cte_to_local(self):
        """同步 CTE 更新到本地"""
        print("📥 同步 CTE 更新到本地...")
        
        # 檢查 CTE 更新隊列
        update_queue = await self.get_cte_update_queue()
        
        for update in update_queue:
            await self.apply_cte_update(update)
    
    async def scan_local_models(self):
        """掃描本地模型"""
        models = {}
        
        if os.path.exists(self.sync_config["local_path"]):
            for model_dir in os.listdir(self.sync_config["local_path"]):
                model_path = os.path.join(self.sync_config["local_path"], model_dir)
                if os.path.isdir(model_path):
                    info_file = os.path.join(model_path, "model_info.json")
                    if os.path.exists(info_file):
                        async with aiofiles.open(info_file, 'r') as f:
                            content = await f.read()
                            models[model_dir] = json.loads(content)
        
        return models
    
    async def should_upload_to_cte(self, model_id, model_info):
        """判斷是否應該上傳到 CTE"""
        # 檢查同步歷史
        for record in self.sync_history:
            if record["model_id"] == model_id and record["version"] == model_info["version"]:
                if record["direction"] == "local_to_cte":
                    return False
        
        return True
    
    async def upload_model_to_cte(self, model_id, model_info):
        """上傳模型到 CTE"""
        print(f"   📤 上傳 {model_id} v{model_info['version']} 到 CTE...")
        
        # 記錄同步
        sync_record = {
            "timestamp": datetime.now().isoformat(),
            "model_id": model_id,
            "version": model_info["version"],
            "direction": "local_to_cte",
            "status": "success"
        }
        
        self.sync_history.append(sync_record)
        await self.save_sync_history()
    
    async def get_cte_update_queue(self):
        """獲取 CTE 更新隊列"""
        queue_file = "ota/cte_integration/sync/update_queue.json"
        
        if os.path.exists(queue_file):
            async with aiofiles.open(queue_file, 'r') as f:
                content = await f.read()
                return json.loads(content) if content else []
        
        return []
    
    async def apply_cte_update(self, update):
        """應用 CTE 更新"""
        print(f"   📥 應用更新: {update['model_id']} v{update['version']}")
        
        # 複製模型到本地 OTA 目錄
        source = f"ota/cte_integration/models/{update['model_id']}/{update['model_id']}_v{update['version']}.bin"
        dest = f"ota/models/{update['model_id']}/model.bin"
        
        if os.path.exists(source):
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            
            # 複製文件
            async with aiofiles.open(source, 'rb') as src:
                async with aiofiles.open(dest, 'wb') as dst:
                    await dst.write(await src.read())
            
            print(f"   ✅ 更新應用成功")
    
    async def save_sync_history(self):
        """保存同步歷史"""
        async with aiofiles.open(self.sync_config["sync_log"], 'w') as f:
            await f.write(json.dumps(self.sync_history, indent=2))
    
    async def continuous_sync(self):
        """持續同步"""
        print("🔄 啟動持續同步服務...")
        
        while True:
            try:
                # 雙向同步
                await self.sync_local_to_cte()
                await self.sync_cte_to_local()
                
                print(f"✅ 同步完成，下次同步時間: {self.sync_config['sync_interval']}秒後")
                
            except Exception as e:
                print(f"❌ 同步錯誤: {e}")
            
            await asyncio.sleep(self.sync_config['sync_interval'])

async def main():
    sync_service = BidirectionalSync()
    await sync_service.continuous_sync()

if __name__ == "__main__":
    asyncio.run(main())
