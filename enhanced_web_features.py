# 加入到 ai_agent_web.py 的額外功能

# 1. 檔案編輯器
@app.route('/api/files')
def api_files():
    """列出可編輯的檔案"""
    files = []
    for root, dirs, filenames in os.walk('ai-isp-ums-integration'):
        for filename in filenames:
            if filename.endswith(('.c', '.h', '.v')):
                files.append(os.path.join(root, filename))
    return jsonify({'files': files})

@app.route('/api/file/<path:filepath>')
def api_get_file(filepath):
    """讀取檔案內容"""
    try:
        with open(filepath, 'r') as f:
            content = f.read()
        return jsonify({'content': content, 'path': filepath})
    except:
        return jsonify({'error': 'File not found'}), 404

@app.route('/api/file/<path:filepath>', methods=['POST'])
def api_save_file(filepath):
    """儲存檔案"""
    try:
        data = request.get_json()
        with open(filepath, 'w') as f:
            f.write(data['content'])
        return jsonify({'status': 'success', 'message': '檔案已儲存'})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

# 2. 編譯輸出檢視
@app.route('/api/compile-output')
def api_compile_output():
    """獲取最新編譯輸出"""
    try:
        compile_logs = glob.glob('agent_logs/compile_*.log')
        if compile_logs:
            latest = max(compile_logs, key=os.path.getctime)
            with open(latest, 'r') as f:
                content = f.read()
            return jsonify({'output': content})
        return jsonify({'output': 'No compile output found'})
    except:
        return jsonify({'output': 'Error reading compile output'})

# 3. 即時通知 (WebSocket)
from flask_socketio import SocketIO, emit

socketio = SocketIO(app)

@socketio.on('connect')
def handle_connect():
    emit('message', {'data': 'Connected to AI Agent'})

# 4. 任務排程
@app.route('/api/schedule', methods=['POST'])
def api_schedule():
    """排程定時任務"""
    data = request.get_json()
    task_type = data.get('type')  # compile, test, report
    interval = data.get('interval')  # minutes
    
    # 實作排程邏輯
    return jsonify({'status': 'scheduled', 'task': task_type, 'interval': interval})

# 5. 歷史記錄
@app.route('/api/history/<int:days>')
def api_history(days):
    """獲取歷史資料"""
    history = []
    for i in range(days):
        date = (datetime.now() - timedelta(days=i)).strftime('%Y%m%d')
        log_file = f'agent_logs/stable_agent_{date}.log'
        if os.path.exists(log_file):
            with open(log_file, 'r') as f:
                content = f.read()
            stats = {
                'date': date,
                'changes': content.count('偵測到檔案變更'),
                'compiles': content.count('編譯成功'),
                'tests': content.count('測試通過'),
                'errors': content.count('ERROR')
            }
            history.append(stats)
    return jsonify({'history': history})

# 6. 系統資源監控
@app.route('/api/system')
def api_system():
    """系統資源使用情況"""
    import psutil
    
    return jsonify({
        'cpu_percent': psutil.cpu_percent(interval=1),
        'memory_percent': psutil.virtual_memory().percent,
        'disk_usage': psutil.disk_usage('/').percent,
        'agent_memory': get_agent_memory_usage()
    })

def get_agent_memory_usage():
    """獲取 Agent 記憶體使用"""
    try:
        result = subprocess.run(['pgrep', '-f', 'stable_ai_agent'], capture_output=True, text=True)
        if result.returncode == 0:
            pid = int(result.stdout.strip().split('\n')[0])
            process = psutil.Process(pid)
            return process.memory_info().rss / 1024 / 1024  # MB
    except:
        pass
    return 0

# 7. 設定管理
@app.route('/api/config')
def api_get_config():
    """獲取設定"""
    config = {
        'check_interval': 30,  # 秒
        'compile_timeout': 60,  # 秒
        'test_timeout': 30,  # 秒
        'log_retention': 7,  # 天
    }
    return jsonify(config)

@app.route('/api/config', methods=['POST'])
def api_set_config():
    """更新設定"""
    data = request.get_json()
    # 儲存設定到檔案
    with open('agent_config.json', 'w') as f:
        json.dump(data, f)
    return jsonify({'status': 'success', 'message': '設定已更新'})
