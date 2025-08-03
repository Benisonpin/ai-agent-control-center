#!/bin/bash
echo "AI HDR ISP Integration Test"
echo "==========================="
echo ""
echo "整合檔案:"
echo "1. support_modules_complete.v - 支援模組 ($(wc -l < support_modules_complete.v) lines)"
echo "2. ai_hdr_isp_system_complete.v - 主整合模組 ($(wc -l < ai_hdr_isp_system_complete.v) lines)"
echo ""
echo "原始模組:"
ls -1 HDR*.v DCG*.v isp*.v ai*.v | head -10
echo ""
echo "準備編譯..."
