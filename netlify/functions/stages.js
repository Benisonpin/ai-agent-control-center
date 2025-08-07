exports.handler = async (event, context) => {
  const stages = {
    1: { 
      name: '大模型訓練', 
      description: '使用開源資料集進行基礎模型訓練',
      duration: 72000,
      datasets: ['COCO', 'ImageNet', 'Open Images'],
      gpu_hours: 72
    },
    2: { 
      name: '知識蒸餾', 
      description: '模型壓縮與邊緣優化',
      duration: 24000,
      compression_ratio: '95%',
      accuracy_retention: '98%'
    },
    3: { 
      name: 'FPGA部署', 
      description: '硬體加速與實際部署',
      duration: 12000,
      target_platform: 'Lattice CrossLink-NX',
      max_frequency: '100MHz'
    }
  };

  if (event.httpMethod === 'POST') {
    try {
      const body = JSON.parse(event.body || '{}');
      const { stage, action } = body;
      
      const stageInfo = stages[stage];
      if (stageInfo) {
        return {
          statusCode: 200,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
          },
          body: JSON.stringify({
            success: true,
            stage: parseInt(stage),
            action: action,
            message: `第${stage}階段 ${stageInfo.name} ${action === 'start' ? '已啟動' : '狀態查詢'}`,
            info: stageInfo,
            timestamp: new Date().toISOString()
          })
        };
      }
    } catch (error) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Invalid request' })
      };
    }
  }

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({
      stages: Object.entries(stages).map(([id, info]) => ({
        id: parseInt(id),
        ...info,
        status: '準備中',
        progress: 0
      }))
    })
  };
};
