#!/bin/bash

echo "=== AI ISP + UMS Integration Progress ==="
echo "Date: $(date)"
echo ""

# 檢查目錄結構
echo "Project Structure:"
find . -type d -name ".*" -prune -o -type d -print | sed 's|[^/]*/|- |g'

echo ""
echo "Source Files:"
find . -name "*.c" -o -name "*.h" | grep -v "./" | wc -l

echo ""
echo "Test Status:"
if [ -f "test_ums_basic" ]; then
    echo "✓ Test binary built"
    ./test_ums_basic > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✓ Tests passing"
    else
        echo "✗ Tests failing"
    fi
else
    echo "✗ No test binary"
fi

echo ""
echo "TODO Items:"
grep -r "TODO" --include="*.c" --include="*.h" . 2>/dev/null | wc -l

echo ""
echo "Next Steps:"
head -n 20 docs/integration_plan.md | grep "\[ \]" | head -5
