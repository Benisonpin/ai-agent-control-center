#!/bin/bash

echo "╔════════════════════════════════════════════════╗"
echo "║        AI ISP Project Statistics               ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# 統計各類檔案
echo "📊 File Statistics:"
echo "==================="
echo "Total C files: $(find . -name "*.c" 2>/dev/null | wc -l)"
echo "Total H files: $(find . -name "*.h" 2>/dev/null | wc -l)"
echo "Total directories: $(find . -type d 2>/dev/null | wc -l)"
echo ""

# 程式碼行數統計
echo "📝 Code Statistics:"
echo "==================="
total_lines=0
for file in $(find . -name "*.c" -o -name "*.h" 2>/dev/null); do
    lines=$(wc -l < "$file" 2>/dev/null)
    total_lines=$((total_lines + lines))
done
echo "Total lines of code: $total_lines"
echo ""

# 元件統計
echo "🔧 Component Breakdown:"
echo "======================"
echo "RTOS Integration: $(find ./rtos -name "*.c" -o -name "*.h" 2>/dev/null | wc -l) files"
echo "HAL Layer: $(find . -path "*hal*" -name "*.c" -o -name "*.h" 2>/dev/null | wc -l) files"
echo "Camera System: $(find . -path "*camera*" -name "*.c" -o -name "*.h" 2>/dev/null | wc -l) files"
echo "ISP Algorithms: $(find . -path "*isp*" -name "*.c" -o -name "*.h" 2>/dev/null | wc -l) files"
echo "AI Models: $(find . -path "*ai*" -name "*.c" -o -name "*.h" 2>/dev/null | wc -l) files"
echo ""

# 最大的檔案
echo "📁 Largest Files:"
echo "================="
find . -name "*.c" -o -name "*.h" | xargs ls -la 2>/dev/null | sort -k5 -nr | head -5 | awk '{printf "%-50s %s\n", $9, $5}'
echo ""

# 最近修改
echo "🕒 Recently Modified:"
echo "===================="
find . -name "*.c" -o -name "*.h" -type f -exec ls -lt {} + 2>/dev/null | head -5 | awk '{print $9}'
