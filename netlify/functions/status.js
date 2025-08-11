exports.handler = async (event, context) => {
  const data = {
    timestamp: new Date().toISOString(),
    hardware: {
      cpu: {
        usage: Math.floor(65 + Math.random() * 20),
        temperature: Math.floor(55 + Math.random() * 20),
        cores: 4,
        frequency: "1.8GHz"
      },
      npu: {
        usage: Math.floor(70 + Math.random() * 25),
        temperature: Math.floor(50 + Math.random() * 25),
        tops: 2.0,
        model_loaded: "YOLOv5s"
      },
      memory: {
        total: 2048,
        used: Math.floor(1200 + Math.random() * 600),
        get usage_percent() { return Math.floor((this.used / this.total) * 100); }
      }
    },
    isp: {
      fps: parseFloat((28 + Math.random() * 8).toFixed(1)),
      latency: Math.floor(25 + Math.random() * 10),
      quality_score: parseFloat((90 + Math.random() * 8).toFixed(1)),
      power_consumption: parseFloat((3.2 + Math.random() * 0.8).toFixed(1))
    }
  };

  // 計算記憶體使用率
  data.hardware.memory.usage_percent = data.hardware.memory.usage_percent;

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify(data)
  };
};
