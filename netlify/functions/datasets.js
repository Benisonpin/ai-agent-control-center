exports.handler = async (event, context) => {
  const datasets = {
    coco: {
      name: 'COCO Dataset 2017',
      url: 'https://cocodataset.org/#download',
      license: 'CC BY 4.0',
      size: '25GB',
      images: 330000,
      categories: 80,
      scenes: ['室內', '戶外', '城市', '自然'],
      status: 'available'
    },
    imagenet: {
      name: 'ImageNet ILSVRC2012',
      url: 'https://www.image-net.org/',
      license: 'Academic Use',
      size: '150GB',
      images: 1400000,
      categories: 1000,
      scenes: ['戶外自然', '室內住宅', '工業場地', '農業場景'],
      status: 'available'
    },
    openimages: {
      name: 'Open Images V7',
      url: 'https://storage.googleapis.com/openimages/web/index.html',
      license: 'CC BY 2.0',
      size: '500GB',
      images: 9000000,
      categories: 600,
      scenes: ['航拍風景', '城市街道', '森林植被', '水域海事'],
      status: 'available'
    },
    kinetics: {
      name: 'Kinetics-700',
      url: 'https://github.com/cvdfoundation/kinetics-dataset',
      license: 'CC BY 4.0',
      size: '650GB',
      videos: 650000,
      categories: 700,
      scenes: ['夜間場景', '海岸沙灘', '山地地形', '沙漠乾旱'],
      status: 'available'
    }
  };

  if (event.httpMethod === 'POST') {
    const body = JSON.parse(event.body || '{}');
    const { action, dataset } = body;
    
    if (action === 'download' && datasets[dataset]) {
      return {
        statusCode: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({
          success: true,
          message: `開始下載 ${datasets[dataset].name}`,
          dataset: datasets[dataset],
          estimatedTime: Math.ceil(parseInt(datasets[dataset].size) / 10) + ' 分鐘'
        })
      };
    }
  }

  const totalImages = Object.values(datasets).reduce((sum, ds) => sum + (ds.images || ds.videos || 0), 0);
  const totalSize = Object.values(datasets).reduce((sum, ds) => sum + parseInt(ds.size), 0);

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({
      datasets,
      summary: {
        total_datasets: Object.keys(datasets).length,
        total_images: totalImages,
        total_size_gb: totalSize,
        all_open_source: true
      }
    })
  };
};
