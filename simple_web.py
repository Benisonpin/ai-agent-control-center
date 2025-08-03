#!/usr/bin/env python3
import os
from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/')
def index():
    return "<h1>AI Agent Dashboard</h1><p>Status: Running</p>"

@app.route('/api/status')
def status():
    return jsonify({'status': 'ok'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
