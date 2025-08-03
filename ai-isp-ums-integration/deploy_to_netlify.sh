#!/bin/bash

echo "======================================"
echo "   📦 部署到 Netlify"
echo "======================================"

cd netlify-deploy

# 檢查是否已安裝 Netlify CLI
if ! command -v netlify &> /dev/null; then
    echo "❌ 請先安裝 Netlify CLI:"
    echo "   npm install -g netlify-cli"
    exit 1
fi

# 初始化 Netlify（如果需要）
if [ ! -f ".netlify/state.json" ]; then
    echo "🔧 初始化 Netlify 站點..."
    netlify init
fi

# 部署
echo "🚀 開始部署..."
netlify deploy --prod

echo ""
echo "✅ 部署完成！"
echo "🌐 您的站點應該已經更新："
echo "   https://comfy-griffin-7bf94b.netlify.app"
