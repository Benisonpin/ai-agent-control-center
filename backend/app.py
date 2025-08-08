#!/usr/bin/env python3
"""
CTE Vibe Code Center - 後端 API 服務器
支援 AI 代碼生成、文件管理、Cloud Shell 整合
"""

from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import os
import json
import subprocess
import tempfile
import uuid
from datetime import datetime

app = Flask(__name__)
CORS(app)  # 允許跨域請求

# 配置
WORKSPACE_DIR = "workspace"
PROJECTS_DIR = "projects"

# 確保目錄存在
os.makedirs(WORKSPACE_DIR, exist_ok=True)
os.makedirs(PROJECTS_DIR, exist_ok=True)

@app.route('/')
def index():
    """主頁面"""
    return send_from_directory('../frontend', 'index.html')

@app.route('/<path:filename>')
def static_files(filename):
    """靜態文件服務"""
    return send_from_directory('../frontend', filename)

@app.route('/api/ai/generate', methods=['POST'])
def generate_code():
    """AI 代碼生成 API"""
    try:
        data = request.get_json()
        prompt = data.get('prompt', '')
        language = data.get('language', 'python')
        complexity = data.get('complexity', 'medium')
        project_type = data.get('projectType', 'generic')
        
        # 模擬 AI 代碼生成
        generated_code = simulate_ai_generation(prompt, language, complexity, project_type)
        
        return jsonify({
            'success': True,
            'code': generated_code['code'],
            'language': language,
            'analysis': generated_code['analysis'],
            'suggestions': generated_code['suggestions']
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/cloud-shell/connect', methods=['POST'])
def connect_cloud_shell():
    """Cloud Shell 連接"""
    session_id = str(uuid.uuid4())
    
    return jsonify({
        'success': True,
        'session_id': session_id,
        'message': '已連接到 CTE Cloud Shell'
    })

@app.route('/api/cloud-shell/execute', methods=['POST'])
def execute_command():
    """執行 Shell 命令"""
    try:
        data = request.get_json()
        command = data.get('command', '')
        
        # 安全檢查
        if not is_safe_command(command):
            return jsonify({
                'success': False,
                'error': '不安全的命令'
            }), 400
        
        # 執行命令
        result = subprocess.run(
            command.split(),
            capture_output=True,
            text=True,
            timeout=30,
            cwd=WORKSPACE_DIR
        )
        
        return jsonify({
            'success': True,
            'output': result.stdout,
            'error': result.stderr,
            'returncode': result.returncode
        })
        
    except subprocess.TimeoutExpired:
        return jsonify({
            'success': False,
            'error': '命令執行超時'
        }), 408
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/cloud-shell/files', methods=['GET'])
def list_files():
    """列出工作空間文件"""
    try:
        files = []
        for root, dirs, filenames in os.walk(WORKSPACE_DIR):
            for filename in filenames:
                filepath = os.path.join(root, filename)
                relative_path = os.path.relpath(filepath, WORKSPACE_DIR)
                files.append({
                    'name': filename,
                    'path': relative_path,
                    'type': 'file',
                    'size': os.path.getsize(filepath),
                    'modified': datetime.fromtimestamp(
                        os.path.getmtime(filepath)
                    ).isoformat()
                })
        
        return jsonify({
            'success': True,
            'files': files
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/cloud-shell/file/<path:filepath>', methods=['GET', 'PUT'])
def handle_file(filepath):
    """文件讀取/寫入"""
    full_path = os.path.join(WORKSPACE_DIR, filepath)
    
    try:
        if request.method == 'GET':
            # 讀取文件
            with open(full_path, 'r', encoding='utf-8') as f:
                content = f.read()
            return content
            
        elif request.method == 'PUT':
            # 寫入文件
            content = request.get_data(as_text=True)
            os.makedirs(os.path.dirname(full_path), exist_ok=True)
            
            with open(full_path, 'w', encoding='utf-8') as f:
                f.write(content)
                
            return jsonify({
                'success': True,
                'message': f'文件已保存: {filepath}'
            })
            
    except FileNotFoundError:
        return jsonify({
            'success': False,
            'error': '文件不存在'
        }), 404
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/projects', methods=['GET', 'POST'])
def handle_projects():
    """專案管理"""
    if request.method == 'GET':
        # 列出專案
        projects = []
        for project_dir in os.listdir(PROJECTS_DIR):
            project_path = os.path.join(PROJECTS_DIR, project_dir)
            if os.path.isdir(project_path):
                try:
                    with open(os.path.join(project_path, 'project.json'), 'r') as f:
                        project_info = json.load(f)
                        projects.append(project_info)
                except:
                    pass
        
        return jsonify({
            'success': True,
            'projects': projects
        })
    
    elif request.method == 'POST':
        # 創建專案
        data = request.get_json()
        project_name = data.get('name')
        project_type = data.get('type')
        
        project_id = project_name.lower().replace(' ', '-')
        project_path = os.path.join(PROJECTS_DIR, project_id)
        
        os.makedirs(project_path, exist_ok=True)
        
        # 創建專案配置
        project_config = {
            'id': project_id,
            'name': project_name,
            'type': project_type,
            'created': datetime.now().isoformat(),
            'files': []
        }
        
        with open(os.path.join(project_path, 'project.json'), 'w') as f:
            json.dump(project_config, f, indent=2)
        
        return jsonify({
            'success': True,
            'project': project_config
        })

def simulate_ai_generation(prompt, language, complexity, project_type):
    """模擬 AI 代碼生成"""
    templates = {
        'python': {
            'simple': f'''# {prompt}
def main():
    print("Hello from CTE AI!")
    return True

if __name__ == "__main__":
    main()''',
            'medium': f'''#!/usr/bin/env python3
"""
{prompt}
Generated by CTE AI Assistant
"""

import logging
from typing import Optional

class GeneratedClass:
    def __init__(self, config: Optional[dict] = None):
        self.config = config or {{}}
        self.setup_logging()
        
    def setup_logging(self):
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
        
    def process(self, data):
        self.logger.info("Processing data...")
        # TODO: Implement logic
        return data
        
    def run(self):
        result = self.process("sample data")
        self.logger.info(f"Result: {{result}}")
        return result

if __name__ == "__main__":
    app = GeneratedClass()
    app.run()''',
            'complex': f'''#!/usr/bin/env python3
"""
{prompt}
Advanced implementation with async support
Generated by CTE AI Assistant
"""

import asyncio
import logging
from typing import Optional, Dict, Any
from dataclasses import dataclass
from abc import ABC, abstractmethod

@dataclass
class Config:
    debug: bool = True
    timeout: int = 30
    max_retries: int = 3

class BaseProcessor(ABC):
    @abstractmethod
    async def process(self, data: Any) -> Any:
        pass

class AdvancedGeneratedClass(BaseProcessor):
    def __init__(self, config: Optional[Config] = None):
        self.config = config or Config()
        self.setup_logging()
        self._state = {{}}
        
    def setup_logging(self):
        level = logging.DEBUG if self.config.debug else logging.INFO
        logging.basicConfig(level=level)
        self.logger = logging.getLogger(__name__)
        
    async def process(self, data: Any) -> Any:
        """Async processing with error handling"""
        try:
            self.logger.info("Starting async processing...")
            
            # Simulate async work
            await asyncio.sleep(0.1)
            
            result = await self._process_with_retry(data)
            self.logger.info("Processing completed successfully")
            return result
            
        except Exception as e:
            self.logger.error(f"Processing failed: {{e}}")
            raise
    
    async def _process_with_retry(self, data: Any) -> Any:
        """Process with retry logic"""
        for attempt in range(self.config.max_retries):
            try:
                # TODO: Implement actual processing logic
                return {{"processed": data, "attempt": attempt + 1}}
            except Exception as e:
                if attempt == self.config.max_retries - 1:
                    raise
                await asyncio.sleep(2 ** attempt)
        
    async def run(self):
        """Main execution method"""
        tasks = [
            self.process(f"data_{{i}}")
            for i in range(3)
        ]
        results = await asyncio.gather(*tasks)
        self.logger.info(f"All tasks completed: {{len(results)}} results")
        return results

async def main():
    app = AdvancedGeneratedClass()
    results = await app.run()
    print(f"Final results: {{results}}")

if __name__ == "__main__":
    asyncio.run(main())'''
        }
    }
    
    # 獲取對應的代碼模板
    code = templates.get(language, {}).get(complexity, f"// {prompt}\nconsole.log('Generated code');")
    
    return {
        'code': code,
        'analysis': f'📊 生成了 {complexity} 複雜度的 {language} 代碼，包含錯誤處理和日誌記錄',
        'suggestions': '💡 建議添加單元測試和詳細文檔'
    }

def is_safe_command(command):
    """檢查命令是否安全"""
    dangerous_commands = [
        'rm', 'rmdir', 'del', 'format', 'fdisk',
        'mkfs', 'dd', 'shutdown', 'reboot', 'halt',
        'sudo', 'su', 'passwd', 'chmod +x'
    ]
    
    return not any(dangerous in command.lower() for dangerous in dangerous_commands)

if __name__ == '__main__':
    print("🚀 啟動 CTE Vibe Code Center 後端服務器...")
    app.run(host='0.0.0.0', port=5000, debug=True)
