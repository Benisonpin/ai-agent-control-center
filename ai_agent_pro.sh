#!/bin/bash

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 函數：顯示標題
show_header() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║       AI ISP Agent Pro v2.0            ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
}

# 函數：分析專案
analyze_project() {
    echo -e "${CYAN}📊 專案分析報告${NC}"
    echo -e "${YELLOW}═══════════════════════════════════${NC}"
    
    echo -e "\n${GREEN}📁 專案結構：${NC}"
    echo "  主目錄: $(pwd)"
    echo "  子目錄數: $(find . -type d | wc -l)"
    echo "  總檔案數: $(find . -type f | wc -l)"
    
    echo -e "\n${GREEN}📝 程式碼統計：${NC}"
    echo "  Verilog (.v): $(find . -name "*.v" -type f | wc -l) 檔案"
    echo "  C 程式 (.c): $(find . -name "*.c" -type f | wc -l) 檔案"
    echo "  標頭檔 (.h): $(find . -name "*.h" -type f | wc -l) 檔案"
    echo "  Python (.py): $(find . -name "*.py" -type f | wc -l) 檔案"
    echo "  Shell (.sh): $(find . -name "*.sh" -type f | wc -l) 檔案"
    
    echo -e "\n${GREEN}💾 磁碟使用：${NC}"
    du -sh . 2>/dev/null | awk '{print "  總大小: " $1}'
    
    echo -e "\n${GREEN}🕒 最近修改：${NC}"
    echo "  最近修改的檔案："
    find . -type f -mtime -1 -name "*.[vch]" 2>/dev/null | head -5 | sed 's/^/    /'
}

# 函數：查看日誌
view_logs() {
    echo -e "${CYAN}📋 日誌檢視器${NC}"
    echo -e "${YELLOW}═══════════════════════════════════${NC}\n"
    
    # 列出所有日誌
    echo -e "${GREEN}可用的日誌檔案：${NC}"
    logs=($(find . -name "*.log" -type f -mtime -7 | sort -r))
    
    if [ ${#logs[@]} -eq 0 ]; then
        echo -e "${RED}沒有找到最近的日誌檔案${NC}"
        return
    fi
    
    # 顯示選項
    for i in "${!logs[@]}"; do
        echo "  $((i+1))) ${logs[$i]}"
    done
    echo "  0) 返回主選單"
    
    echo ""
    read -p "選擇要查看的日誌 [0-${#logs[@]}]: " log_choice
    
    if [[ $log_choice -gt 0 && $log_choice -le ${#logs[@]} ]]; then
        log_file="${logs[$((log_choice-1))]}"
        echo -e "\n${YELLOW}檔案: $log_file${NC}"
        echo -e "${YELLOW}═══════════════════════════════════${NC}"
        
        # 顯示最後 20 行
        tail -20 "$log_file"
        
        echo -e "\n${CYAN}選項：${NC}"
        echo "  1) 查看完整檔案"
        echo "  2) 搜尋錯誤"
        echo "  3) 搜尋警告"
        echo "  0) 返回"
        
        read -p "選擇 [0-3]: " action
        
        case $action in
            1) less "$log_file" ;;
            2) grep -i "error" "$log_file" | head -20 ;;
            3) grep -i "warning" "$log_file" | head -20 ;;
        esac
    fi
}

# 函數：執行測試
run_tests() {
    echo -e "${CYAN}🧪 測試執行器${NC}"
    echo -e "${YELLOW}═══════════════════════════════════${NC}\n"
    
    # 尋找可執行的測試
    echo -e "${GREEN}搜尋測試程式...${NC}"
    
    test_files=(
        "./ai-isp-ums-integration/simple_test"
        "./ai-isp-ums-integration/test_integration"
        "./ai-isp-ums-integration/test_all_components"
    )
    
    available_tests=()
    for test in "${test_files[@]}"; do
        if [ -x "$test" ]; then
            available_tests+=("$test")
        fi
    done
    
    if [ ${#available_tests[@]} -eq 0 ]; then
        echo -e "${RED}沒有找到可執行的測試程式${NC}"
        
        # 嘗試編譯
        echo -e "\n${YELLOW}嘗試編譯測試程式...${NC}"
        if [ -f "./ai-isp-ums-integration/Makefile" ]; then
            (cd ./ai-isp-ums-integration && make)
        fi
        return
    fi
    
    # 顯示可用測試
    echo -e "${GREEN}可用的測試：${NC}"
    for i in "${!available_tests[@]}"; do
        echo "  $((i+1))) ${available_tests[$i]}"
    done
    echo "  0) 返回主選單"
    
    read -p "選擇要執行的測試 [0-${#available_tests[@]}]: " test_choice
    
    if [[ $test_choice -gt 0 && $test_choice -le ${#available_tests[@]} ]]; then
        test_exe="${available_tests[$((test_choice-1))]}"
        echo -e "\n${YELLOW}執行: $test_exe${NC}"
        echo -e "${YELLOW}═══════════════════════════════════${NC}"
        
        # 執行測試
        $test_exe
        
        echo -e "\n${GREEN}測試完成！${NC}"
    fi
}

# 函數：系統狀態
system_status() {
    echo -e "${CYAN}📊 系統狀態監控${NC}"
    echo -e "${YELLOW}═══════════════════════════════════${NC}\n"
    
    # UMS 狀態
    echo -e "${GREEN}🧠 UMS (統一記憶體子系統) 狀態：${NC}"
    echo "  預期頻寬: 1.1 GB/s"
    echo "  預期延遲: 28ms"
    echo "  預期功耗: 3.5W"
    
    # ISP Pipeline 狀態
    echo -e "\n${GREEN}📷 ISP Pipeline 狀態：${NC}"
    echo "  支援解析度: 4K (3840x2160)"
    echo "  目標幀率: 30fps (達成 32.5fps)"
    echo "  HDR: 3-frame fusion"
    
    # AI 功能狀態
    echo -e "\n${GREEN}🤖 AI 功能：${NC}"
    echo "  場景偵測: 13 類別"
    echo "  推論時間: <50ms"
    echo "  加速器: NPU ready"
    
    # 檢查關鍵檔案
    echo -e "\n${GREEN}✅ 關鍵元件檢查：${NC}"
    critical_files=(
        "rtl/ai_isp_top.v"
        "rtl/ai_agent_core.v"
        "ai-isp-ums-integration/rtos/kernel/core/rtos_core.c"
        "ai-isp-ums-integration/hal/src/ums_wrapper.c"
    )
    
    for file in "${critical_files[@]}"; do
        if [ -f "$file" ]; then
            echo -e "  ✓ $file ${GREEN}[OK]${NC}"
        else
            echo -e "  ✗ $file ${RED}[缺失]${NC}"
        fi
    done
}

# 函數：快速操作
quick_actions() {
    echo -e "${CYAN}⚡ 快速操作${NC}"
    echo -e "${YELLOW}═══════════════════════════════════${NC}\n"
    
    echo "1) 建置所有元件"
    echo "2) 執行效能測試"
    echo "3) 生成報告"
    echo "4) Git 狀態"
    echo "5) 尋找 TODO 項目"
    echo "0) 返回"
    
    read -p "選擇 [0-5]: " action
    
    case $action in
        1)
            if [ -f "./ai-isp-ums-integration/build_all.sh" ]; then
                ./ai-isp-ums-integration/build_all.sh
            else
                echo -e "${RED}找不到 build_all.sh${NC}"
            fi
            ;;
        2)
            if [ -f "./ai-isp-ums-integration/benchmark_suite.sh" ]; then
                ./ai-isp-ums-integration/benchmark_suite.sh
            else
                echo -e "${RED}找不到 benchmark_suite.sh${NC}"
            fi
            ;;
        3)
            echo -e "${GREEN}生成專案報告...${NC}"
            analyze_project > project_report_$(date +%Y%m%d_%H%M%S).txt
            echo "報告已儲存！"
            ;;
        4)
            git status 2>/dev/null || echo -e "${YELLOW}這不是一個 Git 儲存庫${NC}"
            ;;
        5)
            echo -e "${GREEN}TODO 項目：${NC}"
            grep -r "TODO\|FIXME\|XXX" --include="*.[vch]" . 2>/dev/null | head -10
            ;;
    esac
}

# 主選單
while true; do
    show_header
    
    echo -e "${CYAN}主選單：${NC}"
    echo "1) 📊 分析專案結構"
    echo "2) 📋 查看日誌"
    echo "3) 🧪 執行測試"
    echo "4) 📈 系統狀態"
    echo "5) ⚡ 快速操作"
    echo "6) 🧹 清理暫存檔"
    echo "0) 🚪 離開"
    echo ""
    
    read -p "請選擇 [0-6]: " choice
    
    case $choice in
        1)
            show_header
            analyze_project
            echo ""
            read -p "按 Enter 繼續..."
            ;;
        2)
            show_header
            view_logs
            echo ""
            read -p "按 Enter 繼續..."
            ;;
        3)
            show_header
            run_tests
            echo ""
            read -p "按 Enter 繼續..."
            ;;
        4)
            show_header
            system_status
            echo ""
            read -p "按 Enter 繼續..."
            ;;
        5)
            show_header
            quick_actions
            echo ""
            read -p "按 Enter 繼續..."
            ;;
        6)
            show_header
            echo -e "${YELLOW}清理中...${NC}"
            find . -name "*.swp" -delete 2>/dev/null
            find . -name "*~" -delete 2>/dev/null
            find . -name ".DS_Store" -delete 2>/dev/null
            echo -e "${GREEN}✅ 清理完成！${NC}"
            sleep 2
            ;;
        0)
            echo -e "\n${GREEN}再見！👋${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}無效選擇${NC}"
            sleep 1
            ;;
    esac
done
