# AI Agent Control Center

CTE Group 的 AI Agent 控制中心 - 部署到 Netlify

## 功能特色

- 🤖 實時 AI 性能監控
- 📊 系統狀態儀表板
- 🎯 場景識別與追踪
- 🔧 FPGA 工具整合
- 📡 OTA 更新管理
- 🔄 ModelSim 仿真控制

## 本地開發

```bash
# 安裝依賴
npm install

# 啟動本地開發服務器
netlify dev
```

## 部署

### 自動部署 (推薦)
推送到 GitHub main 分支會自動觸發 Netlify 部署

### 手動部署
```bash
./deploy.sh
```

## 設定自訂網域

1. 在 Netlify 控制台中設定 `aiagent.ctegroup.com.tw`
2. 在 DNS 中添加 CNAME 記錄指向 Netlify 網址

## API 端點

- `/api/status` - 系統狀態
- `/api/scenes` - 場景識別
- `/api/logs` - 系統日誌
- `/api/tracking` - 物件追踪
- `/api/performance` - 性能指標
- `/api/fpga-status` - FPGA 狀態

## 技術棧

- 前端: HTML5, CSS3, JavaScript (原生)
- 後端: Netlify Functions (Node.js)
- 部署: Netlify
- 網域: aiagent.ctegroup.com.tw
