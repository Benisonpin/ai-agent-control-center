#!/bin/bash
echo "=========================================="
echo "AI HDR ISP Integration Verification"
echo "=========================================="
echo ""

# 檢查所有必要檔案
echo "檢查整合檔案..."
FILES=(
    "ai_hdr_isp_system_complete_final.v"
    "support_modules_complete.v"
    "HDR_TOP_Verilog.v"
    "DCG_Module.v"
    "isp_pipeline_top.v"
    "ai_agent_core.v"
    "statistics_collector.v"
)

missing=0
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file ($(wc -l < $file) lines)"
    else
        echo "✗ $file (缺少)"
        missing=$((missing + 1))
    fi
done

echo ""
echo "檔案檢查完成: $(( ${#FILES[@]} - missing )) / ${#FILES[@]} 檔案存在"

# 檢查模組依賴
echo ""
echo "檢查模組依賴..."
grep -h "module" ai_hdr_isp_system_complete_final.v | grep -v endmodule | head -10

echo ""
echo "整合架構："
echo "  [Sensors] → [HDR/DCG] → [ISP Pipeline] → [RGB Out]"
echo "      ↓                          ↓"
echo "  [AI Agent] ←──────── [Statistics]"
echo ""
echo "準備進行編譯測試..."
