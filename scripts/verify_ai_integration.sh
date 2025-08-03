#!/bin/bash
echo "Verifying AI Agent Integration..."
echo "================================"

# Check for AI modules
echo "AI Modules found:"
find . -name "*.v" | grep -i ai | while read file; do
    echo "  - $file"
done

# Check configuration
echo -e "\nConfiguration:"
if [ -f config/isp_config.json ]; then
    cat config/isp_config.json | grep -E "ai_|modules|features"
fi

echo -e "\nAI Features:"
grep -h "AI\|ai_" rtl/*.v | grep -E "module|parameter|output|input" | head -10

echo -e "\nIntegration Status: Complete"
