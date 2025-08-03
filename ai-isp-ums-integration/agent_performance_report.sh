#!/bin/bash

echo "📊 AI Agent 效能報告"
echo "=================="
echo "日期: $(date)"
echo ""

LOG_FILE=~/isp_ai_agent/agent_logs/stable_agent_$(date +%Y%m%d).log

if [ -f "$LOG_FILE" ]; then
    total_changes=$(grep -c "偵測到檔案變更" "$LOG_FILE")
    total_compiles=$(grep -c "編譯成功" "$LOG_FILE")
    total_tests=$(grep -c "測試通過" "$LOG_FILE")
    total_failures=$(grep -c "編譯失敗\|測試失敗" "$LOG_FILE")
    
    echo "📈 今日統計："
    echo "  總變更偵測: $total_changes 次"
    echo "  編譯成功: $total_compiles 次"
    echo "  測試通過: $total_tests 次"
    echo "  失敗次數: $total_failures 次"
    
    if [ $total_changes -gt 0 ]; then
        success_rate=$((total_compiles * 100 / total_changes))
        echo "  成功率: $success_rate%"
    fi
    
    echo ""
    echo "📝 最近 5 筆活動："
    tail -5 "$LOG_FILE"
else
    echo "找不到今天的日誌檔案"
fi
