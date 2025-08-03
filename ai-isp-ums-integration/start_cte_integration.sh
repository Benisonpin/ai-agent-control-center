#!/bin/bash

echo "======================================"
echo "   🌐 CTE AI Agent 整合系統"
echo "======================================"

# 顏色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 檢查環境
echo -e "\n${BLUE}檢查環境...${NC}"

# 檢查 Python
if command -v python3 &> /dev/null; then
    echo -e "${GREEN}✅ Python3 已安裝${NC}"
else
    echo -e "❌ 需要安裝 Python3"
    exit 1
fi

# 檢查依賴
echo -e "\n${BLUE}檢查依賴...${NC}"
pip3 install -q requests websocket-client aiofiles 2>/dev/null
echo -e "${GREEN}✅ 依賴已安裝${NC}"

# 創建必要目錄
echo -e "\n${BLUE}初始化目錄結構...${NC}"
mkdir -p ota/cte_integration/{sync,api,config,models,reports}
echo -e "${GREEN}✅ 目錄結構已創建${NC}"

# 選單
while true; do
    echo -e "\n${YELLOW}=== CTE 整合功能選單 ===${NC}"
    echo "1. 🔄 啟動同步管理器"
    echo "2. 📊 開啟監控面板"
    echo "3. 🔌 測試 CTE 連接"
    echo "4. 📤 手動同步"
    echo "5. 📋 查看配置"
    echo "6. 🚪 退出"
    
    read -p "請選擇 (1-6): " choice
    
    case $choice in
        1)
            echo -e "\n${BLUE}啟動同步管理器...${NC}"
            python3 ota/cte_integration/cte_sync_manager.py
            ;;
        2)
            echo -e "\n${BLUE}開啟監控面板...${NC}"
            python3 ota/cte_integration/cte_dashboard.py
            ;;
        3)
            echo -e "\n${BLUE}測試 CTE 連接...${NC}"
            python3 -c "
from ota.cte_integration.cte_sync_manager import CTESyncManager
manager = CTESyncManager()
if manager.connect_to_cte():
    print('✅ 連接成功')
else:
    print('❌ 連接失敗')
"
            ;;
        4)
            echo -e "\n${BLUE}執行手動同步...${NC}"
            python3 -c "
from ota.cte_integration.cte_sync_manager import CTESyncManager
manager = CTESyncManager()
manager.sync_with_cte()
"
            ;;
        5)
            echo -e "\n${BLUE}當前配置:${NC}"
            cat ota/cte_integration/config/cte_config.json 2>/dev/null || echo "配置文件尚未創建"
            ;;
        6)
            echo -e "\n${GREEN}👋 感謝使用 CTE 整合系統${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}無效選擇${NC}"
            ;;
    esac
    
    echo -e "\n按 Enter 繼續..."
    read
done
