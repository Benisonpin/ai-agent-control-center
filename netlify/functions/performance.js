exports.handler = async (event, context) => {
  const performanceData = {
    system: {
      cpu_usage: Math.floor(30 + Math.random() * 20),
      memory_usage: Math.floor(60 + Math.random() * 15),
      gpu_usage: Math.floor(75 + Math.random() * 20),
      temperature: Math.floor(45 + Math.random() * 15)
    },
    ai_processing: {
      inference_time: (12 + Math.random() * 8).toFixed(1),
      throughput: (25 + Math.random() * 10).toFixed(1),
      accuracy: (88 + Math.random() * 8).toFixed(1),
      model_load: "98%"
    },
    network: {
      bandwidth_usage: (1.2 + Math.random() * 0.8).toFixed(1),
      latency: Math.floor(15 + Math.random() * 10),
      packet_loss: (Math.random() * 0.5).toFixed(2),
      connection_status: "stable"
    },
    storage: {
      disk_usage: Math.floor(45 + Math.random() * 20),
      read_speed: Math.floor(450 + Math.random() * 100),
      write_speed: Math.floor(380 + Math.random() * 80),
      available_space: "1.2TB"
    }
  };

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify(performanceData)
  };
};
