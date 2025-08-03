#!/bin/bash
echo "📋 RTL 整合狀態報告"
echo "===================="
echo "日期: $(date)"
echo ""

echo "📁 整合目錄內容："
ls -la rtl/integrated/*.v | wc -l
echo ""

echo "🔄 最近整合的模組："
cd rtl/integrated
for file in $(ls -t *.v | head -5); do
    echo "  - $file ($(grep -c "module" $file 2>/dev/null) 個模組)"
done

echo ""
echo "🔗 模組連接統計："
grep -h "wire\|input\|output" *.v | wc -l
echo ""

echo "✅ 整合檢查清單："
key_modules=("ai_isp_top" "ai_agent_core" "hdr_module" "statistics_collector")
for module in "${key_modules[@]}"; do
    if grep -q "module $module" *.v 2>/dev/null; then
        echo "  ✓ $module 已整合"
    else
        echo "  ✗ $module 未找到"
    fi
done
