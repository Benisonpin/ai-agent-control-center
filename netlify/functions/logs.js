exports.handler = async (event, context) => {
  const logMessages = [
    'ISP 管線處理完成', '場景檢測結果更新', 'AI 模型推論完成',
    '硬體狀態檢查', '記憶體使用率正常', 'NPU 溫度穩定'
  ];
  
  const logs = [];
  const now = new Date();
  
  for (let i = 0; i < 20; i++) {
    const timestamp = new Date(now.getTime() - (i * 30000));
    logs.push({
      timestamp: timestamp.toISOString(),
      level: ['INFO', 'WARNING', 'DEBUG'][Math.floor(Math.random() * 3)],
      message: logMessages[Math.floor(Math.random() * logMessages.length)],
      component: ['ISP', 'NPU', 'CPU'][Math.floor(Math.random() * 3)]
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
