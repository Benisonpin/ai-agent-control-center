#!/bin/bash
echo "🤖 Smart Agent 啟動中..."

# 自動檢測並執行適當的動作
if [ -f "*.log" ]; then
    echo "發現日誌檔，自動分析..."
    grep -i "error" *.log || echo "無錯誤"
fi

if [ $(find . -name "*.c" -mmin -10 | wc -l) -gt 0 ]; then
    echo "偵測到最近修改的 C 檔案，建議執行測試"
    read -p "要執行測試嗎？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        make test
    fi
fi

# 持續監控
echo "開始監控模式..."
watch -n 60 'echo "檢查中..."; date; ls -la *.log 2>/dev/null | tail -3'
