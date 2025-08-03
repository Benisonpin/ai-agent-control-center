#!/bin/bash

# AI Agent 控制面板

show_status() {
    if [ -f ai_agent.pid ] && ps -p $(cat ai_agent.pid) > /dev/null 2>&1; then
        echo -e "\033[0;32m● AI Agent 執行中\033[0m (PID: $(cat ai_agent.pid))"
    else
        echo -e "\033[0;31m● AI Agent 已停止\033[0m"
    fi
}

echo "=== AI Agent 控制面板 ==="
show_status
echo ""
echo "1) 啟動 Agent"
echo "2) 停止 Agent"
echo "3) 查看日誌"
echo "4) 查看狀態"
echo ""
read -p "選擇: " choice

case $choice in
    1) ./start_ai_agent.sh ;;
    2) 
        if [ -f ai_agent.pid ]; then
            kill $(cat ai_agent.pid)
            rm ai_agent.pid
            echo "Agent 已停止"
        fi
        ;;
    3) tail -f ai_agent_actions.log ;;
    4) show_status ;;
esac
