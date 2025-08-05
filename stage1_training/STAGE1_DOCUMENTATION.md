# CTE Vibe Code 第一階段：大模型訓練系統

## 🎯 概述

第一階段系統負責從開源數據集收集 13 種無人機場景的資料，並訓練大型教師模型，為第二階段的知識蒸餾提供基礎。

## 📊 13種場景分類

| ID | 場景名稱 | 描述 | 目標樣本數 | 主要數據源 |
|----|----------|------|------------|------------|
| 0 | outdoor_natural | 戶外自然環境 | 15,000 | COCO, Places365 |
| 1 | indoor_residential | 室內住宅環境 | 8,000 | NYU_Depth_V2 |
| 2 | urban_street | 城市街道 | 20,000 | Cityscapes, BDD100K |
| 3 | aerial_landscape | 航拍風景 | 12,000 | DOTA, UC_Merced |
| 4 | night_scene | 夜間場景 | 8,000 | Dark_Zurich |
| 5 | water_maritime | 水域海事 | 6,000 | SeaShips |
| 6 | forest_vegetation | 森林植被 | 10,000 | TreeSatAI |
| 7 | agricultural | 農業場景 | 9,000 | Agriculture_Vision |
| 8 | industrial_site | 工業場地 | 7,000 | Open_Images |
| 9 | coastal_beach | 海岸沙灘 | 5,000 | Places365 |
| 10 | mountain_terrain | 山地地形 | 8,000 | Mountain_Dataset |
| 11 | desert_arid | 沙漠乾旱 | 4,000 | Desert_Scenes |
| 12 | sports_recreation | 運動休閒 | 6,000 | Sports_Dataset |

**總計**: 118,000 樣本

## 🏗️ 系統架構
第一階段系統架構
├── 數據收集模組
│   ├── 開源數據集爬蟲
│   ├── 自動化下載器
│   ├── 數據品質驗證
│   └── 場景分類標註
├── 教師模型建構
│   ├── ConvNeXt Large 架構
│   ├── 自定義分類頭
│   ├── 數據增強策略
│   └── 訓練優化器
├── 訓練管線
│   ├── 分散式訓練
│   ├── 學習率調度
│   ├── 早停機制
│   └── 檢查點保存
└── 第二階段連接器
├── 模型格式轉換
├── 配置文件生成
├── 相容性驗證
└── 啟動腳本建立

## 🚀 使用方法

### 快速開始

```bash
# 執行完整的第一階段流程
~/STAGE1_EXECUTION.sh
分步執行
bash# 1. 數據收集
python3 stage1_training/data_collection/auto_data_collector.py

# 2. 模型訓練
python3 stage1_training/cte_stage1_training_pipeline.py

# 3. 第二階段整合
python3 stage1_training/stage1_to_stage2_connector.py
Web 介面操作

在 CTE Vibe Code Web 介面點擊 "第一階段：大模型訓練" 按鈕
監控訓練進度和數據收集狀態
完成後自動連接第二階段蒸餾系統

📈 效能指標
教師模型規格

架構: ConvNeXt Large
參數量: 197M 參數
模型大小: 788 MB
目標準確度: >95%
訓練時間: ~8-12 小時 (GPU)

數據集統計

總樣本數: 118,000
場景類別: 13 種
數據源: 15+ 開源數據集
數據品質: >90% 通過篩選

🔗 與第二階段的連接
第一階段完成後，系統自動：

保存教師模型: final_teacher_model.pth
生成整合配置: integration_config.json
建立啟動腳本: launch_stage2.py
驗證相容性: 確保與現有蒸餾系統相容

整合配置示例
json{
  "teacher_model": {
    "model_path": "stage1_training/models/teacher_models/final_teacher_model.pth",
    "model_type": "convnext_large",
    "num_classes": 13,
    "scene_categories": ["outdoor_natural", "urban_street", ...]
  },
  "distillation_settings": {
    "temperature": 4.0,
    "alpha": 0.7,
    "epochs": 50
  },
  "hardware_constraints": {
    "max_tops": 1.0,
    "max_latency_ms": 20,
    "max_power_w": 0.8
  }
}
📁 文件結構
stage1_training/
├── data_collection/
│   ├── auto_data_collector.py          # 自動化數據收集器
│   ├── open_source_datasets.json       # 開源數據集配置
│   ├── collection_report.txt           # 收集報告
│   └── collection_results.json         # 收集結果
├── datasets/
│   └── 13_scenes/                      # 13種場景數據
│       ├── outdoor_natural/
│       ├── urban_street/
│       └── ...
├── models/
│   ├── teacher_models/
│   │   └── final_teacher_model.pth     # 最終教師模型
│   ├── checkpoints/                    # 訓練檢查點
│   └── configs/                        # 模型配置
├── cte_stage1_training_pipeline.py     # 主訓練管線
├── stage1_to_stage2_connector.py       # 階段連接器
├── launch_stage2.py                    # 第二階段啟動器
├── integration_config.json             # 整合配置
├── integration_report.txt              # 整合報告
└── STAGE1_DOCUMENTATION.md            # 本文檔
🔧 故障排除
常見問題

數據下載失敗

檢查網路連接
確認數據集 URL 有效性
檢查磁碟空間 (至少 50GB)


記憶體不足

減少批次大小 (batch_size)
使用梯度累積
啟用混合精度訓練


訓練收斂緩慢

調整學習率
檢查數據品質
增加訓練 epochs



效能優化
python# 啟用混合精度訓練
from torch.cuda.amp import autocast, GradScaler

scaler = GradScaler()

with autocast():
    outputs = model(inputs)
    loss = criterion(outputs, targets)

scaler.scale(loss).backward()
scaler.step(optimizer)
scaler.update()
📞 技術支援
如需技術支援，請檢查：

日誌文件: stage1_training/*.log
錯誤報告: `stage1_training
RetryBPContinueEditmarkdown2. 錯誤報告: `stage1_training/error_report.txt`
3. 系統狀態: `stage1_training/system_status.json`

### 聯絡資訊
- 專案: CTE Vibe Code for AI Image Drone Chip
- 文檔更新: 2024-08-05
- 版本: Stage1 v1.0

---

**注意**: 第一階段完成後，請確保執行第二階段連接器以確保順利過渡到知識蒸餾階段。
