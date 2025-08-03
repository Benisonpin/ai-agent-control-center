// AI ISP Agent API 客戶端
class AIISPAgentClient {
    constructor(apiUrl = 'http://localhost:8000') {
        this.apiUrl = apiUrl;
        this.ws = null;
    }

    // 生成 Verilog 模組
    async generateVerilog(moduleType, specifications, creativityLevel = 0.7) {
        const response = await fetch(`${this.apiUrl}/generate/verilog`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                module_type: moduleType,
                specifications: specifications,
                creativity_level: creativityLevel
            })
        });
        return await response.json();
    }

    // 優化 Verilog 程式碼
    async optimizeVerilog(code, goals) {
        const response = await fetch(`${this.apiUrl}/optimize/verilog`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                verilog_code: code,
                optimization_goals: goals
            })
        });
        return await response.json();
    }

    // 分析演算法
    async analyzeAlgorithm(description, platform = 'FPGA') {
        const response = await fetch(`${this.apiUrl}/analyze/algorithm`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                algorithm_description: description,
                target_platform: platform
            })
        });
        return await response.json();
    }

    // 上傳設計檔案
    async uploadDesignFile(file) {
        const formData = new FormData();
        formData.append('file', file);
        
        const response = await fetch(`${this.apiUrl}/upload/design`, {
            method: 'POST',
            body: formData
        });
        return await response.json();
    }

    // 取得系統狀態
    async getSystemStatus() {
        const response = await fetch(`${this.apiUrl}/status`);
        return await response.json();
    }

    // 取得效能指標
    async getPerformanceMetrics() {
        const response = await fetch(`${this.apiUrl}/performance`);
        return await response.json();
    }

    // WebSocket 連接
    connectWebSocket(onMessage) {
        this.ws = new WebSocket(`ws://localhost:8000/ws/agent`);
        
        this.ws.onopen = () => {
            console.log('WebSocket 連接成功');
        };
        
        this.ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            onMessage(data);
        };
        
        this.ws.onerror = (error) => {
            console.error('WebSocket 錯誤:', error);
        };
        
        this.ws.onclose = () => {
            console.log('WebSocket 連接關閉');
        };
    }

    // 發送 WebSocket 訊息
    sendMessage(type, data) {
        if (this.ws && this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify({ type, ...data }));
        }
    }
}

// 匯出供使用
window.AIISPAgentClient = AIISPAgentClient;
