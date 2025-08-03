exports.handler = async (event, context) => {
  const architecture = {
    cpu: {
      model: "ARM Cortex-A55",
      cores: 4,
      frequency: "1.8GHz",
      usage: Math.floor(Math.random() * 20) + 35
    },
    npu: {
      model: "AI NPU 2 TOPS",
      performance: "2 TOPS @ INT8",
      usage: Math.floor(Math.random() * 15) + 70
    },
    isp: {
      model: "ISP Pipeline",
      capability: "4K@32.5fps",
      features: ["HDR", "3DNR", "WDR", "AI-Enhancement"],
      usage: Math.floor(Math.random() * 10) + 85
    },
    memory: {
      total: 2048,
      used: Math.floor(Math.random() * 500) + 1200,
      cache: 512,
      bandwidth: "25.6GB/s"
    },
    ums: {
      name: "Unified Memory Subsystem",
      features: ["Zero-Copy", "AI-Prefetch", "Dynamic Partition"],
      efficiency: "90%+"
    }
  };

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify(architecture)
  };
};
