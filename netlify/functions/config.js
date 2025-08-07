exports.handler = async (event, context) => {
  const defaultConfig = {
    system: {
      name: 'CTE Vibe Code',
      version: '2.1.3',
      environment: 'production',
      features: {
        gpu_training: true,
        scene_recognition: true,
        three_stage_pipeline: true,
        real_time_monitoring: true,
        fpga_deployment: true,
        ota_updates: true
      }
    },
    training: {
      max_epochs: 100,
      default_batch_size: 16,
      learning_rate: 0.001,
      supported_models: ['YOLOv8', 'EfficientNet', 'ResNet', 'MobileNet'],
      optimization_levels: ['O0', 'O1', 'O2', 'O3']
    },
    hardware: {
      supported_gpus: [
        { model: 'RTX 4090', memory: '24GB', performance: 100 },
        { model: 'RTX 4080', memory: '16GB', performance: 85 },
        { model: 'RTX 3080', memory: '10GB', performance: 80 },
        { model: 'RTX 3070', memory: '8GB', performance: 65 }
      ],
      fpga_targets: ['Lattice CrossLink-NX', 'Intel Cyclone V', 'Xilinx Zynq'],
      min_requirements: {
        gpu_memory: '6GB',
        system_ram: '16GB',
        storage: '1TB',
        cuda_version: '11.7'
      }
    },
    datasets: {
      auto_download: true,
      max_concurrent: 3,
      cache_enabled: true,
      supported_formats: ['COCO', 'YOLO', 'Pascal VOC', 'ImageNet']
    }
  };

  if (event.httpMethod === 'POST') {
    // 處理配置更新請求
    try {
      const body = JSON.parse(event.body || '{}');
      return {
        statusCode: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({
          success: true,
          message: '配置已更新',
          config: { ...defaultConfig, ...body }
        })
      };
    } catch (error) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Invalid configuration' })
      };
    }
  }

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify(defaultConfig)
  };
};
