#!/bin/bash
echo "🧪 CTE Vibe Code 功能測試..."

files=(
    "public/js/enhanced-vibe-integration.js"
    "public/css/enhanced-vibe-styles.css" 
    "public/enhanced-vibe-integration.html"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (缺失)"
    fi
done

echo "🎉 測試完成！"
