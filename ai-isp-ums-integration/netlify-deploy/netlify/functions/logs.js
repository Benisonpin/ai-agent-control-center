exports.handler = async (event, context) => {
  const logLevels = ['INFO', 'SUCCESS', 'WARNING', 'ERROR'];
  const logMessages = [
    'AI 模型推論完成',
    '場景切換: 室內 -> 室外',
    'HDR 參數自動調整',
    '記憶體優化完成',
    '物件追蹤: 新目標檢測',
    '系統溫度正常',
    'OTA 更新檢查完成',
    '性能優化生效'
  ];

  const logs = [];
  const now = Date.now();

  // 生成最近的日誌
  for (let i = 0; i < 20; i++) {
    const timestamp = new Date(now - i * 60000).toISOString();
    const level = logLevels[Math.floor(Math.random() * (i < 5 ? 3 : 4))];
    const message = logMessages[Math.floor(Math.random() * logMessages.length)];
    
    logs.push({
      timestamp,
      level,
      message: `${message} ${i < 3 ? '[最新]' : ''}`
    });
  }

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({ logs })
  };
};
