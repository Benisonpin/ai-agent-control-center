#!/bin/bash
echo "AI HDR ISP 系統模擬"
echo "=================="
if [ -f "ai_hdr_isp_final.vvp" ]; then
    vvp ai_hdr_isp_final.vvp
    echo "模擬完成"
else
    echo "請先編譯: iverilog -o ai_hdr_isp_final.vvp -f compile_complete.f"
fi
