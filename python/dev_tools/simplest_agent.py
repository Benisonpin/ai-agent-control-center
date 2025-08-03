#!/usr/bin/env python3
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn
import requests
import json

app = FastAPI(title="Simplest AI Agent")

class Prompt(BaseModel):
    text: str
    model: str = "llama3:8b"

@app.get("/")
def home():
    return {"message": "AI Agent is running"}

@app.post("/ask")
def ask_ollama(prompt: Prompt):
    try:
        # 使用 requests 而不是 httpx
        response = requests.post(
            "http://localhost:11434/api/generate",
            json={
                "model": prompt.model,
                "prompt": prompt.text,
                "stream": False
            },
            timeout=60
        )
        data = response.json()
        return {
            "question": prompt.text,
            "answer": data.get("response", "No response")
        }
    except requests.exceptions.ConnectionError:
        raise HTTPException(status_code=503, detail="Ollama not running")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/test")
def test_ollama():
    try:
        response = requests.get("http://localhost:11434/api/tags", timeout=5)
        models = response.json()
        return {"status": "OK", "available_models": models}
    except:
        return {"status": "Error", "message": "Cannot connect to Ollama"}

if __name__ == "__main__":
    print("\n" + "="*50)
    print("Simplest AI Agent")
    print("="*50)
    print("1. 確保 Ollama 正在運行: ollama serve")
    print("2. API 在 http://localhost:8000")
    print("="*50 + "\n")
    uvicorn.run(app, host="0.0.0.0", port=8000)
