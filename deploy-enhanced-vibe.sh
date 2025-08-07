#!/bin/bash
echo "🚀 開始部署 CTE Vibe Code 增強版..."

if [ ! -d "public" ]; then
    mkdir -p public/{js,css}
fi

echo "🌐 啟動本地測試服務器..."
if command -v python3 &> /dev/null; then
    cd public && python3 -m http.server 8080 &
    echo "🎉 服務器已啟動在 http://localhost:8080"
elif command -v python &> /dev/null; then
    cd public && python -m SimpleHTTPServer 8080 &
    echo "🎉 服務器已啟動在 http://localhost:8080"
else
    echo "⚠️  請手動開啟 public/enhanced-vibe-integration.html"
fi

echo "🎵 CTE Vibe Code 增強版部署完成！"
