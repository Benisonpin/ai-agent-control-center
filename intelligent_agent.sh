#!/bin/bash

# Intelligent AI Agent for ISP Project
# 這個 Agent 會自動監控、分析並執行任務

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日誌檔案
LOG_FILE="ai_agent_actions.log"
LAST_CHECK_FILE=".last_check"

# 記錄動作
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
    echo -e "${BLUE}[AI Agent]${NC} $1"
}

# 自動決策引擎
make_decision() {
    local context=$1
    local action=""
    
    case $context in
        "error_found")
            action="auto_fix"
            ;;
        "test_needed")
            action="run_test"
            ;;
        "performance_issue")
            action="optimize"
            ;;
        "new_code")
            action="analyze"
            ;;
        *)
            action="monitor"
            ;;
    esac
    
    echo $action
}

# 自動修復功能
auto_fix_errors() {
    log_action "🔧 偵測到錯誤，啟動自動修復..."
    
    # 檢查常見錯誤並修復
    if grep -q "undefined reference" *.log 2>/dev/null; then
        log_action "修復連結錯誤..."
        make clean && make all
    fi
    
    if grep -q "No such file" *.log 2>/dev/null; then
        log_action "修復缺失檔案..."
        # 自動建立缺失的檔案或目錄
    fi
}

# 自動測試功能
auto_run_tests() {
    log_action "🧪 執行自動測試..."
    
    cd ai-isp-ums-integration 2>/dev/null
    if [ -f "simple_test" ]; then
        ./simple_test > test_results.log 2>&1
        if [ $? -eq 0 ]; then
            log_action "✅ 測試通過"
        else
            log_action "❌ 測試失敗，檢查 test_results.log"
            auto_fix_errors
        fi
    else
        log_action "編譯測試程式..."
        make test
    fi
    cd ..
}

# 效能優化建議
suggest_optimizations() {
    log_action "💡 分析效能優化機會..."
    
    # 檢查 Verilog 程式碼
    verilog_files=$(find . -name "*.v" | wc -l)
    if [ $verilog_files -gt 50 ]; then
        log_action "建議：考慮模組化設計，目前有 $verilog_files 個 Verilog 檔案"
    fi
    
    # 檢查記憶體使用
    mem_usage=$(free | grep Mem | awk '{print ($3/$2)*100}' | cut -d. -f1)
    if [ $mem_usage -gt 70 ]; then
        log_action "警告：記憶體使用率 ${mem_usage}%，建議優化"
    fi
}

# 主要監控迴圈
monitor_loop() {
    log_action "🚀 AI Agent 啟動，開始智慧監控..."
    
    while true; do
        # 1. 檢查是否有新的變更
        if find . -name "*.[ch]" -newer $LAST_CHECK_FILE 2>/dev/null | grep -q .; then
            log_action "📝 偵測到程式碼變更"
            decision=$(make_decision "new_code")
            
            if [ "$decision" = "analyze" ]; then
                log_action "分析新程式碼..."
                # 執行程式碼分析
                ./ai_agent_pro.sh > /dev/null 2>&1
            fi
            
            # 自動執行測試
            auto_run_tests
        fi
        
        # 2. 檢查錯誤日誌
        if find . -name "*.log" -exec grep -l "error\|Error\|ERROR" {} \; 2>/dev/null | grep -q .; then
            decision=$(make_decision "error_found")
            if [ "$decision" = "auto_fix" ]; then
                auto_fix_errors
            fi
        fi
        
        # 3. 定期效能分析（每小時）
        if [ ! -f ".last_perf_check" ] || [ $(find ".last_perf_check" -mmin +60 | wc -l) -gt 0 ]; then
            suggest_optimizations
            touch .last_perf_check
        fi
        
        # 4. 更新檢查時間
        touch $LAST_CHECK_FILE
        
        # 顯示狀態
        echo -ne "\r${GREEN}[AI Agent]${NC} 監控中... (按 Ctrl+C 停止) "
        
        # 等待 30 秒再檢查
        sleep 30
    done
}

# 背景模式
if [ "$1" = "--daemon" ]; then
    log_action "以背景模式啟動..."
    monitor_loop &
    echo $! > ai_agent.pid
    echo -e "${GREEN}AI Agent 已在背景執行 (PID: $(cat ai_agent.pid))${NC}"
    echo "使用 'tail -f $LOG_FILE' 查看日誌"
    echo "使用 'kill $(cat ai_agent.pid)' 停止 Agent"
else
    # 互動模式
    echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      Intelligent AI Agent          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
    echo ""
    echo "1) 🚀 啟動智慧監控"
    echo "2) 🔧 執行自動修復"
    echo "3) 🧪 執行所有測試"
    echo "4) 💡 效能優化建議"
    echo "5) 📊 查看 Agent 日誌"
    echo "6) 🌙 背景模式執行"
    echo "0) 離開"
    echo ""
    read -p "選擇 [0-6]: " choice
    
    case $choice in
        1) monitor_loop ;;
        2) auto_fix_errors ;;
        3) auto_run_tests ;;
        4) suggest_optimizations ;;
        5) tail -20 $LOG_FILE ;;
        6) 
            $0 --daemon
            ;;
        0) exit 0 ;;
    esac
fi
