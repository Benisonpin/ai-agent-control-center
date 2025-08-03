#!/bin/bash

echo "=== AI ISP 編譯診斷報告 ==="
echo "時間: $(date)"
echo ""

echo "1. 目錄結構："
pwd
ls -la

echo -e "\n2. C 原始檔："
find . -maxdepth 2 -name "*.c" -type f | head -10

echo -e "\n3. 標頭檔："
find . -maxdepth 2 -name "*.h" -type f | head -10

echo -e "\n4. Makefile 檢查："
if [ -f Makefile ]; then
    echo "Makefile 存在"
    echo "--- Makefile 內容 (前 20 行) ---"
    head -20 Makefile
else
    echo "❌ Makefile 不存在！"
fi

echo -e "\n5. 嘗試編譯 simple_test.c："
if [ -f simple_test.c ]; then
    gcc -o simple_test simple_test.c 2>&1 | head -10
else
    echo "❌ simple_test.c 不存在！"
fi

echo -e "\n6. 檢查缺失的依賴："
# 檢查常見的標頭檔
headers=("ums_hal_integration.h" "camera_hal3_interface.h" "rtos_core.h")
for h in "${headers[@]}"; do
    if find . -name "$h" | grep -q .; then
        echo "✓ 找到 $h"
    else
        echo "✗ 缺少 $h"
    fi
done

echo -e "\n7. 最近的錯誤訊息："
find . -name "*.log" -mtime -1 -exec grep -H "error\|Error\|ERROR" {} \; 2>/dev/null | head -10

echo -e "\n=== 診斷完成 ==="
