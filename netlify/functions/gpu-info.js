exports.handler = async (event, context) => {
  // 模擬GPU檢測結果
  const gpuModels = [
    { name: 'RTX 4090', memory: '24GB', performance: 100, power: 450 },
    { name: 'RTX 4080', memory: '16GB', performance: 85, power: 320 },
    { name: 'RTX 3080', memory: '10GB', performance: 80, power: 320 },
    { name: 'RTX 3070', memory: '8GB', performance: 65, power: 220 },
    { name: 'RTX 3060', memory: '12GB', performance: 55, power: 170 }
  ];
  
  const selectedGPU = gpuModels[Math.floor(Math.random() * gpuModels.length)];
  
  const mockData = {
    gpu_available: true,
    gpu_count: 1,
    gpu_info: {
      name: selectedGPU.name,
      memory_total: selectedGPU.memory,
      memory_used: Math.floor(Math.random() * 80 + 10) + '%',
      utilization: Math.floor(Math.random() * 100) + '%',
      temperature: Math.floor(Math.random() * 30 + 50) + '°C',
      power_draw: Math.floor(Math.random() * 100 + selectedGPU.power * 0.3) + 'W',
      performance_score: selectedGPU.performance
    },
    cuda_version: '12.1',
    driver_version: '536.25',
    pytorch_available: true,
    pytorch_version: '2.1.0',
    training_estimates: {
      batch_size_recommended: 16,
      training_time_hours: Math.floor(72 * (100 / selectedGPU.performance)),
      memory_usage_prediction: '85%'
    },
    system_info: {
      platform: 'Linux',
      python_version: '3.10.8',
      cpu_cores: 16,
      ram_total: '32GB'
    }
  };

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify(mockData)
  };
};
