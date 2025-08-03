#!/bin/bash
# 修復 SystemVerilog 陣列端口為 Verilog 相容格式

echo "修復 support_modules_complete.v..."
# 備份原始檔案
cp support_modules_complete.v support_modules_complete.v.bak

# 使用 sed 修改陣列端口宣告
# 將 input wire [31:0] histogram_data[0:255] 改為單一寬匯流排
sed -i 's/input.*histogram_data\[.*\]/input wire [8191:0] histogram_data_bus/' support_modules_complete.v
sed -i 's/output.*ai_params\[.*\]/output wire [1023:0] ai_params_bus/' support_modules_complete.v

echo "修復完成"
