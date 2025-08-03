#!/bin/bash

clear
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              AI ISP Project - Quick Overview                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# 統計資訊
echo "📊 Project Statistics:"
echo "━━━━━━━━━━━━━━━━━━━━"
echo "Total Directories: $(find . -type d 2>/dev/null | wc -l)"
echo "Total Files: $(find . -type f 2>/dev/null | wc -l)"
echo "C Source Files: $(find . -name "*.c" 2>/dev/null | wc -l)"
echo "Header Files: $(find . -name "*.h" 2>/dev/null | wc -l)"
echo "Shell Scripts: $(find . -name "*.sh" 2>/dev/null | wc -l)"
echo ""

# 主要目錄
echo "📁 Directory Structure:"
echo "━━━━━━━━━━━━━━━━━━━━━"
for dir in hal isp_algorithms ai_models drivers camera_app rtos tests; do
    if [ -d "$dir" ]; then
        count=$(find "$dir" -type f 2>/dev/null | wc -l)
        printf "✓ %-20s (%d files)\n" "$dir" "$count"
    else
        printf "✗ %-20s (not found)\n" "$dir"
    fi
done
echo ""

# 最近建立的檔案
echo "📝 Recent Files:"
echo "━━━━━━━━━━━━━━━"
find . -type f -name "*.c" -o -name "*.h" 2>/dev/null | head -10
echo ""

echo "Use ./browse_project.sh for detailed exploration"
