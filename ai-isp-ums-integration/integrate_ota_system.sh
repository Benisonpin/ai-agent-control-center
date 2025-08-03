#!/bin/bash

echo "======================================"
echo "   🔧 OTA System Integration"
echo "======================================"

# 顏色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 檢查並創建必要目錄
echo -e "\n${BLUE}Creating OTA directory structure...${NC}"
mkdir -p ota/{manager,models,config,tests,reports,downloads,logs}

# 編譯 OTA 模組
echo -e "\n${BLUE}Building OTA modules...${NC}"
if [ -f "Makefile" ]; then
    make ota 2>/dev/null || echo "  ℹ️  Manual compilation may be needed"
fi

# 設置 OTA 服務
echo -e "\n${BLUE}Setting up OTA service...${NC}"
cat > ota/ota_service.sh << 'SERVICE'
#!/bin/bash
# OTA Background Service
while true; do
    python3 ota/manager/ota_manager.py > ota/logs/ota_service.log 2>&1
    sleep 86400  # Check daily
done
SERVICE
chmod +x ota/ota_service.sh

# 創建系統整合配置
echo -e "\n${BLUE}Creating system integration config...${NC}"
cat > ota/config/system_integration.json << 'CONFIG'
{
  "integration": {
    "hal_layer": true,
    "hot_swap": true,
    "zero_downtime": true,
    "auto_rollback": true
  },
  "models": {
    "scene_detector": {
      "path": "ai_models/scene_detection/",
      "hal_interface": "scene_detector_hal"
    },
    "object_tracker": {
      "path": "ai_models/object_tracking/",
      "hal_interface": "object_tracker_hal"
    }
  },
  "performance": {
    "max_download_threads": 4,
    "verify_checksum": true,
    "compression": "gzip"
  }
}
CONFIG

echo -e "\n${GREEN}✅ OTA System Integration Complete!${NC}"
echo -e "\n${YELLOW}Available Commands:${NC}"
echo "  ./test_ota_update.sh    - Test OTA functionality"
echo "  ./ota_demo.py          - Run interactive demo"
echo "  ./ota_monitor.py       - Open OTA dashboard"
echo "  ./generate_ota_report.sh - Generate update report"
echo ""
echo -e "${YELLOW}Quick Start:${NC}"
echo "  1. Run './ota_demo.py' for a live demonstration"
echo "  2. Check 'ota/reports/' for update reports"
echo "  3. Monitor 'ota/logs/' for system logs"
