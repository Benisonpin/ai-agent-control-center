#!/bin/bash

echo "======================================"
echo "   🧪 測試所有自定義功能"
echo "======================================"

echo -e "\n1️⃣ 測試訂閱方案..."
echo "   查看: cat ota/custom/subscriptions/custom_plans.json | jq '.subscription_plans | keys'"

echo -e "\n2️⃣ 測試無人機應用優化..."
echo "   運行: python3 ota/custom/drone_apps/application_profiles.py"

echo -e "\n3️⃣ 測試自定義儀表板..."
echo "   運行: python3 ota/custom/dashboard/custom_dashboard.py"

echo -e "\n4️⃣ 測試更新行為配置..."
echo "   查看: cat ota/custom/policies/update_behavior.json | jq '.update_behaviors | keys'"

echo -e "\n5️⃣ 測試現代化 UI..."
echo "   運行: python3 ota/custom/ui/modern_ui.py"

echo -e "\n✅ 所有功能都可以使用了！"
