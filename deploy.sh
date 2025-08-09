#!/bin/bash
echo "🚀 開始部署 AI Agent 控制中心到 Netlify..."

# 檢查是否安裝 Netlify CLI
if ! command -v netlify &> /dev/null; then
    echo "📦 安裝 Netlify CLI..."
    npm install -g netlify-cli
fi

# 部署到 Netlify
echo "🔧 執行部署..."
netlify deploy --prod --dir=public --functions=netlify/functions

echo "✅ 部署完成！"
echo "🌐 請到 Netlify 儀表板設定自訂網域: aiagent.ctegroup.com.tw"
