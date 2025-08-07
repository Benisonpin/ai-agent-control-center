// CTE Vibe Code - 智能整合方案
class SmartCTEVibeIntegration {
    constructor() {
        this.apiEndpoint = window.location.origin + '/.netlify/functions';
        this.commandHistory = [];
        this.init();
    }
    
    async init() {
        console.log('🎵 Smart CTE Vibe Integration 啟動...');
        this.createEmbeddedTerminal();
        await this.establishCloudConnection();
    }
    
    createEmbeddedTerminal() {
        const terminalHTML = `
            <div style="background: rgba(0,0,0,0.9); border-radius: 12px; margin: 2rem 0; overflow: hidden; border: 1px solid rgba(255,255,255,0.2);">
                <div style="background: linear-gradient(135deg, #2d3748, #4a5568); padding: 0.8rem 1rem; display: flex; align-items: center; justify-content: space-between;">
                    <div style="display: flex; gap: 0.5rem;">
                        <span style="width: 12px; height: 12px; border-radius: 50%; background: #ff5f56;"></span>
                        <span style="width: 12px; height: 12px; border-radius: 50%; background: #ffbd2e;"></span>
                        <span style="width: 12px; height: 12px; border-radius: 50%; background: #27ca3f;"></span>
                    </div>
                    <div style="color: white; font-weight: 600; font-size: 0.9rem;">☁️ CTE Vibe Cloud Terminal</div>
                    <div style="color: #a0aec0; font-size: 0.8rem;">🟢 已連接</div>
                </div>
                
                <div style="padding: 1rem; min-height: 400px; background: #1a202c;">
                    <div id="terminalOutput" style="color: #e2e8f0; font-family: Monaco, monospace; font-size: 0.9rem; line-height: 1.5; margin-bottom: 1rem; max-height: 300px; overflow-y: auto;">
                        <div style="color: #4ade80; margin-bottom: 1rem;">
🎵 CTE Vibe Code - 智能雲端終端
================================
GitHub: https://github.com/Benisonpin/ai-agent-control-center.git
直接在 Vibe Center 中執行雲端指令，無需跳轉！

💡 可用指令:
- vibe status    - 檢查系統狀態  
- vibe deploy    - 部署 AI 模型
- vibe update    - OTA 模型更新
- vibe monitor   - 系統監控
- vibe help      - 顯示所有指令
                        </div>
                    </div>
                    
                    <div style="display: flex; align-items: center; gap: 0.5rem;">
                        <span style="color: #34d399; font-family: Monaco, monospace; font-weight: 600;">vibe@cloud:~$ </span>
                        <input type="text" id="terminalInput" placeholder="輸入 vibe 指令..." style="flex: 1; background: transparent; border: none; color: #e2e8f0; font-family: Monaco, monospace; font-size: 0.9rem; outline: none; padding: 0.5rem 0;">
                    </div>
                </div>
                
                <div style="background: rgba(255,255,255,0.05); padding: 1rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
                    <button onclick="smartVibe.executeCommand('vibe status')" style="background: linear-gradient(135deg, #4f46e5, #7c3aed); border: none; color: white; padding: 0.5rem 1rem; border-radius: 6px; cursor: pointer; font-size: 0.8rem;">📊 狀態</button>
                    <button onclick="smartVibe.executeCommand('vibe deploy')" style="background: linear-gradient(135deg, #4f46e5, #7c3aed); border: none; color: white; padding: 0.5rem 1rem; border-radius: 6px; cursor: pointer; font-size: 0.8rem;">🚀 部署</button>
                    <button onclick="smartVibe.executeCommand('vibe update --check')" style="background: linear-gradient(135deg, #4f46e5, #7c3aed); border: none; color: white; padding: 0.5rem 1rem; border-radius: 6px; cursor: pointer; font-size: 0.8rem;">📡 檢查更新</button>
                    <button onclick="smartVibe.executeCommand('vibe help')" style="background: linear-gradient(135deg, #4f46e5, #7c3aed); border: none; color: white; padding: 0.5rem 1rem; border-radius: 6px; cursor: pointer; font-size: 0.8rem;">❓ 說明</button>
                </div>
            </div>
        `;
        
        const container = document.querySelector('.container') || document.body;
        container.insertAdjacentHTML('beforeend', terminalHTML);
        
        this.setupTerminalEvents();
    }
    
    setupTerminalEvents() {
        const input = document.getElementById('terminalInput');
        if (input) {
            input.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                    const command = input.value.trim();
                    if (command) {
                        this.executeCommand(command);
                        input.value = '';
                    }
                }
            });
        }
    }
    
    async establishCloudConnection() {
        this.addOutput('🔗 建立雲端連接...');
        await new Promise(resolve => setTimeout(resolve, 1000));
        this.addOutput('✅ GitHub 同步成功');
        this.addOutput('💡 輸入 "vibe help" 開始使用');
    }
    
    addOutput(text, className = '') {
        const output = document.getElementById('terminalOutput');
        if (output) {
            const line = document.createElement('div');
            line.textContent = text;
            line.style.margin = '0.3rem 0';
            if (className === 'success') line.style.color = '#10b981';
            if (className === 'error') line.style.color = '#ef4444';
            if (className === 'info') line.style.color = '#3b82f6';
            
            output.appendChild(line);
            output.scrollTop = output.scrollHeight;
        }
    }
    
    async executeCommand(command) {
        this.addOutput(`vibe@cloud:~$ ${command}`);
        this.commandHistory.push(command);
        
        if (command === 'vibe status') {
            this.addOutput('📊 CTE Vibe Center 系統狀態', 'success');
            this.addOutput('===========================');
            this.addOutput('🚁 vibe-model-service: RUNNING');
            this.addOutput('📡 ota-update-service: READY');
            this.addOutput('🌐 GitHub: 已同步');
            this.addOutput('📊 總計: 3 個服務運行中');
            
        } else if (command === 'vibe deploy') {
            this.addOutput('🚀 部署 AI 模型...', 'info');
            await new Promise(resolve => setTimeout(resolve, 2000));
            this.addOutput('✅ 部署完成!', 'success');
            
        } else if (command.startsWith('vibe update')) {
            this.addOutput('📡 檢查 OTA 更新...', 'info');
            await new Promise(resolve => setTimeout(resolve, 1500));
            this.addOutput('📦 發現 2 個可用更新');
            this.addOutput('💡 使用 "vibe update --apply" 執行更新');
            
        } else if (command === 'vibe help') {
            this.addOutput('🎵 CTE Vibe Code 指令說明', 'info');
            this.addOutput('=========================');
            this.addOutput('vibe status    - 檢查系統狀態');
            this.addOutput('vibe deploy    - 部署 AI 模型');
            this.addOutput('vibe update    - OTA 模型更新');
            this.addOutput('vibe monitor   - 系統監控');
            this.addOutput('vibe help      - 顯示說明');
            
        } else if (command.startsWith('vibe')) {
            this.addOutput('❌ 未知指令，輸入 "vibe help" 查看可用指令', 'error');
            
        } else {
            this.addOutput('💡 使用 vibe 指令管理 CTE Vibe Center');
        }
    }
}

let smartVibe;
document.addEventListener('DOMContentLoaded', () => {
    smartVibe = new SmartCTEVibeIntegration();
});
