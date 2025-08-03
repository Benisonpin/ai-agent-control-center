#!/bin/bash
echo "執行 AI HDR ISP 模擬..."
echo "========================"
vvp ai_hdr_isp_complete.vvp
if [ -f "ai_hdr_isp_sim.vcd" ]; then
    echo "波形檔案已生成: ai_hdr_isp_sim.vcd"
    echo "可使用 gtkwave ai_hdr_isp_sim.vcd 查看波形"
fi
