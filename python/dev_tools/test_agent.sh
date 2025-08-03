#!/bin/bash
echo "🧪 測試 ISP Agent..."

# 等待服務啟動
sleep 2

echo "測試基本連接:"
curl -s http://localhost:8000/ || echo "❌ 連接失敗"

echo -e "\n測試健康檢查:"
curl -s http://localhost:8000/health || echo "❌ 健康檢查失敗"

echo -e "\n測試 Cloud Shell:"
curl -s -X POST "http://localhost:8000/api/cloud/shell" \
  -H "Content-Type: application/json" \
  -d '{"command": "ping"}' || echo "❌ Cloud Shell 測試失敗"

echo -e "\n✅ 測試完成！"
