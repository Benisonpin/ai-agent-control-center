#!/bin/bash
echo "🌅 AI ISP 每日檢查"
echo "=================="
date
echo ""

# 檢查專案狀態
echo "📊 專案統計："
find . -name "*.v" -o -name "*.c" | wc -l

# 檢查最新修改
echo -e "\n📝 今日修改："
find . -type f -mtime -1 | grep -E "\.(v|c|h)$" | head -5

# 檢查是否有錯誤
echo -e "\n⚠️  錯誤檢查："
grep -l "error" *.log 2>/dev/null | head -3 || echo "✅ 無錯誤日誌"

echo -e "\n完成每日檢查！"
