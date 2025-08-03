#!/bin/bash

watch -n 2 '
echo "🎯 AI ISP 即時儀表板"
echo "===================="
echo ""
echo "📊 檔案統計："
echo "  Verilog: $(find . -name "*.v" | wc -l)"
echo "  C: $(find . -name "*.c" | wc -l)"
echo ""
echo "💾 磁碟使用: $(du -sh . | cut -f1)"
echo ""
echo "📝 最新修改:"
find . -type f -mmin -60 -name "*.[vch]" | head -3
echo ""
echo "🕒 時間: $(date "+%Y-%m-%d %H:%M:%S")"
'
