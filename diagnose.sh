#!/bin/bash
echo "🔍 AI ISP 診斷助手"
echo "=================="

# 檢查關鍵檔案
echo "檢查關鍵元件..."
files=(
    "rtl/ai_isp_top.v"
    "ai-isp-ums-integration/rtos/kernel/core/rtos_core.c"
    "ai-isp-ums-integration/hal/src/ums_wrapper.c"
)

for f in "${files[@]}"; do
    [ -f "$f" ] && echo "✓ $f" || echo "✗ $f [缺失]"
done

# 檢查編譯錯誤
echo -e "\n最近的錯誤："
find . -name "*.log" -mtime -1 -exec grep -l "error" {} \; | head -3

echo -e "\n診斷完成！"
