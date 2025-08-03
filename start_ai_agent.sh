#!/bin/bash

# 檢查 Agent 是否已在執行
if [ -f ~/isp_ai_agent/ai_agent.pid ]; then
    PID=$(cat ~/isp_ai_agent/ai_agent.pid)
    if ps -p $PID > /dev/null; then
        echo "AI Agent 已在執行 (PID: $PID)"
        exit 0
    fi
fi

# 啟動 AI Agent
cd ~/isp_ai_agent
./intelligent_agent.sh --daemon

echo "AI Agent 已啟動！"
