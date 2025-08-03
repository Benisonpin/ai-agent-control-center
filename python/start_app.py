#!/usr/bin/env python3
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
import random
from datetime import datetime
import uvicorn
import os

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def home():
    with open("index.html", "r", encoding="utf-8") as f:
        return HTMLResponse(content=f.read())

@app.get("/api/status")
async def status():
    return {
        "fps": round(32.5 + random.uniform(-2, 2), 1),
        "latency": int(28 + random.uniform(-5, 5)),
        "accuracy": round(85.3 + random.uniform(-2, 2), 1),
        "power": round(3.5 + random.uniform(-0.2, 0.2), 1),
        "timestamp": datetime.now().isoformat()
    }

@app.get("/api/logs")
async def logs():
    return {"logs": []}

if __name__ == "__main__":
    print("🚀 啟動 AI Agent 控制中心 - 端口 8888")
    uvicorn.run(app, host="0.0.0.0", port=8080)
