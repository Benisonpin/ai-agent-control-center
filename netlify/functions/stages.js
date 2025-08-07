exports.handler = async (event, context) => {
  if (event.httpMethod === 'POST') {
    const body = JSON.parse(event.body || '{}');
    const { stage, action } = body;
    
    // 模擬階段操作
    const stages = {
      1: { name: '大模型訓練', duration: 72000 },
      2: { name: '知識蒸餾', duration: 24000 },
      3: { name: 'FPGA部署', duration: 12000 }
    };
    
    const stageInfo = stages[stage];
    
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
      },
      body: JSON.stringify({
        success: true,
        stage: stage,
        action: action,
        message: `第${stage}階段 ${stageInfo.name} ${action === 'start' ? '已啟動' : '狀態查詢'}`,
        duration: stageInfo.duration,
        timestamp: new Date().toISOString()
      })
    };
  }

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({
      stages: [
        { id: 1, name: '大模型訓練', status: '準備中', progress: 0 },
        { id: 2, name: '知識蒸餾', status: '等待中', progress: 0 },
        { id: 3, name: 'FPGA部署', status: '等待中', progress: 0 }
      ]
    })
  };
};
