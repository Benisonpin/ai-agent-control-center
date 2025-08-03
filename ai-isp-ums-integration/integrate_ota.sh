#!/bin/bash

echo "======================================"
echo "   🚀 OTA AI Model Integration"
echo "======================================"

# 檢查 Python 環境
if command -v python3 &> /dev/null; then
    echo "✅ Python3 found"
else
    echo "❌ Python3 not found. Please install Python3."
    exit 1
fi

# 運行 OTA Manager
echo ""
echo "🔄 Starting OTA Manager..."
python3 ota/manager/ota_manager.py

echo ""
echo "✅ OTA Integration Complete!"
echo ""
echo "Next steps:"
echo "1. Configure ota/config/ota_config.json"
echo "2. Run ./integrate_ota.sh to check for updates"
echo "3. Use ./start_ai_agent.sh to start AI Agent with OTA support"
