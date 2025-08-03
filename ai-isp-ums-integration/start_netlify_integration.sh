#!/bin/bash

echo "======================================"
echo "   🌐 Netlify AI Agent 整合系統"
echo "======================================"
echo "   站點: comfy-griffin-7bf94b.netlify.app"
echo "======================================"

# 顏色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 檢查環境
check_environment() {
    echo -e "\n${BLUE}檢查環境...${NC}"
    
    # Python
    if command -v python3 &> /dev/null; then
        echo -e "${GREEN}✅ Python3 已安裝${NC}"
    else
        echo -e "${RED}❌ 需要安裝 Python3${NC}"
        exit 1
    fi
    
    # 必要的 Python 套件
    echo -e "\n${BLUE}安裝必要套件...${NC}"
    pip3 install -q requests 2>/dev/null
    echo -e "${GREEN}✅ 套件已安裝${NC}"
}

# 初始化目錄
init_directories() {
    echo -e "\n${BLUE}初始化目錄結構...${NC}"
    mkdir -p ota/netlify_integration/{api,sync,config,dashboard}
    echo -e "${GREEN}✅ 目錄已創建${NC}"
}

# 主選單
main_menu() {
    while true; do
        echo -e "\n${YELLOW}=== Netlify 整合功能選單 ===${NC}"
        echo "1. 🌐 開啟 Netlify 監控儀表板"
        echo "2. 🔄 啟動同步服務"
        echo "3. 🧪 測試 Netlify API 連接"
        echo "4. 📊 查看同步狀態"
        echo "5. ⚙️  配置 Netlify 整合"
        echo "6. 🌏 在瀏覽器開啟 Netlify 站點"
        echo "7. 📝 查看整合文檔"
        echo "8. 🚪 退出"
        
        read -p "請選擇 (1-8): " choice
        
        case $choice in
            1)
                echo -e "\n${BLUE}啟動 Netlify 監控儀表板...${NC}"
                cd ota/netlify_integration/dashboard && python3 netlify_dashboard.py
                cd - > /dev/null
                ;;
            2)
                echo -e "\n${BLUE}啟動同步服務...${NC}"
                cd ota/netlify_integration/sync && python3 polling_sync.py &
                cd - > /dev/null
                echo -e "${GREEN}✅ 同步服務已在背景運行${NC}"
                ;;
            3)
                test_connection
                ;;
            4)
                show_sync_status
                ;;
            5)
                configure_integration
                ;;
            6)
                echo -e "\n${BLUE}開啟瀏覽器...${NC}"
                open https://comfy-griffin-7bf94b.netlify.app 2>/dev/null || \
                xdg-open https://comfy-griffin-7bf94b.netlify.app 2>/dev/null || \
                echo "請手動開啟: https://comfy-griffin-7bf94b.netlify.app"
                ;;
            7)
                show_documentation
                ;;
            8)
                echo -e "\n${GREEN}👋 感謝使用 Netlify 整合系統${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}無效選擇${NC}"
                ;;
        esac
        
        echo -e "\n按 Enter 繼續..."
        read
    done
}

# 測試連接
test_connection() {
    echo -e "\n${BLUE}測試 Netlify API 連接...${NC}"
    
    # 測試各個函數端點
    endpoints=(
        "status"
        "models"
        "logs"
        "architecture"
    )
    
    for endpoint in "${endpoints[@]}"; do
        echo -n "測試 /$endpoint ... "
        response=$(curl -s -o /dev/null -w "%{http_code}" "https://comfy-griffin-7bf94b.netlify.app/.netlify/functions/$endpoint")
        
        if [ "$response" = "200" ]; then
            echo -e "${GREEN}✅ 成功${NC}"
        else
            echo -e "${RED}❌ 失敗 (HTTP $response)${NC}"
        fi
    done
}

# 顯示同步狀態
show_sync_status() {
    echo -e "\n${BLUE}📊 同步狀態${NC}"
    echo "─────────────────────────────────────"
    
    # 檢查狀態文件
    if [ -f "ota/netlify_integration/sync/netlify_status.json" ]; then
        echo -e "${GREEN}最後同步狀態:${NC}"
        cat ota/netlify_integration/sync/netlify_status.json | python3 -m json.tool | head -20
    else
        echo -e "${YELLOW}尚無同步記錄${NC}"
    fi
    
    # 檢查更新隊列
    if [ -f "ota/netlify_integration/sync/update_queue.json" ]; then
        queue_size=$(cat ota/netlify_integration/sync/update_queue.json | grep -c "model")
        echo -e "\n${BLUE}待處理更新: ${queue_size} 個${NC}"
    fi
}

# 配置整合
configure_integration() {
    echo -e "\n${BLUE}⚙️ 配置 Netlify 整合${NC}"
    echo "─────────────────────────────────────"
    
    config_file="ota/netlify_integration/config/netlify_config.json"
    
    if [ ! -f "$config_file" ]; then
        echo -e "${YELLOW}配置文件不存在，創建預設配置...${NC}"
        python3 ota/netlify_integration/api/netlify_client.py
    fi
    
    echo -e "\n當前配置:"
    cat "$config_file" | python3 -m json.tool
    
    echo -e "\n${YELLOW}配置文件位置: $config_file${NC}"
    read -p "是否編輯配置? (y/n): " edit
    
    if [ "$edit" = "y" ]; then
        ${EDITOR:-nano} "$config_file"
    fi
}

# 顯示文檔
show_documentation() {
    echo -e "\n${BLUE}📝 Netlify 整合文檔${NC}"
    echo "═════════════════════════════════════════════════════════════════"
    echo ""
    echo "🌐 Netlify 站點: https://comfy-griffin-7bf94b.netlify.app"
    echo ""
    echo "📡 API 端點:"
    echo "   • /status     - 系統狀態"
    echo "   • /models     - AI 模型列表"
    echo "   • /logs       - 系統日誌"
    echo "   • /architecture - 架構信息"
    echo ""
    echo "🔄 同步機制:"
    echo "   • 使用輪詢方式 (每30秒)"
    echo "   • 自動檢測模型更新"
    echo "   • 雙向狀態同步"
    echo ""
    echo "📦 功能特性:"
    echo "   • OTA 模型更新"
    echo "   • 即時監控面板"
    echo "   • 系統狀態追蹤"
    echo "   • 更新隊列管理"
    echo ""
    echo "⚙️ 配置說明:"
    echo "   1. 編輯 netlify_config.json"
    echo "   2. 設定 API Key (如需要)"
    echo "   3. 調整同步間隔"
    echo ""
    echo "═════════════════════════════════════════════════════════════════"
}

# 主程序
check_environment
init_directories
main_menu
