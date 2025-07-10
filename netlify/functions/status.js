exports.handler = async (event, context) => {
  const data = {
    fps: 32.5 + (Math.random() * 4 - 2),
    latency: Math.floor(28 + (Math.random() * 10 - 5)),
    accuracy: 85.3 + (Math.random() * 4 - 2),
    power: 3.5 + (Math.random() * 0.4 - 0.2),
    cpu_usage: 35 + (Math.random() * 10 - 5),
    memory_usage: 62 + (Math.random() * 10 - 5),
    npu_usage: 78 + (Math.random() * 10 - 5),
    bandwidth: 1.1,
    timestamp: new Date().toISOString()
  };

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify(data)
  };
};
