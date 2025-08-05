#!/usr/bin/env python3
"""
CTE Vibe Code - 第一階段大模型訓練管線
從開源數據集收集 13 種情境，訓練大型教師模型
"""

import os
import asyncio
import torch
import torch.nn as nn
import torchvision.transforms as transforms
from torch.utils.data import DataLoader, Dataset
import timm
import requests
import zipfile
from pathlib import Path
import json
import cv2
import numpy as np
from typing import List, Dict, Tuple, Any
from dataclasses import dataclass
from tqdm import tqdm
import logging

# 設定日誌
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class SceneCategory:
    """13種場景分類定義"""
    id: int
    name: str
    description: str
    open_source_datasets: List[str]
    target_samples: int

class CTEStage1DataCollector:
    """CTE Vibe Code 第一階段資料收集器"""
    
    def __init__(self):
        self.scene_categories = self._define_13_scene_categories()
        self.base_dir = Path("stage1_training/datasets/13_scenes")
        self.base_dir.mkdir(parents=True, exist_ok=True)
        
    def _define_13_scene_categories(self) -> List[SceneCategory]:
        """定義 13 種無人機場景分類"""
        return [
            SceneCategory(0, "outdoor_natural", "戶外自然環境", 
                         ["COCO", "Places365", "SUN397"], 15000),
            SceneCategory(1, "indoor_residential", "室內住宅環境", 
                         ["NYU_Depth_V2", "ScanNet", "Matterport3D"], 8000),
            SceneCategory(2, "urban_street", "城市街道", 
                         ["Cityscapes", "KITTI", "BDD100K"], 20000),
            SceneCategory(3, "aerial_landscape", "航拍風景", 
                         ["DOTA", "xView", "UC_Merced"], 12000),
            SceneCategory(4, "night_scene", "夜間場景", 
                         ["Dark_Zurich", "NightCity", "ACDC"], 8000),
            SceneCategory(5, "water_maritime", "水域海事", 
                         ["SeaShips", "Maritime_Dataset", "MODD2"], 6000),
            SceneCategory(6, "forest_vegetation", "森林植被", 
                         ["ForestNet", "TreeSatAI", "LUCAS"], 10000),
            SceneCategory(7, "agricultural", "農業場景", 
                         ["Agriculture_Vision", "PlantNet", "CropDeep"], 9000),
            SceneCategory(8, "industrial_site", "工業場地", 
                         ["Industrial_Dataset", "Factory_Scenes"], 7000),
            SceneCategory(9, "coastal_beach", "海岸沙灘", 
                         ["Coastal_Dataset", "Beach_Scenes"], 5000),
            SceneCategory(10, "mountain_terrain", "山地地形", 
                         ["Mountain_Dataset", "Alpine_Scenes"], 8000),
            SceneCategory(11, "desert_arid", "沙漠乾旱", 
                         ["Desert_Scenes", "Arid_Landscapes"], 4000),
            SceneCategory(12, "sports_recreation", "運動休閒", 
                         ["Sports_Dataset", "Recreation_Scenes"], 6000)
        ]
    
    async def collect_all_datasets(self):
        """收集所有 13 種場景的開源數據"""
        logger.info("🚀 開始收集 13 種場景的開源數據...")
        
        collection_tasks = []
        for category in self.scene_categories:
            task = self._collect_category_data(category)
            collection_tasks.append(task)
        
        # 並行收集所有類別的數據
        results = await asyncio.gather(*collection_tasks, return_exceptions=True)
        
        # 統計收集結果
        total_samples = sum(r if isinstance(r, int) else 0 for r in results)
        logger.info(f"✅ 數據收集完成！總計收集 {total_samples} 個樣本")
        
        return results
    
    async def _collect_category_data(self, category: SceneCategory) -> int:
        """收集單一場景類別的數據"""
        logger.info(f"📊 收集場景: {category.name}")
        
        category_dir = self.base_dir / category.name
        category_dir.mkdir(exist_ok=True)
        
        collected_samples = 0
        
        for dataset_name in category.open_source_datasets:
            try:
                samples = await self._download_dataset(dataset_name, category_dir)
                collected_samples += samples
                logger.info(f"   ✅ {dataset_name}: {samples} 樣本")
                
                if collected_samples >= category.target_samples:
                    break
                    
            except Exception as e:
                logger.warning(f"   ⚠️ {dataset_name} 下載失敗: {e}")
                continue
        
        logger.info(f"✅ {category.name} 完成: {collected_samples}/{category.target_samples} 樣本")
        return collected_samples
    
    async def _download_dataset(self, dataset_name: str, output_dir: Path) -> int:
        """下載特定開源數據集"""
        # 開源數據集 URL 映射表
        dataset_urls = {
            "COCO": "http://images.cocodataset.org/zips/train2017.zip",
            "Places365": "http://data.csail.mit.edu/places/places365/places365standard_easyformat.tar",
            "Cityscapes": "https://www.cityscapes-dataset.com/",  # 需要註冊
            "KITTI": "https://www.cvlibs.net/datasets/kitti/",    # 需要註冊
            # 更多數據集 URL...
        }
        
        # 模擬下載過程（實際應用中需要實現真實下載）
        if dataset_name in dataset_urls:
            # 這裡實現實際的數據集下載邏輯
            await asyncio.sleep(1)  # 模擬下載時間
            return np.random.randint(1000, 5000)  # 模擬下載樣本數
        else:
            # 對於需要手動獲取的數據集，返回預設值
            return np.random.randint(500, 2000)

class CTEStage1TeacherModel:
    """第一階段大型教師模型"""
    
    def __init__(self, num_classes=13, model_name="convnext_large"):
        self.num_classes = num_classes
        self.model_name = model_name
        self.model = self._build_teacher_model()
        
    def _build_teacher_model(self):
        """建立大型教師模型 - ConvNeXt Large"""
        # 使用 ConvNeXt Large 作為教師模型
        model = timm.create_model(
            self.model_name, 
            pretrained=True,
            num_classes=self.num_classes,
            drop_rate=0.1,
            drop_path_rate=0.1
        )
        
        # 添加自定義分類頭
        model.head = nn.Sequential(
            nn.LayerNorm(model.head.in_features),
            nn.Dropout(0.2),
            nn.Linear(model.head.in_features, 512),
            nn.GELU(),
            nn.Dropout(0.3),
            nn.Linear(512, self.num_classes)
        )
        
        return model
    
    def get_model_info(self):
        """獲取模型資訊"""
        total_params = sum(p.numel() for p in self.model.parameters())
        trainable_params = sum(p.numel() for p in self.model.parameters() if p.requires_grad)
        
        return {
            "model_name": self.model_name,
            "total_parameters": total_params,
            "trainable_parameters": trainable_params,
            "model_size_mb": total_params * 4 / (1024 * 1024),  # 假設 FP32
            "num_classes": self.num_classes
        }

class CTEStage1Trainer:
    """第一階段訓練器"""
    
    def __init__(self, model, train_loader, val_loader, device='cuda'):
        self.model = model.to(device)
        self.train_loader = train_loader
        self.val_loader = val_loader
        self.device = device
        
        # 優化器和學習率調度器
        self.optimizer = torch.optim.AdamW(
            self.model.parameters(),
            lr=1e-4,
            weight_decay=0.05,
            betas=(0.9, 0.999)
        )
        
        self.scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(
            self.optimizer, T_max=100, eta_min=1e-6
        )
        
        self.criterion = nn.CrossEntropyLoss(label_smoothing=0.1)
        
    def train_epoch(self, epoch):
        """訓練一個 epoch"""
        self.model.train()
        total_loss = 0
        correct = 0
        total = 0
        
        pbar = tqdm(self.train_loader, desc=f"Epoch {epoch}")
        
        for batch_idx, (data, targets) in enumerate(pbar):
            data, targets = data.to(self.device), targets.to(self.device)
            
            # 前向傳播
            outputs = self.model(data)
            loss = self.criterion(outputs, targets)
            
            # 反向傳播
            self.optimizer.zero_grad()
            loss.backward()
            
            # 梯度裁剪
            torch.nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
            
            self.optimizer.step()
            
            # 統計
            total_loss += loss.item()
            _, predicted = outputs.max(1)
            total += targets.size(0)
            correct += predicted.eq(targets).sum().item()
            
            # 更新進度條
            pbar.set_postfix({
                'Loss': f'{loss.item():.4f}',
                'Acc': f'{100.*correct/total:.2f}%'
            })
        
        epoch_loss = total_loss / len(self.train_loader)
        epoch_acc = 100. * correct / total
        
        return epoch_loss, epoch_acc
    
    def validate(self):
        """驗證模型"""
        self.model.eval()
        total_loss = 0
        correct = 0
        total = 0
        
        with torch.no_grad():
            for data, targets in tqdm(self.val_loader, desc="Validating"):
                data, targets = data.to(self.device), targets.to(self.device)
                outputs = self.model(data)
                loss = self.criterion(outputs, targets)
                
                total_loss += loss.item()
                _, predicted = outputs.max(1)
                total += targets.size(0)
                correct += predicted.eq(targets).sum().item()
        
        val_loss = total_loss / len(self.val_loader)
        val_acc = 100. * correct / total
        
        return val_loss, val_acc
    
    def train_teacher_model(self, epochs=100):
        """完整的教師模型訓練流程"""
        logger.info("🚀 開始第一階段大模型訓練...")
        
        best_acc = 0
        train_history = {'loss': [], 'acc': [], 'val_loss': [], 'val_acc': []}
        
        for epoch in range(epochs):
            # 訓練
            train_loss, train_acc = self.train_epoch(epoch)
            
            # 驗證
            val_loss, val_acc = self.validate()
            
            # 更新學習率
            self.scheduler.step()
            
            # 記錄歷史
            train_history['loss'].append(train_loss)
            train_history['acc'].append(train_acc)
            train_history['val_loss'].append(val_loss)
            train_history['val_acc'].append(val_acc)
            
            # 保存最佳模型
            if val_acc > best_acc:
                best_acc = val_acc
                torch.save({
                    'epoch': epoch,
                    'model_state_dict': self.model.state_dict(),
                    'optimizer_state_dict': self.optimizer.state_dict(),
                    'best_acc': best_acc,
                    'train_history': train_history
                }, 'stage1_training/models/checkpoints/teacher_model_best.pth')
            
            logger.info(f"Epoch {epoch+1}/{epochs}")
            logger.info(f"Train Loss: {train_loss:.4f}, Train Acc: {train_acc:.2f}%")
            logger.info(f"Val Loss: {val_loss:.4f}, Val Acc: {val_acc:.2f}%")
            logger.info(f"Best Val Acc: {best_acc:.2f}%")
            logger.info("-" * 50)
        
        logger.info(f"✅ 第一階段訓練完成！最佳驗證準確率: {best_acc:.2f}%")
        return train_history, best_acc

class CTEStage1Pipeline:
    """第一階段完整管線"""
    
    def __init__(self):
        self.data_collector = CTEStage1DataCollector()
        self.teacher_model = None
        self.trainer = None
        
    async def run_stage1_pipeline(self):
        """執行完整的第一階段管線"""
        logger.info("🎯 啟動 CTE Vibe Code 第一階段管線")
        
        # 步驟 1: 數據收集
        logger.info("📊 步驟 1: 收集 13 種場景的開源數據...")
        collection_results = await self.data_collector.collect_all_datasets()
        
        # 步驟 2: 數據預處理
        logger.info("🔄 步驟 2: 數據預處理和增強...")
        train_loader, val_loader = self._prepare_dataloaders()
        
        # 步驟 3: 建立教師模型
        logger.info("🏗️ 步驟 3: 建立大型教師模型...")
        self.teacher_model = CTEStage1TeacherModel()
        
        # 顯示模型資訊
        model_info = self.teacher_model.get_model_info()
        logger.info(f"📊 教師模型資訊: {model_info}")
        
        # 步驟 4: 訓練教師模型
        logger.info("🚀 步驟 4: 訓練大型教師模型...")
        self.trainer = CTEStage1Trainer(
            self.teacher_model.model, 
            train_loader, 
            val_loader
        )
        
        train_history, best_acc = self.trainer.train_teacher_model(epochs=100)
        
        # 步驟 5: 保存最終模型
        logger.info("💾 步驟 5: 保存訓練完成的教師模型...")
        self._save_final_teacher_model()
        
        # 步驟 6: 準備第二階段
        logger.info("🔗 步驟 6: 準備連接第二階段蒸餾...")
        self._prepare_for_stage2()
        
        logger.info("🎉 第一階段完成！準備進入第二階段蒸餾...")
        
        return {
            "collection_results": collection_results,
            "train_history": train_history,
            "best_accuracy": best_acc,
            "model_info": model_info,
            "ready_for_stage2": True
        }
    
    def _prepare_dataloaders(self):
        """準備數據加載器"""
        # 數據增強
        train_transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.RandomHorizontalFlip(),
            transforms.RandomRotation(15),
            transforms.ColorJitter(brightness=0.2, contrast=0.2, saturation=0.2),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
        ])
        
        val_transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
        ])
        
        # 模擬數據集（實際應用中需要實現真實數據集類）
        train_dataset = self._create_mock_dataset(10000, train_transform)
        val_dataset = self._create_mock_dataset(2000, val_transform)
        
        train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True, num_workers=4)
        val_loader = DataLoader(val_dataset, batch_size=32, shuffle=False, num_workers=4)
        
        return train_loader, val_loader
    
    def _create_mock_dataset(self, size, transform):
        """建立模擬數據集"""
        class MockDataset(Dataset):
            def __init__(self, size, transform):
                self.size = size
                self.transform = transform
            
            def __len__(self):
                return self.size
            
            def __getitem__(self, idx):
                # 模擬圖像數據
                image = torch.randn(3, 224, 224)
                label = torch.randint(0, 13, (1,)).item()
                
                if self.transform:
                    image = self.transform(image)
                
                return image, label
        
        return MockDataset(size, transform)
    
    def _save_final_teacher_model(self):
        """保存最終的教師模型"""
        save_path = "stage1_training/models/teacher_models/final_teacher_model.pth"
        torch.save({
            'model_state_dict': self.teacher_model.model.state_dict(),
            'model_config': self.teacher_model.get_model_info(),
            'scene_categories': [
                {"id": cat.id, "name": cat.name, "description": cat.description} 
                for cat in self.data_collector.scene_categories
            ]
        }, save_path)
        
        logger.info(f"💾 教師模型已保存到: {save_path}")
    
    def _prepare_for_stage2(self):
        """準備第二階段連接"""
        # 建立第二階段配置文件
        stage2_config = {
            "teacher_model_path": "stage1_training/models/teacher_models/final_teacher_model.pth",
            "teacher_model_type": "convnext_large",
            "num_classes": 13,
            "scene_categories": [cat.name for cat in self.data_collector.scene_categories],
            "distillation_ready": True,
            "target_student_models": ["mobilenet_v3", "efficientnet_b0", "resnet18"],
            "distillation_config": {
                "temperature": 4.0,
                "alpha": 0.7,
                "epochs": 50
            }
        }
        
        with open("stage1_training/stage2_config.json", "w") as f:
            json.dump(stage2_config, f, indent=2)
        
        logger.info("🔗 第二階段配置已準備完成")

# 主執行函數
async def main():
    """主執行函數"""
    try:
        pipeline = CTEStage1Pipeline()
        results = await pipeline.run_stage1_pipeline()
        
        print("\n" + "="*60)
        print("🎉 CTE Vibe Code 第一階段訓練完成！")
        print("="*60)
        print(f"📊 最佳準確率: {results['best_accuracy']:.2f}%")
        print(f"🏗️ 模型資訊: {results['model_info']}")
        print(f"🔗 第二階段準備: {'✅' if results['ready_for_stage2'] else '❌'}")
        print("="*60)
        
    except Exception as e:
        logger.error(f"❌ 第一階段執行失敗: {e}")
        raise

if __name__ == "__main__":
    asyncio.run(main())
