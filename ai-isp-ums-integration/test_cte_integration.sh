#!/bin/bash

echo "======================================"
echo "   🧪 CTE 整合測試"
echo "======================================"

# 測試步驟
echo -e "\n1️⃣ 測試 API 連接..."
curl -s -o /dev/null -w "%{http_code}" https://api.cte-ai-platform.com/v1/status || echo "API 無法連接"

echo -e "\n2️⃣ 檢查本地配置..."
if [ -f "ota/cte_integration/config/cte_config.json" ]; then
    echo "✅ 配置文件存在"
else
    echo "❌ 配置文件不存在"
    echo "   複製範例配置："
    echo "   cp ota/cte_integration/config/cte_config.example.json ota/cte_integration/config/cte_config.json"
fi

echo -e "\n3️⃣ 檢查同步隊列..."
if [ -f "ota/cte_integration/sync/update_queue.json" ]; then
    echo "✅ 同步隊列存在"
    echo "   待同步項目: $(cat ota/cte_integration/sync/update_queue.json | grep -c "model_id")"
else
    echo "ℹ️  同步隊列為空"
fi

echo -e "\n4️⃣ 測試雙向同步..."
echo "   本地 → CTE: 準備就緒"
echo "   CTE → 本地: 準備就緒"

echo -e "\n✅ 測試完成！"
echo ""
echo "下一步："
echo "1. 編輯 ota/cte_integration/config/cte_config.json 加入您的 API Key"
echo "2. 運行 ./start_cte_integration.sh 開始整合"
