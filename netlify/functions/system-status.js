exports.handler = async (event, context) => {
    // 模擬硬體狀態數據
    const mockData = {
        status: 'operational',
        timestamp: new Date().toISOString(),
        uptime: Math.floor(Math.random() * 86400), // 隨機運行時間（秒）
        hardware: {
            fpga: {
                status: 'active',
                temperature: 45 + Math.random() * 10, // 45-55°C
                utilization: Math.floor(Math.random() * 30) + 70, // 70-100%
                frequency: 250 // MHz
            },
            memory: {
                total: 8192, // MB
                used: Math.floor(Math.random() * 2048) + 6144, // 6144-8192 MB
                free: 2048 - Math.floor(Math.random() * 1024)
            },
            cpu: {
                cores: 4,
                usage: Math.floor(Math.random() * 40) + 20, // 20-60%
                temperature: 50 + Math.random() * 10 // 50-60°C
            }
        },
        ai: {
            currentModel: 'mobilenet-v2',
            modelVersion: '2.1.0',
            inferenceSpeed: 30 + Math.random() * 5, // 30-35 FPS
            accuracy: 94.3,
            totalInferences: Math.floor(Math.random() * 100000) + 50000
        },
        network: {
            status: 'connected',
            latency: Math.floor(Math.random() * 20) + 10, // 10-30ms
            bandwidth: {
                upload: 100,
                download: 1000
            }
        }
    };
    
    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*' // 允許跨域請求
        },
        body: JSON.stringify(mockData)
    };
};