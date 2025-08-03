from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
import os
import random
from datetime import datetime

app = FastAPI(title="AI Agent Control Center - CTE Group")

# 允許所有來源（公開訪問）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def home():
    """主頁面"""
    with open("index.html", "r", encoding="utf-8") as f:
        return HTMLResponse(content=f.read())

@app.get("/api/status")
async def get_status():
    """系統狀態"""
    return {
        "fps": round(32.5 + random.uniform(-2, 2), 1),
        "latency": int(28 + random.uniform(-5, 5)),
        "accuracy": round(85.3 + random.uniform(-2, 2), 1),
        "power": round(3.5 + random.uniform(-0.2, 0.2), 1),
        "timestamp": datetime.now().isoformat()
    }

@app.get("/api/scenes")
async def get_scenes():
    """場景識別"""
    scenes = [
        {"id": "indoor", "name": "室內", "confidence": random.randint(90, 98), "icon": "🏠"},
        {"id": "outdoor", "name": "室外", "confidence": random.randint(2, 10), "icon": "🌳"},
        # ... 其他場景
    ]
    return {"scenes": scenes}

@app.get("/api/logs")
async def get_logs():
    return {"logs": [{"timestamp": datetime.now().isoformat(), "level": "INFO", "message": "系統正常"}]}

@app.get("/health")
async def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)
