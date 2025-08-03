# AI HDR ISP 專案狀態

## 已完成
✅ 最小可運行系統 (minimal_ai_isp_system.v)
✅ AI 場景偵測模組
✅ 統計收集模組
✅ 基本測試平台
✅ 成功編譯和模擬

## 系統規格
- 輸入：12-bit Bayer 資料
- 輸出：24-bit RGB
- AI 功能：3 種場景識別（日光/夜晚/正常）
- 統計：亮度和對比度計算

## 檔案清單
- minimal_ai_isp_system.v - 主系統
- ai_agent_core_simple.v - AI 核心
- statistics_collector_simple.v - 統計模組
- test_minimal_system.v - 測試平台
- test_minimal.vcd - 波形輸出

## 執行指令
編譯: iverilog -o minimal_system.vvp -f compile_minimal_working.f
模擬: vvp minimal_system.vvp
波形: gtkwave test_minimal.vcd
