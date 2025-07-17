document.addEventListener('DOMContentLoaded', function() {
    // 導航按鈕功能
    const navButtons = document.querySelectorAll('.menu-item');
    
    navButtons.forEach(button => {
        button.onclick = function() {
            // 移除所有 active
            navButtons.forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
            
            // 隱藏所有 section
            document.querySelectorAll('.section').forEach(section => {
                section.style.display = 'none';
            });
            
            // 顯示對應內容
            const text = this.textContent.trim();
            let targetSection = null;
            
            switch(text) {
                case '系統總覽':
                    targetSection = document.getElementById('overview');
                    break;
                case '場景識別':
                    targetSection = document.getElementById('scene-recognition');
                    break;
                case '物件追蹤':
                    targetSection = document.getElementById('object-tracking');
                    break;
                case '系統架構':
                    targetSection = document.getElementById('system-architecture');
                    break;
                case '記憶體優化':
                    targetSection = document.getElementById('memory-optimization');
                    break;
                case 'HDR 控制':
                    targetSection = document.getElementById('hdr-control');
                    break;
                case '效能分析':
                    targetSection = document.getElementById('performance-analysis');
                    break;
            }
            
            if (targetSection) {
                targetSection.style.display = 'block';
                initializeSectionFeatures(text);
            }
        };
    });
    
    // OTA 更新按鈕功能
    document.querySelectorAll('.update-button').forEach(button => {
        button.onclick = function() {
            this.textContent = '更新中...';
            this.disabled = true;
            
            setTimeout(() => {
                this.textContent = '已更新';
                this.style.backgroundColor = '#4caf50';
            }, 3000);
        };
    });
    
    // 初始化各功能區的特性
    function initializeSectionFeatures(sectionName) {
        switch(sectionName) {
            case '場景識別':
                initSceneRecognition();
                break;
            case '物件追蹤':
                initObjectTracking();
                break;
            case '系統架構':
                initSystemArchitecture();
                break;
            case '記憶體優化':
                initMemoryOptimization();
                break;
            case 'HDR 控制':
                initHDRControl();
                break;
            case '效能分析':
                initPerformanceAnalysis();
                break;
        }
    }
    
    // 場景識別功能
    function initSceneRecognition() {
        document.querySelectorAll('.scene-mode-btn').forEach(button => {
            button.onclick = function() {
                document.querySelectorAll('.scene-mode-btn').forEach(btn => {
                    btn.classList.remove('active');
                });
                this.classList.add('active');
                
                // 更新場景信息
                const sceneName = this.textContent;
                const sceneInfo = document.querySelector('.stat-card p.stat-value');
                if (sceneInfo) {
                    sceneInfo.textContent = getSceneName(sceneName);
                }
            };
        });
    }
    
    function getSceneName(mode) {
        const sceneMap = {
            '自動': '室內辦公室',
            '室內': '室內環境',
            '戶外': '戶外陽光',
            '夜間': '夜間模式',
            '運動': '運動追蹤'
        };
        return sceneMap[mode] || '未知場景';
    }
    
    // 物件追蹤功能
    function initObjectTracking() {
        // 模擬追蹤狀態更新
        let trackingCount = 3;
        setInterval(() => {
            const countElement = document.querySelector('#object-tracking .stat-value');
            if (countElement && document.getElementById('object-tracking').style.display !== 'none') {
                trackingCount = Math.floor(Math.random() * 5) + 1;
                countElement.textContent = trackingCount;
            }
        }, 5000);
    }
    
    // 系統架構功能
    function initSystemArchitecture() {
        // 動態更新系統負載
        setInterval(() => {
            if (document.getElementById('system-architecture').style.display !== 'none') {
                updateSystemLoad();
            }
        }, 3000);
    }
    
    function updateSystemLoad() {
        const loads = {
            'CPU': Math.floor(Math.random() * 40) + 30,
            'GPU': Math.floor(Math.random() * 50) + 40,
            'NPU': Math.floor(Math.random() * 30) + 10
        };
        
        document.querySelectorAll('.load-fill').forEach(fill => {
            const text = fill.textContent.split(':')[0];
            const value = loads[text];
            if (value) {
                fill.style.width = value + '%';
                fill.textContent = `${text}: ${value}%`;
            }
        });
    }
    
    // 記憶體優化功能
    function initMemoryOptimization() {
        document.querySelectorAll('.opt-button').forEach(button => {
            button.onclick = function() {
                const originalText = this.textContent;
                this.textContent = '處理中...';
                this.disabled = true;
                
                // 更新記憶體使用率
                setTimeout(() => {
                    this.textContent = '✓ 完成';
                    this.style.backgroundColor = '#10b981';
                    this.style.borderColor = '#10b981';
                    this.style.color = 'white';
                    
                    // 降低記憶體使用率
                    const progressValue = document.querySelector('.progress-value');
                    if (progressValue) {
                        let currentValue = parseInt(progressValue.textContent);
                        let newValue = Math.max(currentValue - 10, 45);
                        progressValue.textContent = newValue + '%';
                        
                        // 更新圓形進度條
                        const circularProgress = document.querySelector('.circular-progress');
                        if (circularProgress) {
                            const degree = (newValue / 100) * 360;
                            circularProgress.style.background = 
                                `conic-gradient(#3b82f6 0deg, #3b82f6 ${degree}deg, #1e293b ${degree}deg)`;
                        }
                    }
                    
                    setTimeout(() => {
                        this.textContent = originalText;
                        this.style.backgroundColor = '';
                        this.style.borderColor = '';
                        this.style.color = '';
                        this.disabled = false;
                    }, 2000);
                }, 1500);
            };
        });
    }
    
    // HDR 控制功能
    function initHDRControl() {
        // HDR 開關切換
        document.querySelectorAll('.toggle-btn').forEach(button => {
            button.onclick = function() {
                const group = button.parentElement;
                group.querySelectorAll('.toggle-btn').forEach(btn => {
                    btn.classList.remove('active');
                });
                this.classList.add('active');
                
                // 更新預覽
                if (this.textContent === '開啟') {
                    document.querySelector('.preview-box:last-child').classList.add('active');
                    document.querySelector('.preview-box:first-child').classList.remove('active');
                } else {
                    document.querySelector('.preview-box:first-child').classList.add('active');
                    document.querySelector('.preview-box:last-child').classList.remove('active');
                }
            };
        });
        
        // 滑動條數值更新
        const slider = document.querySelector('.slider');
        if (slider) {
            slider.oninput = function() {
                const value = this.value;
                const valueDisplay = this.nextElementSibling;
                if (valueDisplay) {
                    valueDisplay.textContent = value + '%';
                }
            };
        }
        
        // 下拉選單變更
        const select = document.querySelector('.setting-select');
        if (select) {
            select.onchange = function() {
                console.log('色調映射模式:', this.value);
            };
        }
    }
    
    // 效能分析功能
    function initPerformanceAnalysis() {
        // 動態更新效能指標
        setInterval(() => {
            if (document.getElementById('performance-analysis').style.display !== 'none') {
                updatePerformanceMetrics();
            }
        }, 2000);
    }
    
    function updatePerformanceMetrics() {
        // FPS
        const fpsElement = document.querySelector('#performance-analysis .metric-card:nth-child(1) .metric-value');
        if (fpsElement) {
            const fps = (Math.random() * 2 + 58).toFixed(1);
            fpsElement.textContent = fps;
            
            const fpsTrend = fpsElement.nextElementSibling;
            if (fpsTrend) {
                const change = (Math.random() * 5 - 2.5).toFixed(1);
                fpsTrend.textContent = change > 0 ? `↑ ${Math.abs(change)}%` : `↓ ${Math.abs(change)}%`;
                fpsTrend.className = change > 0 ? 'metric-trend up' : 'metric-trend down';
            }
        }
        
        // 延遲
        const latencyElement = document.querySelector('#performance-analysis .metric-card:nth-child(2) .metric-value');
        if (latencyElement) {
            const latency = Math.floor(Math.random() * 5 + 10);
            latencyElement.textContent = latency + 'ms';
        }
        
        // 吞吐量
        const throughputElement = document.querySelector('#performance-analysis .metric-card:nth-child(3) .metric-value');
        if (throughputElement) {
            const throughput = (Math.random() * 0.8 + 3.8).toFixed(1);
            throughputElement.textContent = throughput + 'GB/s';
        }
        
        // 功耗
        const powerElement = document.querySelector('#performance-analysis .metric-card:nth-child(4) .metric-value');
        if (powerElement) {
            const power = (Math.random() * 0.4 + 3.6).toFixed(1);
            powerElement.textContent = power + 'W';
        }
    }
    
    // 初始化系統狀態更新
    function updateSystemStatus() {
        console.log('System status updated');
    }
    
    // 每5秒更新一次狀態
    setInterval(updateSystemStatus, 5000);
});
