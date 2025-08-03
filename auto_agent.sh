#!/bin/bash
# 自動化 AI Agent - 在背景持續運行

while true; do
    # 每 5 分鐘自動檢查
    
    # 1. 檢查是否有編譯錯誤
    if find . -name "*.log" -exec grep -l "error" {} \; | grep -q .; then
        echo "[$(date)] 發現錯誤，嘗試自動修復..."
        # 自動執行修復腳本
    fi
    
    # 2. 檢查記憶體使用
    if [ $(free | grep Mem | awk '{print ($3/$2)*100}' | cut -d. -f1) -gt 80 ]; then
        echo "[$(date)] 記憶體使用過高，執行清理..."
        # 自動清理
    fi
    
    # 3. 自動執行測試
    if find . -name "*.c" -newer .last_test -print -quit | grep -q .; then
        echo "[$(date)] 偵測到程式碼變更，執行測試..."
        ./run_tests.sh
        touch .last_test
    fi
    
    sleep 300  # 等待 5 分鐘
done
