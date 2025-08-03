#!/bin/bash
echo "🚀 快速測試啟動..."
cd ai-isp-ums-integration
if [ -f simple_test ]; then
    ./simple_test
else
    echo "編譯測試程式..."
    make simple_test && ./simple_test
fi
