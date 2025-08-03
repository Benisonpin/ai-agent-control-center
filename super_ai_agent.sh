#!/bin/bash

# Super AI Agent - 完全自動化的開發助手
# 功能：自動編譯、測試、修復、優化、報告

# 設定
AGENT_HOME="$HOME/isp_ai_agent"
LOG_DIR="$AGENT_HOME/agent_logs"
REPORT_DIR="$AGENT_HOME/agent_reports"
WEBHOOK_URL=""  # 可選：Slack/Discord 通知

# 建立必要目錄
mkdir -p $LOG_DIR $REPORT_DIR

# 顏色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 時間戳記
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# 記錄功能
log() {
    local level=$1
    shift
    local message="$@"
    echo "[$(timestamp)] [$level] $message" >> $LOG_DIR/agent_$(date +%Y%m%d).log
    
    case $level in
        ERROR) echo -e "${RED}[錯誤]${NC} $message" ;;
        WARN)  echo -e "${YELLOW}[警告]${NC} $message" ;;
        INFO)  echo -e "${BLUE}[資訊]${NC} $message" ;;
        SUCCESS) echo -e "${GREEN}[成功]${NC} $message" ;;
    esac
}

# 發送通知（可選）
notify() {
    local message="$1"
    local level="${2:-INFO}"
    
    # 本地通知
    echo -e "\n🔔 ${YELLOW}[通知]${NC} $message\n"
    
    # 如果設定了 webhook，發送到 Slack/Discord
    if [ ! -z "$WEBHOOK_URL" ]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"[AI Agent] $message\"}" \
            $WEBHOOK_URL 2>/dev/null
    fi
}

# 智慧編譯系統
smart_compile() {
    log INFO "開始智慧編譯..."
    
    cd $AGENT_HOME/ai-isp-ums-integration
    
    # 清理舊的編譯結果
    make clean > /dev/null 2>&1
    
    # 嘗試編譯
    if make all > $LOG_DIR/compile_$(date +%Y%m%d_%H%M%S).log 2>&1; then
        log SUCCESS "編譯成功！"
        notify "✅ 專案編譯成功" "SUCCESS"
        return 0
    else
        log ERROR "編譯失敗，分析錯誤..."
        analyze_and_fix_compile_errors
        return 1
    fi
}

# 分析並修復編譯錯誤
analyze_and_fix_compile_errors() {
    local error_log=$(ls -t $LOG_DIR/compile_*.log | head -1)
    
    # 常見錯誤模式和修復方案
    if grep -q "undefined reference" $error_log; then
        log WARN "發現連結錯誤，嘗試修復..."
        # 自動添加缺失的函式庫
        echo "LDFLAGS += -lm -lpthread" >> Makefile
        smart_compile
    elif grep -q "No such file or directory" $error_log; then
        log WARN "發現缺失檔案，嘗試建立..."
        # 從錯誤訊息提取缺失的檔案名
        missing_file=$(grep "No such file" $error_log | awk -F: '{print $3}' | head -1)
        touch "$missing_file"
        smart_compile
    else
        log ERROR "無法自動修復，需要人工介入"
        notify "❌ 編譯錯誤需要人工修復" "ERROR"
    fi
}

# 智慧測試系統
smart_test() {
    log INFO "執行智慧測試套件..."
    
    local test_results="$REPORT_DIR/test_report_$(date +%Y%m%d_%H%M%S).txt"
    local failed_tests=0
    local passed_tests=0
    
    # 執行所有測試
    for test_exe in $(find $AGENT_HOME -name "*test*" -type f -executable); do
        test_name=$(basename $test_exe)
        log INFO "執行測試: $test_name"
        
        if $test_exe > /tmp/test_output.tmp 2>&1; then
            ((passed_tests++))
            echo "✅ PASS: $test_name" >> $test_results
        else
            ((failed_tests++))
            echo "❌ FAIL: $test_name" >> $test_results
            echo "錯誤輸出：" >> $test_results
            cat /tmp/test_output.tmp >> $test_results
            echo "---" >> $test_results
        fi
    done
    
    # 測試報告
    echo "測試總結：通過 $passed_tests，失敗 $failed_tests" >> $test_results
    
    if [ $failed_tests -eq 0 ]; then
        log SUCCESS "所有測試通過！"
        notify "✅ 所有測試通過 ($passed_tests/$((passed_tests+failed_tests)))" "SUCCESS"
    else
        log ERROR "有 $failed_tests 個測試失敗"
        notify "⚠️ 測試失敗 ($failed_tests/$((passed_tests+failed_tests)))" "WARN"
        # 嘗試自動修復
        auto_fix_test_failures $test_results
    fi
}

# 效能監控和優化
performance_monitor() {
    log INFO "執行效能分析..."
    
    local perf_report="$REPORT_DIR/performance_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "=== 效能分析報告 ===" > $perf_report
    echo "時間: $(timestamp)" >> $perf_report
    echo "" >> $perf_report
    
    # CPU 和記憶體使用
    echo "系統資源使用：" >> $perf_report
    top -b -n 1 | head -20 >> $perf_report
    
    # 專案統計
    echo -e "\n專案統計：" >> $perf_report
    echo "Verilog 檔案: $(find $AGENT_HOME -name "*.v" | wc -l)" >> $perf_report
    echo "C 檔案: $(find $AGENT_HOME -name "*.c" | wc -l)" >> $perf_report
    echo "總程式碼行數: $(find $AGENT_HOME -name "*.[vch]" -exec wc -l {} + | tail -1)" >> $perf_report
    
    # 優化建議
    echo -e "\n優化建議：" >> $perf_report
    
    # 檢查大檔案
    large_files=$(find $AGENT_HOME -type f -size +1M -name "*.[vch]")
    if [ ! -z "$large_files" ]; then
        echo "- 發現大型原始檔，建議分割：" >> $perf_report
        echo "$large_files" >> $perf_report
    fi
    
    # 檢查複雜度
    complex_files=$(find $AGENT_HOME -name "*.v" -exec grep -l "always\|module" {} \; | \
                    xargs -I {} sh -c 'echo "{} $(grep -c "always\|module" {})"' | \
                    sort -k2 -n -r | head -5)
    echo "- 最複雜的 Verilog 模組：" >> $perf_report
    echo "$complex_files" >> $perf_report
    
    log SUCCESS "效能分析完成"
}

# 生成每日報告
generate_daily_report() {
    local report="$REPORT_DIR/daily_report_$(date +%Y%m%d).md"
    
    cat > $report << REPORT
# AI Agent 每日報告
**日期**: $(date '+%Y-%m-%d')

## 📊 專案概況
- **總檔案數**: $(find $AGENT_HOME -type f | wc -l)
- **今日修改**: $(find $AGENT_HOME -type f -mtime -1 | wc -l) 個檔案
- **程式碼行數**: $(find $AGENT_HOME -name "*.[vch]" -exec wc -l {} + | tail -1 | awk '{print $1}')

## 🔧 自動化行動
- **編譯次數**: $(grep -c "開始智慧編譯" $LOG_DIR/agent_$(date +%Y%m%d).log 2>/dev/null || echo 0)
- **測試執行**: $(grep -c "執行智慧測試" $LOG_DIR/agent_$(date +%Y%m%d).log 2>/dev/null || echo 0)
- **錯誤修復**: $(grep -c "自動修復" $LOG_DIR/agent_$(date +%Y%m%d).log 2>/dev/null || echo 0)

## 📈 效能指標
$(tail -20 $REPORT_DIR/performance_*.txt 2>/dev/null | grep -E "CPU|記憶體|優化建議" || echo "暫無資料")

## 🎯 明日建議
1. 檢查並優化高複雜度模組
2. 執行完整的迴歸測試
3. 更新技術文件

---
*由 AI Agent 自動生成*
REPORT

    log SUCCESS "每日報告已生成: $report"
    notify "📊 每日報告已生成" "INFO"
}

# 主要監控迴圈
main_loop() {
    log INFO "🚀 Super AI Agent 啟動"
    notify "🤖 AI Agent 已啟動並開始監控" "INFO"
    
    # 初始化
    touch $AGENT_HOME/.last_check
    local last_compile_check=0
    local last_test_check=0
    local last_perf_check=0
    local last_report_time=$(date +%H)
    
    while true; do
        current_time=$(date +%s)
        
        # 1. 檢查檔案變更（每 30 秒）
        if find $AGENT_HOME -name "*.[vch]" -newer $AGENT_HOME/.last_check | grep -q .; then
            log INFO "偵測到檔案變更"
            notify "📝 偵測到程式碼變更，開始處理..." "INFO"
            
            # 自動編譯
            smart_compile
            
            # 如果編譯成功，執行測試
            if [ $? -eq 0 ]; then
                smart_test
            fi
            
            touch $AGENT_HOME/.last_check
        fi
        
        # 2. 定期編譯檢查（每 30 分鐘）
        if [ $((current_time - last_compile_check)) -gt 1800 ]; then
            smart_compile
            last_compile_check=$current_time
        fi
        
        # 3. 定期測試（每小時）
        if [ $((current_time - last_test_check)) -gt 3600 ]; then
            smart_test
            last_test_check=$current_time
        fi
        
        # 4. 效能監控（每 2 小時）
        if [ $((current_time - last_perf_check)) -gt 7200 ]; then
            performance_monitor
            last_perf_check=$current_time
        fi
        
        # 5. 每日報告（每天早上 9 點）
        current_hour=$(date +%H)
        if [ "$current_hour" = "09" ] && [ "$last_report_time" != "09" ]; then
            generate_daily_report
            last_report_time=$current_hour
        fi
        
        # 顯示狀態
        echo -ne "\r${GREEN}[AI Agent]${NC} 運行中... 上次檢查: $(date '+%H:%M:%S') "
        
        # 休眠 30 秒
        sleep 30
    done
}

# 控制介面
case "${1:-}" in
    --daemon)
        # 背景執行
        nohup $0 --loop > /dev/null 2>&1 &
        echo $! > $AGENT_HOME/agent.pid
        echo -e "${GREEN}✅ AI Agent 已在背景啟動 (PID: $(cat $AGENT_HOME/agent.pid))${NC}"
        echo "查看日誌: tail -f $LOG_DIR/agent_$(date +%Y%m%d).log"
        ;;
    --loop)
        main_loop
        ;;
    --stop)
        if [ -f $AGENT_HOME/agent.pid ]; then
            kill $(cat $AGENT_HOME/agent.pid) 2>/dev/null
            rm $AGENT_HOME/agent.pid
            echo -e "${YELLOW}AI Agent 已停止${NC}"
        fi
        ;;
    --status)
        if [ -f $AGENT_HOME/agent.pid ] && ps -p $(cat $AGENT_HOME/agent.pid) > /dev/null; then
            echo -e "${GREEN}● AI Agent 運行中${NC} (PID: $(cat $AGENT_HOME/agent.pid))"
            echo "今日活動："
            grep -c "INFO\|SUCCESS" $LOG_DIR/agent_$(date +%Y%m%d).log 2>/dev/null || echo "0"
        else
            echo -e "${RED}● AI Agent 未運行${NC}"
        fi
        ;;
    --report)
        # 顯示最新報告
        latest_report=$(ls -t $REPORT_DIR/daily_report_*.md 2>/dev/null | head -1)
        if [ -f "$latest_report" ]; then
            cat "$latest_report"
        else
            echo "尚無報告"
        fi
        ;;
    *)
        echo "Super AI Agent - 智慧開發助手"
        echo "用法："
        echo "  $0 --daemon   # 背景執行"
        echo "  $0 --stop     # 停止"
        echo "  $0 --status   # 狀態"
        echo "  $0 --report   # 查看報告"
        ;;
esac
