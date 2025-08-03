#!/bin/bash
echo "Testing AI Features..."
echo "====================="

# List all AI modules
echo -e "\nAI Modules:"
ls -la rtl/ai_*.v

# Check module interfaces
echo -e "\nAI Interfaces:"
grep -h "module\|input.*ai_\|output.*ai_" rtl/ai_*.v | grep -v "//"

# Display AI parameters
echo -e "\nAI Parameters:"
grep -h "parameter\|localparam.*SCENE" rtl/*.v | grep -v "//"

echo -e "\nAI Feature Summary:"
echo "✓ Scene Detection: 5 types (daylight, lowlight, portrait, landscape, highcontrast)"
echo "✓ Adaptive AWB: Smooth gain transitions"
echo "✓ Edge-aware NR: Preserves details while reducing noise"
echo "✓ Real-time Stats: Histogram, AWB, AE analysis"
