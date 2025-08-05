#!/usr/bin/env python3
"""
CTE Vibe Code - 第一階段到第二階段連接器
將訓練完成的大模型連接到現有的蒸餾系統
"""

import torch
import torch.nn as nn
import json
import logging
from pathlib import Path
import timm
from typing import Dict, Any, Optional

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class Stage1ToStage2Connector:
    """第一階段到第二階段的連接器"""
    
    def __init__(self):
        self.stage1_model_path = "stage1_training/models/teacher_models/final_teacher_model.pth"
        self.stage2_config_path = "stage1_training/stage2_config.json"
        
    def validate_stage1_completion(self) -> bool:
        """驗證第一階段是否完成"""
        logger.info("🔍 驗證第一階段訓練完成狀態...")
        
        checks = {
            "teacher_model_exists": Path(self.stage1_model_path).exists(),
            "stage2_config_exists": Path(self.stage2_config_path).exists(),
            "datasets_ready": Path("stage1_training/datasets/13_scenes").exists(),
            "collection_results": Path("stage1_training/data_collection/collection_results.json").exists()
        }
        
        for check_name, result in checks.items():
            status = "✅" if result else "❌"
            logger.info(f"   {status} {check_name}: {result}")
        
        all_passed = all(checks.values())
        
        if all_passed:
            logger.info("✅ 第一階段驗證通過，可以連接第二階段")
        else:
            logger.warning("⚠️ 第一階段未完全完成，請先完成第一階段訓練")
        
        return all_passed
    
    def load_stage1_teacher_model(self) -> Optional[nn.Module]:
        """載入第一階段訓練的教師模型"""
        try:
            logger.info("📥 載入第一階段教師模型...")
            
            checkpoint = torch.load(self.stage1_model_path, map_location='cpu')
            model_config = checkpoint['model_config']
            
            # 重建模型架構
            model = timm.create_model(
                model_config['model_name'], 
                pretrained=False,
                num_classes=model_config['num_classes']
            )
            
            # 載入權重
            model.load_state_dict(checkpoint['model_state_dict'])
            
            logger.info(f"✅ 教師模型載入成功")
            logger.info(f"   模型: {model_config['model_name']}")
            logger.info(f"   參數量: {model_config['total_parameters']:,}")
            logger.info(f"   類別數: {model_config['num_classes']}")
            
            return model
            
        except Exception as e:
            logger.error(f"❌ 教師模型載入失敗: {e}")
            return None
    
    def create_distillation_config(self) -> Dict[str, Any]:
        """建立蒸餾配置"""
        logger.info("⚙️ 建立知識蒸餾配置...")
        
        # 載入第二階段配置
        with open(self.stage2_config_path, 'r') as f:
            stage2_config = json.load(f)
        
        # 建立完整的蒸餾配置
        distillation_config = {
            "teacher_model": {
                "model_path": self.stage1_model_path,
                "model_type": stage2_config["teacher_model_type"],
                "num_classes": stage2_config["num_classes"],
                "scene_categories": stage2_config["scene_categories"]
            },
            "student_models": [
                {
                    "name": "mobilenet_v3_small",
                    "architecture": "mobilenet_v3",
                    "target_tops": 0.3,
                    "target_latency_ms": 15,
                    "compression_ratio": 0.75
                },
                {
                    "name": "efficientnet_b0_lite",
                    "architecture": "efficientnet_b0", 
                    "target_tops": 0.4,
                    "target_latency_ms": 18,
                    "compression_ratio": 0.70
                },
                {
                    "name": "resnet18_compressed",
                    "architecture": "resnet18",
                    "target_tops": 0.35,
                    "target_latency_ms": 16,
                    "compression_ratio": 0.80
                }
            ],
            "distillation_settings": {
                "temperature": 4.0,
                "alpha": 0.7,
                "epochs": 50,
                "batch_size": 64,
                "learning_rate": 1e-4,
                "weight_decay": 1e-5
            },
            "hardware_constraints": {
                "max_tops": 1.0,
                "max_latency_ms": 20,
                "max_power_w": 0.8,
                "memory_budget_mb": 256
            },
            "optimization_stages": [
                {
                    "stage": "knowledge_distillation",
                    "duration_epochs": 50,
                    "focus": "accuracy_preservation"
                },
                {
                    "stage": "model_pruning", 
                    "duration_epochs": 20,
                    "focus": "parameter_reduction"
                },
                {
                    "stage": "quantization",
                    "duration_epochs": 10,
                    "focus": "inference_optimization"
                }
            ]
        }
        
        return distillation_config
    
    def integrate_with_existing_pipeline(self) -> bool:
        """整合到現有的第二階段蒸餾管線"""
        logger.info("🔗 整合到現有蒸餾管線...")
        
        try:
            # 驗證第一階段完成
            if not self.validate_stage1_completion():
                return False
            
            # 載入教師模型
            teacher_model = self.load_stage1_teacher_model()
            if teacher_model is None:
                return False
            
            # 建立蒸餾配置
            distillation_config = self.create_distillation_config()
            
            # 保存整合配置
            integration_config_path = "stage1_training/integration_config.json"
            with open(integration_config_path, 'w') as f:
                json.dump(distillation_config, f, indent=2)
            
            logger.info(f"💾 整合配置已保存: {integration_config_path}")
            
            # 建立第二階段啟動腳本
            self._create_stage2_launcher()
            
            logger.info("✅ 成功整合到第二階段管線")
            return True
            
        except Exception as e:
            logger.error(f"❌ 整合失敗: {e}")
            return False
    
    def _create_stage2_launcher(self):
        """建立第二階段啟動腳本"""
        launcher_script = '''#!/usr/bin/env python3
"""
CTE Vibe Code - 第二階段知識蒸餾啟動器
自動啟動從第一階段教師模型到輕量化學生模型的蒸餾過程
"""

import sys
import json
import torch
from pathlib import Path

# 添加現有蒸餾系統路徑
sys.path.append('.')

def launch_stage2_distillation():
    """啟動第二階段蒸餾"""
    print("🚀 啟動第二階段知識蒸餾...")
    
    # 載入整合配置
    with open('stage1_training/integration_config.json', 'r') as f:
        config = json.load(f)
    
    print("📊 蒸餾配置:")
    print(f"   教師模型: {config['teacher_model']['model_type']}")
    print(f"   學生模型數量: {len(config['student_models'])}")
    print(f"   目標準確度保持: {config['distillation_settings']['alpha'] * 100:.1f}%")
    
    # 這裡連接到現有的蒸餾系統
    # 例如：from your_existing_distillation import KnowledgeDistillationPipeline
    # distiller = KnowledgeDistillationPipeline(config)
    # distiller.run()
    
    print("💡 請將此配置連接到現有的知識蒸餾系統")
    print("📁 配置檔案: stage1_training/integration_config.json")

if __name__ == "__main__":
    launch_stage2_distillation()
'''
        
        launcher_path = "stage1_training/launch_stage2.py"
        with open(launcher_path, 'w') as f:
            f.write(launcher_script)
        
        Path(launcher_path).chmod(0o755)
        logger.info(f"🚀 第二階段啟動器已建立: {launcher_path}")
    
    def generate_integration_report(self) -> str:
        """生成整合報告"""
        report = []
        report.append("=" * 60)
        report.append("🔗 CTE Vibe Code 階段整合報告")
        report.append("=" * 60)
        report.append("")
        
        # 第一階段狀態
        report.append("📊BPContinuepython       report.append("📊 第一階段狀態:")
       
       stage1_files = {
           "教師模型": self.stage1_model_path,
           "數據集": "stage1_training/datasets/13_scenes",
           "收集結果": "stage1_training/data_collection/collection_results.json",
           "配置檔案": self.stage2_config_path
       }
       
       for name, path in stage1_files.items():
           exists = Path(path).exists()
           status = "✅" if exists else "❌"
           report.append(f"   {status} {name}: {path}")
       
       report.append("")
       
       # 模型資訊
       if Path(self.stage1_model_path).exists():
           try:
               checkpoint = torch.load(self.stage1_model_path, map_location='cpu')
               model_config = checkpoint['model_config']
               
               report.append("🏗️ 教師模型資訊:")
               report.append(f"   架構: {model_config['model_name']}")
               report.append(f"   參數量: {model_config['total_parameters']:,}")
               report.append(f"   模型大小: {model_config['model_size_mb']:.1f} MB")
               report.append(f"   類別數: {model_config['num_classes']}")
               report.append("")
               
           except Exception as e:
               report.append(f"   ⚠️ 模型資訊讀取失敗: {e}")
               report.append("")
       
       # 數據統計
       if Path("stage1_training/data_collection/collection_results.json").exists():
           try:
               with open("stage1_training/data_collection/collection_results.json", 'r') as f:
                   results = json.load(f)
               
               report.append("📈 數據收集統計:")
               total_samples = sum(stats['total_processed'] for stats in results.values())
               report.append(f"   總樣本數: {total_samples:,}")
               report.append(f"   場景類別: {len(results)}")
               
               for category, stats in results.items():
                   report.append(f"   {category}: {stats['total_processed']:,} 樣本")
               
               report.append("")
               
           except Exception as e:
               report.append(f"   ⚠️ 數據統計讀取失敗: {e}")
               report.append("")
       
       # 第二階段準備狀態
       report.append("🔗 第二階段整合狀態:")
       
       integration_files = {
           "整合配置": "stage1_training/integration_config.json",
           "啟動腳本": "stage1_training/launch_stage2.py"
       }
       
       for name, path in integration_files.items():
           exists = Path(path).exists()
           status = "✅" if exists else "❌"
           report.append(f"   {status} {name}: {path}")
       
       report.append("")
       
       # 後續步驟
       report.append("🎯 後續步驟:")
       report.append("   1. 執行: python3 stage1_training/launch_stage2.py")
       report.append("   2. 將整合配置連接到現有蒸餾系統")
       report.append("   3. 啟動知識蒸餾訓練")
       report.append("   4. 監控蒸餾過程和模型效能")
       report.append("   5. 部署最終輕量化模型到 FPGA")
       
       report.append("")
       report.append("=" * 60)
       
       return "\n".join(report)

# 主執行函數
def main():
   """主執行函數"""
   try:
       connector = Stage1ToStage2Connector()
       
       logger.info("🔗 開始第一階段到第二階段整合...")
       
       # 執行整合
       success = connector.integrate_with_existing_pipeline()
       
       if success:
           # 生成整合報告
           report = connector.generate_integration_report()
           print("\n" + report)
           
           # 保存報告
           report_path = "stage1_training/integration_report.txt"
           with open(report_path, 'w') as f:
               f.write(report)
           
           logger.info(f"📋 整合報告已保存: {report_path}")
           logger.info("✅ 第一階段到第二階段整合完成！")
           
       else:
           logger.error("❌ 整合失敗，請檢查第一階段完成狀態")
           
   except Exception as e:
       logger.error(f"❌ 整合過程失敗: {e}")
       raise

if __name__ == "__main__":
   main()
