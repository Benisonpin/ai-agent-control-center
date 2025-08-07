exports.handler = async (event, context) => {
  // 模擬即時系統狀態
  const data = {
    system: {
      temperature: (45 + Math.random() * 15).toFixed(1),
      processing_rate: ['4K@60fps', '4K@30fps', '1080p@120fps'][Math.floor(Math.random() * 3)],
      power_consumption: (2.0 + Math.random() * 1.5).toFixed(1),
      latency: (0.5 + Math.random() * 1.0).toFixed(1),
      timestamp: new Date().toISOString()
    },
    stages: {
      stage1: {
        name: '大模型訓練',
        status: ['準備中', '執行中', '已完成'][Math.floor(Math.random() * 3)],
        progress: Math.floor(Math.random() * 100),
        gpu_usage: Math.floor(75 + Math.random() * 20),
        training_loss: (0.01 + Math.random() * 0.05).toFixed(4)
      },
      stage2: {
        name: '知識蒸餾',
        status: ['等待中', '執行中', '已完成'][Math.floor(Math.random() * 3)],
        progress: Math.floor(Math.random() * 100),
        compression_ratio: '94.9%',
        accuracy_retention: '96.3%'
      },
      stage3: {
        name: 'FPGA部署',
        status: ['等待中', '執行中', '已完成'][Math.floor(Math.random() * 3)],
        progress: Math.floor(Math.random() * 100),
        lut_usage: '76%',
        bram_usage: '65%'
      }
    },
    ota: {
      status: 'ready',
      last_update: new Date().toISOString(),
      models_loaded: 13,
      version: 'v2.1.3'
    }
  };

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
    },
    body: JSON.stringify(data)
  };
};
