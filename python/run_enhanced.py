from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
import random
from datetime import datetime

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
        html = f.read()
    
    # 在 HTML 中注入時間戳以強制更新
    import time
    timestamp = str(int(time.time()))
    html = html.replace('</body>', f'''
    <script>
        console.log("版本: 增強版 - 載入時間: {timestamp}");
    </script>
    </body>''')
    
    return HTMLResponse(
        content=html,
        headers={
            "Cache-Control": "no-cache, no-store, must-revalidate",
            "Expires": "0"
        }
    )

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
    return {"logs": [
        {"timestamp": datetime.now().isoformat(), "level": "INFO", "message": "系統正常運行"}
    ]}

if __name__ == "__main__":
    import uvicorn
    print("啟動增強版控制中心...")
    uvicorn.run(app, host="0.0.0.0", port=8080)
