#!/bin/bash

# Stable AI Agent v2 - 簡化但可靠

LOG_DIR="$HOME/isp_ai_agent/agent_logs"
mkdir -p $LOG_DIR

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_DIR/stable_agent_$(date +%Y%m%d).log
}

# 主監控迴圈
log "🚀 Stable AI Agent v2 啟動"

cd ~/isp_ai_agent/ai-isp-ums-integration
touch .last_check

while true; do
    # 1. 檢查檔案變更
    if find . -name "*.[ch]" -newer .last_check 2>/dev/null | grep -q .; then
        log "📝 偵測到檔案變更"
        
        # 2. 簡單編譯
        if gcc -o simple_test simple_test.c 2>/dev/null; then
            log "✅ 編譯成功"
            
            # 3. 執行測試
            if ./simple_test > /dev/null 2>&1; then
                log "✅ 測試通過"
            else
                log "⚠️ 測試失敗"
            fi
        else
            log "❌ 編譯失敗"
        fi
        
        touch .last_check
    fi
    
    # 顯示狀態
    echo -ne "\r[Stable Agent v2] 監控中... $(date '+%H:%M:%S') "
    
    sleep 30
done
