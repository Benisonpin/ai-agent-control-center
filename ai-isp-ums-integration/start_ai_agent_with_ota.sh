#!/bin/bash

echo "======================================"
echo "   🚀 AI Agent with OTA Support"
echo "======================================"

# 檢查 OTA 更新
echo "🔍 Checking for AI model updates..."
python3 ota/manager/ota_manager.py > /dev/null 2>&1

# 啟動 AI Agent
echo "🤖 Starting AI Agent..."
cd ..
./start_ai_agent.sh

echo ""
echo "💡 Tips:"
echo "  - Run './test_ota_update.sh' to test OTA functionality"
echo "  - Run 'python3 ota_monitor.py' for interactive OTA dashboard"
echo "  - Check 'ota/ota_update.log' for update history"
