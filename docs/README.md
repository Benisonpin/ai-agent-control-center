# 🎵 CTE Vibe Code - 智能 AI 開發平台

## 🎯 專案概述

CTE Vibe Code 是一個智能的 AI 開發平台，整合了 Over The Air (OTA) 模型更新、雲端開發工具和無人機個性化系統。

## ✨ 核心特色

### 1. 智能內嵌終端
- 不需要跳轉到 Cloud Shell
- 直接在瀏覽器中執行雲端指令
- 專為 AI 開發優化的 vibe 指令系統

### 2. OTA 模型更新
- 無感知 AI 模型熱更新
- 智能排程與自動回滾
- 版本管理與相依性處理

### 3. 無人機個性化
- Explorer (🌍 冒險探索)
- Guardian (🛡️ 守護監控)
- Artist (🎨 藝術創作)
- Racer (⚡ 競速飛行)

## 🚀 快速開始

### 在線體驗
訪問：[https://your-netlify-url.netlify.app](https://your-netlify-url.netlify.app)

### 基本指令
```bash
vibe status      # 檢查系統狀態
vibe deploy      # 部署 AI 模型
vibe update      # OTA 模型更新
vibe monitor     # 系統監控
vibe help        # 查看所有指令
```

## 🔧 技術架構

### 前端
- Vanilla JavaScript (智能終端)
- CSS3 (現代化 UI)
- 響應式設計

### 後端
- Netlify Functions (Serverless)
- Google Cloud API 代理
- 模擬 + 實際雲端操作

### 部署
- GitHub + Netlify 自動部署
- SSH 金鑰認證
- 即時更新

## 📁 專案結構

```
cte-vibe-code/
├── public/
│   ├── js/
│   │   └── smart-vibe-integration.js    # 智能終端整合
│   ├── css/
│   │   └── vibe-terminal.css            # 終端樣式
│   └── index.html                       # 主頁面
├── netlify/
│   └── functions/
│       └── gcloud-proxy.js              # Google Cloud API 代理
├── docs/
│   └── README.md                        # 專案文件
└── config/
    └── netlify.toml                     # Netlify 配置
```

## 🎮 使用指南

### 基本操作
1. **檢查狀態**: `vibe status`
2. **部署模型**: `vibe deploy [model-name]`
3. **檢查更新**: `vibe update --check`
4. **執行更新**: `vibe update --apply`
5. **查看日誌**: `vibe logs [service]`

### 快速按鈕
- 📊 狀態 - 一鍵檢查系統
- 🚀 部署 - 快速部署模型
- 📡 檢查更新 - OTA 更新掃描
- 🔍 監控 - 系統指標監控

### 指令歷史
- ⬆️ 上箭頭 - 查看上一個指令
- ⬇️ 下箭頭 - 查看下一個指令
- Tab - 自動完成 (計劃中)

## 🔐 安全性

### API 保護
- CORS 策略
- 指令白名單
- 參數驗證

### 模擬模式
- 開發階段使用模擬數據
- 避免意外的雲端操作
- 安全的測試環境

## 📈 效能指標

- ⚡ 終端響應時間: < 100ms
- 🚀 指令執行時間: < 2s
- 📱 移動端支援: 100%
- 🌐 瀏覽器支援: 95%

## 🛠️ 開發

### 本地開發
```bash
git clone https://github.com/Benisonpin/ai-agent-control-center.git
cd ai-agent-control-center
# 直接開啟 public/index.html 或使用本地服務器
```

### 部署更新
```bash
git add .
git commit -m "更新描述"
git push
# Netlify 自動部署
```

## 🤝 貢獻

歡迎提交 Issue 和 Pull Request！

## 📞 支援

- GitHub Issues: [提交問題](https://github.com/Benisonpin/ai-agent-control-center/issues)
- Email: support@ctegroup.com

## 📄 授權

MIT License - 詳見 LICENSE 檔案

---
**CTE Group - Vibe Code 團隊** 🎵
