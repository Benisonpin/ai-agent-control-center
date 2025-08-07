exports.handler = async (event, context) => {
  const generateMetrics = () => ({
    timestamp: new Date().toISOString(),
    system: {
      cpu_usage: Math.floor(Math.random() * 40 + 30) + '%',
      memory_usage: Math.floor(Math.random() * 30 + 50) + '%',
      disk_usage: Math.floor(Math.random() * 20 + 60) + '%',
      network_io: Math.floor(Math.random() * 1000 + 500) + ' MB/s',
      uptime: Math.floor(Math.random() * 168 + 24) + ' hours'
    },
    gpu: {
      temperature: Math.floor(Math.random() * 25 + 55) + '°C',
      utilization: Math.floor(Math.random() * 100) + '%',
      memory_used: Math.floor(Math.random() * 80 + 10) + '%',
      power_draw: Math.floor(Math.random() * 200 + 150) + 'W',
      fan_speed: Math.floor(Math.random() * 40 + 40) + '%'
    },
    training: {
      current_epoch: Math.floor(Math.random() * 100),
      loss: (Math.random() * 0.1 + 0.01).toFixed(4),
      accuracy: (Math.random() * 10 + 88).toFixed(2) + '%',
      learning_rate: (Math.random() * 0.001).toExponential(2),
      samples_per_second: Math.floor(Math.random() * 500 + 100)
    },
    fpga: {
      lut_usage: Math.floor(Math.random() * 30 + 65) + '%',
      bram_usage: Math.floor(Math.random() * 25 + 55) + '%',
      dsp_usage: Math.floor(Math.random() * 20 + 35) + '%',
      frequency: Math.floor(Math.random() * 20 + 95) + ' MHz',
      power: (Math.random() * 1.0 + 1.5).toFixed(1) + 'W'
    }
  });

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Cache-Control': 'no-cache'
    },
    body: JSON.stringify({
      metrics: generateMetrics(),
      collection_interval: 2000,
      retention_period: '24 hours'
    })
  };
};
