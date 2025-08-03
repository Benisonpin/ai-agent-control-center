#!/usr/bin/env python3
"""
簡化版 AI Agent - 最小依賴
"""
import json
import subprocess
from typing import Dict, Any, Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn
import httpx

app = FastAPI(title="Simple AI Agent", version="0.1.0")

class CodeRequest(BaseModel):
    prompt: str
    model: str = "llama3:8b"

class OllamaService:
    """直接調用 Ollama CLI 的服務"""
    
    @staticmethod
    async def generate(prompt: str, model: str = "llama3:8b") -> str:
        """使用 subprocess 調用 ollama"""
        try:
            # 使用 httpx 調用 Ollama API
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    "http://localhost:11434/api/generate",
                    json={
                        "model": model,
                        "prompt": prompt,
                        "stream": False
                    },
                    timeout=60.0
                )
                return response.json()["response"]
        except Exception as e:
            # 備用方案：使用命令行
            try:
                result = subprocess.run(
                    ["ollama", "run", model, prompt],
                    capture_output=True,
                    text=True,
                    timeout=60
                )
                return result.stdout
            except Exception as cli_error:
                raise Exception(f"Ollama 調用失敗: {str(e)}, CLI: {str(cli_error)}")

# 創建服務實例
ollama_service = OllamaService()

@app.get("/")
async def root():
    return {"message": "Simple AI Agent is running"}

@app.post("/generate")
async def generate_code(request: CodeRequest):
    """生成代碼"""
    try:
        # 構建更好的提示
        enhanced_prompt = f"""
You are an expert programmer. 
Task: {request.prompt}

Please provide:
1. A clear solution
2. Well-commented code
3. Example usage

Response:
"""
        result = await ollama_service.generate(enhanced_prompt, request.model)
        return {
            "status": "success",
            "result": result
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health():
    """健康檢查"""
    try:
        # 測試 Ollama 連接
        test_result = await ollama_service.generate("Say 'OK'", "llama3:8b")
        return {
            "status": "healthy",
            "ollama": "connected" if "OK" in test_result else "error"
        }
    except:
        return {"status": "unhealthy", "ollama": "disconnected"}

if __name__ == "__main__":
    print("Starting Simple AI Agent...")
    print("Make sure Ollama is running: ollama serve")
    uvicorn.run(app, host="0.0.0.0", port=8000)
