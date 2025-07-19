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
    // 在"進階版"文字下方顯示
    const sidebarHeader = document.querySelector('.sidebar-header');
    if (sidebarHeader) {
        let statusDisplay = document.querySelector('.live-status');
        if (!statusDisplay) {
            statusDisplay = document.createElement('div');
            statusDisplay.className = 'live-status';
            statusDisplay.style.cssText = `
                margin-top: 20px;
                padding: 15px;
                background: rgba(255,255,255,0.05);
                border-radius: 8px;
                font-size: 14px;
                line-height: 1.8;
            `;
            // 插入到 sidebar-header 之後
            sidebarHeader.parentNode.insertBefore(statusDisplay, sidebarHeader.nextSibling);
        }
        
        statusDisplay.innerHTML = `
            <div style="color: #fff; margin-bottom: 10px;">
                <strong>系統狀態</strong>
            </div>
            <p style="margin: 5px 0;">FPGA: ${status.hardware.fpga.utilization}% | ${status.hardware.fpga.temperature.toFixed(1)}°C</p>
            <p style="margin: 5px 0;">記憶體: ${((status.hardware.memory.used / status.hardware.memory.total) * 100).toFixed(1)}%</p>
            <p style="margin: 5px 0;">${status.ai.inferenceSpeed.toFixed(1)} FPS</p>
            <p style="margin: 5px 0;">${status.network.latency} ms</p>
        `;
    }
}