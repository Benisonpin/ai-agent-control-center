#!/bin/bash
echo "Starting Ollama in background..."
ollama serve > ollama.log 2>&1 &
sleep 3

echo "Starting AI Agent in background..."
python simplest_agent.py > agent.log 2>&1 &
sleep 2

echo "Services started!"
echo "Agent log: tail -f agent.log"
echo "Ollama log: tail -f ollama.log"
echo ""
echo "Test with: curl http://localhost:8000/test"
