#!/usr/bin/env python3
"""
AI Agent 控制中心 - FastAPI 伺服器
用於監控和管理 AI-Powered ISP 系統
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
import uvicorn
from datetime import datetime
import psutil
import asyncio
import json
import os
from typing import Dict, List, Optional
from pydantic import BaseModel

# 建立 FastAPI 應用
app = FastAPI(
    title="AI Agent 控制中心",
    version="1.0.0",
    description="AI-Powered ISP 系統監控與管理介面"
)

# 設定 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 全域變數
agent_status = {
    "running": False,
    "start_time": None,
    "fps": 0.0,
    "latency": 0,
    "memory_usage": 0,
    "error_count": 0
}

logs = []

# 資料模型
class SystemStatus(BaseModel):
    running: bool
    uptime: Optional[str]
    fps: float
    latency: int
    memory_usage: int
    cpu_usage: float
    error_count: int

class LogEntry(BaseModel):
    timestamp: str
    level: str
    message: str

# API 路由
@app.get("/", response_class=HTMLResponse)
async def root():
    """返回控制中心 HTML 介面"""
    return """
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Agent 控制中心</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
# 在 Cloud Shell 中執行
cd ~/cte-ai-agent-platform

# 建立必要的目錄
mkdir -p static
mkdir -p config

# 將 HTML 檔案移到 static 目錄
mv paste.txt static/index.html

cd             background: #f5f5f5;
            color: #333;
        }
        .navbar {
            background: #2c3e50;
            color: white;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo { font-size: 1.5rem; font-weight: bold; }
        .container { padding: 2rem; max-width: 1200px; margin: 0 auto; }
        .status-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        .status-card {
            background: white;
            padding: 1.5rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .status-value {
            font-size: 2rem;
            font-weight: bold;
            color: #2c3e50;
            margin: 0.5rem 0;
        }
        .control-panel {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 2rem;
        }
        .btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            cursor: pointer;
            margin-right: 1rem;
            transition: all 0.3s;
        }
        .btn-success { background: #27ae60; color: white; }
        .btn-danger { background: #e74c3c; color: white; }
        .btn-primary { background: #3498db; color: white; }
        .btn:hover { transform: translateY(-2px); }
        .log-viewer {
            background: #1e1e1e;
            color: #d4d4d4;
            padding: 1.5rem;
            border-radius: 10px;
            height: 400px;
            overflow-y: auto;
            font-family: 'Consolas', monospace;
            font-size: 0.9rem;
        }
        .log-entry { margin-bottom: 0.5rem; }
        .log-time { color: #858585; }
        .log-info { color: #3498db; }
        .log-warn { color: #f39c12; }
        .log-error { color: #e74c3c; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="logo">🤖 AI Agent 控制中心</div>
        <div id="connection-status">連線中...</div>
    </nav>
    
    <div class="container">
        <!-- 狀態卡片 -->
        <div class="status-grid">
            <div class="status-card">
                <div>系統狀態</div>
                <div class="status-value" id="system-status">離線</div>
            </div>
            <div class="status-card">
                <div>處理幀率</div>
                <div class="status-value" id="fps">0 fps</div>
            </div>
            <div class="status-card">
                <div>系統延遲</div>
                <div class="status-value" id="latency">0 ms</div>
            </div>
            <div class="status-card">
                <div>記憶體使用</div>
                <div class="status-value" id="memory">0%</div>
            </div>
        </div>
        
        <!-- 控制面板 -->
        <div class="control-panel">
            <h2>系統控制</h2>
            <div style="margin-top: 1rem;">
                <button class="btn btn-success" onclick="startAgent()">▶️ 啟動</button>
                <button class="btn btn-danger" onclick="stopAgent()">⏹️ 停止</button>
                <button class="btn btn-primary" onclick="refreshStatus()">🔄 重新整理</button>
                <button class="btn btn-primary" onclick="downloadLogs()">💾 下載日誌</button>
            </div>
        </div>
        
        <!-- 日誌檢視器 -->
        <div class="control-panel">
            <h2>系統日誌</h2>
            <div class="log-viewer" id="log-viewer">
                <div class="log-entry">等待日誌...</div>
            </div>
        </div>
    </div>
    
    <script>
        let ws;
        
        // 更新狀態
        async function updateStatus() {
            try {
                const response = await fetch('/api/status');
                const data = await response.json();
                
                document.getElementById('system-status').textContent = 
                    data.running ? '運行中' : '已停止';
                document.getElementById('system-status').style.color = 
                    data.running ? '#27ae60' : '#e74c3c';
                document.getElementById('fps').textContent = data.fps.toFixed(1) + ' fps';
                document.getElementById('latency').textContent = data.latency + ' ms';
                document.getElementById('memory').textContent = data.memory_usage + '%';
            } catch (error) {
                console.error('更新狀態失敗:', error);
            }
        }
        
        // 更新日誌
        async function updateLogs() {
            try {
                const response = await fetch('/api/logs');
                const logs = await response.json();
                const logViewer = document.getElementById('log-viewer');
                
                logViewer.innerHTML = logs.map(log => {
                    const levelClass = log.level.toLowerCase() === 'error' ? 'log-error' :
                                     log.level.toLowerCase() === 'warn' ? 'log-warn' : 'log-info';
                    return `<div class="log-entry">
                        <span class="log-time">${log.timestamp}</span>
                        <span class="${levelClass}">[${log.level}]</span>
                        <span>${log.message}</span>
                    </div>`;
                }).join('');
                
                logViewer.scrollTop = logViewer.scrollHeight;
            } catch (error) {
                console.error('更新日誌失敗:', error);
            }
        }
        
        // 控制函數
        async function startAgent() {
            const response = await fetch('/api/control/start', { method: 'POST' });
            const result = await response.json();
            alert(result.message);
            updateStatus();
        }
        
        async function stopAgent() {
            const response = await fetch('/api/control/stop', { method: 'POST' });
            const result = await response.json();
            alert(result.message);
            updateStatus();
        }
        
        function refreshStatus() {
            updateStatus();
            updateLogs();
        }
        
        async function downloadLogs() {
            window.open('/api/logs/download', '_blank');
        }
        
        // 定期更新
        setInterval(updateStatus, 1000);
        setInterval(updateLogs, 2000);
        
        // 初始更新
        updateStatus();
        updateLogs();
    </script>
</body>
</html>
    """

@app.get("/health")
async def health_check():
    """健康檢查端點"""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

@app.get("/api/status", response_model=SystemStatus)
async def get_status():
    """取得系統狀態"""
    # 模擬資料（實際應連接到真實系統）
    cpu_usage = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    
    uptime = None
    if agent_status["start_time"]:
        delta = datetime.now() - agent_status["start_time"]
        hours, remainder = divmod(delta.seconds, 3600)
        minutes, seconds = divmod(remainder, 60)
        uptime = f"{hours}小時 {minutes}分鐘"
    
    # 模擬 FPS 和延遲
    import random
    agent_status["fps"] = 30 + random.uniform(-2, 2)
    agent_status["latency"] = 28 + random.randint(-5, 5)
    
    return SystemStatus(
        running=agent_status["running"],
        uptime=uptime,
        fps=agent_status["fps"],
        latency=agent_status["latency"],
        memory_usage=int(memory.percent),
        cpu_usage=cpu_usage,
        error_count=agent_status["error_count"]
    )

@app.get("/api/logs", response_model=List[LogEntry])
async def get_logs(limit: int = 50):
    """取得系統日誌"""
    return logs[-limit:]

@app.get("/api/logs/download")
async def download_logs():
    """下載完整日誌"""
    log_content = "\n".join([
        f"{log['timestamp']} [{log['level']}] {log['message']}" 
        for log in logs
    ])
    return JSONResponse(
        content={
            "filename": f"ai_agent_logs_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt",
            "content": log_content
        },
        headers={
            "Content-Disposition": "attachment; filename=logs.txt"
        }
    )

@app.post("/api/control/start")
async def start_agent():
    """啟動 AI Agent"""
    if not agent_status["running"]:
        agent_status["running"] = True
        agent_status["start_time"] = datetime.now()
        add_log("INFO", "AI Agent 啟動成功")
        
        # 模擬啟動過程
        add_log("INFO", "載入 ISP 配置: indoor_inspection")
        add_log("INFO", "HDR 模組初始化完成")
        add_log("INFO", "FreeRTOS 任務調度正常")
        
        return {"success": True, "message": "AI Agent 已啟動"}
    return {"success": False, "message": "AI Agent 已在運行中"}

@app.post("/api/control/stop")
async def stop_agent():
    """停止 AI Agent"""
    if agent_status["running"]:
        agent_status["running"] = False
        agent_status["start_time"] = None
        add_log("INFO", "AI Agent 停止")
        return {"success": True, "message": "AI Agent 已停止"}
    return {"success": False, "message": "AI Agent 未在運行"}

# 輔助函數
def add_log(level: str, message: str):
    """添加日誌條目"""
    log_entry = {
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "level": level,
        "message": message
    }
    logs.append(log_entry)
    # 保持日誌數量在合理範圍
    if len(logs) > 1000:
        logs.pop(0)

# 啟動時添加一些初始日誌
add_log("INFO", "AI Agent 控制中心啟動")
add_log("INFO", "FastAPI 伺服器初始化完成")
add_log("INFO", "等待系統指令...")

if __name__ == "__main__":
    # 啟動伺服器
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)
