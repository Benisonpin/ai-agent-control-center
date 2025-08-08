#!/bin/bash

echo "🚀 啟動 CTE Vibe Code Center"
echo ""
echo "請選擇啟動方式:"
echo "1) 前端 + 後端 (完整功能)"
echo "2) 僅前端 (基本功能)"
echo "3) 僅後端 API"
echo ""

read -p "請輸入選項 (1-3): " choice

case $choice in
    1)
        echo "🔧 啟動完整功能..."
        # 後台啟動後端
        cd backend
        python3 app.py &
        BACKEND_PID=$!
        echo "📡 後端 API 已啟動 (PID: $BACKEND_PID)"
        
        # 前台啟動前端
        cd ../frontend
        echo "🌐 啟動前端服務器..."
        echo "📱 請在瀏覽器中訪問: http://localhost:8080"
        python3 -m http.server 8080
        
        # 清理後端進程
        kill $BACKEND_PID 2>/dev/null
        ;;
    2)
        echo "🌐 啟動前端服務器..."
        cd frontend
        echo "📱 請在瀏覽器中訪問: http://localhost:8080"
        echo "💡 注意: 後端 API 功能將不可用"
        python3 -m http.server 8080
        ;;
    3)
        echo "📡 啟動後端 API..."
        cd backend
        echo "🔗 API 服務器地址: http://localhost:5000"
        python3 app.py
        ;;
    *)
        echo "❌ 無效選項"
        exit 1
        ;;
esac
