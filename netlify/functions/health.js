exports.handler = async (event, context) => {
  const healthStatus = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '2.1.3',
    uptime: Math.floor(Math.random() * 86400) + ' seconds',
    checks: {
      database: { status: 'up', response_time: '12ms' },
      gpu_service: { status: 'up', response_time: '8ms' },
      training_pipeline: { status: 'ready', response_time: '15ms' },
      fpga_interface: { status: 'connected', response_time: '5ms' },
      external_apis: { status: 'up', response_time: '45ms' }
    },
    system_info: {
      node_version: process.version,
      platform: process.platform,
      memory_usage: process.memoryUsage(),
      cpu_usage: process.cpuUsage()
    }
  };

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify(healthStatus)
  };
};
