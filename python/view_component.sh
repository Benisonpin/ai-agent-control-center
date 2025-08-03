#!/bin/bash

show_file_info() {
    local file=$1
    if [ -f "$file" ]; then
        echo "File: $file"
        echo "Size: $(ls -lh "$file" | awk '{print $5}')"
        echo "Lines: $(wc -l < "$file")"
        echo "Modified: $(ls -l "$file" | awk '{print $6, $7, $8}')"
        echo ""
        echo "First 30 lines:"
        echo "==============="
        head -30 "$file"
    else
        echo "File not found: $file"
    fi
}

echo "=== AI ISP Component Viewer ==="
echo ""
echo "Key Components:"
echo ""

# 1. AI Framework
echo "1. AI Agent Framework"
echo "   Location: ./rtos/middleware/ai_framework/ai_agent_framework.c"
if [ -f "./rtos/middleware/ai_framework/ai_agent_framework.c" ]; then
    echo "   Status: ✓ Found"
else
    echo "   Status: ✗ Not found"
fi

# 2. Camera HAL3
echo ""
echo "2. Camera HAL3 Interface"
echo "   Location: ./camera_hal3/include/camera_hal3_interface.h"
if [ -f "./camera_hal3/include/camera_hal3_interface.h" ]; then
    echo "   Status: ✓ Found"
else
    echo "   Status: ✗ Not found"
fi

# 3. ISP Algorithms
echo ""
echo "3. ISP Algorithms"
for algo in "hdr/hdr_fusion.c" "demosaic/aahd_demosaic.c" "denoise/ai_denoise.c"; do
    if [ -f "./camera_hal3/isp_algorithms/$algo" ]; then
        echo "   ✓ $algo"
    else
        echo "   ✗ $algo"
    fi
done

# 4. Camera App
echo ""
echo "4. Camera Application"
echo "   Location: ./camera_app/simple_camera_app.c"
if [ -f "./camera_app/simple_camera_app.c" ]; then
    echo "   Status: ✓ Found (executable: $([ -f ./camera_app/simple_camera_app ] && echo "Yes" || echo "No"))"
else
    echo "   Status: ✗ Not found"
fi

echo ""
echo -n "Enter component number to view (1-4) or 0 to exit: "
read choice

case $choice in
    1) show_file_info "./rtos/middleware/ai_framework/ai_agent_framework.c" ;;
    2) show_file_info "./camera_hal3/include/camera_hal3_interface.h" ;;
    3) 
        echo "Select ISP algorithm:"
        echo "a. HDR Fusion"
        echo "b. Demosaic"
        echo "c. AI Denoise"
        read algo_choice
        case $algo_choice in
            a) show_file_info "./camera_hal3/isp_algorithms/hdr/hdr_fusion.c" ;;
            b) show_file_info "./camera_hal3/isp_algorithms/demosaic/aahd_demosaic.c" ;;
            c) show_file_info "./camera_hal3/isp_algorithms/denoise/ai_denoise.c" ;;
        esac
        ;;
    4) show_file_info "./camera_app/simple_camera_app.c" ;;
    0) exit 0 ;;
esac
