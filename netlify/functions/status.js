exports.handler = async (event, context) => {
  const data = {
    system: {
      status: 'online',
      timestamp: new Date().toISOString(),
      temperature: (45 + Math.random() * 15).toFixed(1) + '°C',
      processing_rate: ['4K@60fps', '4K@30fps', '1080p@120fps'][Math.floor(Math.random() * 3)],
      power_consumption: (2.0 + Math.random() * 1.5).toFixed(1) + 'W',
      latency: (0.5 + Math.random() * 1.0).toFixed(1) + 'ms'
    },
    gpu: {
      available: true,
      model: ['RTX 4090', 'RTX 4080', 'RTX 3080'][Math.floor(Math.random() * 3)],
      memory: ['24GB', '16GB', '10GB'][Math.floor(Math.random() * 3)],
      utilization: Math.floor(Math.random() * 100) + '%',
      temperature: Math.floor(Math.random() * 30 + 50) + '°C'
    },
    training: {
      stage1: {
        name: '大模型訓練',
        progress: Math.floor(Math.random() * 100),
        status: ['準備中', '執行中', '已完成'][Math.floor(Math.random() * 3)]
      },
      stage2: {
        name: '知識蒸餾', 
        progress: Math.floor(Math.random() * 100),
        status: ['等待中', '執行中', '已完成'][Math.floor(Math.random() * 3)]
      },
      stage3: {
        name: 'FPGA部署',
        progress: Math.floor(Math.random() * 100), 
        status: ['等待中', '執行中', '已完成'][Math.floor(Math.random() * 3)]
      }
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
