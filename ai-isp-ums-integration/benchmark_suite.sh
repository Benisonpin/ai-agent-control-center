#!/bin/bash

echo "==================================="
echo "AI ISP + UMS Benchmark Suite"
echo "==================================="
echo "Date: $(date)"
echo "System: $(uname -n)"
echo ""

# 建立結果目錄
mkdir -p benchmarks/results

# 定義輸出檔案
RESULT_FILE="benchmarks/results/benchmark_$(date +%Y%m%d_%H%M%S).txt"

# 執行所有測試並記錄結果
{
    echo "=== System Information ==="
    echo "CPU: $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
    echo "Cores: $(nproc)"
    echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
    echo "Kernel: $(uname -r)"
    echo ""
    
    echo "=== Test Results ==="
    
    # Test 1: Simple UMS HAL Test
    echo -e "\n--- UMS HAL Test ---"
    time ./test_simple
    
    # Test 2: Integration Test
    echo -e "\n--- Integration Test ---"
    time ./integration_test
    
    # Test 3: Full ISP Test (if exists)
    if [ -f test_aisp_integration ]; then
        echo -e "\n--- Full ISP Pipeline Test ---"
        time ./test_aisp_integration
    fi
    
    echo -e "\n=== Performance Summary ==="
    echo "All tests completed at: $(date)"
    
} | tee "$RESULT_FILE"

echo ""
echo "Results saved to: $RESULT_FILE"
echo ""

# 顯示摘要
echo "=== Quick Summary ==="
grep -E "FPS|GB/s|ms|time:" "$RESULT_FILE" | tail -10
