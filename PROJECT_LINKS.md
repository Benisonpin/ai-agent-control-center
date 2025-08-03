# TW-LCEO-AISP-2025 專案連結配置

## 專案架構連結

### 本地開發環境：
- **主專案目錄**: `~/isp_ai_agent/`
- **開發工具**: `~/ai-agent-dev/`
- **GitHub 同步**: `~/cloudshell_open/ai-agent-control-center/`

### CTE AI Agent 連結：
- **Web 介面**: 連結到此 GitHub 儲存庫
- **Cloud Shell**: 智能啟動（不使用 --force_new_clone）
- **即時同步**: 雙向同步機制

### 檔案同步規則：
1. 開發時在 `~/isp_ai_agent/` 進行
2. 使用同步腳本將變更推送到 GitHub
3. CTE AI Agent 從 GitHub 儲存庫讀取
4. 絕不覆蓋本地開發檔案

## 安全機制：
- ✅ 多重備份系統
- ✅ 檔案保護標記
- ✅ 智能衝突檢測
- ✅ 自動備份before sync
