#!/bin/bash

while true; do
    clear
    echo "================================"
    echo "    AI ISP Agent 控制選單"
    echo "================================"
    echo ""
    echo "1) 分析專案結構"
    echo "2) 統計程式碼"
    echo "3) 執行測試"
    echo "4) 查看日誌"
    echo "5) 清理暫存檔"
    echo "0) 離開"
    echo ""
    read -p "請選擇 [0-5]: " choice
    
    case $choice in
        1)
            echo "分析中..."
            find . -type f \( -name "*.v" -o -name "*.c" \) | wc -l
            read -p "按 Enter 繼續..."
            ;;
        2)
            echo "統計程式碼..."
            echo "Verilog: $(find . -name "*.v" | wc -l)"
            echo "C: $(find . -name "*.c" | wc -l)"
            read -p "按 Enter 繼續..."
            ;;
        3)
            echo "執行測試..."
            if [ -f "./ai-isp-ums-integration/simple_test" ]; then
                ./ai-isp-ums-integration/simple_test
            else
                echo "找不到測試程式"
            fi
            read -p "按 Enter 繼續..."
            ;;
        4)
            echo "最新日誌："
            find . -name "*.log" -mtime -1 | head -5
            read -p "按 Enter 繼續..."
            ;;
        5)
            echo "清理中..."
            find . -name "*.swp" -delete
            echo "完成！"
            read -p "按 Enter 繼續..."
            ;;
        0)
            echo "再見！"
            exit 0
            ;;
        *)
            echo "無效選擇"
            read -p "按 Enter 繼續..."
            ;;
    esac
done
