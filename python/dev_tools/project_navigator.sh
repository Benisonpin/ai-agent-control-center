#!/bin/bash

# 顏色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}     AI ISP Project Navigator                  ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""

# 顯示專案結構
echo -e "${GREEN}📁 Project Structure:${NC}"
echo "├── 🎯 RTOS Integration"
echo "│   └── ai_framework/ai_agent_framework.c"
echo "├── 🔧 HAL Layer"
echo "│   ├── hal/inc/ums_hal_integration.h"
echo "│   ├── hal/inc/ums_wrapper.h"
echo "│   └── hal/src/ums_wrapper.c"
echo "├── 📷 Camera System"
echo "│   ├── camera_app/simple_camera_app.c"
echo "│   ├── camera_hal3/include/camera_hal3_interface.h"
echo "│   └── camera_hal3/camera_sensor_interface.c"
echo "├── 🎨 ISP Algorithms"
echo "│   ├── demosaic/aahd_demosaic.c"
echo "│   ├── hdr/hdr_fusion.c"
echo "│   └── denoise/ai_denoise.c"
echo "├── 🤖 AI Models"
echo "│   └── scene_detection/scene_detector.c"
echo "└── 🧪 Tests"
echo "    └── unit/test_ums_basic.c"
echo ""

while true; do
    echo -e "${YELLOW}Select component to explore:${NC}"
    echo "1. RTOS/AI Framework"
    echo "2. HAL Layer"
    echo "3. Camera System"
    echo "4. ISP Algorithms"
    echo "5. AI Models"
    echo "6. View All Files"
    echo "7. Search in Files"
    echo "0. Exit"
    echo ""
    echo -n "Choice: "
    read choice
    
    case $choice in
        1)
            echo -e "\n${GREEN}=== RTOS/AI Framework ===${NC}"
            if [ -f "./rtos/middleware/ai_framework/ai_agent_framework.c" ]; then
                echo "Showing first 50 lines of ai_agent_framework.c:"
                head -50 ./rtos/middleware/ai_framework/ai_agent_framework.c
            else
                echo "File not found"
            fi
            echo -e "\nPress Enter to continue..."
            read
            clear
            ;;
        2)
            echo -e "\n${GREEN}=== HAL Layer Files ===${NC}"
            echo "Available files:"
            ls -la ./ai-isp-ums-integration/hal/inc/ 2>/dev/null
            ls -la ./ai-isp-ums-integration/hal/src/ 2>/dev/null
            echo -e "\nPress Enter to continue..."
            read
            clear
            ;;
        3)
            echo -e "\n${GREEN}=== Camera System ===${NC}"
            echo "1. View Camera App"
            echo "2. View Camera HAL3 Interface"
            echo "3. View Sensor Interface"
            echo -n "Select: "
            read cam_choice
            case $cam_choice in
                1) less ./camera_app/simple_camera_app.c 2>/dev/null ;;
                2) less ./camera_hal3/include/camera_hal3_interface.h 2>/dev/null ;;
                3) less ./camera_hal3/camera_sensor_interface.c 2>/dev/null ;;
            esac
            clear
            ;;
        4)
            echo -e "\n${GREEN}=== ISP Algorithms ===${NC}"
            echo "1. HDR Fusion"
            echo "2. Demosaic (AAHD)"
            echo "3. AI Denoise"
            echo -n "Select: "
            read isp_choice
            case $isp_choice in
                1) less ./camera_hal3/isp_algorithms/hdr/hdr_fusion.c 2>/dev/null ;;
                2) less ./camera_hal3/isp_algorithms/demosaic/aahd_demosaic.c 2>/dev/null ;;
                3) less ./camera_hal3/isp_algorithms/denoise/ai_denoise.c 2>/dev/null ;;
            esac
            clear
            ;;
        5)
            echo -e "\n${GREEN}=== AI Models ===${NC}"
            find . -path "*ai_models*" -name "*.c" -exec echo "Found: {}" \;
            echo -e "\nPress Enter to continue..."
            read
            clear
            ;;
        6)
            echo -e "\n${GREEN}=== All Project Files ===${NC}"
            find . -name "*.c" -o -name "*.h" | sort
            echo -e "\nPress Enter to continue..."
            read
            clear
            ;;
        7)
            echo -n "Enter search term: "
            read search_term
            echo -e "\n${GREEN}=== Search Results for '$search_term' ===${NC}"
            grep -r "$search_term" --include="*.c" --include="*.h" . 2>/dev/null | head -20
            echo -e "\nPress Enter to continue..."
            read
            clear
            ;;
        0)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice"
            sleep 1
            clear
            ;;
    esac
done
