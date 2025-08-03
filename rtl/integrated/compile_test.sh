#!/bin/bash
echo "開始編譯測試..."

# 建立檔案列表
cat > compile_list.f << 'EOL'
// Support modules
support_modules_complete.v

// HDR and DCG
HDR_TOP_Verilog.v
DCG_Module.v

// ISP Pipeline
isp_pipeline_top.v

// AI modules
ai_agent_core.v
ai_auto_white_balance.v
statistics_collector.v

// Main integration
ai_hdr_isp_system_complete_final.v

// Testbench
tb_ai_hdr_isp_detailed.v
EOL

# 編譯命令
iverilog -o ai_hdr_isp_integrated.vvp -f compile_list.f 2>&1 | tee compile_result.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "編譯成功！"
    echo "執行檔：ai_hdr_isp_integrated.vvp"
else
    echo "編譯失敗，請檢查 compile_result.log"
fi
