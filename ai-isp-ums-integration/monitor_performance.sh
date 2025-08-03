#!/bin/bash

echo "=== AI ISP + UMS Performance Monitor ==="
echo "Date: $(date)"
echo ""

# 檢查系統資源
echo "System Resources:"
echo "CPU Cores: $(nproc)"
echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
echo ""

# 編譯測試程式
echo "Building test programs..."
make clean > /dev/null 2>&1
make all

if [ $? -eq 0 ]; then
    echo "✓ Build successful"
    
    # 執行效能測試
    echo -e "\nRunning performance tests..."
    time ./test_aisp_integration
    
    # 顯示結果摘要
    echo -e "\n=== Performance Summary ==="
    echo "Test completed at: $(date)"
else
    echo "✗ Build failed"
    exit 1
fi
