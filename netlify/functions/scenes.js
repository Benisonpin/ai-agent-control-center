exports.handler = async (event, context) => {
  const scenes = [
    { id: 'outdoor', name: '戶外自然', accuracy: 96.8, icon: '🌳', active: false },
    { id: 'indoor', name: '室內住宅', accuracy: 94.2, icon: '🏠', active: false },
    { id: 'urban', name: '城市街道', accuracy: 97.5, icon: '🏙️', active: false },
    { id: 'aerial', name: '航拍風景', accuracy: 95.3, icon: '✈️', active: false },
    { id: 'night', name: '夜間場景', accuracy: 92.7, icon: '🌙', active: false },
    { id: 'water', name: '水域海事', accuracy: 93.9, icon: '🌊', active: false },
    { id: 'forest', name: '森林植被', accuracy: 95.8, icon: '🌲', active: false },
    { id: 'agriculture', name: '農業場景', accuracy: 94.1, icon: '🌾', active: false },
    { id: 'industrial', name: '工業場地', accuracy: 93.4, icon: '🏭', active: false },
    { id: 'beach', name: '海岸沙灘', accuracy: 96.1, icon: '🏖️', active: false },
    { id: 'mountain', name: '山地地形', accuracy: 95.7, icon: '⛰️', active: false },
    { id: 'desert', name: '沙漠乾旱', accuracy: 94.6, icon: '🏜️', active: false },
    { id: 'detection', name: '目標檢測', accuracy: 98.2, icon: '🎯', active: true }
  ];

  if (event.httpMethod === 'POST') {
    try {
      const body = JSON.parse(event.body || '{}');
      const { sceneId } = body;
      
      const scene = scenes.find(s => s.id === sceneId);
      if (scene) {
        scene.active = true;
        return {
          statusCode: 200,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
          },
          body: JSON.stringify({
            success: true,
            message: `${scene.name} 場景已啟動`,
            scene: scene
          })
        };
      }
    } catch (error) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Invalid request body' })
      };
    }
  }

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({ scenes })
  };
};
