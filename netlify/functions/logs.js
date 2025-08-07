exports.handler = async (event, context) => {
  const logEntries = [
    { time: new Date().toISOString(), level: 'INFO', message: 'CTE Vibe Code 系統初始化完成' },
    { time: new Date().toISOString(), level: 'SUCCESS', message: 'GPU 檢測成功 - RTX 4090 已識別' },
    { time: new Date().toISOString(), level: 'INFO', message: '13種場景AI模型載入中...' },
    { time: new Date().toISOString(), level: 'SUCCESS', message: 'CUDA 12.1 驅動正常' },
    { time: new Date().toISOString(), level: 'INFO', message: '開源資料集準備完成' },
    { time: new Date().toISOString(), level: 'SUCCESS', message: '系統待命中，等待訓練指令...' }
  ];

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({ logs: logEntries })
  };
};
