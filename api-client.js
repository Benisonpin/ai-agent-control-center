// CTE AI Agent API 客戶端
class CTEApiClient {
    constructor() {
        // 使用 Netlify Functions 路徑
        this.baseUrl = '/.netlify/functions';
    }

    // 獲取系統狀態
    async getSystemStatus() {
        try {
            const response = await fetch(`${this.baseUrl}/system-status`);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const data = await response.json();
            console.log('系統狀態數據:', data);
            return data;
        } catch (error) {
            console.error('獲取系統狀態失敗:', error);
            return null;
        }
    }

    // 測試 API 連接
    async testConnection() {
        console.log('測試 API 連接...');
        const status = await this.getSystemStatus();
        if (status) {
            console.log('✅ API 連接成功！');
            console.log('FPGA 狀態:', status.hardware.fpga.status);
            console.log('AI 模型:', status.ai.currentModel);
            console.log('推論速度:', status.ai.inferenceSpeed.toFixed(1), 'FPS');
        } else {
            console.log('❌ API 連接失敗');
        }
        return status;
    }
}

// 創建全域 API 實例
const cteAPI = new CTEApiClient();

// 自動更新系統狀態的函數
async function updateSystemStatus() {
    const status = await cteAPI.getSystemStatus();
    if (status) {
        // 更新 UI 顯示
        updateDashboard(status);
    }
}

// 更新儀表板顯示
function updateDashboard(status) {
    // 更新 FPGA 狀態
    const fpgaStatus = document.querySelector('.fpga-status');
    if (fpgaStatus) {
        fpgaStatus.textContent = `FPGA: ${status.hardware.fpga.utilization}% | ${status.hardware.fpga.temperature.toFixed(1)}°C`;
    }

    // 更新記憶體使用
    const memoryStatus = document.querySelector('.memory-status');
    if (memoryStatus) {
        const memoryPercent = ((status.hardware.memory.used / status.hardware.memory.total) * 100).toFixed(1);
        memoryStatus.textContent = `記憶體: ${memoryPercent}%`;
    }

    // 更新 AI 推論速度
    const aiSpeed = document.querySelector('.ai-speed');
    if (aiSpeed) {
        aiSpeed.textContent = `${status.ai.inferenceSpeed.toFixed(1)} FPS`;
    }

    // 更新網路延遲
    const networkLatency = document.querySelector('.network-latency');
    if (networkLatency) {
        networkLatency.textContent = `${status.network.latency} ms`;
    }
}