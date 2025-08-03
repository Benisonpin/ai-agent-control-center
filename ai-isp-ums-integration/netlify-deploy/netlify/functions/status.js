exports.handler = async (event, context) => {
  const status = {
    status: "online",
    timestamp: new Date().toISOString(),
    system: {
      platform: "TW-LCEO-AISP-2025",
      version: "2.0.0",
      uptime: Math.floor(Math.random() * 1000) + " hours"
    },
    metrics: {
      active_drones: Math.floor(Math.random() * 50) + 100,
      cpu_usage: Math.floor(Math.random() * 30) + 40,
      memory_usage: Math.floor(Math.random() * 20) + 60,
      models_updated: Math.floor(Math.random() * 10) + 10,
      success_rate: (Math.random() * 2 + 98).toFixed(1)
    },
    ota: {
      updates_available: 3,
      last_check: new Date(Date.now() - 300000).toISOString(),
      auto_update: true
    }
  };

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify(status)
  };
};
