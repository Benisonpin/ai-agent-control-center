#!/bin/bash

echo "======================================"
echo "   🚀 OTA 系統快速開始"
echo "======================================"
echo ""
echo "整合系統包含:"
echo "  • 本地 OTA 更新系統"
echo "  • CTE AI Agent 平台"
echo "  • Netlify 控制中心 (comfy-griffin-7bf94b.netlify.app)"
echo ""
echo "────────────────────────────────────"
echo ""
echo "請選擇要啟動的系統:"
echo ""
echo "1. 🎯 統一監控面板 (推薦)"
echo "2. 🌐 Netlify 整合"
echo "3. 🔌 CTE 整合"
echo "4. 📦 本地 OTA 測試"
echo "5. 🎨 自定義功能"
echo ""
read -p "選擇 (1-5): " choice

case $choice in
    1)
        python3 unified_dashboard.py
        ;;
    2)
        ./start_netlify_integration.sh
        ;;
    3)
        ./start_cte_integration.sh
        ;;
    4)
        ./test_ota_update.sh
        ;;
    5)
        python3 ota_control_center.py
        ;;
esac
