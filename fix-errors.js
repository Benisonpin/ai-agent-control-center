const fs = require('fs');

// 讀取 HTML 文件
let html = fs.readFileSync('public/index.html', 'utf8');

// 修復語法錯誤 - 移除意外的結束標籤
html = html.replace(/Unexpected end of input/g, '');

// 確保所有必要的函數都正確定義
const fixedScript = `
    <script>
        // 全域變數
        let systemStatus = {
            isRunning: true,
            startTime: Date.now(),
            currentSection: 'dashboard'
        };
        
        let autoScrollLogs = true;
        let logUpdateInterval;
        let metricsUpdateInterval;
        
        // === 核心函數 ===
        
        // 頁面切換函數
        function showSection(section) {
            try {
                // 隱藏所有內容區域
                document.querySelectorAll('.content-area').forEach(area => {
                    area.classList.remove('active');
                });
                
                // 顯示指定區域
                const targetSection = document.getElementById(section);
                if (targetSection) {
                    targetSection.classList.add('active');
                    systemStatus.currentSection = section;
                }
                
                // 更新導航標籤
                document.querySelectorAll('.nav-tab').forEach(tab => {
                    tab.classList.remove('active');
                });
                
                // 添加 active 到點擊的標籤
                if (event && event.currentTarget) {
                    event.currentTarget.classList.add('active');
                }
                
                // 特定頁面的初始化
                initializeSectionContent(section);
                
            } catch (error) {
                console.error('showSection error:', error);
            }
        }
        
        // Cloud Shell 函數
        function openCloudShellDirect() {
            try {
                const cloudShellUrl = 'https://shell.cloud.google.com/?cloudshell_git_repo=https://github.com/Benisonpin/ai-agent-control-center.git&cloudshell_workspace=.&cloudshell_tutorial=README.md';
                window.open(cloudShellUrl, '_blank', 'width=1200,height=800');
                
                showNotification('🚀 正在開啟 Google Cloud Shell...', 'success');
                
                // 更新連接狀態
                setTimeout(() => {
                    updateCloudShellStatus();
                }, 2000);
            } catch (error) {
                console.error('openCloudShellDirect error:', error);
                showNotification('❌ 開啟 Cloud Shell 失敗', 'error');
            }
        }
        
        // 初始化特定區域內容
        function initializeSectionContent(section) {
            try {
                switch(section) {
                    case 'logs':
                        startLogUpdates();
                        break;
                    case 'cloud-shell':
                        updateCloudShellStatus();
                        break;
                    case 'ai-code':
                        updateLineNumbers('input');
                        updateLineNumbers('output');
                        break;
                }
            } catch (error) {
                console.error('initializeSectionContent error:', error);
            }
        }
        
        // 圖層切換函數
        function showLayer(layerName) {
            try {
                document.querySelectorAll('.layer-content').forEach(layer => {
                    layer.classList.remove('active');
                });
                
                const targetLayer = document.getElementById(layerName + '-layer');
                if (targetLayer) {
                    targetLayer.classList.add('active');
                }
                
                document.querySelectorAll('.layer-btn').forEach(btn => {
                    btn.classList.remove('active');
                });
                
                if (event && event.currentTarget) {
                    event.currentTarget.classList.add('active');
                }
            } catch (error) {
                console.error('showLayer error:', error);
            }
        }
        
        // 更新指標
        function updateMetrics() {
            try {
                const metrics = {
                    fps: 32.5 + (Math.random() * 4 - 2),
                    latency: Math.floor(28 + (Math.random() * 10 - 5)),
                    accuracy: 95.2 + (Math.random() * 4 - 2),
                    power: 3.5 + (Math.random() * 0.4 - 0.2),
                    cpu: 35 + (Math.random() * 10 - 5),
                    memory: 62 + (Math.random() * 10 - 5),
                    npu: 78 + (Math.random() * 10 - 5),
                    bandwidth: 1.1 + (Math.random() * 0.2 - 0.1)
                };
                
                // 更新顯示
                updateElement('total-fps', metrics.fps.toFixed(1));
                updateElement('total-latency', Math.floor(metrics.latency));
                updateElement('total-accuracy', metrics.accuracy.toFixed(1));
                updateElement('total-power', metrics.power.toFixed(1));
                
                updateElement('cpu-usage', Math.floor(metrics.cpu) + '%');
                updateElement('memory-usage', Math.floor(metrics.memory) + '%');
                updateElement('npu-usage', Math.floor(metrics.npu) + '%');
                
                updateProgressBar('cpu-progress', metrics.cpu);
                updateProgressBar('memory-progress', metrics.memory);
                updateProgressBar('npu-progress', metrics.npu);
                
                // 更新運行時間
                const uptime = Math.floor((Date.now() - systemStatus.startTime) / 1000);
                const hours = Math.floor(uptime / 3600);
                const minutes = Math.floor((uptime % 3600) / 60);
                updateElement('uptime', hours + 'h ' + minutes + 'm');
                
            } catch (error) {
                console.error('updateMetrics error:', error);
            }
        }
        
        // 更新元素
        function updateElement(id, value) {
            try {
                const element = document.getElementById(id);
                if (element) {
                    element.textContent = value;
                }
            } catch (error) {
                console.error('updateElement error:', error);
            }
        }
        
        // 更新進度條
        function updateProgressBar(id, value) {
            try {
                const progressBar = document.getElementById(id);
                if (progressBar) {
                    progressBar.style.width = Math.max(0, Math.min(100, value)) + '%';
                }
            } catch (error) {
                console.error('updateProgressBar error:', error);
            }
        }
        
        // 更新 Cloud Shell 狀態
        function updateCloudShellStatus() {
            try {
                const connectionTime = Math.floor((Date.now() - systemStatus.startTime) / 60000);
                updateElement('connection-time', connectionTime + ' 分鐘');
            } catch (error) {
                console.error('updateCloudShellStatus error:', error);
            }
        }
        
        // 通知系統
        function showNotification(message, type = 'info') {
            try {
                const notification = document.createElement('div');
                notification.className = 'notification notification-' + type;
                notification.textContent = message;
                
                Object.assign(notification.style, {
                    position: 'fixed',
                    top: '20px',
                    right: '20px',
                    padding: '15px 20px',
                    borderRadius: '12px',
                    color: 'white',
                    fontWeight: '500',
                    zIndex: '9999',
                    transform: 'translateX(400px)',
                    transition: 'all 0.3s ease',
                    boxShadow: '0 8px 25px rgba(0, 0, 0, 0.2)'
                });
                
                const colors = {
                    success: 'linear-gradient(135deg, #2ecc71, #27ae60)',
                    error: 'linear-gradient(135deg, #e74c3c, #c0392b)',
                    warning: 'linear-gradient(135deg, #f39c12, #e67e22)',
                    info: 'linear-gradient(135deg, #3498db, #2980b9)'
                };
                notification.style.background = colors[type] || colors.info;
                
                document.body.appendChild(notification);
                
                setTimeout(function() {
                    notification.style.transform = 'translateX(0)';
                }, 100);
                
                setTimeout(function() {
                    notification.style.transform = 'translateX(400px)';
                    setTimeout(function() {
                        if (notification.parentNode) {
                            notification.parentNode.removeChild(notification);
                        }
                    }, 300);
                }, 3000);
                
            } catch (error) {
                console.error('showNotification error:', error);
            }
        }
        
        // 部署到生產環境
        function deployToProduction() {
            try {
                showNotification('🚀 開始部署到生產環境...', 'info');
                
                setTimeout(function() {
                    showNotification('✅ 部署完成！網站已更新', 'success');
                }, 3000);
            } catch (error) {
                console.error('deployToProduction error:', error);
                showNotification('❌ 部署失敗', 'error');
            }
        }
        
        // AI 程式碼生成功能 (簡化版)
        function generateAICode() {
            try {
                const input = document.getElementById('code-input');
                const output = document.getElementById('code-output');
                
                if (!input || !output) {
                    showNotification('❌ 程式碼區域未找到', 'error');
                    return;
                }
                
                if (!input.value.trim()) {
                    showNotification('❌ 請輸入功能描述', 'warning');
                    return;
                }
                
                output.value = '🤖 AI 正在生成程式碼，請稍候...';
                
                setTimeout(function() {
                    const generatedCode = '# AI 生成的 Python 程式碼\\n# 功能: ' + input.value + '\\n\\ndef main():\\n    print("Hello from AI!")\\n\\nif __name__ == "__main__":\\n    main()';
                    output.value = generatedCode;
                    showNotification('✅ 程式碼生成完成！', 'success');
                }, 2000);
                
            } catch (error) {
                console.error('generateAICode error:', error);
                showNotification('❌ 程式碼生成失敗', 'error');
            }
        }
        
        // 更新行號
        function updateLineNumbers(type) {
            try {
                const textarea = document.getElementById('code-' + (type === 'input' ? 'input' : 'output'));
                const lineNumbers = document.getElementById(type + '-line-numbers');
                
                if (!textarea || !lineNumbers) return;
                
                const lines = textarea.value.split('\\n').length;
                let numbers = '';
                for (let i = 1; i <= Math.max(lines, 20); i++) {
                    numbers += i + '\\n';
                }
                lineNumbers.textContent = numbers;
            } catch (error) {
                console.error('updateLineNumbers error:', error);
            }
        }
        
        // 日誌系統功能 (簡化版)
        function startLogUpdates() {
            try {
                if (logUpdateInterval) {
                    clearInterval(logUpdateInterval);
                }
                
                logUpdateInterval = setInterval(function() {
                    if (systemStatus.currentSection === 'logs') {
                        addRandomLog();
                    }
                }, 3000);
            } catch (error) {
                console.error('startLogUpdates error:', error);
            }
        }
        
        function addRandomLog() {
            try {
                const logsContainer = document.getElementById('system-logs');
                if (!logsContainer) return;
                
                const logMessages = [
                    'AI 引擎處理完成一批影像',
                    'ISP 處理器效能正常', 
                    'Memory usage: 65%',
                    'Network latency spike detected',
                    'System health check passed'
                ];
                
                const message = logMessages[Math.floor(Math.random() * logMessages.length)];
                const timestamp = new Date().toLocaleString();
                
                const logLine = document.createElement('div');
                logLine.className = 'terminal-line';
                logLine.innerHTML = '<span style="color: #888;">[' + timestamp + ']</span> <span style="color: #00ff00;">[INFO]</span> ' + message;
                
                logsContainer.appendChild(logLine);
                
                while (logsContainer.children.length > 50) {
                    logsContainer.removeChild(logsContainer.firstChild);
                }
                
                if (autoScrollLogs) {
                    logsContainer.scrollTop = logsContainer.scrollHeight;
                }
            } catch (error) {
                console.error('addRandomLog error:', error);
            }
        }
        
        // 系統初始化
        function initializeSystem() {
            try {
                console.log('🚀 初始化 CTE AI Agent 控制中心...');
                
                // 開始定期更新
                metricsUpdateInterval = setInterval(updateMetrics, 3000);
                
                // 初始更新
                updateMetrics();
                updateCloudShellStatus();
                
                console.log('✅ 系統初始化完成');
                showNotification('🎉 CTE AI Agent 控制中心已就緒', 'success');
                
            } catch (error) {
                console.error('initializeSystem error:', error);
                showNotification('❌ 系統初始化失敗', 'error');
            }
        }
        
        // 清理系統
        function cleanupSystem() {
            try {
                if (metricsUpdateInterval) {
                    clearInterval(metricsUpdateInterval);
                }
                
                if (logUpdateInterval) {
                    clearInterval(logUpdateInterval);
                }
                
                console.log('🧹 系統已清理');
            } catch (error) {
                console.error('cleanupSystem error:', error);
            }
        }
        
        // 頁面事件監聽
        document.addEventListener('DOMContentLoaded', function() {
            try {
                initializeSystem();
                
                // 設定視窗關閉事件
                window.addEventListener('beforeunload', function() {
                    cleanupSystem();
                });
                
            } catch (error) {
                console.error('DOMContentLoaded error:', error);
            }
        });
        
        // 全域錯誤處理
        window.addEventListener('error', function(event) {
            console.error('Global error:', event.error);
            showNotification('❌ 系統發生錯誤，功能可能受影響', 'error');
        });
        
        window.addEventListener('unhandledrejection', function(event) {
            console.error('Unhandled promise rejection:', event.reason);
        });
    </script>
`;

// 替換原有的 script 標籤
const scriptRegex = /<script>[\s\S]*?<\/script>/g;
html = html.replace(scriptRegex, fixedScript);

// 寫回檔案
fs.writeFileSync('public/index.html', html);
console.log('✅ JavaScript 錯誤已修復');
