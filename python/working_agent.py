#!/usr/bin/env python3
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn
import requests
import json
import time

app = FastAPI(title="Working AI Agent")

class Prompt(BaseModel):
    text: str
    model: str = "tinyllama"

@app.get("/")
def home():
    return {"message": "Working AI Agent is running"}

@app.post("/ask")
async def ask_ollama(prompt: Prompt):
    try:
        start_time = time.time()
        
        # 簡化的請求
        payload = {
            "model": prompt.model,
            "prompt": prompt.text,
            "stream": False
        }
        
        print(f"Sending to Ollama: {payload}")
        
        response = requests.post(
            "http://localhost:11434/api/generate",
            json=payload,
            timeout=120  # 增加超時時間
        )
        
        elapsed = time.time() - start_time
        print(f"Ollama responded in {elapsed:.2f} seconds")
        
        if response.status_code == 200:
            try:
                data = response.json()
                answer = data.get("response", "")
                if answer:
                    return {
                        "question": prompt.text,
                        "answer": answer,
                        "model": prompt.model,
                        "time": f"{elapsed:.2f}s"
                    }
                else:
                    return {
                        "question": prompt.text,
                        "answer": "Empty response from model",
                        "raw_data": str(data)[:200]
                    }
            except json.JSONDecodeError:
                return {
                    "question": prompt.text,
                    "answer": "Invalid JSON response",
                    "raw": response.text[:200]
                }
        else:
            return {
                "question": prompt.text,
                "answer": f"HTTP Error {response.status_code}",
                "error": response.text[:200]
            }
            
    except requests.exceptions.Timeout:
        return {
            "question": prompt.text,
            "answer": "Request timeout - try a shorter prompt"
        }
    except Exception as e:
        return {
            "question": prompt.text,
            "answer": f"Error: {str(e)}"
        }

@app.get("/models")
def list_models():
    try:
        response = requests.get("http://localhost:11434/api/tags")
        return response.json()
    except:
        return {"error": "Cannot fetch models"}

if __name__ == "__main__":
    print("\n" + "="*50)
    print("Working AI Agent")
    print("Models available: tinyllama, gemma:2b")
    print("="*50 + "\n")
    uvicorn.run(app, host="0.0.0.0", port=8000)
